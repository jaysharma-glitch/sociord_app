import 'package:permission_handler/permission_handler.dart'
    as permission_handler;
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static Future<bool> requestGalleryPermission() async {
    try {
      print('🔍 Checking gallery permission status...');

      // Check current status
      var status = await Permission.photos.status;
      print('📱 Current photos permission status: $status');

      if (status.isGranted) {
        print('✅ Gallery permission already granted');
        return true;
      }

      if (status.isPermanentlyDenied) {
        print('❌ Gallery permission permanently denied');
        return false;
      }

      print('🔐 Requesting gallery permission...');
      // Request permission
      status = await Permission.photos.request();
      print('📱 Permission request result: $status');

      if (status.isGranted) {
        print('✅ Gallery permission granted');
        return true;
      }

      if (status.isDenied) {
        print('⚠️ Gallery permission denied, trying again...');
        // Wait a bit before trying again
        await Future.delayed(const Duration(milliseconds: 500));
        status = await Permission.photos.request();
        print('📱 Second permission request result: $status');
        return status.isGranted;
      }

      print('❌ Gallery permission not granted');
      return false;
    } catch (e) {
      print('💥 Error requesting gallery permission: $e');
      return false;
    }
  }

  static Future<bool> requestCameraPermission() async {
    try {
      print('🔍 Checking camera permission status...');

      var status = await Permission.camera.status;
      print('📱 Current camera permission status: $status');

      if (status.isGranted) {
        print('✅ Camera permission already granted');
        return true;
      }

      if (status.isPermanentlyDenied) {
        print('❌ Camera permission permanently denied');
        return false;
      }

      print('🔐 Requesting camera permission...');
      status = await Permission.camera.request();
      print('📱 Permission request result: $status');

      if (status.isGranted) {
        print('✅ Camera permission granted');
        return true;
      }

      if (status.isDenied) {
        print('⚠️ Camera permission denied, trying again...');
        await Future.delayed(const Duration(milliseconds: 500));
        status = await Permission.camera.request();
        print('📱 Second permission request result: $status');
        return status.isGranted;
      }

      print('❌ Camera permission not granted');
      return false;
    } catch (e) {
      print('💥 Error requesting camera permission: $e');
      return false;
    }
  }

  static Future<bool> hasGalleryPermission() async {
    try {
      return await Permission.photos.isGranted;
    } catch (e) {
      print('Error checking gallery permission: $e');
      return false;
    }
  }

  static Future<bool> hasCameraPermission() async {
    try {
      return await Permission.camera.isGranted;
    } catch (e) {
      print('Error checking camera permission: $e');
      return false;
    }
  }

  static Future<void> openAppSettings() async {
    await permission_handler.openAppSettings();
  }

  /// Request all necessary permissions for media access
  static Future<Map<String, bool>> requestAllMediaPermissions() async {
    final results = <String, bool>{};

    try {
      print('🔐 Requesting all media permissions...');

      // Request photos permission
      results['photos'] = await requestGalleryPermission();

      // Small delay between requests
      await Future.delayed(const Duration(milliseconds: 300));

      // Request camera permission
      results['camera'] = await requestCameraPermission();

      print('📊 Permission results: $results');
      return results;
    } catch (e) {
      print('💥 Error in requestAllMediaPermissions: $e');
      return {'photos': false, 'camera': false};
    }
  }

  /// Test method to verify permission system is working
  static Future<void> testPermissions() async {
    print('🧪 Testing permission system...');

    // Check current status
    final photosStatus = await Permission.photos.status;
    final cameraStatus = await Permission.camera.status;

    print('📱 Current status - Photos: $photosStatus, Camera: $cameraStatus');

    // Test requesting permissions
    final results = await requestAllMediaPermissions();
    print('🧪 Test results: $results');
  }

  /// Check if we're on iOS and permissions are properly configured
  static Future<void> debugIOSPermissions() async {
    print('🍎 Debugging iOS permissions...');

    // Check all photo-related permissions
    final photosStatus = await Permission.photos.status;
    final cameraStatus = await Permission.camera.status;

    print('📱 Photos permission: $photosStatus');
    print('📱 Camera permission: $cameraStatus');

    // Try to request permissions individually
    print('🔐 Requesting photos permission...');
    final photosResult = await Permission.photos.request();
    print('📱 Photos request result: $photosResult');

    await Future.delayed(const Duration(milliseconds: 1000));

    print('🔐 Requesting camera permission...');
    final cameraResult = await Permission.camera.request();
    print('📱 Camera request result: $cameraResult');
  }
}
