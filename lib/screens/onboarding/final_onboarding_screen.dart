import 'dart:async';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:sociord/utils/app_constants.dart';
import 'package:sociord/utils/asset_path_constants.dart';

class FinalOnboardingScreen extends StatefulWidget {
  static var routName = '/final-onboarding';
  const FinalOnboardingScreen({super.key});

  @override
  State<FinalOnboardingScreen> createState() => _FinalOnboardingScreenState();
}

class _FinalOnboardingScreenState extends State<FinalOnboardingScreen> {
  final List<Map<String, String>> onboardData = [
    {"image": kFinalOnboardingImage1},
    {"image": kFinalOnboardingImage2},
    {"image": kFinalOnboardingImage3},
  ];

  Timer? timer;

  @override
  void initState() {
    super.initState();
    startTimer();
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
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 20,
            ),
            AbsorbPointer(
              child: CarouselSlider(
                options:
                    CarouselOptions(aspectRatio: 1.5, viewportFraction: 0.48),
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
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Wow! Your profile looks awesome.',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  Text(
                    'As we add our finishing touches, we’d love to get to know you better. \nWe\'ve got 5 personality-based questions lined up for you.',
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium!
                        .copyWith(fontWeight: FontWeight.w400),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    'This is our way of making sure your experience here is nothing short of fantastic',
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        fontWeight: FontWeight.w800, color: kAppPurple),
                  ),
                  const SizedBox(height: 40),
                  Center(
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/personality-flow');
                        },
                        child: Text(
                          'Continue',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
