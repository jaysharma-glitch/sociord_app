import 'package:flutter/material.dart';
import 'package:sociord/utils/app_constants.dart';

class DashedProgressIndicator extends StatelessWidget {
  final int totalSteps;
  final int currentStep;
  final double width;
  final double height;
  final Color activeColor;
  final Color inactiveColor;

  DashedProgressIndicator({
    required this.totalSteps,
    required this.currentStep,
    this.width = 50.0,
    this.height = 4.0,
    this.activeColor = kAppPurple,
    this.inactiveColor = kBorderGreay,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalSteps, (index) {
        return Container(
          width: width,
          height: height,
          margin: EdgeInsets.symmetric(horizontal: 3.0),
          decoration: BoxDecoration(
            color: index < currentStep ? activeColor : inactiveColor,
            borderRadius: BorderRadius.circular(20.0),
          ),
        );
      }),
    );
  }
}
