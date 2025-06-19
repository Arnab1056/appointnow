import 'package:appointnow/Pages/assistant/assistant_profile.dart';
import 'package:appointnow/Pages/index/homepage.dart';
import 'package:appointnow/Pages/widgets/app_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';


class PremiumPlansPage extends StatelessWidget {
  final plans = [
    {
      'title': 'FREE',
      'price': '0.00 TK',
      'color': Colors.blue,
      'features': [true, false, false, false],
    },
    {
      'title': 'Yearly',
      'price': '360.00 TK',
      'color': Colors.deepOrange,
      'features': [true, true, true, true],
    },
    {
      'title': 'Monthly',
      'price': '30.00 TK',
      'color': Colors.teal,
      'features': [true, true, true, true],
    },
  ];

  final featureTitles = [
    "Offline Appointment Booking",
    "Online Consultation",
    "Realtime Messaging",
    "Video Call"
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: plans.map((plan) {
                return Container(
                  width: 260,
                  margin: EdgeInsets.all(8),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: Colors.black12, blurRadius: 10),
                    ],
                    color: Colors.white,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        plan['title'] as String,
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: (plan['color'] as Color).withOpacity(0.9),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            Text(
                              plan['price'] as String,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "/ month",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 15),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: List.generate(featureTitles.length, (index) {
                          bool enabled =
                              (plan['features'] as List<bool>)[index];
                          return ListTile(
                            dense: true,
                            leading: Icon(
                              enabled ? Icons.check_circle : Icons.cancel,
                              color: enabled ? Colors.green : Colors.grey,
                            ),
                            title: Text(
                              featureTitles[index],
                              style: TextStyle(
                                color: enabled ? Colors.black : Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                          );
                        }),
                      ),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          // Handle plan selection
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: plan['color'] as Color,
                          shape: StadiumBorder(),
                          padding: EdgeInsets.symmetric(
                              horizontal: 32, vertical: 12),
                        ),
                        child: Text(
                          "SELECT",
                          style: TextStyle(color: Colors.white, fontSize: 16),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNavigationBar(
        currentIndex: 2,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomePage()),
            );
          } else if (index == 2) {
            // Already on doctor list, do nothing or pop to root
          } else if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const UserProfilePage()),
            );
          }
        },
      ),
    );
  }
}
