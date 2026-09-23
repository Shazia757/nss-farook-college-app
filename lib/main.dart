import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:nss_new/config/color_scheme.dart';
import 'package:nss_new/config/text_theme.dart';
import 'package:responsive_framework/responsive_framework.dart';

import 'package:nss_new/common_pages/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) => GetMaterialApp(
    title: 'NSS Farook College',
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: lightColorScheme,
      textTheme: appTextTheme,
    ),
    darkTheme: ThemeData(
      colorScheme: darkColorScheme,
      useMaterial3: true,
      textTheme: appTextTheme,
    ),
    builder: (context, child) => ResponsiveBreakpoints.builder(
      child: child!,
      breakpoints: [
        const Breakpoint(start: 0, end: 450, name: MOBILE),
        const Breakpoint(start: 451, end: 800, name: TABLET),
        const Breakpoint(start: 801, end: 1920, name: DESKTOP),
        const Breakpoint(start: 1921, end: double.infinity, name: '4K'),
      ],
    ),
    themeMode: ThemeMode.light,
    debugShowCheckedModeBanner: false,

    home: const SplashScreen(),
  );
}
