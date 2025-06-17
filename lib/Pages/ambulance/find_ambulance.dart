import 'package:appointnow/Pages/ambulance/ambulance_booking.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FindAmbulancePage extends StatefulWidget {
  const FindAmbulancePage({Key? key}) : super(key: key);

  @override
  State<FindAmbulancePage> createState() => _FindAmbulancePageState();
}

class _FindAmbulancePageState extends State<FindAmbulancePage> {
  String selectedCategory = 'All';
  final List<String> ambulanceCategories = [
    'All',
    'Basic',
    'ICU',
    'AC',
    'Non-AC',
    'Freezer',
    'Patient Transport',
    'Other',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          "Find Ambulance",
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          // Category selector
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: ambulanceCategories.map((cat) {
                final isSelected = selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: ChoiceChip(
                    label: Text(cat),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() {
                        selectedCategory = cat;
                      });
                    },
                    selectedColor: Colors.teal,
                    backgroundColor: Colors.grey[200],
                    labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.black),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: selectedCategory == 'All'
                  ? FirebaseFirestore.instance
                      .collection('ambulance_details')
                      .snapshots()
                  : FirebaseFirestore.instance
                      .collection('ambulance_details')
                      .where('category', isEqualTo: selectedCategory)
                      .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No ambulances found.'));
                }
                final ambulances = snapshot.data!.docs;
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: ambulances.length,
                  itemBuilder: (context, index) {
                    final data =
                        ambulances[index].data() as Map<String, dynamic>;
                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        leading: CircleAvatar(
                          radius: 32,
                          backgroundImage: data['profileImageUrl'] != null &&
                                  data['profileImageUrl'] != ''
                              ? NetworkImage(data['profileImageUrl'])
                              : const AssetImage('assets/ambulance.jpg')
                                  as ImageProvider,
                        ),
                        title: Text(data['name'] ?? 'Ambulance Name',
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(data['location'] ?? '',
                                style: const TextStyle(color: Colors.grey)),
                            Text(data['hotline'] ?? '',
                                style: const TextStyle(color: Colors.teal)),
                            Text(data['category'] ?? '',
                                style: const TextStyle(fontSize: 12)),
                          ],
                        ),
                        onTap: () async {
                          // Optionally, fetch ratings if needed
                          double avgRating = 0.0;
                          int totalRatings = 0;
                          final ratingsSnap = await FirebaseFirestore.instance
                              .collection('ambulance_details')
                              .doc(ambulances[index].id)
                              .collection('ratings')
                              .get();
                          if (ratingsSnap.docs.isNotEmpty) {
                            double sum = 0;
                            for (var r in ratingsSnap.docs) {
                              final d = r.data();
                              sum += (d['rating'] ?? 0).toDouble();
                            }
                            avgRating = sum / ratingsSnap.docs.length;
                            totalRatings = ratingsSnap.docs.length;
                          }
                          final dataWithUid = Map<String, dynamic>.from(data);
                          dataWithUid['id'] = ambulances[index].id;
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AmbulanceBookingPage(
                                ambulanceData: dataWithUid,
                                avgRating: avgRating,
                                totalRatings: totalRatings,
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
          ),
        ],
      ),
    );
  }
}
