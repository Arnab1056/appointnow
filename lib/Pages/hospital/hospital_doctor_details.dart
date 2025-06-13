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
        return Scaffold(
          appBar: AppBar(
            title: Text(docData['name'] ?? 'Doctor Details',
                style: const TextStyle(color: Colors.black)),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
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
                      backgroundImage: docData['profileImageUrl'] != null &&
                              docData['profileImageUrl'] != ''
                          ? NetworkImage(docData['profileImageUrl'])
                          : (docData['image'] != null && docData['image'] != ''
                                  ? NetworkImage(docData['image'])
                                  : const AssetImage(
                                      'assets/images/doctor1.jpg'))
                              as ImageProvider,
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(docData['name'] ?? '',
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                          Text(docData['designation'] ?? '',
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.grey)),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.location_on,
                                  size: 14, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text(docData['hospital'] ?? '',
                                  style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildDetailRow('Designation', docData['designation']),
                _buildDetailRow('Email', docData['email']),
                _buildDetailRow('Phone', docData['phone']),
                _buildDetailRow('Register Number', docData['registerNumber']),
                _buildDetailRow('About', docData['about']),
                const SizedBox(height: 32),
                // Assign Assistant Button
                Center(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final hospitalUid = FirebaseAuth.instance.currentUser?.uid;
                      if (hospitalUid == null) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Hospital ID not found.')));
                        return;
                      }
                      // Fetch assistants for this hospital
                      final assistantsQuery = await FirebaseFirestore.instance
                          .collection('assistants')
                          .where('hospitalId', isEqualTo: hospitalUid)
                          .get();
                      final assistants = assistantsQuery.docs;
                      if (assistants.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No assistants found for this hospital.')));
                        return;
                      }
                      showDialog(
                        context: context,
                        builder: (context) {
                          // Find assistants already assigned to this doctor
                          final assignedAssistantIndexes = <int>[];
                          for (int i = 0; i < assistants.length; i++) {
                            final a = assistants[i].data();
                            final doctorIds = (a['doctorIds'] as List?)?.map((e) => e.toString()).toList() ?? [];
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
                                  final doctorIds = (assistant['doctorIds'] as List?)?.map((e) => e.toString()).toList() ?? [];
                                  final alreadyAssigned = doctorIds.contains(docData['id']);
                                  return ListTile(
                                    leading: CircleAvatar(
                                      backgroundImage: (assistant['profileImageUrl'] != null && assistant['profileImageUrl'] != '')
                                          ? NetworkImage(assistant['profileImageUrl'])
                                          : (assistant['image'] != null && assistant['image'] != ''
                                              ? NetworkImage(assistant['image'])
                                              : const AssetImage('assets/images/doctor1.jpg')) as ImageProvider,
                                    ),
                                    title: Row(
                                      children: [
                                        Text(assistant['name'] ?? 'Assistant'),
                                        if (alreadyAssigned)
                                          const Padding(
                                            padding: EdgeInsets.only(left: 8.0),
                                            child: Icon(Icons.check_circle, color: Colors.green, size: 18),
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
                                              final aDoctorIds = (aData['doctorIds'] as List?)?.map((e) => e.toString()).toList() ?? [];
                                              if (aDoctorIds.contains(docData['id'])) {
                                                await FirebaseFirestore.instance.collection('assistants').doc(aId).update({
                                                  'doctorIds': FieldValue.arrayRemove([docData['id']])
                                                });
                                              }
                                            }
                                            // Add doctorId to the selected assistant
                                            final docRef = FirebaseFirestore.instance.collection('assistants').doc(assistantId);
                                            await docRef.set({
                                              'doctorIds': FieldValue.arrayUnion([docData['id']])
                                            }, SetOptions(merge: true));
                                            Navigator.of(context).pop();
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('Assistant assigned to doctor!')),
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
              ],
            ),
          ),
        );
      },
    );
  }

  // Helper widget for displaying details
  Widget _buildDetailRow(String label, dynamic value) {
    String displayValue = '';
    if (value == null || (value is String && value.trim().isEmpty)) {
      displayValue = 'Not provided';
    } else if (value is List) {
      displayValue = value.isEmpty ? 'Not provided' : value.join(', ');
    } else {
      displayValue = value.toString();
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Expanded(child: Text(displayValue)),
        ],
      ),
    );
  }
}
