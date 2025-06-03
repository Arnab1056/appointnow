import 'package:appointnow/Pages/Auth/register.dart';
import 'package:appointnow/pages/doctor_details_pages/appointment.dart';
import 'package:appointnow/pages/doctor_details_pages/doctor_details.dart';
import 'package:appointnow/pages/findDoctors/find_doctors.dart';
import 'package:appointnow/pages/index/homepage.dart';
import 'package:appointnow/pages/index/screen01.dart'; // Add this import for Screen01
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
        debugShowCheckedModeBanner: false, home: AppointmentPage()
        // DoctorDetailsPage()
        // FindDoctorsPage()
        // StreamBuilder<User?>(
        //   stream: FirebaseAuth.instance.authStateChanges(),
        //   builder: (context, snapshot) {
        //     if (snapshot.connectionState == ConnectionState.waiting) {
        //       return const Scaffold(
        //         body: Center(child: CircularProgressIndicator()),
        //       );
        //     }
        //     if (snapshot.hasData && snapshot.data != null) {
        //       // User is logged in
        //       return HomePage();
        //     } else {
        //       // User is not logged in
        //       return Screen01();
        //     }
        //   },
        // ),
        // Removed the invalid reference to FindDoctorsPage
        );
  }
}
