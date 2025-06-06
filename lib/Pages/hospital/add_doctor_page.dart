import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../hospital/appointment_time.dart'; // Import the ScheduleTimePage from the correct file

class AddDoctorPage extends StatefulWidget {
  const AddDoctorPage({super.key});

  @override
  State<AddDoctorPage> createState() => _AddDoctorPageState();
}

class _AddDoctorPageState extends State<AddDoctorPage> {
  String _searchText = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // <-- Set background color to white
      appBar: AppBar(
        title: const Text('Add Doctor', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: TextField(
              
              decoration: InputDecoration(
                
                hintText: 'Search by name or designation',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24.0),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchText = value.trim().toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('doctordetails')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No doctors found'));
                }
                List<Map<String, dynamic>> doctors =
                    snapshot.data!.docs.map((doc) {
                  final data = doc.data() as Map<String, dynamic>;
                  data['id'] = doc.id;
                  return data;
                }).toList();

                // Sort by rating (descending)
                doctors.sort((a, b) {
                  double ratingA = (a['rating'] is num)
                      ? (a['rating'] as num).toDouble()
                      : 0.0;
                  double ratingB = (b['rating'] is num)
                      ? (b['rating'] as num).toDouble()
                      : 0.0;
                  return ratingB.compareTo(ratingA);
                });

                // Filter by search text
                if (_searchText.isNotEmpty) {
                  doctors = doctors.where((doc) {
                    final name = (doc['name'] ?? '').toString().toLowerCase();
                    final designation =
                        (doc['designation'] ?? '').toString().toLowerCase();
                    return name.contains(_searchText) ||
                        designation.contains(_searchText);
                  }).toList();
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: doctors.length,
                  itemBuilder: (context, index) {
                    final doctor = doctors[index];
                    return StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('doctordetails')
                          .doc(doctor['id'])
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
                        return Container(
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
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      ScheduleTimePage(doctor: doctor),
                                ),
                              );
                            },
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 40,
                                  backgroundImage: doctor['profileImageUrl'] !=
                                              null &&
                                          doctor['profileImageUrl'] != ''
                                      ? NetworkImage(doctor['profileImageUrl'])
                                          as ImageProvider
                                      : (doctor['image'] != null &&
                                              doctor['image'] != ''
                                          ? NetworkImage(doctor['image'])
                                              as ImageProvider
                                          : const AssetImage(
                                              'assets/images/doctor1.jpg')),
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
                                      Container(
                                        decoration: BoxDecoration(
                                          color: Colors.teal.withOpacity(0.1),
                                          borderRadius:
                                              BorderRadius.circular(2),
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 5, vertical: 4),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Icon(Icons.star,
                                                size: 14, color: Colors.teal),
                                            const SizedBox(width: 2),
                                            Text(
                                              avgRating > 0
                                                  ? avgRating.toStringAsFixed(1)
                                                  : 'No rating',
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                                color: Color(0xFF199A8E),
                                              ),
                                            ),
                                            if (totalRatings > 0) ...[
                                              const SizedBox(width: 4),
                                              Text('($totalRatings)',
                                                  style: const TextStyle(
                                                      fontSize: 10,
                                                      color: Colors.grey)),
                                            ]
                                          ],
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(Icons.location_on,
                                              size: 14, color: Colors.grey),
                                          const SizedBox(width: 4),
                                          Text(
                                            doctor['hospital'] ?? '',
                                            style: const TextStyle(
                                              fontSize: 12,
                                              color: Colors.black,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
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
    );
  }
}
