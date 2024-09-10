import 'package:flutter/material.dart';
import 'package:sociord/screens/log_in_otp_screen.dart';
import 'package:sociord/screens/login_in_screen.dart';
import 'package:sociord/screens/onboarding/final_onboarding_screen.dart';
import 'package:sociord/screens/onboarding/location_search.dart';
import 'package:sociord/screens/onboarding/other_gender.dart';
import 'package:sociord/screens/sign_in_sign_up_screen.dart';
import 'package:sociord/screens/onboarding/sign_up_flow.dart';
import 'package:sociord/screens/personality/personality_flow.dart';
import 'package:sociord/screens/profile_pic.dart';
import 'package:sociord/utils/app_constants.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() => runApp(const ProviderScope(child: MyApp()));

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData().copyWith(
        colorScheme: kColorScheme,
        scaffoldBackgroundColor: Colors.white,
        textTheme: ThemeData().textTheme.copyWith(
              headlineLarge: const TextStyle(
                  fontSize: 26, fontWeight: FontWeight.w800, color: kAppBlack),
              headlineMedium: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF822FAF)),
              headlineSmall: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: kAppWhite,
              ),
              bodyLarge: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: kAppBlack,
              ),
              bodyMedium: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: kAppBlack,
              ),
              bodySmall: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: kAppBlack,
              ),
            ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: kAppPurple,
            padding: const EdgeInsets.symmetric(
              vertical: 15,
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(
              vertical: 15,
            ),
            side: const BorderSide(color: kAppPurple, width: 1),
          ),
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(colorScheme: kDarkColorScheme),
      themeMode: ThemeMode.light,
      initialRoute: SignInSignUpScreen.routeName,
      routes: {
        SignInSignUpScreen.routeName: (context) => const SignInSignUpScreen(),
        SignUpFlow.routeName: (context) => const SignUpFlow(),
        LocationSearch.routeName: (context) => const LocationSearch(),
        FinalOnboardingScreen.routName: (context) =>
            const FinalOnboardingScreen(),
        PersonalityFlow.routeName: (context) => const PersonalityFlow(),
        ProfilePicScreen.routeName: (context) => const ProfilePicScreen(),
        OtherGenderDes.routeName: (context) => const OtherGenderDes(),
        LoginScreen.routeName: (context) => LoginScreen(),
        LogInOtpScreen.routeName: (context) => LogInOtpScreen(),
      },
    );
  }
}
