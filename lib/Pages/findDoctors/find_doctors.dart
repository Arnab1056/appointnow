import 'package:appointnow/Pages/doctor_details_pages/doctor_details.dart';
import 'package:appointnow/Pages/findDoctors/doctor_list_page.dart';
import 'package:appointnow/pages/index/homepage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';


class FindDoctorsPage extends StatefulWidget {
  const FindDoctorsPage({super.key});

  @override
  State<FindDoctorsPage> createState() => _FindDoctorsPageState();
}

class _FindDoctorsPageState extends State<FindDoctorsPage> {
  bool showAllCategories = false;
  String searchQuery = '';

  final List<Map<String, String>> categories = [
    {"label": "General", "icon": "assets/icon/Doctor.png"},
    {"label": "Lungs", "icon": "assets/icon/lungs.png"},
    {"label": "Dentist", "icon": "assets/icon/dentist.png"},
    {"label": "Psychiatrist", "icon": "assets/icon/neuron.png"},
    {"label": "Covid-19", "icon": "assets/icon/alargy.png"},
    {"label": "Surgeon", "icon": "assets/icon/surgeon.png"},
    {"label": "Cardiologist", "icon": "assets/icon/cardiologist.png"},
    {"label": "Allergy", "icon": "assets/icon/alargy.png"},
    {"label": "Neurologist", "icon": "assets/icon/neuron.png"},
    {"label": "Orthopedic", "icon": "assets/icon/surgeon.png"},
    {"label": "Pediatrician", "icon": "assets/icon/Doctor.png"},
    {"label": "Dermatologist", "icon": "assets/icon/Doctor.png"},
    {"label": "ENT", "icon": "assets/icon/Doctor.png"},
    {"label": "Ophthalmologist", "icon": "assets/icon/Doctor.png"},
    {"label": "Gynecologist", "icon": "assets/icon/Doctor.png"},
    {"label": "Urologist", "icon": "assets/icon/Doctor.png"},
    {"label": "Oncologist", "icon": "assets/icon/Doctor.png"},
    {"label": "Nephrologist", "icon": "assets/icon/Doctor.png"},
    {"label": "Gastroenterologist", "icon": "assets/icon/Doctor.png"},
    {"label": "Endocrinologist", "icon": "assets/icon/Doctor.png"},
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
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        const HomePage())); // Navigate to the previous page
          },
        ),
        centerTitle: true, // Center the title properly
        title: const Text(
          "Find Doctors ",
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ),
      body: SafeArea(
        child: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('doctordetails')
              .snapshots(),
          builder: (context, doctorSnapshot) {
            // Filter doctors based on search query
            final allDocs = doctorSnapshot.data?.docs ?? [];
            final filteredDocs = searchQuery.isEmpty
                ? allDocs
                : allDocs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final name = (data['name'] ?? '').toString().toLowerCase();
                    final designation =
                        (data['designation'] ?? '').toString().toLowerCase();
                    final hospital =
                        (data['hospital'] ?? '').toString().toLowerCase();
                    final q = searchQuery.toLowerCase();
                    return name.contains(q) ||
                        designation.contains(q) ||
                        hospital.contains(q);
                  }).toList();
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  // Search Bar (match HomePage style)
                  SizedBox(
                    height: 40.0, // Match HomePage search bar height
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value;
                        });
                      },
                      decoration: InputDecoration(
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 0, horizontal: 16),
                        hintText: "Find a doctor use name/designation/hospital",
                        hintStyle:
                            const TextStyle(fontSize: 14, color: Colors.grey),
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.grey,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24.0),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24.0),
                          borderSide: const BorderSide(color: Colors.grey),
                        ),
                      ),
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                  // Show search results as cards below the search bar
                  if (searchQuery.isNotEmpty)
                    Column(
                      children: filteredDocs.isEmpty
                          ? [
                              const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Text('No doctors found.'),
                              )
                            ]
                          : filteredDocs.map((doc) {
                              final data = doc.data() as Map<String, dynamic>;
                              return GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          DoctorDetailsPage(doctor: data),
                                    ),
                                  );
                                },
                                child: Container(
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 8),
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
                                        radius: 32,
                                        backgroundImage: data[
                                                        'profileImageUrl'] !=
                                                    null &&
                                                data['profileImageUrl'] != ''
                                            ? NetworkImage(
                                                    data['profileImageUrl'])
                                                as ImageProvider
                                            : (data['image'] != null &&
                                                    data['image'] != ''
                                                ? NetworkImage(data['image'])
                                                    as ImageProvider
                                                : const AssetImage(
                                                    'assets/images/doctor1.jpg')),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(data['name'] ?? '',
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16)),
                                            Text(data['designation'] ?? '',
                                                style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey)),
                                            const SizedBox(height: 4),
                                            Row(
                                              children: [
                                                const Icon(Icons.location_on,
                                                    size: 14,
                                                    color: Colors.grey),
                                                const SizedBox(width: 4),
                                                Text(data['hospital'] ?? '',
                                                    style: const TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.grey)),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                    ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Category",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w700)),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            showAllCategories = !showAllCategories;
                          });
                        },
                        child: Text(
                          showAllCategories ? "Show less" : "See all",
                          style: const TextStyle(
                            color: Colors.teal,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  GridView.count(
                    shrinkWrap: true,
                    crossAxisCount: 4,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.8,
                    physics: const NeverScrollableScrollPhysics(),
                    children: List.generate(
                      showAllCategories
                          ? categories.length
                          : (categories.length < 8 ? categories.length : 8),
                      (index) => GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DoctorListPage(
                                category: categories[index]['label']!,
                              ),
                            ),
                          );
                        },
                        child: Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                              child: Image.asset(
                                categories[index]['icon']!,
                                width: 32,
                                height: 32,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              categories[index]['label']!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Recommended Doctors Section
                  FutureBuilder<List<Map<String, dynamic>>>(
                    future: Future.wait(filteredDocs.map((doc) async {
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
                        return const Text("No recommended doctors found");
                      }
                      // Sort by avgRating descending
                      final sorted =
                          List<Map<String, dynamic>>.from(ratingSnapshot.data!);
                      sorted.sort((a, b) => (b['avgRating'] as double)
                          .compareTo(a['avgRating'] as double));
                      // Show top 5 doctors (or less if not enough)
                      final topDoctors = sorted.take(5).toList();
                      return SizedBox(
                        height: 132,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: topDoctors.length,
                          separatorBuilder: (context, idx) =>
                              const SizedBox(width: 16),
                          itemBuilder: (context, idx) {
                            final topDoctor = topDoctors[idx];
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        DoctorDetailsPage(doctor: topDoctor),
                                  ),
                                );
                              },
                              child: Container(
                                width: 320,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.2),
                                      spreadRadius: 1,
                                      blurRadius: 5,
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 50,
                                      backgroundImage: topDoctor[
                                                      'profileImageUrl'] !=
                                                  null &&
                                              topDoctor['profileImageUrl'] != ''
                                          ? NetworkImage(
                                                  topDoctor['profileImageUrl'])
                                              as ImageProvider
                                          : (topDoctor['image'] != null &&
                                                  topDoctor['image'] != ''
                                              ? NetworkImage(topDoctor['image'])
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
                                          Text(topDoctor['name'] ?? '',
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16)),
                                          Text(topDoctor['designation'] ?? '',
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.grey)),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Container(
                                                decoration: BoxDecoration(
                                                  color: Colors.teal
                                                      .withOpacity(0.1),
                                                  borderRadius:
                                                      BorderRadius.circular(2),
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 5,
                                                        vertical: 4),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    const Icon(Icons.star,
                                                        size: 14,
                                                        color:
                                                            Color(0xFF199A8E)),
                                                    const SizedBox(width: 4),
                                                    Text(
                                                      topDoctor['avgRating'] > 0
                                                          ? topDoctor[
                                                                  'avgRating']
                                                              .toStringAsFixed(
                                                                  1)
                                                          : 'No rating',
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 12,
                                                        color:
                                                            Color(0xFF199A8E),
                                                      ),
                                                    ),
                                                    if (topDoctor[
                                                            'totalRatings'] >
                                                        0) ...[
                                                      const SizedBox(width: 4),
                                                      Text(
                                                          '(${topDoctor['totalRatings']})',
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 10,
                                                                  color: Colors
                                                                      .grey)),
                                                    ]
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              const Icon(Icons.location_on,
                                                  color: Colors.grey, size: 14),
                                              const SizedBox(width: 4),
                                              Text(topDoctor['hospital'] ?? '',
                                                  style: const TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.grey)),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Your Recent Doctors",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 80,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        _recentDoctor(
                            "Dr. Marcus", "assets/images/doctor1.jpg"),
                        _recentDoctor("Dr. Maria", "assets/images/doctor2.jpg"),
                        _recentDoctor("Dr. Stevi", "assets/images/doctor3.jpg"),
                        _recentDoctor("Dr. Luke", "assets/images/doctor4.jpg"),
                      ],
                    ),
                  ),
                  const SizedBox(height: 50),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _recentDoctor(String name, String imagePath) {
    return Padding(
      padding: const EdgeInsets.only(right: 30),
      child: Column(
        children: [
          CircleAvatar(radius: 24, backgroundImage: AssetImage(imagePath)),
          const SizedBox(height: 10),
          Text(name, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
