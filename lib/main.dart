import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safe_track/presentation/screens/login_otp_screen.dart';
import 'package:safe_track/presentation/screens/login_screen.dart';
import 'package:safe_track/state/login_provider.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginProvider())
      ],
      child: const MyApp(),
    )
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
      home: LoginOtpScreen(),
    );
  }
}


