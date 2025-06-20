import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sociord/models/user_model.dart';
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
    widget.pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeIn,
    );
    setState(() => permissionDenied = false);
    final locationNotifier = ref.read(locationNotifierProvider.notifier);
    await locationNotifier.getCurrentPosition();

    if (hasValidLocation) {
      await _submitLocation();
    } else {
      final granted = await locationNotifier.handleLocationPermission();
      if (!granted) setState(() => permissionDenied = true);
    }
  }

  Future<void> _submitLocation() async {
    final userId = ref.read(userNotifierProvider).userId;
    final notifier = ref.read(locationNotifierProvider.notifier);

    try {
      setState(() => isLoading = true);
      final success = await notifier.addLocation(userId!);
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

  Future<void> _handleManualLocation() async {
    final result = await context.push('/locationSearch');

    if (result != null && hasValidLocation) {
      await _submitLocation();
    } else {
      final granted = await ref
          .read(locationNotifierProvider.notifier)
          .handleLocationPermission();
      if (!granted) setState(() => permissionDenied = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(userNotifierProvider);
    final locationNotifier = ref.watch(locationNotifierProvider);

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
              child: isLoading
                  ? kLoadingIndicator
                  : Text(
                      'Allow access to your location',
                      style:
                          Theme.of(context).textTheme.headlineSmall!.copyWith(
                                color: Colors.white,
                              ),
                    ),
            ),
          ),
          if (permissionDenied) _buildPermissionError(context),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                widget.pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeIn,
                );
              },
              child: Text(
                'Enter location manually',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(color: kAppPurple),
              ),
            ),
          ),
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
            style:
                Theme.of(context).textTheme.bodySmall!.copyWith(color: kAppRed),
          ),
          GestureDetector(
            onTap: () => AppSettings.openAppSettings(
              type: AppSettingsType.location,
            ),
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
