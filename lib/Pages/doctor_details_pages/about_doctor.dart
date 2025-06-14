import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AboutDoctorPage extends StatelessWidget {
  final String doctorName;
  final String designation;
  final String about;
  final String? imageUrl;
  final String? hospital;

  const AboutDoctorPage({
    Key? key,
    required this.doctorName,
    required this.designation,
    required this.about,
    this.imageUrl,
    this.hospital,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _fetchDoctorAppointments(),
      builder: (context, snapshot) {
        final appointments = snapshot.data ?? [];
        // Extract unique hospital names and days from appointments
        final Set<String> hospitalNames = {};
        final Set<String> appointmentDays = {};
        final Set<String> appointmentTimes = {};
        for (final appt in appointments) {
          if (appt['hospitalName'] != null &&
              appt['hospitalName'].toString().isNotEmpty) {
            hospitalNames.add(appt['hospitalName']);
          }
          if (appt['selectedDays'] != null && appt['selectedDays'] is List) {
            for (final d in appt['selectedDays']) {
              appointmentDays.add(d.toString());
            }
          }
          if (appt['selectedTimes'] != null && appt['selectedTimes'] is List) {
            for (final t in appt['selectedTimes']) {
              appointmentTimes.add(t.toString());
            }
          } else if (appt['selectedTime'] != null) {
            appointmentTimes.add(appt['selectedTime'].toString());
          }
        }
        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'About',
              style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            centerTitle: true,
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
          ),
          backgroundColor: Colors.white,
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 60,
                    backgroundImage: (imageUrl != null && imageUrl!.isNotEmpty)
                        ? NetworkImage(imageUrl!)
                        : const AssetImage('assets/doctor.jpg')
                            as ImageProvider,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  doctorName,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  designation,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.teal,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
                // Doctor Ratings
                FutureBuilder<QuerySnapshot>(
                  future: FirebaseFirestore.instance
                      .collection('doctors')
                      .where('name', isEqualTo: doctorName)
                      .limit(1)
                      .get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const SizedBox(height: 16);
                    }
                    if (!snapshot.hasData || snapshot.data == null || snapshot.data!.docs.isEmpty) {
                      return const SizedBox();
                    }
                    final doc = snapshot.data!.docs.first;
                    final rating = doc['rating'] != null ? doc['rating'] as num : null;
                    final ratingCount = doc['ratingCount'] != null ? doc['ratingCount'] as int : null;
                    if (rating == null) return const SizedBox();
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0, bottom: 4.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 20),
                          const SizedBox(width: 4),
                          Text(
                            rating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.black87,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (ratingCount != null) ...[
                            const SizedBox(width: 6),
                            Text(
                              '($ratingCount reviews)',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.grey,
                              ),
                            ),
                          ]
                        ],
                      ),
                    );
                  },
                ),
                if (hospitalNames.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ...hospitalNames.map((name) => Padding(
                            padding: const EdgeInsets.only(bottom: 4.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.location_on, color: Colors.grey, size: 18),
                                const SizedBox(width: 4),
                                Flexible(
                                  child: Text(
                                    name,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          )),
                    ],
                  ),
                ],
                if (appointmentDays.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Appointment Days',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    children: appointmentDays
                        .map((day) => Chip(
                              label: Text(day),
                              backgroundColor: Colors.teal.withOpacity(0.1),
                              labelStyle: const TextStyle(color: Colors.teal),
                            ))
                        .toList(),
                  ),
                ],
                if (appointmentTimes.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Appointment Times',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    children: appointmentTimes
                        .map((time) => Chip(
                              label: Text(time),
                              backgroundColor: Colors.teal.withOpacity(0.1),
                              labelStyle: const TextStyle(color: Colors.teal),
                            ))
                        .toList(),
                  ),
                ],
                const SizedBox(height: 24),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'About',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  about.isNotEmpty ? about : 'No details available.',
                  style: const TextStyle(fontSize: 15, color: Colors.black87),
                  textAlign: TextAlign.justify,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<List<Map<String, dynamic>>> _fetchDoctorAppointments() async {
    // You may need to adjust the doctor id key depending on your data
    final doctorId = doctorName; // Or use a unique id if available
    final query = await FirebaseFirestore.instance
        .collection('appointments')
        .where('doctorName', isEqualTo: doctorName)
        .get();
    return query.docs.map((doc) => doc.data()).toList();
  }
}
