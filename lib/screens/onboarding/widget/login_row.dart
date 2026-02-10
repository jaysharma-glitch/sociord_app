// lib/screens/onboarding/widgets/login_row.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sociord/constants/color.dart';
import 'package:sociord/provider/user_provider.dart';
import 'package:sociord/utils/routes.dart';

class LoginRow extends ConsumerWidget {
  const LoginRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          "Already have an account? ",
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        GestureDetector(
          onTap: () {
            ref.read(userNotifierProvider.notifier).setCountryCode('');
            context.push(loginRoute);
          },
          child: Text(
            'Login',
            style: Theme.of(context).textTheme.bodyMedium!.copyWith(
              color: kAppPurple,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: 25),
      ],
    );
  }
}
