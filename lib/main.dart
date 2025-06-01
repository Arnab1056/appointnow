import 'package:appointnow/Pages/Auth/login.dart';
// import 'package:appointnow/Pages/Auth/register.dart';
import 'package:appointnow/pages/user_profile/user_profile.dart';
import 'package:appointnow/pages/auth/login_success_screen.dart';
import 'package:appointnow/pages/auth/register.dart';
import 'package:appointnow/pages/auth/register_success_screen.dart';
import 'package:appointnow/pages/index/homepage.dart';
import 'package:appointnow/pages/index/screen01.dart';
import 'package:appointnow/pages/index/screen02.dart';
import 'package:appointnow/pages/index/screen03.dart';
import 'package:flutter/material.dart';

void main() {
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
        home:
            // UserProfilePage()
            HomePage()
        // Screen01()
        // RegisterSuccessScreen()
        // // Change this to Screen02() to test the second scree
        );
  }
}
