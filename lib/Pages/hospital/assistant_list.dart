import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AssistantListPage extends StatelessWidget {
  final String hospitalUid;
  const AssistantListPage({super.key, required this.hospitalUid});

  Stream<List<Map<String, dynamic>>> _getAssistantsForHospital() async* {
    final query = await FirebaseFirestore.instance
        .collection('assistants')
        .where('hospitalId', isEqualTo: hospitalUid)
        .get();
    yield query.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Assistants list",
            style: TextStyle(
                color: Colors.black,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _getAssistantsForHospital(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final assistants = snapshot.data ?? [];
          if (assistants.isEmpty) {
            return const Center(
                child: Text('No assistants found for this hospital.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: assistants.length,
            itemBuilder: (context, index) {
              final assistant = assistants[index];
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      blurRadius: 6,
                      color: Colors.grey.withOpacity(0.1),
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: assistant['profileImageUrl'] != null &&
                              assistant['profileImageUrl'] != ''
                          ? NetworkImage(assistant['profileImageUrl'])
                          : (assistant['image'] != null &&
                                      assistant['image'] != ''
                                  ? NetworkImage(assistant['image'])
                                  : const AssetImage(
                                      'assets/images/doctor1.jpg'))
                              as ImageProvider,
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            assistant['name'] ?? 'Assistant Name',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            assistant['email'] ?? '',
                            style: const TextStyle(
                                fontSize: 14, color: Colors.grey),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            assistant['phone'] ?? '',
                            style: const TextStyle(
                                fontSize: 13, color: Colors.teal),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
