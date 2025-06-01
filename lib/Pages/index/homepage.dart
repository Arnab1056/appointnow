import 'package:appointnow/pages/user_profile/user_profile.dart';
import 'package:appointnow/pages/findDoctors/find_doctors.dart';
import 'package:flutter/material.dart';

// Converted the HomePage widget to a StatefulWidget
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0; // Added variable to track the current index

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Added background color
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Find Your desire',
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
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
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
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search Doctor, Hospitals, Ambulance...',
                  hintStyle: TextStyle(
                      color: Colors.grey), // Hint text color changed to black
                  prefixIcon: Icon(Icons.search,
                      color: Colors.grey), // Icon color changed to black
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24.0),
                    borderSide: BorderSide(color: Colors.teal),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24.0),
                    borderSide: BorderSide(color: Colors.teal),
                  ),
                ),
              ),
              SizedBox(height: 16.0),

              // Categories
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildCategoryCard('assets/icon/Doctor.png', 'Doctor'),
                  _buildCategoryCard('assets/icon/Pharmacy.png', 'Pharmacy'),
                  _buildCategoryCard('assets/icon/Hospital.png', 'Hospital'),
                  _buildCategoryCard('assets/icon/Ambulance.png', 'Ambulance'),
                ],
              ),
              SizedBox(height: 16.0),

              // Banner
              Container(
                padding: EdgeInsets.all(8.0),
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
                          Text(
                            'Early protection for your family health',
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                              color:
                                  Colors.black, // Text color changed to black
                            ),
                          ),
                          SizedBox(height: 20.0),
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Colors.teal, // Button color changed to teal
                            ),
                            child: Text('Learn more',
                                style: TextStyle(
                                    color: Colors
                                        .white)), // Text color changed to white
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 16.0),
                    Image.asset('assets/image.png',
                        width: 180.0, height: 180.0),
                    // Icon(Icons.health_and_safety,
                    //     size: 64.0,
                    //     color: Colors.teal), // Icon color changed to teal
                  ],
                ),
              ),
              SizedBox(height: 16.0),

              // Top Doctors
              _buildSectionHeader('Top Doctor', onViewAll: () {}),
              SizedBox(height: 8.0),
              _buildHorizontalList(
                  ['Dr. Marcus Horiz', 'Dr. Maria Elena', 'Dr. Stevi Jess']),

              // Top Hospitals
              SizedBox(height: 16.0),
              _buildSectionHeader('Top Hospitals', onViewAll: () {}),
              SizedBox(height: 8.0),
              _buildHorizontalList(['Hospital A', 'Hospital B', 'Hospital C']),

              // Top Ambulance Service
              SizedBox(height: 16.0),
              _buildSectionHeader('Top Ambulance Service', onViewAll: () {}),
              SizedBox(height: 8.0),
              _buildHorizontalList(
                  ['Ambulance A', 'Ambulance B', 'Ambulance C']),
            ],
          ),
        ),
      ),
      // Updated BottomNavigationBar to navigate to specific pages on tap
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex, // Set the current index
        selectedItemColor: Colors.teal, // Ensure selected item color is teal
        unselectedItemColor:
            Colors.grey, // Added unselected item color for visibility
        showUnselectedLabels:
            true, // Ensures labels are visible for unselected items
        backgroundColor:
            Colors.white, // Ensures labels are visible for unselected items
        type: BottomNavigationBarType
            .fixed, // Ensures equal spacing between items
        onTap: (index) {
          setState(() {
            _currentIndex = index; // Update the selected index
          });

          // Navigate to the specific page based on the selected index
          switch (index) {
            case 0:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),
              );
              break;
            // case 1:
            //   Navigator.push(
            //     context,
            //     MaterialPageRoute(builder: (context) => ChatPage()),
            //   );
            //   break;
            // case 2:
            //   Navigator.push(
            //     context,
            //     MaterialPageRoute(builder: (context) => AppointmentsPage()),
            //   );
            //   break;
            case 3:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => UserProfilePage()),
              );
              break;
            default:
              break;
          }
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
          BottomNavigationBarItem(icon: Icon(Icons.mail_outline), label: ''),
          BottomNavigationBarItem(
              icon: Icon(Icons.calendar_today),
              label: ''), // Appointment date icon
          BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(String iconPath, String label) {
    return GestureDetector(
      onTap: () {
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(builder: (context) => FindDoctorScreen()),
        // );
        // Handle card click
        print('$label card clicked');
      },
      child: Column(
        children: [
          Container(
            width: 60.0,
            height: 60.0,
            decoration: BoxDecoration(
              color: Colors.white, // Set background color to white
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: [
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
          SizedBox(height: 8.0),
          Text(label,
              style: TextStyle(
                  color: const Color.fromARGB(
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
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
            color: Colors.black, // Text color changed to black
          ),
        ),
        TextButton(
          onPressed: onViewAll,
          child: Text('See all',
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
            margin: EdgeInsets.only(right: 8.0),
            decoration: BoxDecoration(
              color: Colors.teal.withOpacity(
                  0.2), // Changed background color to teal with opacity
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Center(
              child: Text(
                items[index],
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.black), // Text color changed to black
              ),
            ),
          );
        },
      ),
    );
  }
}
