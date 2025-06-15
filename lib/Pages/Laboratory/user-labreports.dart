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
        title:
            const Text('My Lab Reports', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF199A8E),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: Padding(
        padding: const EdgeInsets.all(0),
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
                          final doc = reports[index];
                          final data = doc.data() as Map<String, dynamic>;
                          final isDone = data['done'] == true;
                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      CircleAvatar(
                                        backgroundColor:
                                            const Color(0xFF199A8E),
                                        child: Text(
                                          data['patientName'] != null &&
                                                  data['patientName']
                                                      .toString()
                                                      .isNotEmpty
                                              ? data['patientName']
                                                  .toString()[0]
                                                  .toUpperCase()
                                              : '?',
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          data['patientName'] ?? 'Unknown',
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18),
                                        ),
                                      ),
                                      Icon(
                                        isDone
                                            ? Icons.check_circle
                                            : Icons.pending,
                                        color: isDone
                                            ? Colors.green
                                            : Colors.orange,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Text('Phone: ${data['phone'] ?? '-'}',
                                      style: const TextStyle(fontSize: 15)),
                                  const SizedBox(height: 4),
                                  Text(
                                      'Details: ${data['reportDetails'] ?? '-'}',
                                      style: const TextStyle(fontSize: 15)),
                                  const SizedBox(height: 4),
                                  Text(
                                    isDone
                                        ? 'Report is done'
                                        : 'Report is not done',
                                    style: TextStyle(
                                      color: isDone ? Colors.green : Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (data['createdAt'] != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Text(
                                        'Created: '
                                        '${(data['createdAt'] as Timestamp).toDate().toString().split('.')[0]}',
                                        style: const TextStyle(
                                            fontSize: 12, color: Colors.grey),
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
