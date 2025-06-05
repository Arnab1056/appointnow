import 'package:appointnow/pages/findDoctors/cardiologist_page.dart';
import 'package:appointnow/pages/index/homepage.dart';
import 'package:flutter/material.dart';

class FindDoctorsPage extends StatefulWidget {
  const FindDoctorsPage({super.key});

  @override
  State<FindDoctorsPage> createState() => _FindDoctorsPageState();
}

class _FindDoctorsPageState extends State<FindDoctorsPage> {
  bool showAllCategories = false;

  final List<Map<String, String>> categories = [
    {"label": "General", "icon": "assets/icon/Doctor.png"},
    {"label": "Lungs", "icon": "assets/icon/lungs.png"},
    {"label": "Dentist", "icon": "assets/icon/dentist.png"},
    {"label": "Psychiatrist", "icon": "assets/icon/neuron.png"},
    {"label": "Covid-19", "icon": "assets/icon/alargy.png"},
    {"label": "Surgeon", "icon": "assets/icon/surgeon.png"},
    {"label": "Cardiologist", "icon": "assets/icon/cardiologist.png"},
    {"label": "Allergy", "icon": "assets/icon/alargy.png"},
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
          "Find Doctors",
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              // Search Bar (match HomePage style)
              SizedBox(
                height: 40.0, // Match HomePage search bar height
                child: TextField(
                  decoration: InputDecoration(
                    contentPadding:
                        const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    hintText: "Find a doctor",
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
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Category",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
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
                          builder: (context) =>
                              CardiologistPage(), // Replace with actual category page
                        ),
                      );
                      print("Tapped on ${categories[index]['label']!}");
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
              const Text(
                "Recommended Doctors",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () {
                  // Navigate to doctor's profile
                  print("Tapped on Dr. Marcus Horizon");
                },
                child: Container(
                  height: 132,
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
                      const CircleAvatar(
                        radius: 50,
                        backgroundImage:
                            AssetImage('assets/images/doctor1.jpg'),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text("Dr. Marcus Horizon",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 16)),
                            const Text("Cardiologist",
                                style: TextStyle(
                                    fontSize: 12, color: Colors.grey)),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.teal.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 5, vertical: 4),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.star,
                                          size: 14, color: Color(0xFF199A8E)),
                                      SizedBox(width: 4),
                                      Text(
                                        "4.7",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                          color: Color(0xFF199A8E),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Icon(Icons.location_on,
                                    color: Colors.grey, size: 14),
                                const SizedBox(width: 4),
                                const Text("Epic Healthcare",
                                    style: TextStyle(
                                        fontSize: 12, color: Colors.grey)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
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
                    _recentDoctor("Dr. Marcus", "assets/images/doctor1.jpg"),
                    _recentDoctor("Dr. Maria", "assets/images/doctor2.jpg"),
                    _recentDoctor("Dr. Stevi", "assets/images/doctor3.jpg"),
                    _recentDoctor("Dr. Luke", "assets/images/doctor4.jpg"),
                  ],
                ),
              ),
              const SizedBox(height: 50),
            ],
          ),
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
