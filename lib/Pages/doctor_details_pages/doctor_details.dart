import 'package:flutter/material.dart';
import 'appointment.dart';

// Updated the DoctorDetailsPage to include read more functionality, improved card layout, and added bottom action buttons
class DoctorDetailsPage extends StatefulWidget {
  const DoctorDetailsPage({super.key});

  @override
  State<DoctorDetailsPage> createState() => _DoctorDetailsPageState();
}

class _DoctorDetailsPageState extends State<DoctorDetailsPage> {
  int selectedSlot = -1;
  bool showFullAbout = false; // Track whether to show full about text

  final List<Map<String, dynamic>> slots = [
    {
      "day": "Wed",
      "date": "23",
      "times": ["02:00 PM", "03:00 PM"],
      "location": "Epic Healthcare"
    },
    {
      "day": "Thu",
      "date": "24",
      "times": ["01:00 PM", "02:00 PM"],
      "location": "Parkview Hospital"
    },
    {
      "day": "Fri",
      "date": "25",
      "times": ["03:00 PM", "04:00 PM"],
      "location": "Max Hospital"
    },
    {
      "day": "Sat",
      "date": "26",
      "times": ["07:00 PM", "08:00 PM"],
      "location": "Ibn Sina Diagnostic"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title:
            const Text("Doctor Detail", style: TextStyle(color: Colors.black)),
        centerTitle: true,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () {
              // Handle three-dotted icon action
              print("Three-dotted icon clicked");
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 50,
                  backgroundImage: AssetImage('assets/images/doctor1.jpg'),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Dr. Marcus Horizon",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        "Cardiologist",
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.teal.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 4),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.star, size: 14, color: Colors.teal),
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
                      const SizedBox(height: 4),
                      const Row(
                        children: [
                          Icon(Icons.location_on, size: 14, color: Colors.grey),
                          SizedBox(width: 4),
                          Text(
                            "Epic Healthcare",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text("About",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              showFullAbout
                  ? "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua..."
                  : "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod...",
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  showFullAbout = !showFullAbout;
                });
              },
              child: Text(
                showFullAbout ? "Read less" : "Read more",
                style: const TextStyle(
                    color: Colors.teal, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            Column(
              children: List.generate(slots.length, (index) {
                var slot = slots[index];
                return Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                    side: BorderSide(color: Colors.white.withOpacity(0.1)),
                  ),
                  margin: const EdgeInsets.only(bottom: 7),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.teal,
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                slot['day'],
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                              Text(
                                slot['date'],
                                style: const TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 15),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children:
                                  List.generate(slot['times'].length, (tIndex) {
                                String time = slot['times'][tIndex];
                                bool selected =
                                    selectedSlot == index * 10 + tIndex;
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 6),
                                  child: ChoiceChip(
                                    label: Text(time),
                                    selected: selected,
                                    selectedColor: Colors.teal,
                                    labelStyle: TextStyle(
                                      color: selected
                                          ? Colors.white
                                          : Colors.black,
                                      fontSize: 12,
                                    ),
                                    backgroundColor: Colors.white,
                                    onSelected: (_) {
                                      setState(() {
                                        selectedSlot = index * 10 + tIndex;
                                      });
                                    },
                                  ),
                                );
                              }),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.location_on,
                                    size: 14, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(
                                  slot['location'],
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.black),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceAround, // Align items to the edges
              children: [
                GestureDetector(
                  onTap: () {
                    print("Chat icon clicked");
                  },
                  child: Container(
                    padding: const EdgeInsets.only(left: 10, right: 10),
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.teal.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Image.asset(
                      'assets/icon/chat.png',
                      width: 24,
                      height: 24,
                    ),
                  ),
                ),
                SizedBox(
                  width: 250, // Set button width to 266 pixels
                  height: 45, // Set button height to 50 pixels
                  child: ElevatedButton(
                    onPressed: selectedSlot >= 0
                        ? () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const AppointmentPage(),
                              ),
                            );
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      shape: const StadiumBorder(),
                      backgroundColor: Colors.teal,
                    ),
                    child: const Text(
                      "Book Appointment",
                      style: TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
