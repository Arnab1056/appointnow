import 'package:flutter/material.dart';

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
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
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
                      Row(
                        children: const [
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
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(color: Colors.grey.withOpacity(0.2)),
                  ),
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Colors.teal,
                                borderRadius: BorderRadius.circular(8),
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
                            const SizedBox(width: 8),
                            ...List.generate(slot['times'].length, (tIndex) {
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
                                  onSelected: (_) {
                                    setState(() {
                                      selectedSlot = index * 10 + tIndex;
                                    });
                                  },
                                ),
                              );
                            })
                          ],
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
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    print("Message icon clicked");
                  },
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.teal.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.message, color: Colors.teal),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: selectedSlot >= 0
                      ? () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  const Placeholder(), // Replace with AppointmentsPage
                            ),
                          );
                        }
                      : null,
                  style: ElevatedButton.styleFrom(
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50, vertical: 14),
                    backgroundColor: Colors.teal,
                  ),
                  child: const Text(
                    "Book Appointment",
                    style: TextStyle(color: Colors.white, fontSize: 14),
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
