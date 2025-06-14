import 'package:appointnow/Pages/doctor/doctor_serial.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:appointnow/Pages/hospital/appointments_serial.dart';

class DoctorAppointmentsHospitalsPage extends StatefulWidget {
  const DoctorAppointmentsHospitalsPage({Key? key}) : super(key: key);

  @override
  State<DoctorAppointmentsHospitalsPage> createState() =>
      _DoctorAppointmentsHospitalsPageState();
}

class _DoctorAppointmentsHospitalsPageState
    extends State<DoctorAppointmentsHospitalsPage> {
  late Future<List<Map<String, dynamic>>> _hospitalsFuture;

  @override
  void initState() {
    super.initState();
    _hospitalsFuture = _fetchHospitalsWithAppointments();
  }

  Future<List<Map<String, dynamic>>> _fetchHospitalsWithAppointments() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];
    // Get all appointments for this doctor
    final apptQuery = await FirebaseFirestore.instance
        .collection('appointments')
        .where('doctorId', isEqualTo: user.uid)
        .get();
    final hospitalIds = <String>{};
    for (final doc in apptQuery.docs) {
      final hid = doc['hospitalId'];
      if (hid != null && hid.toString().isNotEmpty) {
        hospitalIds.add(hid);
      }
    }
    if (hospitalIds.isEmpty) return [];
    // Fetch hospital details for each hospitalId
    final hospitals = <Map<String, dynamic>>[];
    for (final hid in hospitalIds) {
      final hospSnap = await FirebaseFirestore.instance
          .collection('hospitaldetails')
          .doc(hid)
          .get();
      if (hospSnap.exists) {
        final data = hospSnap.data()!..['id'] = hid;
        hospitals.add(data);
      }
    }
    return hospitals;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Appointment Hospitals'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _hospitalsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final hospitals = snapshot.data ?? [];
          if (hospitals.isEmpty) {
            return const Center(
                child: Text('No hospitals found for your appointments.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: hospitals.length,
            separatorBuilder: (context, idx) => const SizedBox(height: 16),
            itemBuilder: (context, idx) {
              final hospital = hospitals[idx];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: (hospital['profileImageUrl'] != null &&
                          hospital['profileImageUrl'].toString().isNotEmpty)
                      ? NetworkImage(hospital['profileImageUrl'])
                      : const AssetImage('assets/hospital.jpg')
                          as ImageProvider,
                  radius: 28,
                ),
                title: Text(hospital['name'] ?? '',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(hospital['location'] ?? ''),
                trailing: const Icon(Icons.arrow_forward_ios,
                    size: 18, color: Colors.teal),
                onTap: () async {
                  final user = FirebaseAuth.instance.currentUser;
                  if (user == null) return;
                  final docSnap = await FirebaseFirestore.instance
                      .collection('doctordetails')
                      .doc(user.uid)
                      .get();
                  final doctor = docSnap.data() ?? {};
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DoctorSerialPage(
                        doctorName: doctor['name'] ?? '',
                        doctorDesignation: doctor['designation'] ?? '',
                        doctorImage: doctor['profileImageUrl'] ?? '',
                        avgRating: (doctor['avgRating'] is num)
                            ? (doctor['avgRating'] as num).toDouble()
                            : 0.0,
                        totalRatings: doctor['totalRatings'] ?? 0,
                        hospitalId: hospital['id'],
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
