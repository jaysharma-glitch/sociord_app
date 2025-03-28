import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Utils
import 'package:sociord/constants/color.dart';
import 'package:sociord/utils/routes.dart';
import 'package:sociord/themes/app_theme.dart';

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
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,
    );
  }
}
