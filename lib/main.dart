import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sms_autofill/sms_autofill.dart';
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

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SmsAutoFill().listenForCode;
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // Status bar color
    ));
    return MaterialApp(
      theme: ThemeData().copyWith(
        colorScheme: kColorScheme,
        scaffoldBackgroundColor: Colors.white,
        textTheme: ThemeData().textTheme.copyWith(
              headlineLarge: const TextStyle(
                  fontFamily: 'Gibson',
                  fontSize: 28,
                  fontWeight: FontWeight.w600,
                  color: kAppBlack,
                  height: 1),
              headlineMedium: const TextStyle(
                  fontFamily: 'Gibson',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF822FAF)),
              headlineSmall: const TextStyle(
                fontFamily: 'Gibson',
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: kAppWhite,
              ),
              bodyLarge: const TextStyle(
                fontFamily: 'Lato',
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: kAppBlack,
              ),
              bodyMedium: const TextStyle(
                fontFamily: 'Lato',
                fontSize: 15,
                fontWeight: FontWeight.w400,
                color: kAppBlack,
              ),
              bodySmall: const TextStyle(
                fontFamily: 'Lato',
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
