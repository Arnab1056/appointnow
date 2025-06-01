// import 'package:appointnow/Pages/Auth/login.dart';
// import 'package:appointnow/Pages/Auth/register.dart';
import 'package:appointnow/pages/index/homepage.dart';
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
        home: HomePage()
        // Screen01()
        // RegisterSuccessScreen()
        // // Change this to Screen02() to test the second scree
        );
  }
}
