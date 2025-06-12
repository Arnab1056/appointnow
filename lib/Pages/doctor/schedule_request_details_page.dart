import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ScheduleRequestDetailsPage extends StatelessWidget {
  final String requestId;
  final Map<String, dynamic> requestData;
  const ScheduleRequestDetailsPage({super.key, required this.requestId, required this.requestData});

  @override
  Widget build(BuildContext context) {
    final hospitalName = requestData['hospitalName'] ?? '';
    final selectedDay = requestData['selectedDay'] ?? '';
    final selectedTimeRange = requestData['selectedTimeRange'];
    String timeRangeStr = '';
    if (selectedTimeRange != null && selectedTimeRange['from'] != null && selectedTimeRange['to'] != null) {
      timeRangeStr = '${selectedTimeRange['from']} - ${selectedTimeRange['to']}';
    }
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
            Text('Requested Day: $selectedDay', style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text('Requested Time: $timeRangeStr', style: const TextStyle(fontSize: 16)),
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
    final selectedDay = requestData['selectedDay'];
    final selectedTimeRange = requestData['selectedTimeRange'];
    // 1. Add to appointments
    await FirebaseFirestore.instance.collection('appointments').add({
      ...requestData,
      'status': 'accepted',
      'acceptedAt': FieldValue.serverTimestamp(),
    });
    // 2. Update doctor availability (remove selected slot from that day)
    final doctorDoc = FirebaseFirestore.instance.collection('doctordetails').doc(doctorId);
    final doctorSnap = await doctorDoc.get();
    if (doctorSnap.exists) {
      final data = doctorSnap.data() as Map<String, dynamic>;
      List<String> availableDays = List<String>.from(data['availableDays'] ?? []);
      Map<String, dynamic> availableTimeRangesPerDay = Map<String, dynamic>.from(data['availableTimeRangesPerDay'] ?? {});
      if (availableTimeRangesPerDay[selectedDay] is List) {
        List slots = List.from(availableTimeRangesPerDay[selectedDay]);
        slots.removeWhere((slot) =>
          slot['from'] == selectedTimeRange['from'] && slot['to'] == selectedTimeRange['to']
        );
        availableTimeRangesPerDay[selectedDay] = slots;
        // If no slots left for the day, remove the day from availableDays
        if (slots.isEmpty) {
          availableDays.remove(selectedDay);
        }
      }
      // If request is accepted, delete availableDays and availableTimeRangesPerDay from doctor
      await doctorDoc.update({
        'availableDays': FieldValue.delete(),
        'availableTimeRangesPerDay': FieldValue.delete(),
      });
    }
    // 3. Mark request as accepted (or delete)
    await docRef.delete();
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Request accepted and appointment created.')));
  }
}
