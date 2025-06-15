import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

class HospitalLabReportsPage extends StatefulWidget {
  final String laboratoryName;
  const HospitalLabReportsPage({Key? key, required this.laboratoryName})
      : super(key: key);

  @override
  State<HospitalLabReportsPage> createState() => _HospitalLabReportsPageState();
}

class _HospitalLabReportsPageState extends State<HospitalLabReportsPage> {
  String? get hospitalId => FirebaseAuth.instance.currentUser?.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.laboratoryName} Reports',
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600, color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            tooltip: 'Add Report',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  final _popupFormKey = GlobalKey<FormState>();
                  final TextEditingController _popupPatientNameController =
                      TextEditingController();
                  final TextEditingController _popupReportDetailsController =
                      TextEditingController();
                  final TextEditingController _popupPhoneController =
                      TextEditingController();
                  bool _popupSubmitting = false;
                  return StatefulBuilder(
                    builder: (context, setState) {
                      return AlertDialog(
                        title: Text('Add Report'),
                        content: Form(
                          key: _popupFormKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextFormField(
                                controller: _popupPatientNameController,
                                decoration: const InputDecoration(
                                  labelText: 'Patient Name',
                                ),
                                validator: (v) => v == null || v.isEmpty
                                    ? 'Enter patient name'
                                    : null,
                              ),
                              const SizedBox(height: 10),
                              TextFormField(
                                controller: _popupPhoneController,
                                decoration: const InputDecoration(
                                  labelText: 'Phone Number',
                                ),
                                keyboardType: TextInputType.phone,
                                validator: (v) => v == null || v.isEmpty
                                    ? 'Enter phone number'
                                    : null,
                              ),
                              const SizedBox(height: 10),
                              TextFormField(
                                controller: _popupReportDetailsController,
                                decoration: const InputDecoration(
                                  labelText: 'Report Details',
                                ),
                                maxLines: 3,
                                validator: (v) => v == null || v.isEmpty
                                    ? 'Enter report details'
                                    : null,
                              ),
                            ],
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: _popupSubmitting
                                ? null
                                : () async {
                                    if (_popupFormKey.currentState!
                                        .validate()) {
                                      setState(() => _popupSubmitting = true);
                                      final user =
                                          FirebaseAuth.instance.currentUser;
                                      String? phoneNumber;
                                      if (user != null) {
                                        // Try to get phone from users collection
                                        final userDoc = await FirebaseFirestore
                                            .instance
                                            .collection('users')
                                            .doc(user.uid)
                                            .get();
                                        phoneNumber = userDoc
                                                .data()?['phone'] ??
                                            _popupPhoneController.text.trim();
                                        await FirebaseFirestore.instance
                                            .collection('labreports')
                                            .add({
                                          'hospitalId': hospitalId,
                                          'laboratory': widget.laboratoryName,
                                          'patientName':
                                              _popupPatientNameController.text
                                                  .trim(),
                                          'phone': phoneNumber,
                                          'reportDetails':
                                              _popupReportDetailsController.text
                                                  .trim(),
                                          'createdAt':
                                              FieldValue.serverTimestamp(),
                                        });
                                        Navigator.pop(context);
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                              content: Text(
                                                  'Report added successfully!')),
                                        );
                                      }
                                      setState(() => _popupSubmitting = false);
                                    }
                                  },
                            child: _popupSubmitting
                                ? const SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2))
                                : const Text('Add'),
                          ),
                        ],
                      );
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24),
            Text('Reports',
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600, fontSize: 16)),
            const SizedBox(height: 10),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('labreports')
                    .where('laboratory', isEqualTo: widget.laboratoryName)
                    .orderBy('createdAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: \\${snapshot.error}'));
                  }
                  final reports = snapshot.data?.docs ?? [];
                  if (reports.isEmpty) {
                    return Center(child: Text('No reports found.'));
                  }
                  return ListView.builder(
                    itemCount: reports.length,
                    itemBuilder: (context, index) {
                      final report = reports[index];
                      final data = report.data() as Map<String, dynamic>;
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
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.check_circle,
                                    color: Colors.green),
                                tooltip: 'Mark as Done',
                                onPressed: () async {
                                  await FirebaseFirestore.instance
                                      .collection('labreports')
                                      .doc(report.id)
                                      .update({'done': true});
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Marked as done.')),
                                  );
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                tooltip: 'Delete',
                                onPressed: () async {
                                  await FirebaseFirestore.instance
                                      .collection('labreports')
                                      .doc(report.id)
                                      .delete();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Report deleted.')),
                                  );
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
            ),
          ],
        ),
      ),
    );
  }
}
