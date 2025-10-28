import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sociord/provider/user_provider.dart';
import 'package:sociord/models/user_model.dart';
import 'package:sociord/constants/color.dart';
import 'package:sociord/constants/text_styles.dart';
import 'package:sociord/widgets/common/profile_avatar.dart';
import 'package:sociord/utils/asset_path_constants.dart';
import 'package:sociord/utils/routes.dart';
import 'package:sociord/screens/upload/personal_upload_screen.dart';
import 'package:sociord/services/permission_service.dart';

class AddScreen extends ConsumerStatefulWidget {
  const AddScreen({super.key});

  @override
  ConsumerState<AddScreen> createState() => _AddScreenState();
}

class _AddScreenState extends ConsumerState<AddScreen> {
  int _selectedTabIndex = 0;
  final PageController _pageController = PageController();
  bool _isRequestingPermissions = false;
  bool _permissionsDenied = false;
  Map<String, bool> _permissionResults = {};

  @override
  void initState() {
    super.initState();
    _requestPermissionsOnLoad();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _requestPermissionsOnLoad() async {
    setState(() {
      _isRequestingPermissions = true;
      _permissionsDenied = false;
    });

    try {
      print('🚀 Starting permission requests...');

      // Debug iOS permissions first
      await PermissionService.debugIOSPermissions();

      // Request all media permissions
      final results = await PermissionService.requestAllMediaPermissions();

      print('✅ Permission requests completed: $results');

      // Check if any permissions were denied
      final hasDeniedPermissions = results.values.any((granted) => !granted);

      setState(() {
        _permissionResults = results;
        _permissionsDenied = hasDeniedPermissions;
      });
    } catch (e) {
      print('💥 Error requesting permissions: $e');
      setState(() {
        _permissionsDenied = true;
      });
    } finally {
      setState(() {
        _isRequestingPermissions = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userNotifierProvider);
    final isCreator =
        user.profileType == 'Creator' || user.profileType == 'Business';

    // Show loading indicator while requesting permissions
    if (_isRequestingPermissions) {
      return Scaffold(
        backgroundColor: kAppWhite,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(kAppPurple),
              ),
              const SizedBox(height: 16),
              Text(
                'Requesting permissions...',
                style: kBodyMediumBlack.copyWith(color: kAppLightBlack),
              ),
            ],
          ),
        ),
      );
    }

    // Show permission denied screen if permissions are denied
    if (_permissionsDenied) {
      return _buildPermissionDeniedScreen();
    }

    // For Personal users, show the Personal Upload screen directly
    if (!isCreator) {
      return const PersonalUploadScreen();
    }

