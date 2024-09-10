import 'package:flutter/material.dart';
import 'package:sociord/utils/app_constants.dart';

class OptionSelector extends StatelessWidget {
  final String title;
  final bool isSelected;
  final onTap;

  const OptionSelector({
    super.key,
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: kAppLightGreay,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? Colors.purple : Colors.grey.shade300,
            width: isSelected ? 0 : 0,
          ),
          boxShadow: [
            // BoxShadow(
            //   color: Colors.grey.withOpacity(0.1),
            //   spreadRadius: 1,
            //   blurRadius: 5,
            //   offset: const Offset(0, 3),
            // ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  Text(title,
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall!
                          .copyWith(
                              color: kAppBlack, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle_rounded, color: Colors.purple)
            else
              Icon(Icons.radio_button_unchecked, color: Colors.grey.shade300),
          ],
        ),
      ),
    );
  }
}
