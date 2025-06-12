import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:appointnow/Pages/hospital/appointments_serial.dart';

class DoctorListForAppointmentsPage extends StatelessWidget {
  final String hospitalUid;
  const DoctorListForAppointmentsPage({super.key, required this.hospitalUid});

  Future<List<String>> _getDoctorIdsWithAppointments() async {
    final appointments = await FirebaseFirestore.instance
        .collection('appointments')
        .where('hospitalId', isEqualTo: hospitalUid)
        .get();
    final doctorIds = <String>{};
    for (var doc in appointments.docs) {
      final data = doc.data();
      if (data['doctorId'] != null) {
        doctorIds.add(data['doctorId']);
      }
    }
    return doctorIds.toList();
  }

  Stream<List<Map<String, dynamic>>> _getDoctorsWithAppointments() async* {
    final doctorIds = await _getDoctorIdsWithAppointments();
    if (doctorIds.isEmpty) {
      yield [];
      return;
    }
    final doctorsQuery = await FirebaseFirestore.instance
        .collection('doctordetails')
        .where(FieldPath.documentId, whereIn: doctorIds)
        .get();
    yield doctorsQuery.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Appointments",
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
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _getDoctorsWithAppointments(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final doctors = snapshot.data ?? [];
          if (doctors.isEmpty) {
            return const Center(
                child: Text('No doctors with appointments found.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: doctors.length,
            itemBuilder: (context, index) {
              final doctor = doctors[index];
              final docId = doctor['id'];
              return FutureBuilder<QuerySnapshot>(
                future: FirebaseFirestore.instance
                    .collection('appointments')
                    .where('doctorId', isEqualTo: docId)
                    .limit(1)
                    .get(),
                builder: (context, appointmentSnapshot) {
                  String hospitalId = '';
                  if (appointmentSnapshot.hasData &&
                      appointmentSnapshot.data!.docs.isNotEmpty) {
                    final appointmentData = appointmentSnapshot.data!.docs.first
                        .data() as Map<String, dynamic>;
                    hospitalId = appointmentData['hospitalId'] ?? '';
                  }
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
                          // Always use hospitalUid from the home page (passed as a parameter)
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => AppointmentsSerialPage(
                                doctorName: doctor['name'] ?? 'Doctor Name',
                                doctorDesignation: doctor['designation'] ?? '',
                                doctorImage: doctor['profileImageUrl'] ??
                                    doctor['image'] ??
                                    '',
                                avgRating: avgRating,
                                totalRatings: totalRatings,
                                hospitalId:
                                    hospitalUid, // Use hospitalUid from home page
                              ),
                            ),
                          );
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
                                      doctor['name'] ?? 'Doctor Name',
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      doctor['designation'] ?? '',
                                      style: const TextStyle(
                                          fontSize: 14, color: Colors.grey),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.star,
                                            size: 14, color: Colors.teal),
                                        const SizedBox(width: 4),
                                        Text(
                                          avgRating.toStringAsFixed(1),
                                          style: const TextStyle(
                                              fontSize: 13, color: Colors.teal),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          '($totalRatings reviews)',
                                          style: const TextStyle(
                                              fontSize: 12, color: Colors.grey),
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
          );
        },
      ),
    );
  }
}

// Add this page to show appointments for a doctor
class DoctorAppointmentsPage extends StatelessWidget {
  final String doctorId;
  final String doctorName;
  const DoctorAppointmentsPage(
      {super.key, required this.doctorId, required this.doctorName});

  Stream<QuerySnapshot> getAppointmentsForDoctor() {
    return FirebaseFirestore.instance
        .collection('appointments')
        .where('doctorId', isEqualTo: doctorId)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Appointments for $doctorName',
            style: const TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: getAppointmentsForDoctor(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No appointments found.'));
          }
          final appointments = snapshot.data!.docs;
          return ListView.builder(
            itemCount: appointments.length,
            itemBuilder: (context, index) {
              final data = appointments[index].data() as Map<String, dynamic>;
              return ListTile(
                title: Text(data['patientName'] ?? 'Patient'),
                subtitle: Text(
                    'Date: ${data['date'] ?? ''}  Time: ${data['time'] ?? ''}'),
                trailing: Text(data['status'] ?? ''),
              );
            },
          );
        },
      ),
    );
  }
}