    // For Creator users, show the original Add screen with tabs
    return Scaffold(
      backgroundColor: kAppWhite,
      appBar: AppBar(
        backgroundColor: kAppWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: kAppBlack),
          onPressed: () => _handleCancel(context),
        ),
        title: Text('Create Post', style: kHeadlineMediumBlack),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {
              // Handle save as draft
              _showSaveDraftDialog();
            },
            child: Text('Save Draft', style: kBodyMediumPurple),
          ),
        ],
      ),
      body: Column(
        children: [
          // User info header
          _buildUserHeader(user),

          // Tab selector for Creator users
          _buildTabSelector(),

          // Content area
          Expanded(child: _buildCreatorContent()),
        ],
      ),
    );
  }

  void _handleCancel(BuildContext context) {
    // Navigate back to the home screen
    context.go(homeRoute);
  }

  Widget _buildUserHeader(UserModel user) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          ProfileAvatar(imageUrl: user.profilePic ?? kProfilePic, size: 40),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user.firstName ?? 'User', style: kBodyLargeBlack),
                Text(
                  '@${user.userName ?? 'username'}',
                  style: kBodySmallBlack.copyWith(color: kAppLightBlack),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: kAppLightPurple,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              user.profileType ?? 'Personal',
              style: kBodySmallPurple,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: kAppLightGreay,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildTab('Post', 0),
          _buildTab('Story', 1),
          _buildTab('Reel', 2),
        ],
      ),
    );
  }

  Widget _buildTab(String title, int index) {
    final isSelected = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTabIndex = index;
          });
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? kAppWhite : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow:
                isSelected
                    ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ]
                    : null,
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: isSelected ? kBodyMediumPurple : kBodyMediumBlack,
          ),
        ),
      ),
    );
  }

  Widget _buildCreatorContent() {
    return PageView(
      controller: _pageController,
      onPageChanged: (index) {
        setState(() {
          _selectedTabIndex = index;
        });
      },
      children: [
        _buildPostCreator(),
        _buildStoryCreator(),
        _buildReelCreator(),
      ],
    );
  }

  Widget _buildPostCreator() {
    return _buildContentCreator(
      title: 'Create Post',
      description: 'Share photos, videos, or text with your audience',
      options: [
        _buildMediaOption(
          icon: Icons.photo_library_outlined,
          title: 'Photo/Video',
          subtitle: 'Upload from gallery',
          onTap: () => _handleMediaSelection('gallery'),
        ),
        _buildMediaOption(
          icon: Icons.camera_alt_outlined,
          title: 'Camera',
          subtitle: 'Take a photo or video',
          onTap: () => _handleMediaSelection('camera'),
        ),
        _buildMediaOption(
          icon: Icons.text_fields,
          title: 'Text Post',
          subtitle: 'Share thoughts and ideas',
          onTap: () => _handleTextPost(),
        ),
      ],
    );
  }

  Widget _buildStoryCreator() {
    return _buildContentCreator(
      title: 'Create Story',
      description: 'Share moments that disappear after 24 hours',
      options: [
        _buildMediaOption(
          icon: Icons.photo_library_outlined,
          title: 'Photo/Video',
          subtitle: 'Upload from gallery',
          onTap: () => _handleMediaSelection('gallery'),
        ),
        _buildMediaOption(
          icon: Icons.camera_alt_outlined,
          title: 'Camera',
          subtitle: 'Take a photo or video',
          onTap: () => _handleMediaSelection('camera'),
        ),
        _buildMediaOption(
          icon: Icons.text_fields,
          title: 'Text Story',
          subtitle: 'Create a text story',
          onTap: () => _handleTextStory(),
        ),
      ],
    );
  }

  Widget _buildReelCreator() {
    return _buildContentCreator(
      title: 'Create Reel',
      description: 'Create short, engaging videos for your audience',
      options: [
        _buildMediaOption(
          icon: Icons.video_library_outlined,
          title: 'Video Library',
          subtitle: 'Upload from gallery',
          onTap: () => _handleMediaSelection('gallery'),
        ),
        _buildMediaOption(
          icon: Icons.videocam_outlined,
          title: 'Record Video',
          subtitle: 'Record a new video',
          onTap: () => _handleMediaSelection('camera'),
        ),
        _buildMediaOption(
          icon: Icons.music_note,
          title: 'Add Music',
          subtitle: 'Browse music library',
          onTap: () => _handleMusicSelection(),
        ),
      ],
    );
  }

  Widget _buildContentCreator({
    required String title,
    required String description,
    required List<Widget> options,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: kHeadlineSmallBlack),
          const SizedBox(height: 8),
          Text(
            description,
            style: kBodyMediumBlack.copyWith(color: kAppLightBlack),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: options,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: kAppWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kBorderGreay),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: kAppPurple),
            const SizedBox(height: 12),
            Text(title, style: kBodyMediumBlack, textAlign: TextAlign.center),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: kBodySmallBlack.copyWith(color: kAppLightBlack),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _handleMediaSelection(String source) {
    if (source == 'gallery') {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const PersonalUploadScreen()),
      );
    } else {
      // TODO: Implement camera capture logic
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Opening $source...'),
          backgroundColor: kAppPurple,
        ),
      );
    }
  }

  void _handleTextPost() {
    // TODO: Navigate to text post creation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Opening text post editor...'),
        backgroundColor: kAppPurple,
      ),
    );
  }

  void _handleTextStory() {
    // TODO: Navigate to text story creation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Opening text story editor...'),
        backgroundColor: kAppPurple,
      ),
    );
  }

  void _handleMusicSelection() {
    // TODO: Navigate to music selection
  }

  Widget _buildPermissionDeniedScreen() {
    return Scaffold(
      backgroundColor: kAppWhite,
      appBar: AppBar(
        backgroundColor: kAppWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: kAppBlack),
          onPressed: () => _handleCancel(context),
        ),
        title: Text('Permissions Required', style: kHeadlineMediumBlack),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.security_outlined, size: 80, color: kAppPurple),
            const SizedBox(height: 24),
            Text(
              'Camera & Gallery Access Required',
              style: kHeadlineMediumBlack,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'To create posts and upload media, Sociord needs access to your camera and photo library. Please enable these permissions in your device settings.',
              style: kBodyMediumBlack.copyWith(color: kAppLightBlack),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            _buildPermissionStatus(),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  await PermissionService.openAppSettings();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kAppPurple,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Open Settings',
                  style: kBodyMediumWhite.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                setState(() {
                  _permissionsDenied = false;
                });
                _requestPermissionsOnLoad();
              },
              child: Text(
                'Try Again',
                style: kBodyMediumPurple.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionStatus() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kAppLightGreay,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildPermissionItem(
            'Camera',
            _permissionResults['camera'] ?? false,
            Icons.camera_alt,
          ),
          const SizedBox(height: 12),
          _buildPermissionItem(
            'Photo Library',
            _permissionResults['photos'] ?? false,
            Icons.photo_library,
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionItem(String title, bool isGranted, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: isGranted ? Colors.green : Colors.red, size: 20),
        const SizedBox(width: 12),
        Expanded(child: Text(title, style: kBodyMediumBlack)),
        Icon(
          isGranted ? Icons.check_circle : Icons.cancel,
          color: isGranted ? Colors.green : Colors.red,
          size: 20,
        ),
      ],
    );
  }

  void _showSaveDraftDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Save Draft', style: kHeadlineSmallBlack),
            content: Text(
              'Your post will be saved as a draft and you can continue editing later.',
              style: kBodyMediumBlack,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Cancel', style: kBodyMediumBlack),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // TODO: Implement save draft logic
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Draft saved successfully!'),
                      backgroundColor: kAppGreen,
                    ),
                  );
                },
                child: const Text('Save Draft'),
              ),
            ],
          ),
    );
  }
}
