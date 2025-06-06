import 'package:flutter/material.dart';
import 'package:appointnow/Pages/widgets/app_bottom_navigation_bar.dart';
import 'package:appointnow/Pages/hospital/hospitalprofile.dart';
import 'package:appointnow/Pages/hospital/add_doctor_page.dart'; // Import AddDoctorPage from the correct path
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HospitalHomePage extends StatefulWidget {
  const HospitalHomePage({super.key});

  @override
  State<HospitalHomePage> createState() => _HospitalHomePageState();
}

class _HospitalHomePageState extends State<HospitalHomePage> {
  int _currentIndex = 0;

  // Add state for hospital details
  String? _hospitalName;
  String? _hospitalLocation;
  String? _hospitalImageUrl;
  double? _hospitalRating;
  String? _hospitalDistance;
  String? _hospitalAbout; // <-- Add about field
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchHospitalDetails();
  }

  Future<void> _fetchHospitalDetails() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('hospitaldetails')
          .doc(user.uid)
          .get();
      final data = doc.data();
      setState(() {
        _hospitalName = data?['name'] ?? 'Hospital Name';
        _hospitalLocation = data?['location'] ?? 'Location';
        _hospitalImageUrl = data?['profileImageUrl'];
        _hospitalRating = (data?['rating'] is num)
            ? (data?['rating'] as num).toDouble()
            : 5.0;
        _hospitalDistance = data?['distance'] ?? '800m away';
        _hospitalAbout = data?['about'] ?? ''; // <-- Fetch about
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> items = [
      {"label": "Add Doctor"},
      {"label": "Add Assistant"},
      {"label": "Add Laboratory"},
      {"label": "Assistant list"},
      {"label": "Doctors list"},
      {"label": "Laboratory list"},
      {"label": "Lab Reports"},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Home", style: TextStyle(color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Hospital Card
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : Row(
                        children: [
                          _hospitalImageUrl != null &&
                                  _hospitalImageUrl!.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(40),
                                  child: Image.network(
                                    _hospitalImageUrl!,
                                    width: 80,
                                    height: 80,
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : const CircleAvatar(
                                  radius: 40,
                                  backgroundColor: Color(0xFFE0F2F1),
                                  child: Icon(Icons.local_hospital,
                                      color: Colors.teal, size: 40),
                                ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _hospitalName ?? 'Hospital Name',
                                  style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _hospitalLocation ?? 'Location',
                                  style: const TextStyle(color: Colors.grey),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(Icons.star,
                                        size: 16, color: Colors.teal),
                                    const SizedBox(width: 4),
                                    Text(
                                      (_hospitalRating?.toStringAsFixed(1) ??
                                          '5.0'),
                                      style:
                                          const TextStyle(color: Colors.teal),
                                    ),
                                    const SizedBox(width: 12),
                                    const Icon(Icons.location_on,
                                        size: 16, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Text(
                                      _hospitalDistance ?? '800m away',
                                      style:
                                          const TextStyle(color: Colors.grey),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          )
                        ],
                      ),
              ),
            ),

            const SizedBox(height: 20),

            // About Section
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'About',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                Text(
                  'Read more',
                  style: TextStyle(color: Colors.teal),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Text(
                    (_hospitalAbout != null && _hospitalAbout!.isNotEmpty)
                        ? _hospitalAbout!
                        : 'No description available.',
                    style: const TextStyle(color: Colors.grey),
                  ),

            const SizedBox(height: 20),

            // Action Grid
            GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: items.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.9,
              ),
              itemBuilder: (context, index) {
                final label = items[index]['label']!;
                return GestureDetector(
                  onTap: () {
                    if (label == "Add Doctor") {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const AddDoctorPage()),
                      );
                    }
                    // Navigate or handle tap for other items
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.medical_services_outlined,
                            size: 32, color: Colors.teal),
                        const SizedBox(height: 10),
                        Text(
                          items[index]['label']!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == _currentIndex) return;
          setState(() {
            _currentIndex = index;
          });
          if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const HospitalProfilePage()),
            );
          }
          // Add navigation logic for other tabs if needed
        },
      ),
    );
  }
}
