import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserAppointmentsPage extends StatelessWidget {
  final String userId;
  const UserAppointmentsPage({Key? key, required this.userId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Use the passed userId instead of FirebaseAuth
    if (userId.isEmpty) {
      return const Center(
          child: Text('You must be logged in to view appointments.'));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Appointments'),
        backgroundColor: const Color(0xFF199A8E),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('serial')
            .where('patientUid', isEqualTo: userId)
            .orderBy('createdAt') // ascending by default
            .snapshots(),
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
              final doc = appointments[index];
              final data = doc.data() as Map<String, dynamic>;
              final serialNumber = index + 1;
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFF199A8E),
                    child: Text(
                      serialNumber.toString(),
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text(data['doctorName'] ?? 'Doctor'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Date: ${data['day']}, ${data['date']}'),
                      Text('Time: ${data['time']}'),
                      Text('Hospital: ${data['hospitalName'] ?? ''}'),
                      if (data['reason'] != null && data['reason'].toString().isNotEmpty)
                        Text('Reason: ${data['reason']}'),
                      Text('Serial ID: ${doc.id}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                  trailing: Text(
                    data['paymentMethod'] ?? '',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
