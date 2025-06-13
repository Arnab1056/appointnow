import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AppointmentRequestsPage extends StatelessWidget {
  final String hospitalId;
  const AppointmentRequestsPage({Key? key, required this.hospitalId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointment Requests'),
        backgroundColor: Colors.teal,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('serial')
            .where('hospitalId', isEqualTo: hospitalId)
            .where('status', isEqualTo: 'pending') // Only show pending requests
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No appointment requests.'));
          }
          final requests = snapshot.data!.docs;
          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final doc = requests[index];
              final data = doc.data() as Map<String, dynamic>;
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  // Remove leading images
                  title: Text(data['patientName'] ?? 'Unknown Patient'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Doctor: ${data['doctorName'] ?? ''}'),
                      Text('Date: ${data['day']}, ${data['date']}'),
                      Text('Time: ${data['time']}'),
                      Text('Reason: ${data['reason'] ?? 'No reason'}'),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon:
                            const Icon(Icons.check_circle, color: Colors.green),
                        onPressed: () async {
                          // Get the current number of accepted appointments for this doctor, date, and time
                          final acceptedQuery = await FirebaseFirestore.instance
                              .collection('serial')
                              .where('doctorId', isEqualTo: data['doctorId'])
                              .where('date', isEqualTo: data['date'])
                              .where('day', isEqualTo: data['day'])
                              .where('time', isEqualTo: data['time'])
                              .where('status', isEqualTo: 'accepted')
                              .get();
                          final serialNumber = acceptedQuery.docs.length + 1;
                          await doc.reference.update({'status': 'accepted', 'serialNumber': serialNumber});
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Appointment accepted. Serial: $serialNumber')),
                            );
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.cancel, color: Colors.red),
                        onPressed: () async {
                          await doc.reference.update({'status': 'rejected'});
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Appointment rejected.')),
                            );
                          }
                        },
                      ),
                    ],
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
