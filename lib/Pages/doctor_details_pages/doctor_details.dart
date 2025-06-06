import 'package:flutter/material.dart';
import 'appointment.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Updated the DoctorDetailsPage to include read more functionality, improved card layout, and added bottom action buttons
class DoctorDetailsPage extends StatefulWidget {
  final Map<String, dynamic> doctor;
  const DoctorDetailsPage({super.key, required this.doctor});

  @override
  State<DoctorDetailsPage> createState() => _DoctorDetailsPageState();
}

class _DoctorDetailsPageState extends State<DoctorDetailsPage> {
  int selectedSlot = -1;
  bool showFullAbout = false; // Track whether to show full about text

  // Remove the static slots list and instead fetch available slots from Firestore or doctor data
  List<Map<String, dynamic>> getAvailableSlots() {
    final doctor = widget.doctor;
    final List<String> days = (doctor['availableDays'] ?? []) is List
        ? List<String>.from(doctor['availableDays'] ?? [])
        : [];
    final List<String> times = (doctor['availableTimeSlots'] ?? []) is List
        ? List<String>.from(doctor['availableTimeSlots'] ?? [])
        : [];
    // Generate slot objects for each day/time combination
    List<Map<String, dynamic>> slots = [];
    for (var day in days) {
      slots.add({
        'day': day,
        'date': '', // You can add logic to map day to a date if needed
        'times': times,
        'location': doctor['hospital'] ?? '',
      });
    }
    return slots;
  }

  // Add this helper to get hospital name from accepted appointments for a slot
  String getHospitalNameForSlot(
      String day, List<Map<String, dynamic>> appointments) {
    for (final appt in appointments) {
      if (appt['selectedDays'] != null &&
          (appt['selectedDays'] as List).contains(day)) {
        return appt['hospitalName'] ?? '';
      }
    }
    return '';
  }

