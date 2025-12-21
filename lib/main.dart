import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:provider/provider.dart';
import 'package:safe_track/firebase_options.dart';
import 'package:safe_track/presentation/screens/splash_screen.dart';
import 'package:safe_track/services/auth_services.dart';
import 'package:safe_track/state/home_provider.dart';
import 'package:safe_track/state/login_provider.dart';
import 'package:safe_track/state/otp_provider.dart';
import 'package:safe_track/state/profile_provider.dart';
import 'package:safe_track/state/sos_history_provider.dart';
import 'package:safe_track/state/sos_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginProvider()),
        ChangeNotifierProvider(create: (_) => OtpProvider()),
        ChangeNotifierProvider(create: (_) => AuthServices()),
        ChangeNotifierProvider(
          create: (_) {
            final profile = ProfileProvider();
            profile.init();
            return profile;
          },
        ),
        ChangeNotifierProvider(create: (_)
        {
          final home = HomeProvider();
          home.init();
          return home;
        }),
        ChangeNotifierProvider(create: (_) => SosProvider()),
        ChangeNotifierProvider(
          create: (_) {
            final provider = SosHistoryProvider();
            provider.loadHistory();
            return provider;
          },
        ),
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
      home: SplashScreen(),
    );
  }
}
