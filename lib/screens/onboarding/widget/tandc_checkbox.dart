import 'package:flutter/material.dart';
import 'package:sociord/constants/color.dart';

class TandCCheckBox extends StatelessWidget {
  final bool isChecked;
  final Function(bool?) onChanged;

  const TandCCheckBox({
    super.key,
    required this.isChecked,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(value: isChecked, onChanged: onChanged),
        Text("I agree to Sociord's ",
            style: Theme.of(context).textTheme.bodySmall),
        GestureDetector(
          onTap: () {
            // Open terms and conditions
          },
          child: Text(
            'Terms and Conditions',
            style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  decoration: TextDecoration.underline,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
      ],
    );
  }
}
