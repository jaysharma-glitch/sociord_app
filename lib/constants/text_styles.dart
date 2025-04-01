import 'package:flutter/material.dart';
import 'package:sociord/constants/color.dart';

TextStyle gibsonTextStyle({
  required double fontSize,
  required FontWeight fontWeight,
  required Color color,
}) =>
    TextStyle(
      fontFamily: 'Gibson',
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: 1.2,
    );

TextStyle latoTextStyle({
  required double fontSize,
  required FontWeight fontWeight,
  required Color color,
}) =>
    TextStyle(
      fontFamily: 'Lato',
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      height: 1.2,
    );

// === Headline (Gibson) ===
final kHeadlineLargeBlack = gibsonTextStyle(
    fontSize: 28, fontWeight: FontWeight.w600, color: kAppBlack);
final kHeadlineLargeWhite = gibsonTextStyle(
    fontSize: 28, fontWeight: FontWeight.w600, color: kAppWhite);
final kHeadlineLargePurple = gibsonTextStyle(
    fontSize: 28, fontWeight: FontWeight.w600, color: kAppPurple);

final kHeadlineMediumBlack = gibsonTextStyle(
    fontSize: 20, fontWeight: FontWeight.w700, color: kAppBlack);
final kHeadlineMediumWhite = gibsonTextStyle(
    fontSize: 20, fontWeight: FontWeight.w700, color: kAppWhite);
final kHeadlineMediumPurple = gibsonTextStyle(
    fontSize: 20, fontWeight: FontWeight.w700, color: kAppPurple);

final kHeadlineSmallBlack = gibsonTextStyle(
    fontSize: 18, fontWeight: FontWeight.w600, color: kAppBlack);
final kHeadlineSmallWhite = gibsonTextStyle(
    fontSize: 18, fontWeight: FontWeight.w600, color: kAppWhite);
final kHeadlineSmallPurple = gibsonTextStyle(
    fontSize: 18, fontWeight: FontWeight.w600, color: kAppPurple);

// === Body (Lato) ===
final kBodyLargeBlack =
    latoTextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: kAppBlack);
final kBodyLargeWhite =
    latoTextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: kAppWhite);
final kBodyLargePurple =
    latoTextStyle(fontSize: 18, fontWeight: FontWeight.w500, color: kAppPurple);

final kBodyMediumBlack =
    latoTextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: kAppBlack);
final kBodyMediumWhite =
    latoTextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: kAppWhite);
final kBodyMediumPurple =
    latoTextStyle(fontSize: 15, fontWeight: FontWeight.w400, color: kAppPurple);

final kBodySmallBlack =
    latoTextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: kAppBlack);
final kBodySmallWhite =
    latoTextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: kAppWhite);
final kBodySmallPurple =
    latoTextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: kAppPurple);
