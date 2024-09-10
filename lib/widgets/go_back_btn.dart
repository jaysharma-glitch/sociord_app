import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sociord/utils/app_constants.dart';

class GoBackButton extends StatelessWidget {
  final VoidCallback onPressedFunction;
  const GoBackButton({super.key, required this.onPressedFunction});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressedFunction,
      icon: Platform.isIOS
          ? const Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
              size: 15,
            )
          : const Icon(
              Icons.arrow_back,
              color: Colors.black,
              size: 15,
            ),
      label: Text('Go back',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontSize: 15, color: Colors.black, fontWeight: FontWeight.w300)),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
        backgroundColor: kAppGreay,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15), // Border radius
        ),
      ),
    );
  }
}
