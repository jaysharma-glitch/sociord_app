import 'dart:async';

import 'package:carousel_slider/carousel_slider.dart' as cs;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sociord/utils/app_constants.dart';
import 'package:sociord/utils/asset_path_constants.dart';

class SignInSignUpScreen extends StatefulWidget {
  static const routeName = '/signInSignUp';

  const SignInSignUpScreen({super.key});

  @override
  State<SignInSignUpScreen> createState() => _SignInSignUpScreenState();
}

class _SignInSignUpScreenState extends State<SignInSignUpScreen> {
  final List<Map<String, String>> onboardData = [
    {"image": kOnboardingImage1, "title": "Cre8"},
    {"image": kOnboardingImage2, "title": "Communic8"},
    {"image": kOnboardingImage3, "title": "Innov8"},
    {"image": kOnboardingImage4, "title": "Rel8"},
  ];

  Timer? timer;

  @override
  void initState() {
    super.initState();
    startTimer();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(seconds: 2), (Timer t) {
      setState(() {
        var firstElement = onboardData.first;

        // Add it to the end
        onboardData.add(firstElement);

        // Remove the first element
        onboardData.removeAt(0);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).viewPadding.top;
    return Scaffold(
      body: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: height,
          ),
          const SizedBox(
            height: 20,
          ),
          AbsorbPointer(
            child: cs.CarouselSlider(
              options:
                  cs.CarouselOptions(aspectRatio: 0.9, viewportFraction: 0.85),
              items: onboardData.map((item) {
                return Builder(
                  builder: (BuildContext context) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 0.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                            20.0), // Adjust the radius as needed
                        child: Image.asset(
                          item['image']!,
                          fit: BoxFit.fill,
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome to Sociord',
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                Text(
                  onboardData[0]['title']!.toString(),
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 50),
                Center(
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/signUpFlow');
                      },
                      child: Text(
                        'Create an account',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Center(
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pushNamed(context, '/login');
                        // Navigator.pushNamed(context, '/personality-flow');
                        // Navigator.pushNamed(context, '/profile-pic');
                      },
                      child: Text(
                        'Login',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(color: kAppPurple),
                      ),
                    ),
                    // child: ElevatedButton(
                    //   onPressed: () {},
                    //   style: ElevatedButton.styleFrom(
                    //       backgroundColor: kAppWhite,
                    //       side:
                    //           const BorderSide(color: kAppPurple, width: 1)),
                    //   child: Text(
                    //     'Login',
                    //     style: Theme.of(context)
                    //         .textTheme
                    //         .headlineSmall
                    //         ?.copyWith(color: kAppPurple),
                    //   ),
                    // ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
