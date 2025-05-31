import 'package:appointnow/pages/index/screen02.dart';
import 'package:flutter/material.dart';

class Screen01 extends StatelessWidget {
  const Screen01({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF199A8E),
              Color(0xFF199A8E),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/logo.png', height: 180, width: 180),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      floatingActionButton: Align(
        alignment: Alignment.bottomRight,
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const Screen02()),
            ); // Navigate to next onboarding screen
          },
          backgroundColor: const Color(0xFF199A8E),
          child: const Icon(Icons.arrow_forward, color: Colors.white),
        ),
      ),
    );
  }
}
