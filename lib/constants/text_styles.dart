import 'package:flutter/material.dart';
import 'package:sociord/constants/color.dart';

TextStyle gibsonTextStyle({
  required double fontSize,
  required FontWeight fontWeight,
  required Color color,
}) => TextStyle(
  fontFamily: 'Gibson',
  fontSize: fontSize,
  fontWeight: fontWeight,
  color: color,
  height: 1.2,
);

TextStyle interTextStyle({
  required double fontSize,
  required FontWeight fontWeight,
  required Color color,
}) => TextStyle(
  fontFamily: 'Inter',
  fontSize: fontSize,
  fontWeight: fontWeight,
  color: color,
  height: 1.2,
);

// === Headline (Gibson) ===
final kHeadlineLargeBlack = gibsonTextStyle(
  fontSize: 28,
  fontWeight: FontWeight.w600,
  color: kAppBlack,
);
final kHeadlineLargeWhite = gibsonTextStyle(
  fontSize: 28,
  fontWeight: FontWeight.w600,
  color: kAppWhite,
);
final kHeadlineLargePurple = gibsonTextStyle(
  fontSize: 28,
  fontWeight: FontWeight.w600,
  color: kAppPurple,
);

final kHeadlineMediumBlack = gibsonTextStyle(
  fontSize: 20,
  fontWeight: FontWeight.w700,
  color: kAppBlack,
);
final kHeadlineMediumWhite = gibsonTextStyle(
  fontSize: 20,
  fontWeight: FontWeight.w700,
  color: kAppWhite,
);
final kHeadlineMediumPurple = gibsonTextStyle(
  fontSize: 20,
  fontWeight: FontWeight.w700,
  color: kAppPurple,
);

final kHeadlineSmallBlack = gibsonTextStyle(
  fontSize: 18,
  fontWeight: FontWeight.w600,
  color: kAppBlack,
);
final kHeadlineSmallWhite = gibsonTextStyle(
  fontSize: 18,
  fontWeight: FontWeight.w600,
  color: kAppWhite,
);
final kHeadlineSmallPurple = gibsonTextStyle(
  fontSize: 18,
  fontWeight: FontWeight.w600,
  color: kAppPurple,
);

// === Body (Inter) ===
final kBodyLargeBlack = interTextStyle(
  fontSize: 18,
  fontWeight: FontWeight.w500,
  color: kAppBlack,
);
final kBodyLargeWhite = interTextStyle(
  fontSize: 18,
  fontWeight: FontWeight.w500,
  color: kAppWhite,
);
final kBodyLargePurple = interTextStyle(
  fontSize: 18,
  fontWeight: FontWeight.w500,
  color: kAppPurple,
);

final kBodyMediumBlack = interTextStyle(
  fontSize: 15,
  fontWeight: FontWeight.w400,
  color: kAppBlack,
);
final kBodyMediumWhite = interTextStyle(
  fontSize: 15,
  fontWeight: FontWeight.w400,
  color: kAppWhite,
);
final kBodyMediumPurple = interTextStyle(
  fontSize: 15,
  fontWeight: FontWeight.w400,
  color: kAppPurple,
);

final kBodySmallBlack = interTextStyle(
  fontSize: 12,
  fontWeight: FontWeight.w400,
  color: kAppBlack,
);
final kBodySmallWhite = interTextStyle(
  fontSize: 12,
  fontWeight: FontWeight.w400,
  color: kAppWhite,
);
final kBodySmallPurple = interTextStyle(
  fontSize: 12,
  fontWeight: FontWeight.w400,
  color: kAppPurple,
);
