import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:async';
import 'firebase_options.dart';
import 'splash_screen.dart';
import 'login_screen.dart';
import 'signup_screen.dart';
import 'home_page.dart';

Future<void> main() async {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    runApp(const MyApp());
  }, (Object error, StackTrace stack) {
    print('Uncaught error: $error');
    print(stack);
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Grocery App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Roboto',
      ),
      home: const SplashScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/homepage': (context) => const HomePage(),
      },
    );
  }
}

// [ecom] flutter pub get --no-example
// Resolving dependencies...
// Because no versions of cloud_firestore match >4.17.5 <5.0.0 and cloud_firestore >=4.13.5 <4.15.0 depends on firebase_core ^2.24.2, cloud_firestore >=4.13.5 <4.15.0-∞ or >4.17.5 <5.0.0 requires firebase_core ^2.24.2.
// And because cloud_firestore >=4.15.0 <4.15.1 depends on firebase_core ^2.25.0, cloud_firestore >=4.13.5 <4.15.1-∞ or >4.17.5 <5.0.0 requires firebase_core ^2.24.2.
// And because cloud_firestore >=4.15.1 <4.15.2 depends on firebase_core ^2.25.1 and cloud_firestore >=4.15.2 <4.15.3 depends on firebase_core ^2.25.2, cloud_firestore >=4.13.5 <4.15.3-∞ or >4.17.5 <5.0.0 requires firebase_core ^2.24.2.
// And because cloud_firestore >=4.15.3 <4.15.4 depends on firebase_core ^2.25.3 and cloud_firestore >=4.15.4 <4.15.6 depends on firebase_core ^2.25.4, cloud_firestore >=4.13.5 <4.15.6-∞ or >4.17.5 <5.0.0 requires firebase_core ^2.24.2.
// And because cloud_firestore >=4.15.6 <4.15.7 depends on firebase_core ^2.25.5 and cloud_firestore >=4.15.7 <4.15.8 depends on firebase_core ^2.26.0, cloud_firestore >=4.13.5 <4.15.8-∞ or >4.17.5 <5.0.0 requires firebase_core ^2.24.2.
// And because cloud_firestore >=4.15.8 <4.15.9 depends on firebase_core ^2.27.0 and cloud_firestore >=4.15.9 <4.15.10 depends on firebase_core ^2.27.1, cloud_firestore >=4.13.5 <4.15.10-∞ or >4.17.5 <5.0.0 requires firebase_core ^2.24.2.
// And because cloud_firestore >=4.15.10 <4.16.0 depends on firebase_core ^2.27.2 and cloud_firestore >=4.16.0 <4.16.1 depends on firebase_core ^2.28.0, cloud_firestore >=4.13.5 <4.16.1-∞ or >4.17.5 <5.0.0 requires firebase_core ^2.24.2.
// And because cloud_firestore >=4.16.1 <4.17.0 depends on firebase_core ^2.29.0 and cloud_firestore >=4.17.0 <4.17.1 depends on firebase_core ^2.30.0, cloud_firestore >=4.13.5 <4.17.1-∞ or >4.17.5 <5.0.0 requires firebase_core ^2.24.2.
// And because cloud_firestore >=4.17.1 <4.17.3 depends on firebase_core ^2.30.1 and cloud_firestore >=4.17.3 <4.17.4 depends on firebase_core ^2.31.0, cloud_firestore >=4.13.5 <4.17.4-∞ or >4.17.5 <5.0.0 requires firebase_core ^2.24.2.
// And because cloud_firestore >=4.17.4 <4.17.5 depends on firebase_core ^2.31.1 and cloud_firestore 4.17.5 depends on firebase_core ^2.32.0, cloud_firestore ^4.13.5 requires firebase_core ^2.24.2.
// So, because ecom depends on both firebase_core ^3.6.0 and cloud_firestore ^4.14.0, version solving failed.


// You can try the following suggestion to make the pubspec resolve:
// * Try an upgrade of your constraints: flutter pub upgrade --major-versions
// exit code 1
