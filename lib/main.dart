import 'package:flutter/material.dart';
import 'core.dart';
import 'screens/welcome_screen.dart';
import 'screens/shell_screen.dart';
import 'services/storage.dart';
import 'services/app_state.dart';
import 'services/auth.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
            hoverColor: const Color(0x246E927F),
            splashColor: const Color(0x406E927F),
            highlightColor: const Color(0x2E6E927F),
            textButtonTheme: TextButtonThemeData(style: ButtonStyle(foregroundColor: WidgetStatePropertyAll(C.forest), overlayColor: appOverlay)),
            iconButtonTheme: IconButtonThemeData(style: ButtonStyle(overlayColor: appOverlay)),
            outlinedButtonTheme: OutlinedButtonThemeData(style: ButtonStyle(overlayColor: appOverlay)),
            elevatedButtonTheme: ElevatedButtonThemeData(style: ButtonStyle(overlayColor: appOverlay)),
            floatingActionButtonTheme: const FloatingActionButtonThemeData(hoverColor: Color(0xFF9DBFD0), focusColor: Color(0xFF9DBFD0), splashColor: Color(0xFFB9D3DF)),
            switchTheme: SwitchThemeData(
              thumbColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? C.cream : null),
              trackColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? C.forest : null),
            )),
        home: Auth.loggedIn ? const Shell() : const Welcome(),
      );
}
