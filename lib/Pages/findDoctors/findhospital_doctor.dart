import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FindHospitalDoctorsPage extends StatelessWidget {
  final Map<String, dynamic> hospital;
  final Color primaryColor = Color(0xFF009E7F);

  FindHospitalDoctorsPage({Key? key, required this.hospital}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: BackButton(color: Colors.black),
        title: Text(hospital['name'] ?? "Find Doctors",
            style: GoogleFonts.poppins(
                color: Colors.black, fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
              onPressed: () {},
              icon: Icon(Icons.more_vert, color: Colors.black))
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHospitalCard(),
            SizedBox(height: 20),
            Text("About",
                style: GoogleFonts.poppins(
                    fontSize: 16, fontWeight: FontWeight.w600)),
            SizedBox(height: 8),
            Text(
              hospital['about'] ?? "No description available.",
              style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[700]),
            ),
            SizedBox(height: 24),
            _buildSectionHeader("Doctors Category"),
            SizedBox(height: 12),
            _buildIconGrid([
              'General',
              'Lungs Specialist',
              'Dentist',
              'Psychiatrist',
              'Covid-19',
              'Surgeon',
              'Cardiologist',
              'Alargy',
            ]),
            SizedBox(height: 24),
            if (hospital['hasLab'] == true) ...[
              _buildSectionHeader("Laboratory"),
              SizedBox(height: 12),
              _buildIconGrid([
                'X-Ray',
                'MRI',
                'ECO',
                'Blood Test',
                'Pressure',
                'Urine Test',
                'CT-Scan',
                'Endoscopy',
              ]),
            ],
            if (hospital['hasCabin'] == true) ...[
              SizedBox(height: 24),
              _buildSectionHeader("Cabin Facilities"),
              SizedBox(height: 12),
              Text('Cabin facilities are available in this hospital.',
                  style: GoogleFonts.poppins(
                      fontSize: 13, color: Colors.grey[700])),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHospitalCard() {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.grey.shade200, blurRadius: 10)],
        color: Colors.white,
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: hospital['profileImageUrl'] != null &&
                    hospital['profileImageUrl'] != ''
                ? Image.network(hospital['profileImageUrl'],
                    height: 80, width: 80, fit: BoxFit.cover)
                : Image.asset("assets/hospital.jpg",
                    height: 80, width: 80, fit: BoxFit.cover),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(hospital['name'] ?? "",
                    style: GoogleFonts.poppins(
                        fontSize: 16, fontWeight: FontWeight.w600)),
                Text(hospital['location'] ?? "",
                    style: GoogleFonts.poppins(color: Colors.grey[600])),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.green, size: 16),
                    Text(
                      hospital['rating'] != null
                          ? ' ${hospital['rating'].toStringAsFixed(1)}'
                          : ' No rating',
                      style: GoogleFonts.poppins(fontSize: 13),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.location_on_outlined,
                        size: 16, color: Colors.grey),
                    Text(
                        hospital['distance'] != null
                            ? ' ${hospital['distance']}'
                            : '',
                        style: GoogleFonts.poppins(
                            fontSize: 12, color: Colors.grey[700])),
                  ],
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style:
                GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600)),
        Text("See all",
            style: GoogleFonts.poppins(
                fontSize: 13, color: primaryColor, fontWeight: FontWeight.w500))
      ],
    );
  }

  Widget _buildIconGrid(List<String> labels) {
    return GridView.count(
      crossAxisCount: 4,
      mainAxisSpacing: 20,
      crossAxisSpacing: 10,
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      children: List.generate(labels.length, (index) {
        return Column(
          children: [
            Container(
              height: 46,
              width: 46,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: primaryColor.withOpacity(0.1),
              ),
              child: Icon(Icons.medical_services_outlined, color: primaryColor),
            ),
            SizedBox(height: 6),
            Text(labels[index],
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 11)),
          ],
        );
      }),
    );
  }
}
