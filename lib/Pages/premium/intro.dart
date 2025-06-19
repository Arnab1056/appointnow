import 'package:flutter/material.dart';
import 'plans.dart'; // Correct import for PremiumPlansPage

class PremiumIntroPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              SizedBox(height: 40
              ),
              // Logo
              Image.asset(
                'assets/no.png', // Fixed case to match asset
                height: 100,
              ),
              
              SizedBox(height: 100),

              // Feature Images
              Center(
                child: 
                Image.asset(
                  'assets/premium_intro.png', // Corrected asset path
                  height: 300,
                  fit: BoxFit.contain,
                ),
              ),

              SizedBox(height: 80),

              // Get Premium Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => PremiumPlansPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                    minimumSize: Size(double.infinity, 50),
                  ),
                  child: Text(
                    'Get Premium',
                    style: TextStyle(fontSize: 16,color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _phoneMockup(String imgPath, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Container(
            height: 300,
            width: 160,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(36),
              image: DecorationImage(
                image: AssetImage(imgPath),
                fit: BoxFit.cover,
              ),
              boxShadow: [
                BoxShadow(
                    color: Colors.black12, blurRadius: 10, offset: Offset(2, 4))
              ],
            ),
          ),
          SizedBox(height: 8),
          Text(label, style: TextStyle(color: Colors.grey[700])),
        ],
      ),
    );
  }
}
