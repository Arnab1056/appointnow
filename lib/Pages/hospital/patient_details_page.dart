import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PatientDetailsPage extends StatelessWidget {
  final Map<String, dynamic> patient;
  final int serialNumber;
  final String appointmentDate;
  final String appointmentDay;
  final String appointmentTime;

  const PatientDetailsPage({
    Key? key,
    required this.patient,
    required this.serialNumber,
    required this.appointmentDate,
    required this.appointmentDay,
    required this.appointmentTime,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _fetchPatientDetails(patient),
      builder: (context, snapshot) {
        final dbPatient = snapshot.data ?? patient;
        return Scaffold(
          appBar: AppBar(
            title: Text('Patient Details',
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600, color: Colors.black)),
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
            centerTitle: true,
            leading: const BackButton(color: Colors.black),
          ),
          backgroundColor: Colors.white,
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 40,
                    backgroundColor: Colors.teal.shade50,
                    backgroundImage:
                        dbPatient['imageUrl'] != null && dbPatient['imageUrl'] != ''
                            ? NetworkImage(dbPatient['imageUrl']) as ImageProvider
                            : const AssetImage('assets/icon/Doctor.png'),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: Text(
                    dbPatient['patientName'] ?? 'Patient Name',
                    style: GoogleFonts.poppins(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    dbPatient['gender'] != null ? 'Gender: ${dbPatient['gender']}' : '',
                    style:
                        GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700]),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    dbPatient['age'] != null ? 'Age: ${dbPatient['age']}' : '',
                    style:
                        GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700]),
                  ),
                ),
                const SizedBox(height: 24),
                Divider(),
                ListTile(
                  leading: Icon(Icons.confirmation_number, color: Colors.teal),
                  title: Text('Serial Number',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                  subtitle:
                      Text(serialNumber.toString(), style: GoogleFonts.poppins()),
                ),
                ListTile(
                  leading: Icon(Icons.calendar_today, color: Colors.teal),
                  title: Text('Appointment Date',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                  subtitle: Text('$appointmentDay, $appointmentDate',
                      style: GoogleFonts.poppins()),
                ),
                ListTile(
                  leading: Icon(Icons.access_time, color: Colors.teal),
                  title: Text('Appointment Time',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                  subtitle: Text(appointmentTime, style: GoogleFonts.poppins()),
                ),
                if (dbPatient['phone'] != null && dbPatient['phone'] != '')
                  ListTile(
                    leading: Icon(Icons.phone, color: Colors.teal),
                    title: Text('Phone',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                    subtitle: Text(dbPatient['phone'], style: GoogleFonts.poppins()),
                  ),
                if (dbPatient['address'] != null && dbPatient['address'] != '')
                  ListTile(
                    leading: Icon(Icons.location_on, color: Colors.teal),
                    title: Text('Address',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                    subtitle:
                        Text(dbPatient['address'], style: GoogleFonts.poppins()),
                  ),
                if (dbPatient['notes'] != null && dbPatient['notes'] != '')
                  ListTile(
                    leading: Icon(Icons.note, color: Colors.teal),
                    title: Text('Notes',
                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                    subtitle: Text(dbPatient['notes'], style: GoogleFonts.poppins()),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<Map<String, dynamic>?> _fetchPatientDetails(Map<String, dynamic> patient) async {
    if (patient['patientUid'] != null && patient['patientUid'].toString().isNotEmpty) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(patient['patientUid']).get();
      if (doc.exists) {
        final dbData = doc.data() ?? {};
        // Merge Firestore user data with appointment data, appointment data takes precedence
        return {...dbData, ...patient};
      }
    }
    return patient;
  }
}
