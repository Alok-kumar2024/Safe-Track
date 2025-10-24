import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safe_track/firebase_options.dart';
import 'package:safe_track/presentation/screens/login_otp_screen.dart';
import 'package:safe_track/presentation/screens/login_screen.dart';
import 'package:safe_track/services/auth_services.dart';
import 'package:safe_track/state/login_provider.dart';
import 'package:safe_track/state/otp_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginProvider()),
        ChangeNotifierProvider(create: (_) => OtpProvider()),
        ChangeNotifierProvider(create: (_) => AuthServices()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      debugShowCheckedModeBanner: false,
      // home: const MyHomePage(title: 'Flutter Demo Home Page'),
      home: LoginScreen(),
    );
  }
}
