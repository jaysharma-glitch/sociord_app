import 'package:flutter/material.dart';

class CustomSnackBar {
  final String text;
  final int duration;

  CustomSnackBar({this.text = 'Network Issue', this.duration = 800});

  SnackBar build(BuildContext context) {
    return SnackBar(
      content: Text(
        text,
        style: Theme.of(context)
            .textTheme
            .bodySmall!
            .copyWith(color: Colors.white),
      ),
      duration: Duration(milliseconds: duration),
    );
  }
}
