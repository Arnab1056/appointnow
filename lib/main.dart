import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:appointnow/Pages/doctor/doctor_home.dart' as doctor;
import 'package:appointnow/pages/index/homepage.dart' as user;
import 'package:appointnow/pages/index/screen01.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'firebase_options.dart';
import 'package:appointnow/Pages/hospital/hospital_home.dart' as hospital;
import 'package:appointnow/Pages/Laboratory/user-labreports.dart';
import 'package:appointnow/Pages/ambulance/ambulance_home.dart' as ambulance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await supabase.Supabase.initialize(
    url: 'https://ahxtqzjnvqevxuqxhlyz.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFoeHRxempudnFldnh1cXhobHl6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDkxMDE4MDIsImV4cCI6MjA2NDY3NzgwMn0.Q2I8jIn2pAZ-Y5pqscFMICNL4gESky5xidsjKSXDIcs',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        '/user-labreports': (context) => const UserLabReportsPage(),
      },
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.hasData && snapshot.data != null) {
            // Always fetch the role from Firestore on every app start
            return FutureBuilder<String?>(
              future: _getUserRole(snapshot.data!.uid),
              builder: (context, roleSnapshot) {
                if (roleSnapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }
                return _getHomePage(roleSnapshot.data);
              },
            );
          } else {
            return const Screen01();
          }
        },
      ),
    );
  }
}

Widget _getHomePage(String? role) {
  if (role != null && role.trim().toLowerCase() == 'doctor') {
    return const doctor.Doctorhome();
  } else if (role != null && role.trim().toLowerCase() == 'hospital') {
    return const hospital.HospitalHomePage();
  } else if (role != null && role.trim().toLowerCase() == 'ambulance') {
    return const ambulance.AmbulanceHomePage();
  } else {
    return const user.HomePage();
  }
}

// Helper function to get user role from Firestore
Future<String?> _getUserRole(String uid) async {
  final doc =
      await FirebaseFirestore.instance.collection('users').doc(uid).get();
  return doc.data()?['role'] as String?;
}
