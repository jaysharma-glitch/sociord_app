import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Utils
import 'package:sociord/utils/app_constants.dart';
import 'package:sociord/utils/routes.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SmsAutoFill().listenForCode;
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: ThemeData.light().copyWith(
        colorScheme: kColorScheme,
        scaffoldBackgroundColor: Colors.white,
        textTheme: ThemeData.light().textTheme.copyWith(
              headlineLarge: const TextStyle(
                fontFamily: 'Gibson',
                fontSize: 28,
                fontWeight: FontWeight.w600,
                color: kAppBlack,
                height: 1,
              ),
              headlineMedium: const TextStyle(
                fontFamily: 'Gibson',
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF822FAF),
              ),
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
                letterSpacing: 0.1,
              ),
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
      ),
      darkTheme: ThemeData.dark().copyWith(
        colorScheme: kDarkColorScheme,
        scaffoldBackgroundColor: Colors.black,
      ),
      themeMode: ThemeMode.system,
    );
  }
}
