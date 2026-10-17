import 'package:flutter/material.dart';
import 'core.dart';
import 'screens/welcome_screen.dart';
import 'services/storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Store.init();
  UserStore.init();
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
            colorScheme: ColorScheme.fromSeed(seedColor: C.forest)),
        home: const Welcome(),
      );
}
