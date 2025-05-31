import 'package:flutter/material.dart';

class LoginSuccessScreen extends StatelessWidget {
  const LoginSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade200.withOpacity(0.8),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Login',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Check Icon
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey.shade100,
                  ),
                  padding: const EdgeInsets.all(20),
                  child: const Icon(Icons.check,
                      size: 40, color: Color(0xFF009688)),
                ),
                const SizedBox(height: 20),

                // Welcome Text
                const Text(
                  "Welcome Back",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 10),

                // Sub Text
                const Text(
                  "Once again you login successfully\ninto AppointNow app",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 25),

                // Go to home button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigate to home page
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF009688),
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      "Go to home",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
