import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sociord/models/user_model.dart';
import 'package:sociord/provider/location_provider.dart';
import 'package:sociord/provider/user_provider.dart';
import 'package:sociord/utils/app_constants.dart';
import 'package:sociord/utils/asset_path_constants.dart';
import 'package:sociord/widgets/custom_snack_bar.dart';

class LocationPage extends ConsumerStatefulWidget {
  // ignore: prefer_typing_uninitialized_variables
  final pageController;
  const LocationPage({super.key, this.pageController});
  @override
  _LocationPageState createState() => _LocationPageState();
}

class _LocationPageState extends ConsumerState<LocationPage> {
  bool permisionDenied = false;
  bool isLoading = false;

  @override
  Widget build(BuildContext context) {
    final locationState = ref.watch(locationNotifierProvider);
    final locationNotifier = ref.read(locationNotifierProvider.notifier);
    final userState = ref.watch(userNotifierProvider);
    ref.listen<UserModel>(userNotifierProvider, (previous, next) {
      if (previous?.userId != next.userId) {
        print('userId has changed: ${previous!.userId} -- ${next.userId}');
      }
    });

    bool checkLocationData() {
      var location = ref.read(locationNotifierProvider).location;
      return location != null ? true : false;
    }

    return Padding(
      padding: const EdgeInsets.only(top: 40),
      child: Column(
        children: [
          Center(
            child: Image.asset(
              kGlobe,
            ),
          ), // Add your image asset here
          const SizedBox(height: 50),
          Center(
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  // widget.pageController.nextPage(
                  //   duration: Duration(milliseconds: 300),
                  //   curve: Curves.easeIn,
                  // );
                  setState(() {
                    permisionDenied = false;
                  });
                  await ref
                      .read(locationNotifierProvider.notifier)
                      .getCurrentPosition();

                  if (checkLocationData()) {
                    try {
                      setState(() {
                        isLoading = true;
                      });
                      print(userState.userId);
                      var result =
                          await locationNotifier.addLocation(userState.userId!);
                      setState(() {
                        isLoading = false;
                      });
                      if (result != null) {
                        // Add your logic here (e.g., trigger navigation,
                        widget.pageController.nextPage(
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeIn,
                        );
                      }
                    } catch (e) {
                      setState(() {
                        isLoading = false;
                      });
                      if (e.toString().contains('Connection refused')) {
                        ScaffoldMessenger.of(context)
                            .showSnackBar(CustomSnackBar().build(context));
                      } else {
                        print(e.toString());
                      }
                    }
                  } else {
                    var permision = await ref
                        .read(locationNotifierProvider.notifier)
                        .handleLocationPermission();
                    if (!permision) {
                      setState(() {
                        permisionDenied = true;
                      });
                    }
                  }
                },
                child: isLoading
                    ? kLoadingIndicator
                    : Text(
                        'Allow access to your location',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
              ),
            ),
          ),

          if (permisionDenied)
            Padding(
              padding: const EdgeInsets.only(top: 15, left: 10, right: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Location permession has been denied',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall!
                        .copyWith(color: kAppRed),
                  ),
                  GestureDetector(
                    onTap: () {
                      AppSettings.openAppSettings(
                          type: AppSettingsType.location);
                    },
                    child: Text(
                      'Setings',
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: kAppBlack,
                          fontWeight: FontWeight.w800,
                          decoration: TextDecoration.underline),
                    ),
                  )
                ],
              ),
            ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/locationSearch')
                    .then((value) async {
                  print(value);
                  if (value != null) {
                    if (checkLocationData()) {
                      try {
                        print(userState.userId);
                        var result = await locationNotifier
                            .addLocation(userState.userId!);
                        if (result != null) {
                          widget.pageController.nextPage(
                            duration: Duration(milliseconds: 300),
                            curve: Curves.easeIn,
                          );
                        }
                      } catch (e) {
                        if (e.toString().contains('Connection refused')) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(CustomSnackBar().build(context));
                        } else {
                          print(e.toString());
                        }
                      }
                    } else {
                      var permision = await ref
                          .read(locationNotifierProvider.notifier)
                          .handleLocationPermission();
                      if (!permision) {
                        setState(() {
                          permisionDenied = true;
                        });
                      }
                    }
                    // widget.pageController.nextPage(
                    //   duration: Duration(milliseconds: 300),
                    //   curve: Curves.easeIn,
                    // );
                  }
                });
              },
              child: Text(
                'Enter location manually',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(color: kAppPurple),
              ),
            ),
          )
        ],
      ),
    );
  }
}
