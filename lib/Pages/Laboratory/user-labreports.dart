import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserLabReportsPage extends StatelessWidget {
  const UserLabReportsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Lab Reports'),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: user == null
            ? const Center(child: Text('Not logged in'))
            : StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(user.uid)
                    .snapshots(),
                builder: (context, userSnapshot) {
                  if (!userSnapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final userData =
                      userSnapshot.data?.data() as Map<String, dynamic>?;
                  final userNumber = userData?['number'];
                  if (userNumber == null || userNumber.isEmpty) {
                    return const Center(child: Text('No phone number found.'));
                  }
                  return StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('labreports')
                        .where('phone', isEqualTo: userNumber)
                        .orderBy('createdAt', descending: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(
                            child: Text('Error: \\${snapshot.error}'));
                      }
                      final reports = snapshot.data?.docs ?? [];
                      if (reports.isEmpty) {
                        return const Center(
                            child: Text('No lab reports found.'));
                      }
                      return ListView.builder(
                        itemCount: reports.length,
                        itemBuilder: (context, index) {
                          final report = reports[index];
                          final data = report.data() as Map<String, dynamic>;
                          final isDone = data['done'] == true;
                          return Card(
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              title: Text(data['patientName'] ?? 'Unknown'),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Phone: \\${data['phone'] ?? '-'}'),
                                  Text(
                                      'Details: \\${data['reportDetails'] ?? '-'}'),
                                  const SizedBox(height: 8),
                                  Text(
                                    isDone
                                        ? 'Report is done'
                                        : 'Report is not done',
                                    style: TextStyle(
                                      color: isDone ? Colors.green : Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  );
                },
              ),
      ),
    );
  }
}
