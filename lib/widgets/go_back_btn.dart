import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sociord/utils/app_constants.dart';

class GoBackButton extends StatelessWidget {
  final VoidCallback onPressedFunction;
  final String title;
  const GoBackButton(
      {super.key, required this.onPressedFunction, this.title = "Go back"});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressedFunction,
      icon: Platform.isIOS
          ? const Icon(
              Icons.arrow_back_ios,
              color: kAppBlack,
              size: 12,
            )
          : const Icon(
              Icons.arrow_back,
              color: kAppBlack,
              size: 12,
            ),
      label: Text(title,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontSize: 12, color: kAppBlack, fontWeight: FontWeight.w300)),
      style: ElevatedButton.styleFrom(
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
        backgroundColor: kAppGreay,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15), // Border radius
        ),
      ),
    );
  }
}
