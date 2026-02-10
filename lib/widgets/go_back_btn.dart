import 'dart:io';

import 'package:flutter/material.dart';
import 'package:sociord/constants/color.dart';

class GoBackButton extends StatelessWidget {
  final VoidCallback onPressedFunction;
  final String title;
  const GoBackButton({
    super.key,
    required this.onPressedFunction,
    this.title = "Go back",
  });

  @override
  Widget build(BuildContext context) {
    // Simple icon button matching Figma design
    return IconButton(
      onPressed: onPressedFunction,
      icon: Icon(
        Platform.isIOS ? Icons.arrow_back_ios : Icons.arrow_back,
        color: kAppBlack,
        size: 20,
      ),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(),
    );
  }
}
