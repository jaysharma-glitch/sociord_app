import 'package:flutter/material.dart';

ColorScheme kColorScheme =
    ColorScheme.fromSeed(seedColor: const Color(0xFF822FAF));

ColorScheme kDarkColorScheme = ColorScheme.fromSeed(
    brightness: Brightness.dark, seedColor: const Color(0xFF822FAF));

const kTextFormFieldBorderStyles = OutlineInputBorder(
    borderSide: BorderSide(color: kBorderGreay),
    borderRadius: BorderRadius.all(Radius.circular(10.0)));

const kLoadingIndicator = SizedBox(
  height: 25,
  width: 25,
  child: CircularProgressIndicator(
    backgroundColor: Colors.white,
    strokeWidth: 2,
  ),
);
const kSmallLoadingIndicator = SizedBox(
  height: 15,
  width: 15,
  child: CircularProgressIndicator(
    backgroundColor: Colors.white,
    strokeWidth: 2,
  ),
);

const kAppPurple = Color(0xFF822FAF);
const kAppGreen = Color(0xFF9FC7AA);
const kAppBlack = Color(0xFF444246);
const kAppLightBlack = Color(0xFF6E6969);
const kAppWhite = Color(0xFFFFFFFF);
const kAppGreay = Color(0xffECECEC);
const kAppLightGreay = Color(0xffFAF9FB);
const kBorderGreay = Color(0xffD9D9D9);
const kAppDarkGreen = Color(0xFF037002);
const kAppRed = Color(0xFF8E0000);
const kAppLightPurple = Color(0xFFF3EAF7);
