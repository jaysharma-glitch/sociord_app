// lib/screens/onboarding/widgets/onboarding_page.dart

import 'package:flutter/material.dart';
import 'package:sociord/constants/color.dart';

class OnboardingPage extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget content;

  const OnboardingPage({
    super.key,
    required this.title,
    this.subtitle,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 50),
            Text(title, style: Theme.of(context).textTheme.headlineLarge),
            if (subtitle != null) ...[
              const SizedBox(height: 5),
              Text(
                subtitle!,
                style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                  color: kAppPurple,
                  fontSize: 18,
                ),
              ),
            ],
            const SizedBox(height: 20),
            content,
          ],
        ),
      ),
    );
  }
}
