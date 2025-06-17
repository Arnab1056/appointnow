import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AppointmentRequestsPage extends StatelessWidget {
  final String hospitalId;
  const AppointmentRequestsPage({Key? key, required this.hospitalId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Appointment Requests',
            style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.more_vert), onPressed: () {}),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('serial')
            .where('hospitalId', isEqualTo: hospitalId)
            .where('status', isEqualTo: 'pending')
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
              return _appointmentCard(context, doc, data);
            },
          );
        },
      ),
    );
  }

  Widget _appointmentCard(BuildContext context, QueryDocumentSnapshot doc,
      Map<String, dynamic> data) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
             Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.teal,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Text(data['day'] ?? '',
                                style: const TextStyle(color: Colors.white)),
                            Text(data['date'] ?? '',
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 18)),
                          ],
                        ),
                      ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(data['patientName'] ?? 'Patient Name',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text(
                      '${data['day'] ?? ''}, ${data['date'] ?? ''} | ${data['time'] ?? ''}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_city_rounded, color: Colors.teal, size: 16),
                      const SizedBox(width: 4),
                      Text(data['hospitalName'] ?? '',
                          style: TextStyle(fontSize: 12, color: Colors.black,fontWeight: FontWeight.w800)),
                    ],
                  ),
                  if (data['reason'] != null &&
                      data['reason'].toString().isNotEmpty)
                    Text('Reason: ${data['reason']}',
                        style: const TextStyle(fontSize: 12)),
                  const SizedBox(height: 4),
                  // Only doctor name and time box
                  Row(
                    children: [
                      Icon(Icons.person, color: Colors.teal, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        data['doctorName'] ?? 'Doctor',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.teal,
                        ),
                      ),
                      const Spacer(),
                     
                    ],
                  ),
                ],
              ),
            ),
            Column(
              children: [
                ElevatedButton(
                  onPressed: () async {
                    // Accept logic
                    final acceptedQuery = await FirebaseFirestore.instance
                        .collection('serial')
                        .where('doctorId', isEqualTo: data['doctorId'])
                        .where('date', isEqualTo: data['date'])
                        .where('day', isEqualTo: data['day'])
                        .where('time', isEqualTo: data['time'])
                        .where('status', isEqualTo: 'accepted')
                        .get();
                    final serialNumber = acceptedQuery.docs.length + 1;
                    await doc.reference.update(
                        {'status': 'accepted', 'serialNumber': serialNumber});
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                'Appointment accepted. Serial: $serialNumber')),
                      );
                    }
                  },
                  child: const Text(
                    "Accept",
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    shape: const StadiumBorder(),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  ),
                ),
                const SizedBox(height: 6),
                OutlinedButton(
                  onPressed: () async {
                    await doc.reference.update({'status': 'rejected'});
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Appointment rejected.')),
                      );
                    }
                  },
                  child: const Text("Decline",
                      style: TextStyle(
                        color: Colors.grey,
                      )),
                  style: OutlinedButton.styleFrom(
                    shape: const StadiumBorder(),
                    side: const BorderSide(color: Colors.grey),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  ),
                ),
              ],
            ),
            
          ],
        ),
      ),
    );
  }
}
