import 'package:flutter/material.dart';

// Converted the HomePage widget to a StatefulWidget
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find your desire health solution',
            style:
                TextStyle(color: Colors.black)), // Text color changed to black
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
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search Doctor, Hospitals, Ambulance...',
                  hintStyle: const TextStyle(
                      color: Colors.grey), // Hint text color changed to black
                  prefixIcon: const Icon(Icons.search,
                      color: Colors.grey), // Icon color changed to black
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    borderSide: const BorderSide(color: Colors.teal),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20.0),
                    borderSide: const BorderSide(color: Colors.teal),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),

              // Categories
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildCategoryIcon(Icons.local_hospital, 'Doctor'),
                  _buildCategoryIcon(Icons.local_pharmacy, 'Pharmacy'),
                  _buildCategoryIcon(Icons.apartment, 'Hospital'),
                  _buildCategoryIcon(Icons.local_taxi, 'Ambulance'),
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
                          const Text(
                            'Early protection for your family health',
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.normal,
                              color:
                                  Colors.black, // Text color changed to black
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
                        width: 180.0, height: 180.0),
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
              _buildHorizontalList(['Hospital A', 'Hospital B', 'Hospital C']),

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
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.teal, // Changed selected item color to teal
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _buildCategoryIcon(IconData icon, String label) {
    return Column(
      children: [
        CircleAvatar(
          radius: 24.0,
          backgroundColor: Colors.teal, // Changed background color to teal
          child: Icon(icon,
              size: 24.0, color: Colors.white), // Icon color changed to white
        ),
        const SizedBox(height: 8.0),
        Text(label,
            style:
                const TextStyle(color: Colors.black)), // Text color changed to black
      ],
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
