import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AboutHospitalPage extends StatelessWidget {
  final String hospitalId;
  final String? hospitalName;
  final String? location;
  final String? about;
  final String? imageUrl;
  final double? rating;

  const AboutHospitalPage({
    Key? key,
    required this.hospitalId,
    this.hospitalName,
    this.location,
    this.about,
    this.imageUrl,
    this.rating,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('hospitaldetails')
          .doc(hospitalId)
          .get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final data = snapshot.data?.data() as Map<String, dynamic>?;
        final name = data?['name'] ?? hospitalName ?? '';
        final loc = data?['location'] ?? location ?? '';
        final aboutText = data?['about'] ?? about ?? '';
        final img = data?['profileImageUrl'] ?? imageUrl ?? '';
        final rat = data?['rating'] is num
            ? (data?['rating'] as num).toDouble()
            : rating;
        final phone = data?['phone'] ?? '';
        final email = data?['email'] ?? '';
        final website = data?['website'] ?? '';
        final facilities = (data?['facilities'] is List)
            ? List<String>.from(data?['facilities'])
            : <String>[];
        final departments = (data?['departments'] is List)
            ? List<String>.from(data?['departments'])
            : <String>[];
        return Scaffold(
          appBar: AppBar(
            title: const Text(
              'About',
              style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 20,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            
            centerTitle: true,
            
            backgroundColor: Colors.white,
            foregroundColor: Colors.black,
            elevation: 0,
          ),
          backgroundColor: Colors.white,
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 60,
                    backgroundImage: (img.isNotEmpty)
                        ? NetworkImage(img)
                        : const AssetImage('assets/hospital.jpg')
                            as ImageProvider,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (loc.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.location_on,
                          color: Colors.grey, size: 18),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          loc,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
                if (rat != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 18),
                      const SizedBox(width: 4),
                      Text(
                        rat.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.amber,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
                if (phone.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.phone, color: Colors.teal, size: 18),
                      const SizedBox(width: 4),
                      Text(phone, style: const TextStyle(fontSize: 14)),
                    ],
                  ),
                ],
                if (email.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.email, color: Colors.teal, size: 18),
                      const SizedBox(width: 4),
                      Text(email, style: const TextStyle(fontSize: 14)),
                    ],
                  ),
                ],
                if (website.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.language, color: Colors.teal, size: 18),
                      const SizedBox(width: 4),
                      Text(website, style: const TextStyle(fontSize: 14)),
                    ],
                  ),
                ],
                const SizedBox(height: 24),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'About',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  aboutText.isNotEmpty ? aboutText : 'No details available.',
                  style: const TextStyle(fontSize: 15, color: Colors.black87),
                  textAlign: TextAlign.justify,
                ),
                if (facilities.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Facilities',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    children:
                        facilities.map((f) => Chip(label: Text(f))).toList(),
                  ),
                ],
                if (departments.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Departments',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    children:
                        departments.map((d) => Chip(label: Text(d))).toList(),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
