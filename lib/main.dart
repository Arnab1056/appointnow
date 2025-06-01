import 'package:appointnow/Pages/Auth/register.dart';
import 'package:appointnow/pages/index/homepage.dart';
import 'package:appointnow/pages/index/screen01.dart'; // Add this import for Screen01
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        // initialRoute: '/register',
        // routes: {
        //   '/register': (context) => const RegisterPage(),
        //   '/login': (context) => LoginPage(),
        // },
        home: Screen01(),
        // Screen01()
        // RegisterSuccessScreen()
        // // Change this to Screen02() to test the second scree
        );
  }
}
