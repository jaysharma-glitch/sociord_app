import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:sociord/constants/color.dart';
import 'package:sociord/constants/text_styles.dart';
import 'package:sociord/services/permission_service.dart';
import 'package:sociord/provider/media_selection_provider.dart';
import 'package:sociord/widgets/media_thumbnail.dart';
import 'package:sociord/utils/routes.dart';

class PersonalUploadScreen extends ConsumerStatefulWidget {
  const PersonalUploadScreen({super.key});

  @override
  ConsumerState<PersonalUploadScreen> createState() =>
      _PersonalUploadScreenState();
}

class _PersonalUploadScreenState extends ConsumerState<PersonalUploadScreen> {
  bool _isLoading = true;
  bool _hasPermission = false;
  String _errorMessage = '';
  int _selectedTabIndex = 0; // 0 = Photos, 1 = Videos

  @override
  void initState() {
    super.initState();
    _initializeGallery();
  }

  Future<void> _initializeGallery() async {
    try {
      // Check if we already have gallery permission (should be granted by AddScreen)
      final hasPermission = await PermissionService.hasGalleryPermission();

      if (!hasPermission) {
        setState(() {
          _hasPermission = false;
          _isLoading = false;
          _errorMessage =
              'Gallery permission is required to access your photos and videos.';
        });
        return;
      }

      setState(() {
        _hasPermission = true;
      });

      // Load gallery assets
      await _loadGalleryAssets();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load gallery: ${e.toString()}';
      });
    }
  }

  Future<void> _loadGalleryAssets() async {
    try {
      // Get all albums
      final albums = await PhotoManager.getAssetPathList(
        type: RequestType.common,
        hasAll: true,
      );

      if (albums.isEmpty) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'No photos or videos found in your gallery.';
        });
        return;
      }

      // Get the first album (usually "Recent" or "All Photos")
      final recentAlbum = albums.first;

      // Load assets from the album
      final assets = await recentAlbum.getAssetListPaged(
        page: 0,
        size: 1000, // Load up to 1000 assets
      );

      // Filter by media type based on selected tab
      final filteredAssets =
          assets.where((asset) {
            if (_selectedTabIndex == 0) {
              return asset.type == AssetType.image;
            } else {
              return asset.type == AssetType.video;
            }
          }).toList();

      // Update the provider with filtered assets
      ref
          .read(galleryAssetsNotifierProvider.notifier)
          .setAssets(filteredAssets);

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to load gallery assets: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedCount = ref.watch(mediaSelectionNotifierProvider).length;
    final galleryAssets = ref.watch(galleryAssetsNotifierProvider);

    return Scaffold(
      backgroundColor: kAppWhite,
      appBar: AppBar(
        backgroundColor: kAppWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: kAppBlack),
          onPressed: () => _handleCancel(context),
        ),
        title: Text(
          'Upload Page - Personal',
          style: kBodyMediumBlack.copyWith(color: kAppLightBlack),
        ),
        centerTitle: true,
        actions: [
          if (selectedCount > 0)
            TextButton(
              onPressed: () {
                // Navigate to next screen (Filter/Edit)
                _navigateToNextScreen();
              },
              child: Text(
                'Next →',
                style: kBodyMediumPurple.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // Navigation pills
          _buildNavigationPills(),

          // Main content
          Expanded(child: _buildMainContent(galleryAssets)),

          // Bottom tabs
          _buildBottomTabs(),
        ],
      ),
    );
  }

  Widget _buildNavigationPills() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: kAppLightGreay,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [_buildPill('Gallery', true), _buildPill('Capture', false)],
      ),
    );
  }

  Widget _buildPill(String title, bool isActive) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isActive ? kAppWhite : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow:
              isActive
                  ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                  : null,
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: isActive ? kBodyMediumPurple : kBodyMediumBlack,
        ),
      ),
    );
  }

  Widget _buildMainContent(List<AssetEntity> galleryAssets) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(kAppPurple),
        ),
      );
    }

    if (!_hasPermission) {
      return _buildPermissionError();
    }

    if (_errorMessage.isNotEmpty) {
      return _buildErrorMessage();
    }

    if (galleryAssets.isEmpty) {
      return _buildEmptyState();
    }

    return _buildGalleryGrid(galleryAssets);
  }

  Widget _buildPermissionError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.photo_library_outlined, size: 64, color: kAppLightBlack),
            const SizedBox(height: 16),
            Text(
              'Gallery Permission Required',
              style: kHeadlineSmallBlack,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage,
              style: kBodyMediumBlack.copyWith(color: kAppLightBlack),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () async {
                await PermissionService.openAppSettings();
              },
              child: const Text('Open Settings'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: kAppRed),
            const SizedBox(height: 16),
            Text(
              'Error Loading Gallery',
              style: kHeadlineSmallBlack,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage,
              style: kBodyMediumBlack.copyWith(color: kAppLightBlack),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _errorMessage = '';
                });
                _initializeGallery();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _selectedTabIndex == 0
                  ? Icons.photo_outlined
                  : Icons.videocam_outlined,
              size: 64,
              color: kAppLightBlack,
            ),
            const SizedBox(height: 16),
            Text(
              _selectedTabIndex == 0 ? 'No Photos Found' : 'No Videos Found',
              style: kHeadlineSmallBlack,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              _selectedTabIndex == 0
                  ? 'Take some photos to get started!'
                  : 'Record some videos to get started!',
              style: kBodyMediumBlack.copyWith(color: kAppLightBlack),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGalleryGrid(List<AssetEntity> galleryAssets) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: MasonryGridView.count(
        crossAxisCount: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        itemCount: galleryAssets.length,
        itemBuilder: (context, index) {
          final asset = galleryAssets[index];
          return MediaThumbnail(
            asset: asset,
            onTap: () {
              ref
                  .read(mediaSelectionNotifierProvider.notifier)
                  .toggleMedia(asset);
            },
          );
        },
      ),
    );
  }

  Widget _buildBottomTabs() {
    return Container(
      decoration: BoxDecoration(
        color: kAppWhite,
        border: Border(top: BorderSide(color: kBorderGreay)),
      ),
      child: Row(
        children: [_buildBottomTab('Photos', 0), _buildBottomTab('Videos', 1)],
      ),
    );
  }

  Widget _buildBottomTab(String title, int index) {
    final isSelected = _selectedTabIndex == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTabIndex = index;
          });
          _loadGalleryAssets();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style:
                    isSelected
                        ? kBodyMediumPurple.copyWith(
                          fontWeight: FontWeight.w600,
                        )
                        : kBodyMediumBlack.copyWith(color: kAppLightBlack),
              ),
              const SizedBox(height: 4),
              if (isSelected)
                Container(
                  width: 24,
                  height: 2,
                  decoration: BoxDecoration(
                    color: kAppPurple,
                    borderRadius: BorderRadius.circular(1),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleCancel(BuildContext context) {
    // Navigate back to the home screen
    context.go(homeRoute);
  }

  void _navigateToNextScreen() {
    // TODO: Navigate to Filter/Edit screen
    // For now, show a snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${ref.read(mediaSelectionNotifierProvider).length} items selected. Navigating to edit screen...',
        ),
        backgroundColor: kAppPurple,
      ),
    );
  }
}
