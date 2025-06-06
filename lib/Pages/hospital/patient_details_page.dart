import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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
                    patient['imageUrl'] != null && patient['imageUrl'] != ''
                        ? NetworkImage(patient['imageUrl']) as ImageProvider
                        : const AssetImage('assets/icon/Doctor.png'),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Text(
                patient['name'] ?? 'Patient Name',
                style: GoogleFonts.poppins(
                    fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                patient['gender'] != null ? 'Gender: ${patient['gender']}' : '',
                style:
                    GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700]),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                patient['age'] != null ? 'Age: ${patient['age']}' : '',
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
            if (patient['phone'] != null && patient['phone'] != '')
              ListTile(
                leading: Icon(Icons.phone, color: Colors.teal),
                title: Text('Phone',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                subtitle: Text(patient['phone'], style: GoogleFonts.poppins()),
              ),
            if (patient['address'] != null && patient['address'] != '')
              ListTile(
                leading: Icon(Icons.location_on, color: Colors.teal),
                title: Text('Address',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                subtitle:
                    Text(patient['address'], style: GoogleFonts.poppins()),
              ),
            if (patient['notes'] != null && patient['notes'] != '')
              ListTile(
                leading: Icon(Icons.note, color: Colors.teal),
                title: Text('Notes',
                    style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                subtitle: Text(patient['notes'], style: GoogleFonts.poppins()),
              ),
          ],
        ),
      ),
    );
  }
}
