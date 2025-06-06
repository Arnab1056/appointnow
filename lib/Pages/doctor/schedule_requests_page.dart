import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'schedule_request_details_page.dart';

class ScheduleRequestsPage extends StatelessWidget {
  const ScheduleRequestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Not logged in')),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule Requests'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('scheduleRequests')
            .where('doctorId', isEqualTo: user.uid)
            .where('status', isEqualTo: 'pending')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No pending requests'));
          }
          final requests = snapshot.data!.docs;
          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, i) {
              final req = requests[i];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: const Icon(Icons.local_hospital, color: Colors.teal),
                  title: Text(req['hospitalName'] ?? 'Hospital'),
                  subtitle:
                      Text('Days: ${(req['selectedDays'] as List).join(', ')}'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 18),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ScheduleRequestDetailsPage(
                            requestId: req.id,
                            requestData: req.data() as Map<String, dynamic>),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
