import 'package:appointnow/pages/Profile/user_profile.dart';
import 'package:appointnow/pages/findDoctors/find_doctors.dart';
import 'package:appointnow/Pages/widgets/app_bottom_navigation_bar.dart';
// Make sure the path above is correct and the file 'app_bottom_navigation_bar.dart' defines 'AppBottomNavigationBar'
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Converted the HomePage widget to a StatefulWidget
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0; // Added variable to track the current index

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Minimize the app (go to phone's home screen) instead of navigating back
        SystemNavigator.pop();
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.white, // Added background color
        appBar: AppBar(
          automaticallyImplyLeading: false, // Remove the top back button
          title: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Find your desire',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 22.0,
                          fontWeight: FontWeight.w500),
                    ),
                    Text(
                      'health solution',
                      style: TextStyle(
                          color: Colors.black,
                          fontSize: 22.0,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
            ],
          ),
          backgroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications),
              onPressed: () {},
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Bar
                SizedBox(
                  height: 40.0, // Set a shorter height for the search bar
                  child: TextField(
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 0, horizontal: 16),
                      hintText: 'Search Doctor, Hospitals, Ambulance...',
                      hintStyle: const TextStyle(
                          color:
                              Colors.grey), // Hint text color changed to black
                      prefixIcon: const Icon(Icons.search,
                          color: Colors.grey), // Icon color changed to black
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24.0),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24.0),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),

                // Categories
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildCategoryCard('assets/icon/Doctor.png', 'Doctor'),
                    _buildCategoryCard('assets/icon/Pharmacy.png', 'Pharmacy'),
                    _buildCategoryCard('assets/icon/Hospital.png', 'Hospital'),
                    _buildCategoryCard(
                        'assets/icon/Ambulance.png', 'Ambulance'),
                  ],
                ),
                const SizedBox(height: 16.0),

                // Banner
                Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.teal.withOpacity(
                        0.2), // Changed background color to teal with opacity
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                'Early protection for your family health',
                                style: TextStyle(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors
                                      .black, // Text color changed to black
                                ),
                              ),
                            ),
                            const SizedBox(height: 20.0),
                            ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Colors.teal, // Button color changed to teal
                              ),
                              child: const Text('Learn more',
                                  style: TextStyle(
                                      color: Colors
                                          .white)), // Text color changed to white
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16.0),
                      Image.asset('assets/image.png',
                          width: 120.0, height: 120.0),
                      // Icon(Icons.health_and_safety,
                      //     size: 64.0,
                      //     color: Colors.teal), // Icon color changed to teal
                    ],
                  ),
                ),
                const SizedBox(height: 16.0),

                // Top Doctors
                _buildSectionHeader('Top Doctor', onViewAll: () {}),
                const SizedBox(height: 8.0),
                _buildHorizontalList(
                    ['Dr. Marcus Horiz', 'Dr. Maria Elena', 'Dr. Stevi Jess']),

                // Top Hospitals
                const SizedBox(height: 16.0),
                _buildSectionHeader('Top Hospitals', onViewAll: () {}),
                const SizedBox(height: 8.0),
                _buildHorizontalList(
                    ['Hospital A', 'Hospital B', 'Hospital C']),

                // Top Ambulance Service
                const SizedBox(height: 16.0),
                _buildSectionHeader('Top Ambulance Service', onViewAll: () {}),
                const SizedBox(height: 8.0),
                _buildHorizontalList(
                    ['Ambulance A', 'Ambulance B', 'Ambulance C']),
              ],
            ),
          ),
        ),
        // Updated BottomNavigationBar to ensure equal spacing between items
        bottomNavigationBar: AppBottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });

            switch (index) {
              case 0:
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const HomePage()),
                );
                break;
              case 3:
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const UserProfilePage()),
                );
                break;
              default:
                break;
            }
          },
        ),
      ),
    );
  }

  Widget _buildCategoryCard(String iconPath, String label) {
    return GestureDetector(
      onTap: () {
        if (label == 'Doctor') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const FindDoctorsPage()),
          );
        } else {
          // Handle other card clicks if needed
        }
      },
      child: Column(
        children: [
          Container(
            width: 60.0,
            height: 60.0,
            decoration: BoxDecoration(
              color: Colors.white, // Set background color to white
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: const [
                BoxShadow(
                  color: Colors.white,
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 3), // changes position of shadow
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset(iconPath,
                  width: 32.0, height: 32.0), // Fixed image size to 32x32
            ),
          ),
          const SizedBox(height: 8.0),
          Text(label,
              style: const TextStyle(
                  color: Color.fromARGB(
                      255, 103, 102, 102))), // Text color set to black
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, {required VoidCallback onViewAll}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            color: Colors.black, // Text color changed to black
          ),
        ),
        TextButton(
          onPressed: onViewAll,
          child: const Text('See all',
              style: TextStyle(
                  color: Colors.teal)), // Button text color changed to black
        ),
      ],
    );
  }

  Widget _buildHorizontalList(List<String> items) {
    return SizedBox(
      height: 120.0,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        itemBuilder: (context, index) {
          return Container(
            width: 100.0,
            margin: const EdgeInsets.only(right: 8.0),
            decoration: BoxDecoration(
              color: Colors.teal.withOpacity(
                  0.2), // Changed background color to teal with opacity
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Center(
              child: Text(
                items[index],
                textAlign: TextAlign.center,
                style: const TextStyle(
                    color: Colors.black), // Text color changed to black
              ),
            ),
          );
        },
      ),
    );
  }
}
