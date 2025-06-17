import 'package:appointnow/Pages/ambulance/ambulance_profile.dart';
import 'package:appointnow/pages/findDoctors/find_doctors.dart';
import 'package:appointnow/Pages/widgets/app_bottom_navigation_bar.dart';
import 'package:appointnow/Pages/doctor_details_pages/doctor_details.dart'; // <-- Add this import
import 'package:appointnow/Pages/findDoctors/hospitallist.dart'; // Add this import
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Converted the HomePage widget to a StatefulWidget
class AmbulanceHomePage extends StatefulWidget {
  const AmbulanceHomePage({super.key});

  @override
  _AmbulanceHomePageState createState() => _AmbulanceHomePageState();
}

class _AmbulanceHomePageState extends State<AmbulanceHomePage> {
  int _currentIndex = 0; // Added variable to track the current index
  String? _userName;

  @override
  void initState() {
    super.initState();
    _fetchUserName();
  }

  Future<void> _fetchUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      setState(() {
        _userName = doc.data()?['name'] ?? 'No Name';
      });
    }
  }

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
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('doctordetails')
                      .snapshots(),
                  builder: (context, doctorSnapshot) {
                    if (doctorSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final allDocs = doctorSnapshot.data?.docs ?? [];
                    return FutureBuilder<List<Map<String, dynamic>>>(
                      future: Future.wait(allDocs.map((doc) async {
                        final ratingsSnap = await FirebaseFirestore.instance
                            .collection('doctordetails')
                            .doc(doc.id)
                            .collection('ratings')
                            .get();
                        double avg = 0.0;
                        if (ratingsSnap.docs.isNotEmpty) {
                          double sum = 0;
                          for (var r in ratingsSnap.docs) {
                            final data = r.data();
                            sum += (data['rating'] ?? 0).toDouble();
                          }
                          avg = sum / ratingsSnap.docs.length;
                        }
                        return {
                          ...doc.data() as Map<String, dynamic>,
                          'avgRating': avg,
                          'id': doc.id,
                          'totalRatings': ratingsSnap.docs.length,
                        };
                      }).toList()),
                      builder: (context, ratingSnapshot) {
                        if (!ratingSnapshot.hasData ||
                            ratingSnapshot.data!.isEmpty) {
                          return const Text("No top doctors found");
                        }
                        final sorted = List<Map<String, dynamic>>.from(
                            ratingSnapshot.data!);
                        sorted.sort((a, b) => (b['avgRating'] as double)
                            .compareTo(a['avgRating'] as double));
                        final topDoctors = sorted.take(5).toList();
                        return SizedBox(
                          height: 170.0,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: topDoctors.length,
                            separatorBuilder: (context, idx) =>
                                const SizedBox(width: 12),
                            itemBuilder: (context, idx) {
                              final doc = topDoctors[idx];
                              return InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => DoctorDetailsPage(
                                        doctor: doc,
                                        userName: _userName ?? '',
                                      ),
                                    ),
                                  );
                                },
                                child: Container(
                                  width:
                                      140.0, // Reduced width to prevent overflow
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 4.0),
                                  padding: const EdgeInsets.all(
                                      10.0), // Slightly reduced padding
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16.0),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.15),
                                        blurRadius: 6,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      CircleAvatar(
                                        radius: 28, // Slightly smaller avatar
                                        key: ValueKey(
                                            '${doc['profileImageUrl'] ?? ''}_${DateTime.now().millisecondsSinceEpoch}_${doc['id']}'), // Unique key to force refresh
                                        backgroundColor: Colors.grey[200],
                                        backgroundImage: (doc[
                                                        'profileImageUrl'] !=
                                                    null &&
                                                doc['profileImageUrl']
                                                    .toString()
                                                    .isNotEmpty)
                                            ? NetworkImage(
                                                doc['profileImageUrl'])
                                            : (doc['image'] != null &&
                                                        doc['image']
                                                            .toString()
                                                            .isNotEmpty
                                                    ? NetworkImage(doc['image'])
                                                    : const AssetImage(
                                                        'assets/images/doctor1.jpg'))
                                                as ImageProvider,
                                        onBackgroundImageError: (_, __) {},
                                      ),
                                      const SizedBox(height: 6),
                                      Text(doc['name'] ?? '',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 13)),
                                      Text(doc['designation'] ?? '',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey)),
                                      const SizedBox(height: 2),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(Icons.star,
                                              size: 13,
                                              color: Color(0xFF199A8E)),
                                          const SizedBox(width: 2),
                                          Text(
                                            doc['avgRating'] > 0
                                                ? doc['avgRating']
                                                    .toStringAsFixed(1)
                                                : 'No rating',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 11,
                                              color: Color(0xFF199A8E),
                                            ),
                                          ),
                                          if (doc['totalRatings'] > 0) ...[
                                            const SizedBox(width: 2),
                                            Text('(${doc['totalRatings']})',
                                                style: const TextStyle(
                                                    fontSize: 9,
                                                    color: Colors.grey)),
                                          ]
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    );
                  },
                ),

                // Top Hospitals
                const SizedBox(height: 16.0),
                _buildSectionHeader('Top Hospitals', onViewAll: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          HospitallistPage(category: 'hospital'),
                    ),
                  );
                }),
                const SizedBox(height: 8.0),
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('hospitaldetails')
                      .orderBy('rating', descending: true)
                      .limit(5)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Text("No top hospitals found");
                    }
                    final hospitals = snapshot.data!.docs;
                    return SizedBox(
                      height: 160,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: hospitals.length,
                        separatorBuilder: (context, idx) =>
                            const SizedBox(width: 12),
                        itemBuilder: (context, idx) {
                          final hospital =
                              hospitals[idx].data() as Map<String, dynamic>;
                          return Container(
                            width: 140,
                            margin: const EdgeInsets.symmetric(vertical: 4.0),
                            padding: const EdgeInsets.all(10.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.withOpacity(0.15),
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                CircleAvatar(
                                  radius: 28,
                                  backgroundColor: Colors.grey[200],
                                  backgroundImage:
                                      (hospital['profileImageUrl'] != null &&
                                              hospital['profileImageUrl']
                                                  .toString()
                                                  .isNotEmpty)
                                          ? NetworkImage(
                                              hospital['profileImageUrl'])
                                          : const AssetImage(
                                                  'assets/hospital.jpg')
                                              as ImageProvider,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  hospital['name'] ?? '',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13),
                                ),
                                Text(
                                  hospital['location'] ?? '',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      fontSize: 11, color: Colors.grey),
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.star,
                                        size: 13, color: Color(0xFF199A8E)),
                                    const SizedBox(width: 2),
                                    Text(
                                      hospital['rating'] != null
                                          ? (hospital['rating'] is num
                                              ? hospital['rating']
                                                  .toStringAsFixed(1)
                                              : hospital['rating'].toString())
                                          : 'No rating',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11,
                                        color: Color(0xFF199A8E),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),

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
                  MaterialPageRoute(
                      builder: (context) => const AmbulanceHomePage()),
                );
                break;
              case 3:
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const AmbulanceProfilePage()),
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
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(8.0),
        onTap: () {
          if (label == 'Doctor') {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const FindDoctorsPage()),
            );
          } else if (label == 'Hospital') {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HospitallistPage(category: 'hospital'),
              ),
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
