import 'package:appointnow/Pages/auth/login.dart';
import 'package:appointnow/Pages/hospital/doctorlistforappointments.dart';
import 'package:flutter/material.dart';
import 'package:appointnow/Pages/widgets/app_bottom_navigation_bar.dart';
import 'package:appointnow/Pages/hospital/add_doctor_page.dart';
import 'package:appointnow/Pages/hospital/doctor_list_for_hospital.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:appointnow/Pages/hospital/appointment_requests_page.dart';
import 'package:appointnow/Pages/hospital/add_assistant.dart';
import 'package:appointnow/Pages/assistant/assistant_profile.dart';


class AssistantHomePage extends StatefulWidget {
  const AssistantHomePage({super.key});

  @override
  State<AssistantHomePage> createState() => _AssistantHomePageState();
}

class _AssistantHomePageState extends State<AssistantHomePage> {
  int _currentIndex = 0;

  // Add state for hospital details
  String? _hospitalName;
  String? _hospitalLocation;
  String? _hospitalImageUrl;
  double? _hospitalRating;
  String? _hospitalDistance;
  String? _hospitalAbout; // <-- Add about field
  bool _isLoading = true;
  String? _hospitalId; // Store the fetched hospitalId

  @override
  void initState() {
    super.initState();
    _fetchHospitalDetails();
  }

  Future<void> _fetchHospitalDetails() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Step 1: Get assistant doc
      final assistantDoc = await FirebaseFirestore.instance
          .collection('assistants')
          .doc(user.uid)
          .get();
      final assistantData = assistantDoc.data();
      final hospitalId = assistantData?['hospitalId'];
      if (hospitalId != null && hospitalId.toString().isNotEmpty) {
        // Step 2: Get hospital details
        final doc = await FirebaseFirestore.instance
            .collection('hospitaldetails')
            .doc(hospitalId)
            .get();
        final data = doc.data();
        setState(() {
          _hospitalId = hospitalId;
          _hospitalName = data?['name'] ?? 'Hospital Name';
          _hospitalLocation = data?['location'] ?? 'Location';
          _hospitalImageUrl = data?['profileImageUrl'];
          _hospitalRating = (data?['rating'] is num)
              ? (data?['rating'] as num).toDouble()
              : 5.0;
          _hospitalDistance = data?['distance'] ?? '800m away';
          _hospitalAbout = data?['about'] ?? '';
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> items = [

      {"label": "Doctors list"},
      {"label": "Appointments"},
      // <-- Add this line
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

            // Appointments Request Card
            StreamBuilder<QuerySnapshot>(
              stream: (_hospitalId != null)
                  ? FirebaseFirestore.instance
                      .collection('serial')
                      .where('hospitalId', isEqualTo: _hospitalId)
                      .where('status', isEqualTo: 'pending')
                      .snapshots()
                  : const Stream.empty(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                final count = snapshot.hasData ? snapshot.data!.docs.length : 0;
                if (count == 0) return const SizedBox.shrink(); // Hide card if no requests
                return Card(
                  color: Colors.teal[50],
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  margin: const EdgeInsets.only(bottom: 20),
                  child: ListTile(
                    leading: const Icon(Icons.notifications_active,
                        color: Colors.teal, size: 36),
                    title: Text('Appointment Requests',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('You have $count appointment requests'),
                    trailing: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                      ),
                      onPressed: () {
                        if (_hospitalId != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AppointmentRequestsPage(
                                  hospitalId: _hospitalId!),
                            ),
                          );
                        }
                      },
                      child: const Text('View',
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                );
              },
            ),

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
                    if (label == "Add Assistant") {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => AddAssistantPage()),
                      );
                    }
                    if (label == "Doctors list") {
                      if (_hospitalId != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DoctorListForHospitalPage(
                                hospitalUid: _hospitalId!),
                          ),
                        );
                      }
                    }
                    if (label == "Appointments") {
                      if (_hospitalId != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                DoctorListForAppointmentsPage(
                                    hospitalUid: _hospitalId!),
                          ),
                        );
                      }
                    }
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
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const UserProfilePage()),
            );
          }
          // Add navigation logic for other tabs if needed
        },
      ),
    );
  }

  // Logout dialog and tile logic (mirroring hospital home)
  void showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            padding: const EdgeInsets.all(20),
            width: MediaQuery.of(context).size.width * 0.8,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.teal.withOpacity(0.1),
                  radius: 30,
                  child: const Icon(Icons.logout, size: 30, color: Colors.teal),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Are you sure to log out of your account?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.of(context).pop(); // Close the dialog
                    await FirebaseAuth.instance.signOut();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginPage()),
                      (route) => false, // Removes all previous routes
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 12),
                  ),
                  child: const Text("Log Out",
                      style: TextStyle(color: Colors.white)),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: const Text(
                    "Cancel",
                    style: TextStyle(color: Colors.teal, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildListTile(IconData icon, String title,
      {Color color = Colors.black, double iconSize = 24.0, Color? iconColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: MouseRegion(
        onEnter: (_) => setState(() {}),
        onExit: (_) => setState(() {}),
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24.0),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ListTile(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            leading: Container(
              width: 43.0,
              height: 43.0,
              decoration: BoxDecoration(
                color: const Color(0xFFE5F8F6),
                borderRadius: BorderRadius.circular(20.0),
              ),
              child: Icon(icon,
                  color: iconColor ?? const Color(0xFF00B5A2), size: iconSize),
            ),
            title: Text(title,
                style: TextStyle(fontWeight: FontWeight.normal, color: color)),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              if (title == 'Logout') {
                showLogoutDialog(context);
              }
            },
          ),
        ),
      ),
    );
  }
}
