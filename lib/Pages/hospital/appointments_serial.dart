import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:appointnow/Pages/hospital/patient_details_page.dart';

class AppointmentsSerialPage extends StatefulWidget {
  final String doctorName;
  final String doctorDesignation;
  final String doctorImage;
  final double avgRating;
  final int totalRatings;
  final Color primaryColor;
  final String hospitalId; // Renamed from hospitalName

  AppointmentsSerialPage({
    Key? key,
    required this.doctorName,
    required this.doctorDesignation,
    required this.doctorImage,
    required this.avgRating,
    required this.totalRatings,
    required this.hospitalId, // Renamed from hospitalName
    this.primaryColor = const Color(0xFF009E7F),
  }) : super(key: key);

  @override
  State<AppointmentsSerialPage> createState() => _AppointmentsSerialPageState();
}

class _AppointmentsSerialPageState extends State<AppointmentsSerialPage> {
  int selectedSerial = 1;
  int appointmentCount = 0;
  List<Map<String, dynamic>> appointments = [];
  String? selectedDate;
  String? selectedDay;

  @override
  void initState() {
    super.initState();
    _fetchAppointments();
  }

  Future<void> _fetchAppointments() async {
    // Use doctorId and hospitalId from the serial collection fields
    final doctorId = widget.doctorName; // This should be doctorId, but widget.doctorName is used as a param. If you have doctorId, use it here.
    final hospitalId = widget.hospitalId;
    // Fetch from 'serial' collection using doctorName and hospitalId, and only accepted
    final query = await FirebaseFirestore.instance
        .collection('serial')
        .where('doctorName', isEqualTo: doctorId)
        .where('hospitalId', isEqualTo: hospitalId)
        .where('status', isEqualTo: 'accepted')
        .get();
    final docs = query.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    setState(() {
      appointments = docs;
      appointmentCount = docs.length;
      if (appointments.isNotEmpty) {
        selectedDate = appointments[0]['date'];
        selectedDay = appointments[0]['day'];
      }
    });
  }

  List<Map<String, dynamic>> get _filteredAppointments {
    if (selectedDate == null) return [];
    // Filter by date and day for accuracy
    return appointments.where((a) => a['date'] == selectedDate && a['day'] == selectedDay).toList();
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
        body: Column(
          children: [
            _buildDoctorCard(),
            if (appointments.isNotEmpty) _buildDateSelector(),
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
        ),
      ),
    );
  }

  Widget _buildDateSelector() {
    final uniqueDates = <Map<String, String>>[];
    final seen = <String>{};
    for (final a in appointments) {
      final key = a['day'] ?? '';
      if (!seen.contains(key)) {
        seen.add(key);
        uniqueDates.add({'date': a['date'], 'day': a['day']});
      }
    }
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: uniqueDates.map((d) {
          final isSelected = d['date'] == selectedDate;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                backgroundColor:
                    isSelected ? widget.primaryColor : Colors.white,
                side: BorderSide(color: widget.primaryColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                setState(() {
                  selectedDate = d['date'];
                  selectedDay = d['day'];
                  selectedSerial = 1;
                });
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    d['day'] ?? '',
                    style: GoogleFonts.poppins(
                        color: isSelected ? Colors.white : widget.primaryColor,
                        fontWeight: FontWeight.w600),
                  ),
                  Text(
                    d['date'] ?? '',
                    style: GoogleFonts.poppins(
                        color: isSelected ? Colors.white : widget.primaryColor,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          );
        }).toList(),
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
    final filtered = _filteredAppointments;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        itemCount: filtered.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 6, mainAxisSpacing: 12, crossAxisSpacing: 12),
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          int serial = index + 1;
          bool selected = serial == selectedSerial;
          final patient = filtered[index];
          return GestureDetector(
            onTap: () {
              setState(() {
                selectedSerial = serial;
              });
            },
            onLongPress: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => PatientDetailsPage(
                    patient: patient,
                    serialNumber: serial,
                    appointmentDate: patient['date'] ?? '',
                    appointmentDay: patient['day'] ?? '',
                    appointmentTime: patient['time'] ?? '', // Use 'time' field from serial
                  ),
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: selected ? widget.primaryColor : Colors.white,
                border: Border.all(
                    color:
                        selected ? Colors.transparent : Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              alignment: Alignment.center,
              child: Text(
                serial.toString(),
                style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: selected ? Colors.white : Colors.black),
              ),
            ),
          );
        },
      ),
    );
  }
}
