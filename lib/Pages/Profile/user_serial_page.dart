import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:appointnow/Pages/hospital/patient_details_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserSerialPage extends StatefulWidget {
  final String doctorName;
  final String doctorDesignation;
  final String doctorImage;
  final double avgRating;
  final int totalRatings;
  final Color primaryColor;
  final String hospitalId; // Renamed from hospitalName
  final String? initialDate;
  final String? initialDay;

  UserSerialPage({
    Key? key,
    required this.doctorName,
    required this.doctorDesignation,
    required this.doctorImage,
    required this.avgRating,
    required this.totalRatings,
    required this.hospitalId,
    this.primaryColor = const Color(0xFF009E7F),
    this.initialDate,
    this.initialDay,
  }) : super(key: key);

  @override
  State<UserSerialPage> createState() => _UserSerialPageState();
}

class _UserSerialPageState extends State<UserSerialPage> {
  int selectedSerial = 1;
  int appointmentCount = 0;
  List<Map<String, dynamic>> appointments = [];
  String? selectedDate;
  String? selectedDay;
  late final Stream<QuerySnapshot> _serialStream;

  @override
  void initState() {
    super.initState();
    _serialStream = FirebaseFirestore.instance
        .collection('serial')
        .where('doctorName', isEqualTo: widget.doctorName)
        .where('hospitalId', isEqualTo: widget.hospitalId)
        .where('status', isEqualTo: 'accepted')
        .snapshots();
    selectedDate = widget.initialDate;
    selectedDay = widget.initialDay;
  }

  List<Map<String, dynamic>> get _filteredAppointments {
    if (selectedDate == null) return [];
    // Filter by date and day for accuracy
    return appointments
        .where((a) => a['date'] == selectedDate && a['day'] == selectedDay)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading: BackButton(color: Colors.black),
          title: Text('Appointments',
              style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black)),
          centerTitle: true,
          backgroundColor: Colors.white,
          elevation: 0,
          actions: [
            IconButton(
                icon: Icon(Icons.shopping_cart_outlined, color: Colors.black),
                onPressed: () {}),
          ],
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: _serialStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Center(child: Text('No appointments found.'));
            }
            final docs = snapshot.data!.docs
                .map((doc) => doc.data() as Map<String, dynamic>)
                .toList();
            appointments = docs;
            appointmentCount = docs.length;
            if (appointments.isNotEmpty &&
                (selectedDate == null || selectedDay == null)) {
              selectedDate = appointments[0]['date'];
              selectedDay = appointments[0]['day'];
            }
            // Do not show the date selector at all in this context
            return Column(
              children: [
                _buildDoctorCard(),
                // Date selector removed
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Text(
                    "Patients (${_filteredAppointments.length})",
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600, fontSize: 16),
                  ),
                ),
                Expanded(child: _buildPatientGrid())
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildDoctorCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.grey.shade300, blurRadius: 8, offset: Offset(0, 4))
        ],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: Colors.grey[200],
            backgroundImage: widget.doctorImage.isNotEmpty
                ? NetworkImage(widget.doctorImage) as ImageProvider
                : const AssetImage('assets/doctor.jpg'),
            radius: 30,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.doctorName,
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600, fontSize: 16)),
                Text(widget.doctorDesignation,
                    style: GoogleFonts.poppins(
                        fontSize: 12, color: Colors.grey[600])),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.green, size: 16),
                    SizedBox(width: 4),
                    Text(widget.avgRating.toStringAsFixed(1),
                        style: GoogleFonts.poppins(
                            fontSize: 12, color: Colors.black)),
                    SizedBox(width: 8),
                    Text('(${widget.totalRatings} reviews)',
                        style: GoogleFonts.poppins(
                            fontSize: 12, color: Colors.grey[600])),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: widget.primaryColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Text(selectedDay ?? "-",
                    style:
                        GoogleFonts.poppins(fontSize: 12, color: Colors.white)),
                Text(selectedDate ?? "-",
                    style: GoogleFonts.poppins(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold))
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientGrid() {
    // Only show serials for the selected date and day
    final filtered = List<Map<String, dynamic>>.from(_filteredAppointments)
      ..sort((a, b) {
        int aSerial = int.tryParse(a['serialNumber']?.toString() ?? '') ?? 0;
        int bSerial = int.tryParse(b['serialNumber']?.toString() ?? '') ?? 0;
        return aSerial.compareTo(bSerial);
      });
    final currentUser = FirebaseAuth.instance.currentUser;
    final currentUid = currentUser?.uid;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        itemCount: filtered.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 6, mainAxisSpacing: 12, crossAxisSpacing: 12),
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          final patient = filtered[index];
          int serial = 1;
          if (patient['serialNumber'] != null &&
              patient['serialNumber'].toString().isNotEmpty) {
            serial =
                int.tryParse(patient['serialNumber'].toString()) ?? (index + 1);
          } else {
            serial = index + 1;
          }
          bool isCurrentUser = (patient['patientUid'] == currentUid);
          bool isSeen = patient['seen'] == true;
          Color bgColor;
          if (isCurrentUser) {
            bgColor = isSeen ? Colors.teal : Colors.yellow[700]!;
          } else {
            bgColor = isSeen ? Colors.teal : Colors.white;
          }
          return Container(
            decoration: BoxDecoration(
              color: bgColor,
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            margin: const EdgeInsets.all(2),
            child: Text(
              serial.toString(),
              style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color:
                      (isCurrentUser || isSeen) ? Colors.white : Colors.black),
            ),
          );
        },
      ),
    );
  }
}
