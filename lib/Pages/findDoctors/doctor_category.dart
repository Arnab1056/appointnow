import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../Pages/doctor_details_pages/doctor_details.dart'; // Import the DoctorDetailsPage

class DoctorCategoryPage extends StatelessWidget {
  final String category;
  DoctorCategoryPage({super.key, required this.category});

  Stream<QuerySnapshot> getDoctorsByCategory() {
    return FirebaseFirestore.instance
        .collection('doctordetails')
        .where('designation', isEqualTo: category)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: Text(category,
            style: const TextStyle(
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
        stream: getDoctorsByCategory(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No doctors found for $category'));
          }
          final doctors = snapshot.data!.docs;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: doctors.length,
            itemBuilder: (context, index) {
              final doctor = doctors[index].data() as Map<String, dynamic>;
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
                            doctor: {
                              ...doctor,
                              'avgRating': avgRating,
                              'totalRatings': totalRatings,
                            },
                            userName: FirebaseAuth.instance.currentUser?.displayName ?? '',
                          ),
                        ),
                      );
                    },
                    onLongPress: () async {
                      final user = FirebaseAuth.instance.currentUser;
                      if (user == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('You must be logged in to rate.')),
                        );
                        return;
                      }
                      double? selectedRating = await showDialog<double>(
                        context: context,
                        builder: (context) {
                          double tempRating = avgRating > 0 ? avgRating : 5.0;
                          return AlertDialog(
                            title: const Text('Rate this doctor'),
                            content: StatefulBuilder(
                              builder: (context, setState) {
                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: List.generate(5, (starIdx) {
                                        return IconButton(
                                          icon: Icon(
                                            tempRating >= starIdx + 1 ? Icons.star : Icons.star_border,
                                            color: Colors.amber,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              tempRating = (starIdx + 1).toDouble();
                                            });
                                          },
                                        );
                                      }),
                                    ),
                                    Text('Your rating:  ${tempRating.toStringAsFixed(1)}'),
                                  ],
                                );
                              },
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context, tempRating),
                                child: const Text('Submit'),
                              ),
                            ],
                          );
                        },
                      );
                      if (selectedRating != null) {
                        await FirebaseFirestore.instance
                            .collection('doctordetails')
                            .doc(docId)
                            .collection('ratings')
                            .doc(user.uid)
                            .set({'rating': selectedRating});
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Thank you for rating!')),
                        );
                      }
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
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 5, vertical: 4),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      GestureDetector(
                                        onTap: () async {
                                          final user =
                                              FirebaseAuth.instance.currentUser;
                                          if (user == null) {
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                  content: Text(
                                                      'You must be logged in to rate.')),
                                            );
                                            return;
                                          }
                                          double? selectedRating =
                                              await showDialog<double>(
                                            context: context,
                                            builder: (context) {
                                              double tempRating = avgRating > 0
                                                  ? avgRating
                                                  : 5.0;
                                              return AlertDialog(
                                                title: const Text(
                                                    'Rate this doctor'),
                                                content: StatefulBuilder(
                                                  builder: (context, setState) {
                                                    return Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .center,
                                                          children:
                                                              List.generate(5,
                                                                  (starIdx) {
                                                            return IconButton(
                                                              icon: Icon(
                                                                tempRating >=
                                                                        starIdx +
                                                                            1
                                                                    ? Icons.star
                                                                    : Icons
                                                                        .star_border,
                                                                color: Colors
                                                                    .amber,
                                                              ),
                                                              onPressed: () {
                                                                setState(() {
                                                                  tempRating =
                                                                      (starIdx +
                                                                              1)
                                                                          .toDouble();
                                                                });
                                                              },
                                                            );
                                                          }),
                                                        ),
                                                        Text(
                                                            'Your rating: 	${tempRating.toStringAsFixed(1)}'),
                                                      ],
                                                    );
                                                  },
                                                ),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.pop(context),
                                                    child: const Text('Cancel'),
                                                  ),
                                                  ElevatedButton(
                                                    onPressed: () =>
                                                        Navigator.pop(context,
                                                            tempRating),
                                                    child: const Text('Submit'),
                                                  ),
                                                ],
                                              );
                                            },
                                          );
                                          if (selectedRating != null) {
                                            await FirebaseFirestore.instance
                                                .collection('doctordetails')
                                                .doc(docId)
                                                .collection('ratings')
                                                .doc(user.uid)
                                                .set(
                                                    {'rating': selectedRating});
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                  content: Text(
                                                      'Thank you for rating!')),
                                            );
                                          }
                                        },
                                        child: const Icon(Icons.star,
                                            size: 14, color: Colors.teal),
                                      ),
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
    );
  }
}