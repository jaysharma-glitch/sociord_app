import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sms_autofill/sms_autofill.dart';

// Themes + Routing
import 'package:sociord/themes/app_theme.dart';
import 'package:sociord/provider/router_provider.dart';
import 'package:sociord/provider/user_provider.dart';
import 'package:sociord/constants/color.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SmsAutoFill().listenForCode();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Check reservation validity when app resumes
      final userNotifier = ref.read(userNotifierProvider.notifier);
      userNotifier.checkReservationValidity();
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: kAppPurple,
        statusBarIconBrightness: Brightness.light,
      ),
    );

    // ✅ Get router from Riverpod
    final router = ref.watch(goRouterProvider);
    if (router == null) return const SizedBox();

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,
      supportedLocales: const [
        Locale('en', 'US'), // English
        Locale('hi', 'IN'), // Hindi (for future support)
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
