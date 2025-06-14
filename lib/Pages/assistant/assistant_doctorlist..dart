import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AssistantDoctorListPage extends StatelessWidget {
  const AssistantDoctorListPage({super.key});

  Future<List<Map<String, dynamic>>> _fetchDoctorsForAssistant() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];
    final assistantDoc = await FirebaseFirestore.instance
        .collection('assistants')
        .doc(user.uid)
        .get();
    final doctorIds = (assistantDoc.data()?['doctorIds'] as List?)
            ?.map((e) => e.toString())
            .toList() ??
        [];
    final hospitalId = assistantDoc.data()?['hospitalId'];
    if (doctorIds.isEmpty || hospitalId == null) return [];
    // 1. Get all appointments for this hospital and these doctors (chunked for >10)
    Set<String> validDoctorIds = {};
    for (var chunk in _chunkList(doctorIds, 10)) {
      final appointmentsQuery = await FirebaseFirestore.instance
          .collection('appointments')
          .where('hospitalId', isEqualTo: hospitalId)
          .where('doctorId', whereIn: chunk)
          .get();
      validDoctorIds.addAll(
          appointmentsQuery.docs.map((doc) => doc['doctorId'] as String));
    }
    if (validDoctorIds.isEmpty) return [];
    // 2. Now fetch only those doctors from doctordetails
    List<Map<String, dynamic>> allDoctors = [];
    for (var chunk in _chunkList(validDoctorIds.toList(), 10)) {
      final doctorsQuery = await FirebaseFirestore.instance
          .collection('doctordetails')
          .where(FieldPath.documentId, whereIn: chunk)
          .get();
      allDoctors.addAll(doctorsQuery.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }));
    }
    return allDoctors;
  }

  List<List<T>> _chunkList<T>(List<T> list, int chunkSize) {
    List<List<T>> chunks = [];
    for (var i = 0; i < list.length; i += chunkSize) {
      chunks.add(list.sublist(
          i, i + chunkSize > list.length ? list.length : i + chunkSize));
    }
    return chunks;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Doctors', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchDoctorsForAssistant(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final doctors = snapshot.data ?? [];
          if (doctors.isEmpty) {
            return const Center(child: Text('No assigned doctors found.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: doctors.length,
            itemBuilder: (context, index) {
              final doctor = doctors[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: doctor['profileImageUrl'] != null &&
                            doctor['profileImageUrl'] != ''
                        ? NetworkImage(doctor['profileImageUrl'])
                        : (doctor['image'] != null && doctor['image'] != ''
                                ? NetworkImage(doctor['image'])
                                : const AssetImage('assets/images/doctor1.jpg'))
                            as ImageProvider,
                  ),
                  title: Text(doctor['name'] ?? 'Doctor'),
                  subtitle: Text(doctor['designation'] ?? ''),
                  // You can add onTap to show doctor details if needed
                ),
              );
            },
          );
        },
      ),
    );
  }
}
