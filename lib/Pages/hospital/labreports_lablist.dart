import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:appointnow/Pages/Laboratory/hospital_labreports.dart'; // Import HospitalLabReportsPage

class LabReportsLabListPage extends StatelessWidget {
  const LabReportsLabListPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
        title: Text('Lab Reports',
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600, color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true,
      ),
      backgroundColor: Colors.white,
      body: user == null
          ? Center(child: Text('Not logged in'))
          : FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('hospitaldetails')
                  .doc(user.uid)
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (!snapshot.hasData || !snapshot.data!.exists) {
                  return Center(child: Text('No laboratory data found'));
                }
                final data = snapshot.data!.data() as Map<String, dynamic>?;
                final List labs = data?['laboratories'] ?? [];
                if (labs.isEmpty) {
                  return Center(child: Text('No laboratories added yet'));
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: labs.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: const Icon(Icons.science_outlined,
                          color: Color(0xFF009E7F)),
                      title: Text(labs[index],
                          style:
                              GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HospitalLabReportsPage(
                              laboratoryName: labs[index],
                            // Pass hospitalId to next page
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
    );
  }
}
