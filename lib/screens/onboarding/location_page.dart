import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sociord/models/user_model.dart';
import 'package:sociord/models/location_model.dart';
import 'package:sociord/provider/location_provider.dart';
import 'package:sociord/provider/user_provider.dart';
import 'package:sociord/constants/color.dart';
import 'package:sociord/constants/ui.dart';
import 'package:sociord/utils/asset_path_constants.dart';
import 'package:sociord/widgets/custom_snack_bar.dart';

class LocationPage extends ConsumerStatefulWidget {
  final PageController pageController;

  const LocationPage({super.key, required this.pageController});

  @override
  ConsumerState<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends ConsumerState<LocationPage> {
  bool permissionDenied = false;
  bool isLoading = false;

  bool get hasValidLocation =>
      ref.read(locationNotifierProvider).location != null;

  Future<void> _handleAutoLocation() async {
    setState(() {
      permissionDenied = false;
      isLoading = true;
    });

    final locationNotifier = ref.read(locationNotifierProvider.notifier);

    // First, check and request permission
    final granted = await locationNotifier.handleLocationPermission();
    if (!granted) {
      final error = ref.read(locationNotifierProvider).error;
      print('Permission denied. Error: $error');
      setState(() {
        permissionDenied = true;
        isLoading = false;
      });
      return;
    }

    // Then get current position - it now returns the location directly
    final location = await locationNotifier.getCurrentPosition();

    // Also read the state for error checking
    final currentState = ref.read(locationNotifierProvider);
    final error = currentState.error;

    print('After getCurrentPosition - Error: $error, Location returned: ${location?.city}, State location: ${currentState.location?.city}');

    // Check if location was successfully obtained first
    if (location != null) {
      print('Location obtained successfully: ${location.city}, ${location.state}');
      await _submitLocation(location);
      return;
    }

    // If no location, check for errors
    if (error != null && error.isNotEmpty) {
      print('Location error: $error');
      // Check if it's a permission error
      if (error.contains('permission') || error.contains('denied')) {
        setState(() {
          permissionDenied = true;
          isLoading = false;
        });
      } else {
        // Other errors (like location services disabled, network, etc.)
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Location error: $error')));
      }
      return;
    }

    // Fallback: no location and no error (shouldn't happen)
    print('No location and no error - showing generic error');
    setState(() {
      isLoading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Could not determine your location. Please try again.'),
      ),
    );
  }

  Future<void> _submitLocation(LocationModel location) async {
    final userId = ref.read(userNotifierProvider).userId;
    final notifier = ref.read(locationNotifierProvider.notifier);

    try {
      setState(() => isLoading = true);
      print('Submitting location: lat=${location.lat}, long=${location.long}, city=${location.city}');
      final success = await notifier.addLocation(userId!, location);
      setState(() => isLoading = false);

      if (success != null) {
        widget.pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeIn,
        );
      }
    } catch (e) {
      setState(() => isLoading = false);
      final isConnectionError = e.toString().contains('Connection refused');
      ScaffoldMessenger.of(context).showSnackBar(
        isConnectionError
            ? CustomSnackBar().build(context)
            : SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<UserModel>(userNotifierProvider, (previous, next) {
      if (previous?.userId != next.userId) {
        print('userId changed: ${previous!.userId} -> ${next.userId}');
      }
    });

    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: Column(
        children: [
          Center(child: Image.asset(kGlobe)),
          const SizedBox(height: 50),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _handleAutoLocation,
              child:
                  isLoading
                      ? kLoadingIndicator
                      : Text(
                        'Allow access to your location',
                        style: Theme.of(context).textTheme.headlineSmall!
                            .copyWith(color: Colors.white),
                      ),
            ),
          ),
          if (permissionDenied) _buildPermissionError(context),
        ],
      ),
    );
  }

  Widget _buildPermissionError(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 15, left: 10, right: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Location permission has been denied',
            style: Theme.of(
              context,
            ).textTheme.bodySmall!.copyWith(color: kAppRed),
          ),
          GestureDetector(
            onTap:
                () =>
                    AppSettings.openAppSettings(type: AppSettingsType.location),
            child: Text(
              'Settings',
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                color: kAppBlack,
                fontWeight: FontWeight.w800,
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
