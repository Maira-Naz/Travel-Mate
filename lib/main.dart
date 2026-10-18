import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core.dart';
import 'screens/welcome_screen.dart';
import 'screens/shell_screen.dart';
import 'services/storage.dart';
import 'services/app_state.dart';
import 'services/auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Store.init();
  UserStore.init();
  AppState.init();
  runApp(const RoamApp());
}

class RoamApp extends StatelessWidget {
  const RoamApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Roam',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: C.cream,
        colorScheme: ColorScheme.fromSeed(seedColor: C.forest),
        textTheme: GoogleFonts.dmSansTextTheme(),
        pageTransitionsTheme: PageTransitionsTheme(builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
          TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.linux: CupertinoPageTransitionsBuilder(),
        }),
        hoverColor: const Color(0x246E927F),
        splashColor: const Color(0x406E927F),
        highlightColor: const Color(0x2E6E927F),
        textButtonTheme: TextButtonThemeData(style: ButtonStyle(foregroundColor: WidgetStatePropertyAll(C.forest), overlayColor: appOverlay)),
        iconButtonTheme: IconButtonThemeData(style: ButtonStyle(overlayColor: appOverlay)),
        outlinedButtonTheme: OutlinedButtonThemeData(style: ButtonStyle(overlayColor: appOverlay)),
        elevatedButtonTheme: ElevatedButtonThemeData(style: ButtonStyle(overlayColor: appOverlay)),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(hoverColor: Color(0xFF45685C), focusColor: Color(0xFF45685C), splashColor: Color(0xFF6E927F)),
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? C.cream : null),
          trackColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? C.forest : null),
        )),
    home: Auth.loggedIn ? const Shell() : const Welcome(),
  );
}