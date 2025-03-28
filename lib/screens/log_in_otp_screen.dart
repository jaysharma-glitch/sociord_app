import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sociord/provider/user_provider.dart';
import 'package:sociord/screens/onboarding/otp.dart';
import 'package:sociord/constants/color.dart';
import 'package:sociord/widgets/go_back_btn.dart';

class LogInOtpScreen extends ConsumerWidget {
  LogInOtpScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var userState = ref.watch(userNotifierProvider);
    return Scaffold(
        body: SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            GoBackButton(
              onPressedFunction: () {
                context.pop();
              },
            ),
            const SizedBox(height: 20),
            Text(
              'Enter the OTP sent to',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 5),
            Text(
              '+${userState.countryCode}${userState.phoneNumber}',
              style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                  color: kAppPurple, fontSize: 15, fontWeight: FontWeight.w800),
            ),
            const Otp(isLogin: true)
          ],
        ),
      ),
    ));
  }
}
