import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ScheduleRequestDetailsPage extends StatelessWidget {
  final String requestId;
  final Map<String, dynamic> requestData;
  const ScheduleRequestDetailsPage({super.key, required this.requestId, required this.requestData});

  @override
  Widget build(BuildContext context) {
    final hospitalName = requestData['hospitalName'] ?? '';
    final selectedDays = (requestData['selectedDays'] as List?)?.join(', ') ?? '';
    final selectedTimes = (requestData['selectedTimes'] as List?)?.join(', ') ?? '';
    return Scaffold(
      appBar: AppBar(
        title: const Text('Request Details'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hospital: $hospitalName', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Text('Requested Days: $selectedDays', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text('Requested Times: $selectedTimes', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      // Accept logic: move to appointments, update doctor availability, mark request as accepted
                      await _acceptRequest(context);
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.teal),
                    child: const Text('Accept'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      // Remove logic: delete or mark as removed
                      await FirebaseFirestore.instance.collection('scheduleRequests').doc(requestId).delete();
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                    child: const Text('Remove'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _acceptRequest(BuildContext context) async {
    final docRef = FirebaseFirestore.instance.collection('scheduleRequests').doc(requestId);
    final doctorId = requestData['doctorId'];
    final selectedDays = List<String>.from(requestData['selectedDays'] ?? []);
    final selectedTimes = List<String>.from(requestData['selectedTimes'] ?? []);
    // 1. Add to appointments
    await FirebaseFirestore.instance.collection('appointments').add({
      ...requestData,
      'status': 'accepted',
      'acceptedAt': FieldValue.serverTimestamp(),
    });
    // 2. Update doctor availability (remove selected times)
    final doctorDoc = FirebaseFirestore.instance.collection('doctordetails').doc(doctorId);
    final doctorSnap = await doctorDoc.get();
    if (doctorSnap.exists) {
      final data = doctorSnap.data() as Map<String, dynamic>;
      List<String> availableDays = List<String>.from(data['availableDays'] ?? []);
      List<String> availableTimeSlots = List<String>.from(data['availableTimeSlots'] ?? []);
      availableDays.removeWhere((d) => selectedDays.contains(d));
      availableTimeSlots.removeWhere((t) => selectedTimes.contains(t));
      await doctorDoc.update({
        'availableDays': availableDays,
        'availableTimeSlots': availableTimeSlots,
      });
    }
    // 3. Mark request as accepted (or delete)
    await docRef.delete();
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Request accepted and appointment created.')));
  }
}
