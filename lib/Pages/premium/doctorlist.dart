import 'package:appointnow/Pages/Profile/user_profile.dart';
import 'package:appointnow/Pages/widgets/app_bottom_navigation_bar.dart';
import 'package:appointnow/pages/index/homepage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:appointnow/Pages/doctor_details_pages/doctor_details.dart';

class PremiumDoctorListPage extends StatefulWidget {
  const PremiumDoctorListPage({Key? key}) : super(key: key);

  @override
  State<PremiumDoctorListPage> createState() => _PremiumDoctorListPageState();
}

class _PremiumDoctorListPageState extends State<PremiumDoctorListPage> {
  String searchQuery = '';

  Stream<QuerySnapshot> getDoctors() {
    return FirebaseFirestore.instance.collection('doctordetails').snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Get consultation',
            style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                hintText: 'Search doctor by name, designation, or hospital',
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: getDoctors(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No doctors found.'));
                }
                final doctors = snapshot.data!.docs.where((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  final q = searchQuery.toLowerCase();
                  return searchQuery.isEmpty ||
                      (data['name'] ?? '')
                          .toString()
                          .toLowerCase()
                          .contains(q) ||
                      (data['designation'] ?? '')
                          .toString()
                          .toLowerCase()
                          .contains(q) ||
                      (data['hospital'] ?? '')
                          .toString()
                          .toLowerCase()
                          .contains(q);
                }).toList();
                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: doctors.length,
                  itemBuilder: (context, index) {
                    final doctor =
                        doctors[index].data() as Map<String, dynamic>;
                    final docId = doctors[index].id;
                    return StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('doctordetails')
                          .doc(docId)
                          .collection('ratings')
                          .snapshots(),
                      builder: (context, ratingSnapshot) {
                        double avgRating = 0.0;
                        int totalRatings = 0;
                        if (ratingSnapshot.hasData &&
                            ratingSnapshot.data!.docs.isNotEmpty) {
                          final ratings = ratingSnapshot.data!.docs;
                          double sum = 0;
                          for (var r in ratings) {
                            final data = r.data() as Map<String, dynamic>;
                            sum += (data['rating'] ?? 0).toDouble();
                          }
                          avgRating = sum / ratings.length;
                          totalRatings = ratings.length;
                        }
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => DoctorDetailsPage(
                                  doctor: doctor,
                                  userName: '',
                                ),
                              ),
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 16),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  blurRadius: 6,
                                  color: Colors.grey.withOpacity(0.1),
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 40,
                                  backgroundImage: doctor['profileImageUrl'] !=
                                              null &&
                                          doctor['profileImageUrl'] != ''
                                      ? NetworkImage(doctor['profileImageUrl'])
                                      : (doctor['image'] != null &&
                                                  doctor['image'] != ''
                                              ? NetworkImage(doctor['image'])
                                              : const AssetImage(
                                                  'assets/images/doctor1.jpg'))
                                          as ImageProvider,
                                ),
                                const SizedBox(width: 20),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        doctor['name'] ?? '',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Text(
                                        doctor['designation'] ?? '',
                                        style: const TextStyle(
                                            fontSize: 12, color: Colors.grey),
                                      ),
                                      const SizedBox(height: 4),
                                      
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(Icons.star,
                                              size: 16, color: Colors.teal),
                                          const SizedBox(width: 4),
                                          Text(
                                            avgRating > 0
                                                ? avgRating.toStringAsFixed(1)
                                                : 'No rating',
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 13,
                                                color: Color(0xFF199A8E)),
                                          ),
                                          if (totalRatings > 0) ...[
                                            const SizedBox(width: 4),
                                            Text(
                                              '($totalRatings)',
                                              style: const TextStyle(
                                                  fontSize: 11,
                                                  color: Colors.grey),
                                            ),
                                          ]
                                        ],
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
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
