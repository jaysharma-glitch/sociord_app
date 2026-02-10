import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import 'package:sociord/constants/text_styles.dart';
import 'package:sociord/constants/color.dart';
import 'package:sociord/utils/routes.dart';
import 'package:sociord/utils/asset_path_constants.dart';
import 'package:sociord/widgets/onboarding/onboarding_carousel.dart';

class SignInSignUpScreen extends StatefulWidget {
  const SignInSignUpScreen({super.key});

  @override
  State<SignInSignUpScreen> createState() => _SignInSignUpScreenState();
}

class _SignInSignUpScreenState extends State<SignInSignUpScreen> {
  // Keep track of the current text - synchronized with carousel
  String _currentText = "Cre";

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  }

  void _onTextChanged(String newText) {
    if (mounted) {
      setState(() {
        _currentText = newText;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double topPadding = MediaQuery.of(context).viewPadding.top;

    return Scaffold(
      body: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: topPadding + 20),
          OnboardingCarousel(onTextChanged: _onTextChanged),
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
                const SizedBox(height: 5),
                // Display the changing text with Sociord 8 icon
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      _currentText,
                      style: Theme.of(
                        context,
                      ).textTheme.headlineLarge?.copyWith(
                        color: kAppPurple,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Image.asset(
                      kSociord8Icon,
                      height: 24,
                      width: 24,
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
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
                        style: Theme.of(context).textTheme.headlineSmall!
                            .copyWith(color: Colors.white),
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
                      child: Text('Login', style: kHeadlineSmallPurple),
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
