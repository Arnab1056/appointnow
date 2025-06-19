import 'package:appointnow/Pages/assistant/assistant_profile.dart';
import 'package:appointnow/Pages/index/homepage.dart';
import 'package:appointnow/Pages/widgets/app_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class PremiumPlansPage extends StatefulWidget {
  @override
  _PremiumPlansPageState createState() => _PremiumPlansPageState();
}

class _PremiumPlansPageState extends State<PremiumPlansPage> {
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

  int selectedIndex = 0;
  late final PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController =
        PageController(viewportFraction: 0.75, initialPage: selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SizedBox(
          height: 500,
          child: PageView.builder(
            controller: _pageController,
            itemCount: plans.length,
            onPageChanged: (index) {
              setState(() {
                selectedIndex = index;
              });
            },
            itemBuilder: (context, i) {
              final plan = plans[i];
              final isSelected = selectedIndex == i;
              return AnimatedScale(
                scale: isSelected ? 1.1 : 0.9,
                duration: Duration(milliseconds: 350),
                curve: Curves.easeInOut,
                child: GestureDetector(
                  onTap: () {
                    _pageController.animateToPage(
                      i,
                      duration: Duration(milliseconds: 350),
                      curve: Curves.easeInOut,
                    );
                  },
                  child: Container(
                    width: 260,
                    margin: EdgeInsets.symmetric(horizontal: 12, vertical: 32),
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: Colors.black12, blurRadius: 10),
                      ],
                      color: Colors.white,
                      border: isSelected
                          ? Border.all(color: plan['color'] as Color, width: 2)
                          : null,
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
                                style: TextStyle(
                                    color: Colors.white, fontSize: 15),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children:
                              List.generate(featureTitles.length, (index) {
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
                          child: Text("SELECT",
                              style:
                                  TextStyle(color: Colors.white, fontSize: 16)),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
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
