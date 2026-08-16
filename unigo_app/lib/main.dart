import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'core/theme.dart';
import 'screens/auth/auth_screen.dart';
import 'screens/main/main_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const UnigoApp());
}

class UnigoApp extends StatelessWidget {
  const UnigoApp({super.key});
  @override Widget build(BuildContext context) => MaterialApp(title: 'UNIGO', debugShowCheckedModeBanner: false, theme: UnigoTheme.light(), darkTheme: UnigoTheme.dark(), themeMode: ThemeMode.system, home: StreamBuilder<User?>(stream: FirebaseAuth.instance.authStateChanges(), builder: (_, snap) => snap.data == null ? const AuthScreen() : const MainShell()));
}
