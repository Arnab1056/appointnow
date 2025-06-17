import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AmbulanceListPage extends StatelessWidget {
  const AmbulanceListPage({super.key});

  Stream<QuerySnapshot> getAmbulances() {
    return FirebaseFirestore.instance
        .collection('ambulance_details')
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Ambulance List",
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
        stream: getAmbulances(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No ambulances found.'));
          }
          final ambulances = snapshot.data!.docs;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: ambulances.length,
            itemBuilder: (context, index) {
              final data = ambulances[index].data() as Map<String, dynamic>;
              final docId = ambulances[index].id;
              return StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('ambulance_details')
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
                    onLongPress: () async {
                      final user = FirebaseAuth.instance.currentUser;
                      if (user == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('You must be logged in to rate.')),
                        );
                        return;
                      }
                      double? selectedRating = await showDialog<double>(
                        context: context,
                        builder: (context) {
                          double tempRating = avgRating > 0 ? avgRating : 5.0;
                          return AlertDialog(
                            title: const Text('Rate this ambulance'),
                            content: StatefulBuilder(
                              builder: (context, setState) {
                                return Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: List.generate(5, (starIdx) {
                                        return IconButton(
                                          icon: Icon(
                                            tempRating >= starIdx + 1
                                                ? Icons.star
                                                : Icons.star_border,
                                            color: Colors.amber,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              tempRating =
                                                  (starIdx + 1).toDouble();
                                            });
                                          },
                                        );
                                      }),
                                    ),
                                    Text(
                                        'Your rating:  	${tempRating.toStringAsFixed(1)}'),
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
                                onPressed: () =>
                                    Navigator.pop(context, tempRating),
                                child: const Text('Submit'),
                              ),
                            ],
                          );
                        },
                      );
                      if (selectedRating != null) {
                        await FirebaseFirestore.instance
                            .collection('ambulance_details')
                            .doc(docId)
                            .collection('ratings')
                            .doc(user.uid)
                            .set({'rating': selectedRating});
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text('Thank you for rating!')),
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
                            backgroundImage: data['profileImageUrl'] != null &&
                                    data['profileImageUrl'] != ''
                                ? NetworkImage(data['profileImageUrl'])
                                : const AssetImage('assets/ambulance.jpg')
                                    as ImageProvider,
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  data['name'] ?? 'Ambulance Name',
                                  style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  data['hotline'] ?? '',
                                  style: const TextStyle(
                                      fontSize: 14, color: Colors.grey),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  data['location'] ?? '',
                                  style: const TextStyle(
                                      fontSize: 13, color: Colors.teal),
                                ),
                                const SizedBox(height: 6),
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
