import 'package:appointnow/pages/index/homepage.dart';
import 'package:appointnow/pages/index/screen01.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await supabase.Supabase.initialize(
    url: 'https://ahxtqzjnvqevxuqxhlyz.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImFoeHRxempudnFldnh1cXhobHl6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDkxMDE4MDIsImV4cCI6MjA2NDY3NzgwMn0.Q2I8jIn2pAZ-Y5pqscFMICNL4gESky5xidsjKSXDIcs',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.hasData && snapshot.data != null) {
            // User is logged in
            return const HomePage();
          } else {
            // User is not logged in
            return const Screen01();
          }
        },
      ),
    );
  }
}
