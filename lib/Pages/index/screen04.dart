import 'package:appointnow/pages/index/screen05.dart';
import 'package:flutter/material.dart';

class Screen04 extends StatelessWidget {
  const Screen04({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // Back Arrow Button
                  Row(
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () {
                            Navigator.pop(
                                context); // Goes back to previous screen
                          },
                        ),
                      ),
                      const Spacer(),
                      // Skip button
                      Align(
                        alignment: Alignment.topRight,
                        child: TextButton(
                          onPressed: () {
                            // Skip action
                          },
                          child: const Text("Skip"),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Doctor Image
                  Expanded(
                    child: Image.asset(
                      'assets/MaleDoctor.webP',
                      fit: BoxFit.contain,
                      // height: 300,
                      // width: 300,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Bottom Card
                  Container(
                    padding: const EdgeInsets.all(20),
                    margin: const EdgeInsets.only(bottom: 30),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F7FA),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      children: [
                        // Text content
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Get connect our online consultation",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              SizedBox(height: 10),
                              // Dots indicator
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 4,
                                    backgroundColor: Colors.grey,
                                  ),
                                  SizedBox(width: 6),
                                  CircleAvatar(
                                    radius: 4,
                                    backgroundColor: Colors.grey,
                                  ),
                                  SizedBox(width: 6),
                                  CircleAvatar(
                                    radius: 4,
                                    backgroundColor: Colors.teal,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),

                        // Next button
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: Colors.teal,
                          child: IconButton(
                            icon: const Icon(Icons.arrow_forward,
                                color: Colors.white),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const Screen05()),
                              ); // Navigate to next onboarding screen
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
