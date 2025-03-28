// lib/themes/app_theme.dart
import 'package:flutter/material.dart';
import 'package:sociord/constants/color.dart';
import 'package:sociord/constants/text_styles.dart';

final ThemeData lightTheme = ThemeData().copyWith(
  colorScheme: kColorScheme,
  scaffoldBackgroundColor: Colors.white,
  textTheme: TextTheme(
    headlineLarge: kHeadlineLargeBlack,
    headlineMedium: kHeadlineLargeBlack,
    headlineSmall: kHeadlineSmallBlack,
    bodyLarge: kBodyLargeBlack,
    bodyMedium: kBodyMediumBlack,
    bodySmall: kBodySmallBlack,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: kAppPurple,
      padding: const EdgeInsets.symmetric(vertical: 15),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      padding: const EdgeInsets.symmetric(vertical: 15),
      side: const BorderSide(color: kAppPurple, width: 1),
    ),
  ),
);

final ThemeData darkTheme = ThemeData.dark().copyWith(
  colorScheme: kDarkColorScheme,
  textTheme: const TextTheme().copyWith(
    headlineLarge: kHeadlineLargeWhite,
    headlineMedium: kHeadlineMediumWhite,
    headlineSmall: kHeadlineSmallWhite,
    bodyLarge: kBodyLargeWhite,
    bodyMedium: kBodyMediumWhite,
    bodySmall: kBodySmallWhite,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: kAppPurple,
      padding: const EdgeInsets.symmetric(vertical: 15),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      padding: const EdgeInsets.symmetric(vertical: 15),
      side: const BorderSide(color: kAppPurple, width: 1),
    ),
  ),
);

final ColorScheme kColorScheme = ColorScheme.fromSeed(seedColor: kAppPurple);

final ColorScheme kDarkColorScheme = ColorScheme.fromSeed(
  brightness: Brightness.dark,
  seedColor: kAppPurple,
);
