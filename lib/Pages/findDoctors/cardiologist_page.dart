import 'package:flutter/material.dart';

class CardiologistPage extends StatelessWidget {
  final List<Map<String, String>> cardiologists = [
    {
      "name": "Dr. Marcus Horizon",
      "hospital": "Epic Healthcare",
      // "image": "",
    },
    {
      "name": "Dr. Maria Elena",
      "hospital": "Parkview Hospital",
      // "image": "",
    },
    {
      "name": "Dr. Stefi Jessi",
      "hospital": "Max Hospital",
      // "image": "",
    },
    {
      "name": "Dr. Gerty Cori",
      "hospital": "Ibn Sina Diagnostic",
      // "image": "",
    },
    {
      "name": "Dr. Diandra",
      "hospital": "Memon Maternity Hospital",
      // "image": "",
    },
    // You can add more doctor maps here or fetch them from a database
  ];

  CardiologistPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true, // Center the title properly
        title: const Text("Cardiologist", style: TextStyle(color: Colors.black,fontSize:18,fontWeight: FontWeight.bold )),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: cardiologists.length,
        itemBuilder: (context, index) {
          final doctor = cardiologists[index];
          return GestureDetector(
            onTap: () {
              // Navigate to doctor's detail page
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (_) => DoctorDetailPage(doctor: doctor),
              //   ),
              // );
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
                    radius: 50,
                    backgroundImage: AssetImage('assets/images/doctor1.jpg'),
                  ),
                  //   ClipRRect(
                  //     borderRadius: BorderRadius.circular(8),
                  //     child: Image.asset(
                  //       doctor["image"]!,
                  //       width: 70,
                  //       height: 70,
                  //       fit: BoxFit.cover,
                  //     ),
                  //   ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          doctor["name"]!,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          "Cardiologist",
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        // Adjusted the container to fit the star and 4.7 text size
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.teal.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(
                                2), // Added rounded corners
                          ),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 4), // Adjusted padding
                          child: Row(
                            mainAxisSize: MainAxisSize
                                .min, // Ensures the container wraps its content
                            children: const [
                              Icon(Icons.star, size: 14, color: Colors.teal),
                              SizedBox(width: 2),
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
                        const SizedBox(
                          height: 4,
                        ),
                        Row(
                          children: [
                            const Icon(Icons.location_on,
                                size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              doctor["hospital"]!,
                              style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
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
      ),
    );
  }
}