  // Add this helper for star rating
  Widget _buildStarRating(double rating, {double size = 14}) {
    int fullStars = rating.floor();
    bool hasHalfStar = (rating - fullStars) >= 0.5;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < fullStars; i++)
          Icon(Icons.star, size: size, color: const Color(0xFF199A8E)),
        if (hasHalfStar)
          Icon(Icons.star_half, size: size, color: const Color(0xFF199A8E)),
        for (int i = 0; i < (5 - fullStars - (hasHalfStar ? 1 : 0)); i++)
          Icon(Icons.star_border, size: size, color: const Color(0xFF199A8E)),
      ],
    );
  }

  // Helper to get the next date for a given weekday string (e.g., 'Mon', 'Tue', ...)
  String getNextDateForDay(String day) {
    final now = DateTime.now();
    final weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    int targetWeekday =
        weekDays.indexOf(day) + 1; // DateTime weekday: 1=Mon, ..., 7=Sun
    if (targetWeekday == 0) return '';
    int diff = (targetWeekday - now.weekday) % 7;
    if (diff < 0) diff += 7;
    final nextDate = now.add(Duration(days: diff == 0 ? 7 : diff));
    // Only return the day number as a string
    return nextDate.day.toString().padLeft(2, '0');
  }

  // Place this above the build method
  Future<List<Map<String, dynamic>>> _fetchAcceptedAppointments(
      String doctorId) async {
    final query = await FirebaseFirestore.instance
        .collection('appointments')
        .where('doctorId', isEqualTo: doctorId)
        .where('status', isEqualTo: 'accepted')
        .get();
    return query.docs.map((doc) => doc.data()).toList();
  }

  Future<String?> _fetchHospitalNameForDoctor(String doctorId) async {
    final query = await FirebaseFirestore.instance
        .collection('appointments')
        .where('doctorId', isEqualTo: doctorId)
        .limit(1)
        .get();
    if (query.docs.isNotEmpty) {
      return query.docs.first.data()['hospitalName'] as String?;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final doctor = widget.doctor;
    // Fix: Support both 'avgRating' and fallback to 'rating' if present
    double avgRating = 0.0;
    if (doctor['avgRating'] != null) {
      avgRating = doctor['avgRating'] is double
          ? doctor['avgRating']
          : (doctor['avgRating'] is int
              ? (doctor['avgRating'] as int).toDouble()
              : 0.0);
    } else if (doctor['rating'] != null) {
      avgRating = doctor['rating'] is double
          ? doctor['rating']
          : (doctor['rating'] is int
              ? (doctor['rating'] as int).toDouble()
              : 0.0);
    }
    final int totalRatings = doctor['totalRatings'] ?? 0;
    return FutureBuilder<String?>(
      future: _fetchHospitalNameForDoctor(doctor['id'] ?? doctor['uid'] ?? ''),
      builder: (context, snapshot) {
        final hospitalName = snapshot.data ?? doctor['hospital'] ?? 'Hospital';
        return FutureBuilder<List<Map<String, dynamic>>>(
          future:
              _fetchAcceptedAppointments(doctor['id'] ?? doctor['uid'] ?? ''),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            final List<Map<String, dynamic>> acceptedAppointments =
                snapshot.data ?? [];
            final slots = getAvailableSlots();
            // Find the first hospitalName from accepted appointments if any
            String? acceptedHospitalName;
            for (final slot in slots) {
              final apptHospitalName =
                  getHospitalNameForSlot(slot['day'], acceptedAppointments);
              if (apptHospitalName.isNotEmpty) {
                acceptedHospitalName = apptHospitalName;
                break;
              }
            }
            // Flatten appointments so each day gets its own card
            List<Map<String, dynamic>> dayWiseAppointments = [];
            for (final appt in acceptedAppointments) {
              final List days = appt['selectedDays'] ?? [];
              final List times = appt['selectedTimes'] ??
                  (appt['selectedTime'] != null ? [appt['selectedTime']] : []);
              final hospital = appt['hospitalName'] ?? hospitalName;
              for (final day in days) {
                dayWiseAppointments.add({
                  'day': day,
                  'times': times,
                  'hospital': hospital,
                  'originalAppt': appt,
                });
              }
            }
            return Scaffold(
              backgroundColor: Colors.white,
              appBar: AppBar(
                backgroundColor: Colors.white,
                title: const Text(
                  'DoctorDetails',
                  style: TextStyle(color: Colors.black),
                ),
                centerTitle: true,
                elevation: 0,
                leading: const BackButton(color: Colors.black),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.more_vert, color: Colors.black),
                    onPressed: () {
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
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: doctor['profileImageUrl'] != null &&
                                  doctor['profileImageUrl'] != ''
                              ? NetworkImage(doctor['profileImageUrl'])
                              : (doctor['image'] != null &&
                                          doctor['image'] != ''
                                      ? NetworkImage(doctor['image'])
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
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 4),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    _buildStarRating(avgRating, size: 14),
                                    const SizedBox(width: 4),
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
                                      Text(
                                        '($totalRatings)',
                                        style: const TextStyle(
                                            fontSize: 11, color: Colors.grey),
                                      ),
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
                                      color: Colors.grey, // Set to grey
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
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(
                      showFullAbout
                          ? (doctor['about'] ?? "No details available.")
                          : ((doctor['about'] != null &&
                                  doctor['about'].length > 60)
                              ? doctor['about'].substring(0, 60) + '...'
                              : (doctor['about'] ?? "No details available.")),
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
                    // Slots Section
                    if (dayWiseAppointments.isEmpty) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        alignment: Alignment.center,
                        child: const Text(
                          'No available appointments',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ),
                    ] else ...[
                      Column(
                        children:
                            List.generate(dayWiseAppointments.length, (index) {
                          final appt = dayWiseAppointments[index];
                          final String day = appt['day'] ?? '-';
                          final List times = appt['times'] ?? [];
                          final hospital = appt['hospital'] ?? hospitalName;
                          return Card(
                            elevation:
                                1, // Remove elevation change based on selectedSlot
                            color: Colors
                                .white, // Remove color change based on selectedSlot
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                              side: BorderSide(
                                color: Colors.white.withOpacity(0.1),
                                width: 1,
                              ),
                            ),
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 54,
                                    height: 54,
                                    decoration: BoxDecoration(
                                      color: Colors.teal,
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          day,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          getNextDateForDay(day),
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 18),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (times.isNotEmpty) ...[
                                          Wrap(
                                            spacing: 8,
                                            runSpacing: 8,
                                            children: List.generate(
                                                times.length, (tIndex) {
                                              String time = times[tIndex];
                                              int chipIndex =
                                                  index * 10 + tIndex;
                                              bool selected =
                                                  selectedSlot == chipIndex;
                                              return ChoiceChip(
                                                label: Text(time),
                                                selected: selected,
                                                selectedColor: Colors.teal,
                                                labelStyle: TextStyle(
                                                  color: selected
                                                      ? Colors.white
                                                      : Colors.black,
                                                  fontSize: 13,
                                                ),
                                                backgroundColor: Colors.white,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(24),
                                                ),
                                                onSelected: (_) {
                                                  setState(() {
                                                    if (selectedSlot ==
                                                        chipIndex) {
                                                      selectedSlot =
                                                          -1; // Deselect if already selected
                                                    } else {
                                                      selectedSlot = chipIndex;
                                                    }
                                                  });
                                                },
                                              );
                                            }),
                                          ),
                                        ] else ...[
                                          const Text(
                                            'No times available',
                                            style: TextStyle(
                                                fontSize: 13,
                                                color: Colors.grey),
                                          ),
                                        ],
                                        const SizedBox(height: 10),
                                        Row(
                                          children: [
                                            const Icon(Icons.location_on,
                                                size: 15, color: Colors.teal),
                                            const SizedBox(width: 5),
                                            Flexible(
                                              child: Text(
                                                hospital,
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.teal,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                                maxLines: 1,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                    const SizedBox(height: 16),
                  ],
                ),
              ),
              bottomNavigationBar: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
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
                      width: 250,
                      height: 45,
                      child: ElevatedButton(
                        onPressed: selectedSlot >= 0
                            ? () {
                                // Find selected day/time
                                final appt =
                                    dayWiseAppointments[selectedSlot ~/ 10];
                                final String day = appt['day'];
                                final String date = getNextDateForDay(day);
                                final String time =
                                    appt['times'][selectedSlot % 10];
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => AppointmentPage(
                                      doctor: doctor,
                                      day: day,
                                      date: date,
                                      time: time,
                                      hospitalName: appt['hospital'],
                                    ),
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
                ),
              ),
            );
          },
        );
      },
    );
  }
}
