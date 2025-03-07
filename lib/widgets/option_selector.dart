import 'package:flutter/material.dart';
import 'package:sociord/utils/app_constants.dart';

class OptionSelector extends StatelessWidget {
  final String title;
  final bool isSelected;
  final onTap;
  final isSizeLarge;

  const OptionSelector({
    super.key,
    required this.title,
    required this.isSelected,
    required this.onTap,
    this.isSizeLarge = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: isSizeLarge
            ? const EdgeInsets.all(16)
            : const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
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
                  isSizeLarge
                      ? const SizedBox(
                          height: 10,
                        )
                      : const SizedBox(
                          height: 5,
                        ),
                  Text(title,
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall!
                          .copyWith(
                              fontSize: isSizeLarge ? 18 : 12,
                              color: kAppBlack,
                              fontWeight: isSizeLarge
                                  ? FontWeight.w600
                                  : FontWeight.w400)),
                  const SizedBox(height: 4),
                ],
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle_rounded,
                color: Colors.purple,
                size: isSizeLarge ? 24 : 16,
              )
            else
              Icon(
                Icons.radio_button_unchecked,
                color: Colors.grey.shade300,
                size: isSizeLarge ? 24 : 15,
              ),
            isSizeLarge
                ? const SizedBox()
                : const SizedBox(
                    width: 15,
                  )
          ],
        ),
      ),
    );
  }
}
