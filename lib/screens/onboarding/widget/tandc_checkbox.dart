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
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Checkbox(
          value: isChecked,
          onChanged: onChanged,
          activeColor: kAppDarkGreen,
          checkColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
        ),
        const SizedBox(width: 8),
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: RichText(
              text: TextSpan(
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(fontSize: 15),
                children: [
                  const TextSpan(text: "I agree to Sociord's "),
                  WidgetSpan(
                    child: GestureDetector(
                      onTap: () {
                        // Open terms and conditions
                      },
                      child: Text(
                        'Terms and Conditions',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 15,
                          decoration: TextDecoration.underline,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
