import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:padly/route/route_constants.dart';
import 'package:padly/route/router.dart' as router;
import 'package:padly/theme/app_theme.dart';

import 'firebase_options.dart';

Future<void> main() async {
  /*WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://alfculmdvcgrymxnmowq.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFsZmN1bG1kdmNncnlteG5tb3dxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDQyODU4MDUsImV4cCI6MjA1OTg2MTgwNX0.hBWfjKXJQUVs-erDsFj2gwbj8jMFhM8LbO2pApB-Uwk',
  );*/

  WidgetsFlutterBinding.ensureInitialized();
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final route = FirebaseAuth.instance.currentUser != null
        ? entryPointScreenRoute
        : logInScreenRoute;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Padly: Play More. Search Less',
      theme: AppTheme.lightTheme(context),
      // Dark theme is inclided in the Full template
      themeMode: ThemeMode.light,
      onGenerateRoute: router.generateRoute,
      initialRoute: route,
    );
  }
}
