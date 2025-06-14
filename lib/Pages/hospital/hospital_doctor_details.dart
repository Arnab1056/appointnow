import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HospitalDoctorDetailsPage extends StatelessWidget {
  final Map<String, dynamic> doctor;
  const HospitalDoctorDetailsPage({super.key, required this.doctor});

  Future<Map<String, dynamic>?> fetchDoctorDetails(String doctorId) async {
    final doc = await FirebaseFirestore.instance
        .collection('doctordetails')
        .doc(doctorId)
        .get();
    if (doc.exists) {
      final data = doc.data()!;
      data['id'] = doc.id;
      return data;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final doctorId = doctor['id'] ?? doctor['uid'] ?? '';
    return FutureBuilder<Map<String, dynamic>?>(
      future: fetchDoctorDetails(doctorId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (!snapshot.hasData || snapshot.data == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Doctor Details',
                  style: TextStyle(color: Colors.black)),
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 0,
            ),
            body: const Center(child: Text('Doctor details not found.')),
          );
        }
        final docData = snapshot.data!;
        return FutureBuilder<List<Map<String, dynamic>>>(
          future: _fetchDoctorAppointments(docData['id']),
          builder: (context, apptSnapshot) {
            final appointments = apptSnapshot.data ?? [];
            final Set<String> hospitalNames = {};
            final Set<String> appointmentDays = {};
            final Set<String> appointmentTimes = {};
            for (final appt in appointments) {
              if (appt['hospitalName'] != null &&
                  appt['hospitalName'].toString().isNotEmpty) {
                hospitalNames.add(appt['hospitalName']);
              }
              if (appt['selectedDays'] != null &&
                  appt['selectedDays'] is List) {
                for (final d in appt['selectedDays']) {
                  appointmentDays.add(d.toString());
                }
              }
              if (appt['selectedTimes'] != null &&
                  appt['selectedTimes'] is List) {
                for (final t in appt['selectedTimes']) {
                  appointmentTimes.add(t.toString());
                }
              } else if (appt['selectedTime'] != null) {
                appointmentTimes.add(appt['selectedTime'].toString());
              }
            }
            return Scaffold(
              appBar: AppBar(
                title: const Text('About',
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
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
                        backgroundImage: (docData['profileImageUrl'] != null &&
                                docData['profileImageUrl'].isNotEmpty)
                            ? NetworkImage(docData['profileImageUrl'])
                            : (docData['image'] != null &&
                                        docData['image'] != ''
                                    ? NetworkImage(docData['image'])
                                    : const AssetImage('assets/doctor.jpg'))
                                as ImageProvider,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      docData['name'] ?? '',
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      docData['designation'] ?? '',
                      style: const TextStyle(
                          fontSize: 16,
                          color: Colors.teal,
                          fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                    ),
                    if (hospitalNames.isNotEmpty ||
                        (docData['hospital'] != null &&
                            docData['hospital'].toString().isNotEmpty)) ...[
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.location_on,
                              color: Colors.grey, size: 18),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              hospitalNames.isNotEmpty
                                  ? hospitalNames.join(', ')
                                  : (docData['hospital'] ?? ''),
                              style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w500),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (appointmentDays.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Appointment Days',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        children: appointmentDays
                            .map((day) => Chip(
                                  label: Text(day),
                                  backgroundColor: Colors.teal.withOpacity(0.1),
                                  labelStyle:
                                      const TextStyle(color: Colors.teal),
                                ))
                            .toList(),
                      ),
                    ],
                    if (appointmentTimes.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Appointment Times',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        children: appointmentTimes
                            .map((time) => Chip(
                                  label: Text(time),
                                  backgroundColor: Colors.teal.withOpacity(0.1),
                                  labelStyle:
                                      const TextStyle(color: Colors.teal),
                                ))
                            .toList(),
                      ),
                    ],
                    const SizedBox(height: 24),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text('About',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      (docData['about'] ?? '').isNotEmpty
                          ? docData['about']
                          : 'No details available.',
                      style:
                          const TextStyle(fontSize: 15, color: Colors.black87),
                      textAlign: TextAlign.justify,
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
              bottomNavigationBar: Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
                child: SafeArea(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final hospitalUid = FirebaseAuth.instance.currentUser?.uid;
                      if (hospitalUid == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Hospital ID not found.')));
                        return;
                      }
                      // Fetch assistants for this hospital
                      final assistantsQuery = await FirebaseFirestore
                          .instance
                          .collection('assistants')
                          .where('hospitalId', isEqualTo: hospitalUid)
                          .get();
                      final assistants = assistantsQuery.docs;
                      if (assistants.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('No assistants found for this hospital.')));
                        return;
                      }
                      showDialog(
                        context: context,
                        builder: (context) {
                          // Find assistants already assigned to this doctor
                          final assignedAssistantIndexes = <int>[];
                          for (int i = 0; i < assistants.length; i++) {
                            final a = assistants[i].data();
                            final doctorIds = (a['doctorIds'] as List?)
                                    ?.map((e) => e.toString())
                                    .toList() ??
                                [];
                            if (doctorIds.contains(docData['id'])) {
                              assignedAssistantIndexes.add(i);
                            }
                          }
                          return AlertDialog(
                            title: const Text('Select Assistant'),
                            content: SizedBox(
                              width: double.maxFinite,
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: assistants.length,
                                itemBuilder: (context, index) {
                                  final assistant = assistants[index].data();
                                  final assistantId = assistants[index].id;
                                  final doctorIds =
                                      (assistant['doctorIds'] as List?)
                                              ?.map((e) => e.toString())
                                              .toList() ??
                                          [];
                                  final alreadyAssigned =
                                      doctorIds.contains(docData['id']);
                                  return ListTile(
                                    leading: CircleAvatar(
                                      backgroundImage: (assistant[
                                                      'profileImageUrl'] !=
                                                  null &&
                                              assistant[
                                                      'profileImageUrl'] !=
                                                  '')
                                          ? NetworkImage(
                                              assistant['profileImageUrl'])
                                          : (assistant['image'] != null &&
                                                  assistant['image'] != ''
                                              ? NetworkImage(assistant['image'])
                                              : const AssetImage(
                                                  'assets/images/doctor1.jpg'))
                                          as ImageProvider,
                                    ),
                                    title: Row(
                                      children: [
                                        Text(assistant['name'] ?? 'Assistant'),
                                        if (alreadyAssigned)
                                          const Padding(
                                            padding: EdgeInsets.only(left: 8.0),
                                            child: Icon(Icons.check_circle,
                                                color: Colors.green, size: 18),
                                          ),
                                      ],
                                    ),
                                    subtitle: Text(assistant['email'] ?? ''),
                                    enabled: !alreadyAssigned,
                                    onTap: alreadyAssigned
                                        ? null
                                        : () async {
                                            // Remove doctorId from all assistants for this hospital
                                            for (final aDoc in assistants) {
                                              final aId = aDoc.id;
                                              final aData = aDoc.data();
                                              final aDoctorIds =
                                                  (aData['doctorIds'] as List?)
                                                          ?.map((e) => e.toString())
                                                          .toList() ??
                                                      [];
                                              if (aDoctorIds.contains(docData['id'])) {
                                                await FirebaseFirestore.instance
                                                    .collection('assistants')
                                                    .doc(aId)
                                                    .update({
                                                  'doctorIds':
                                                      FieldValue.arrayRemove(
                                                          [docData['id']])
                                                });
                                              }
                                            }
                                            // Add doctorId to the selected assistant
                                            final docRef = FirebaseFirestore
                                                .instance
                                                .collection('assistants')
                                                .doc(assistantId);
                                            await docRef.set({
                                              'doctorIds':
                                                  FieldValue.arrayUnion(
                                                      [docData['id']])
                                            }, SetOptions(merge: true));
                                            Navigator.of(context).pop();
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                  content: Text(
                                                      'Assistant assigned to doctor!')),
                                            );
                                          },
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      );
                    },
                    icon: const Icon(Icons.person_add),
                    label: const Text('Assign Assistant'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 32, vertical: 16),
                      textStyle: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<List<Map<String, dynamic>>> _fetchDoctorAppointments(
      String doctorId) async {
    final query = await FirebaseFirestore.instance
        .collection('appointments')
        .where('doctorId', isEqualTo: doctorId)
        .get();
    return query.docs.map((doc) => doc.data()).toList();
  }
}
