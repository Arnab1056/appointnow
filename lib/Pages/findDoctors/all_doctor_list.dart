import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../Pages/doctor_details_pages/doctor_details.dart';

class AllDoctorListPage extends StatelessWidget {
  const AllDoctorListPage({super.key});

  Stream<QuerySnapshot> getDoctors() {
    return FirebaseFirestore.instance.collection('doctordetails').snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: const Text("All Doctors",
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
      body: StreamBuilder<QuerySnapshot>(
        stream: getDoctors(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No doctors found.'));
          }
          final doctors = snapshot.data!.docs;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: doctors.length,
            itemBuilder: (context, index) {
              final data = doctors[index].data() as Map<String, dynamic>;
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
                      final d = r.data() as Map<String, dynamic>;
                      sum += (d['rating'] ?? 0).toDouble();
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
                            doctor: {
                              ...data,
                              'avgRating': avgRating,
                              'totalRatings': totalRatings,
                            },
                            userName: FirebaseAuth
                                    .instance.currentUser?.displayName ??
                                '',
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
                            backgroundImage: data['profileImageUrl'] != null &&
                                    data['profileImageUrl'] != ''
                                ? NetworkImage(data['profileImageUrl'])
                                : (data['image'] != null && data['image'] != ''
                                        ? NetworkImage(data['image'])
                                        : const AssetImage(
                                            'assets/images/doctor1.jpg'))
                                    as ImageProvider,
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data['name'] ?? 'Doctor Name',
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  data['designation'] ?? '',
                                  style: const TextStyle(
                                      fontSize: 14, color: Colors.grey),
                                ),
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
                                      Text('($totalRatings)',
                                          style: const TextStyle(
                                              fontSize: 11,
                                              color: Colors.grey)),
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
    );
  }
}
