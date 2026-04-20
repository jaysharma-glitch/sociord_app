import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sociord/constants/color.dart';
import 'package:sociord/constants/text_styles.dart';
import 'package:sociord/provider/user_provider.dart';
import 'package:sociord/screens/upload/personal_upload_screen.dart';
import 'package:sociord/services/permission_service.dart';
import 'package:sociord/utils/routes.dart';

class AddScreen extends ConsumerStatefulWidget {
  const AddScreen({super.key});

  @override
  ConsumerState<AddScreen> createState() => _AddScreenState();
}

class _AddScreenState extends ConsumerState<AddScreen> {
  bool _isRequestingPermissions = false;
  bool _permissionsDenied = false;
  Map<String, bool> _permissionResults = <String, bool>{};

  @override
  void initState() {
    super.initState();
    _requestPermissionsOnLoad();
  }

  Future<void> _requestPermissionsOnLoad() async {
    setState(() {
      _isRequestingPermissions = true;
      _permissionsDenied = false;
    });

    try {
      final results = await PermissionService.requestAllMediaPermissions();
      final hasDeniedPermissions = results.values.any((granted) => !granted);
      setState(() {
        _permissionResults = results;
        _permissionsDenied = hasDeniedPermissions;
      });
    } catch (_) {
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
        user.profileType == 'Creator' ||
        user.profileType == 'Business' ||
        user.contentType == 'Creator' ||
        user.creatorIntention == 'creator';

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

    if (_permissionsDenied) {
      return _buildPermissionDeniedScreen();
    }

    return PersonalUploadScreen(
      mode: isCreator ? UploadFlowMode.creator : UploadFlowMode.explorer,
    );
  }

  Widget _buildPermissionDeniedScreen() {
    return Scaffold(
      backgroundColor: kAppWhite,
      appBar: AppBar(
        backgroundColor: kAppWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: kAppBlack),
          onPressed: _handleCancel,
        ),
        title: Text('Permissions Required', style: kHeadlineMediumBlack),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.security_outlined, size: 80, color: kAppPurple),
            const SizedBox(height: 24),
            Text(
              'Camera & Gallery Access Required',
              style: kHeadlineMediumBlack,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'To create posts and upload media, Sociord needs access to your camera and photo library.',
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
              onPressed: _requestPermissionsOnLoad,
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

  void _handleCancel() {
    context.go(homeRoute);
  }
}
