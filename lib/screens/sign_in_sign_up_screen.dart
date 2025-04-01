import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import 'package:sociord/constants/text_styles.dart';
import 'package:sociord/utils/routes.dart';
import 'package:sociord/widgets/onboarding/onboarding_carousel.dart';

class SignInSignUpScreen extends StatefulWidget {
  const SignInSignUpScreen({super.key});

  @override
  State<SignInSignUpScreen> createState() => _SignInSignUpScreenState();
}

class _SignInSignUpScreenState extends State<SignInSignUpScreen> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  @override
  Widget build(BuildContext context) {
    final double topPadding = MediaQuery.of(context).viewPadding.top;

    return Scaffold(
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: topPadding + 20),
          const OnboardingCarousel(),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Welcome to Sociord',
                    style: Theme.of(context).textTheme.headlineLarge),
                const SizedBox(height: 5),
                // title now handled inside OnboardingCarousel
                const SizedBox(height: 50),
                Center(
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        context.push(signUpFlowRoute);
                      },
                      child: Text(
                        'Create an account',
                        style:
                            Theme.of(context).textTheme.headlineSmall!.copyWith(
                                  color: Colors.white,
                                ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        context.push(loginRoute);
                        // Navigator.pushNamed(context, '/personality-flow');
                        // Navigator.pushNamed(context, '/profile-pic');
                      },
                      child: Text(
                        'Login',
                        style: kHeadlineSmallPurple,
                      ),
                    ),
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
