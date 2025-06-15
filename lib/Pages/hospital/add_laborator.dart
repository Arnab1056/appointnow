import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddLaboratoryPage extends StatelessWidget {
  final List<String> labCategories = const [
    'X-Ray',
    'MRI',
    'ECO',
    'Blood Test',
    'Pressure',
    'Urine Test',
    'CT-Scan',
    'Endoscopy',
    'Ultrasound',
    'Biopsy',
    'ECG',
    'Liver Function Test',
    'Kidney Function Test',
    'Thyroid Test',
    'Stool Test',
    'Sputum Test',
    'Glucose Test',
    'Cholesterol Test',
    'Allergy Test',
    'Hormone Test',
    'Vitamin D Test',
    'COVID-19 Test',
    'Dengue Test',
    'Malaria Test',
    'HIV Test',
    'Pregnancy Test',
    'Pathology',
    'Microbiology',
    'Serology',
    'Immunology',
    'Genetic Test',
    'Blood Grouping',
    'Platelet Count',
    'Hemoglobin Test',
    'CBC',
    'ESR',
    'Widal Test',
    'Lipid Profile',
    'Rheumatoid Factor',
    'Prothrombin Time',
    'PTT',
    'Blood Urea',
    'Creatinine',
    'Electrolyte Test',
    'Calcium Test',
    'Magnesium Test',
    'Phosphorus Test',
    'Iron Test',
    'Ferritin Test',
    'Bilirubin Test',
    'Amylase Test',
    'Lipase Test',
    'Troponin Test',
    'D-Dimer',
    'Hepatitis Test',
    'TORCH Test',
    'Pap Smear',
    'Semen Analysis',
    'Sickle Cell Test',
    'Mantoux Test',
    'PSA Test',
    'HBA1C',
    'C-Reactive Protein',
    'ANA Test',
    'HLA Typing',
    'Coombs Test',
    'Zinc Test',
    'Copper Test',
    'Lead Test',
    'Arsenic Test',
    'Drug Screening',
    'Tumor Marker',
    'Bone Marrow Test',
    'Sweat Chloride Test',
    'Genetic Screening',
    'Prenatal Screening',
    'Newborn Screening',
    'Hearing Test',
    'Vision Test',
    'Spirometry',
    'Allergen Panel',
    'Food Intolerance Test',
    'Autoimmune Panel',
    'Infectious Disease Panel',
    'Metabolic Panel',
    'Toxicology',
    'Histopathology',
    'Cytology',
    'Flow Cytometry',
    'PCR Test',
    'RT-PCR',
    'ELISA',
    'Western Blot',
    'Immunofluorescence',
    'Electrophoresis',
    'Blood Culture',
    'Urine Culture',
    'Sputum Culture',
    'Stool Culture',
    'CSF Analysis',
    'Ascitic Fluid Analysis',
    'Pleural Fluid Analysis',
    'Synovial Fluid Analysis',
    'Fine Needle Aspiration',
    'Bone Density Test',
    'PET Scan',
    'Mammography',
    'Angiography',
    'Doppler Test',
    'EEG',
    'EMG',
    'Nerve Conduction Study',
    'Sleep Study',
    'Holter Monitoring',
    'Tilt Table Test',
    'Cardiac Enzyme Test',
    'Lactate Test',
    'Ammonia Test',
    'Sweat Test',
    'Bence Jones Protein',
    'Myeloma Panel',
    'Thalassemia Test',
    'Genetic Counseling',
  ];

  final Color primaryColor = const Color(0xFF009E7F);

  AddLaboratoryPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    ValueNotifier<String> searchQuery = ValueNotifier('');
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: BackButton(color: Colors.black),
        title: Text('Add Laboratory',
            style: GoogleFonts.poppins(
                color: Colors.black, fontWeight: FontWeight.w600)),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Select Laboratory Category',
                style: GoogleFonts.poppins(
                    fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            // Search Bar
            ValueListenableBuilder<String>(
              valueListenable: searchQuery,
              builder: (context, value, _) {
                return TextField(
                  decoration: InputDecoration(
                    hintText: 'Search laboratory category...',
                    prefixIcon: Icon(Icons.search, color: primaryColor),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                  ),
                  onChanged: (q) => searchQuery.value = q,
                );
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ValueListenableBuilder<String>(
                valueListenable: searchQuery,
                builder: (context, query, _) {
                  final filtered = labCategories
                      .where((cat) =>
                          cat.toLowerCase().contains(query.toLowerCase()))
                      .toList();
                  return GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 16,
                    children: List.generate(filtered.length, (index) {
                      return GestureDetector(
                        onTap: () async {
                          final selectedLab = filtered[index];
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text('Add Laboratory'),
                                content: Text(
                                    'Do you want to add "$selectedLab" to your laboratories?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      if (user != null) {
                                        final docRef = FirebaseFirestore
                                            .instance
                                            .collection('hospitaldetails')
                                            .doc(user.uid);
                                        final docSnap = await docRef.get();
                                        final data = docSnap.data();
                                        List labs = (data != null &&
                                                data['laboratories'] != null)
                                            ? List.from(data['laboratories'])
                                            : [];
                                        if (!labs.contains(selectedLab)) {
                                          labs.add(selectedLab);
                                          await docRef
                                              .update({'laboratories': labs});
                                        }
                                      }
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                'Laboratory "$selectedLab" added.')),
                                      );
                                    },
                                    child: Text('Add'),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      if (user != null) {
                                        final docRef = FirebaseFirestore
                                            .instance
                                            .collection('hospitaldetails')
                                            .doc(user.uid);
                                        final docSnap = await docRef.get();
                                        final data = docSnap.data();
                                        List labs = (data != null &&
                                                data['laboratories'] != null)
                                            ? List.from(data['laboratories'])
                                            : [];
                                        if (labs.contains(selectedLab)) {
                                          labs.remove(selectedLab);
                                          await docRef
                                              .update({'laboratories': labs});
                                        }
                                      }
                                      Navigator.pop(context);
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        SnackBar(
                                            content: Text(
                                                'Laboratory "$selectedLab" deleted.')),
                                      );
                                    },
                                    child: Text('Delete',
                                        style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            color: primaryColor.withOpacity(0.08),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.shade100,
                                blurRadius: 6,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.science_outlined,
                                  color: primaryColor, size: 36),
                              const SizedBox(height: 10),
                              Text(
                                filtered[index],
                                textAlign: TextAlign.center,
                                style: GoogleFonts.poppins(
                                    fontSize: 14, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
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
