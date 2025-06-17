import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:image/image.dart' as img;

class AmbulanceProfileEditPage extends StatefulWidget {
  @override
  _AmbulanceProfileEditPageState createState() =>
      _AmbulanceProfileEditPageState();
}

class _AmbulanceProfileEditPageState extends State<AmbulanceProfileEditPage> {
  bool isChecked = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _hotlineController = TextEditingController();
  final TextEditingController _registerController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  String? _profileImageUrl;
  String? _profileImageName;
  bool _isLoading = true;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fetchProfileImageUrl();
    _fetchAmbulanceDetails();
  }

  Future<void> _fetchAmbulanceDetails() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('ambulance_details')
          .doc(user.uid)
          .get();
      final data = doc.data();
      if (data != null) {
        _nameController.text = data['name'] ?? '';
        _emailController.text = data['email'] ?? '';
        _hotlineController.text = data['hotline'] ?? '';
        _registerController.text = data['register_number'] ?? '';
        _locationController.text = data['location'] ?? '';
      }
      setState(() {});
    }
  }

  Future<void> _fetchProfileImageUrl() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      setState(() {
        _profileImageUrl = doc.data()?['profileImageUrl'];
        _profileImageName = doc.data()?['profileImageName'];
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickAndUploadImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final file = File(pickedFile.path);

    // Resize image to 300x300 before upload
    final originalBytes = await file.readAsBytes();
    final decodedImage = img.decodeImage(originalBytes);
    if (decodedImage == null) return;
    final resizedImage = img.copyResize(decodedImage, width: 300, height: 300);
    final resizedBytes = img.encodeJpg(resizedImage);

    // Get previous image name from Firestore
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .get();
    final prevImageName = doc.data()?['profileImageName'] as String?;
    if (prevImageName != null && prevImageName.isNotEmpty) {
      await supabase.Supabase.instance.client.storage
          .from('appointnow')
          .remove([prevImageName]);
    }

    final fileName =
        'ambulance_profile_${user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final storageResponse = await supabase.Supabase.instance.client.storage
        .from('appointnow')
        .uploadBinary(fileName, resizedBytes,
            fileOptions: const supabase.FileOptions(contentType: 'image/jpeg'));
    if (storageResponse.isNotEmpty) {
      final imageUrl = supabase.Supabase.instance.client.storage
          .from('appointnow')
          .getPublicUrl(fileName);
      // Update both users and ambulance_details collections
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'profileImageUrl': imageUrl, 'profileImageName': fileName});
      await FirebaseFirestore.instance
          .collection('ambulance_details')
          .doc(user.uid)
          .set({'profileImageUrl': imageUrl, 'profileImageName': fileName},
              SetOptions(merge: true));
      setState(() {
        _profileImageUrl = imageUrl;
        _profileImageName = fileName;
      });
    }
  }

  ImageProvider _getProfileImageProvider() {
    if (_profileImageUrl != null && _profileImageUrl!.isNotEmpty) {
      return NetworkImage(_profileImageUrl!);
    } else {
      return const AssetImage('assets/ambulance.jpg');
    }
  }

  Future<void> _saveAmbulanceDetails() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await FirebaseFirestore.instance
        .collection('ambulance_details')
        .doc(user.uid)
        .set({
      'name': _nameController.text.trim(),
      'email': _emailController.text.trim(),
      'hotline': _hotlineController.text.trim(),
      'register_number': _registerController.text.trim(),
      'location': _locationController.text.trim(),
      'uid': user.uid,
      'profileImageUrl': _profileImageUrl ?? '',
      'profileImageName': _profileImageName ?? '',
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Ambulance details saved!')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ambulance Profile'),
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            }),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            // Profile image
            Center(
              child: Stack(
                children: [
                  GestureDetector(
                    onTap: _pickAndUploadImage,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: _getProfileImageProvider(),
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(6),
                          child: const Icon(Icons.camera_alt,
                              color: Color(0xFF00B5A2)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 12),
            Text('Ambulance Name',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("About",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text("Change", style: TextStyle(color: Colors.teal)),
              ],
            ),
            SizedBox(height: 6),
            Text(
              'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam...',
              style: TextStyle(color: Colors.grey[600]),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text('Read more',
                  style: TextStyle(color: Colors.teal, fontSize: 13)),
            ),
            SizedBox(height: 20),

            // Input fields
            _buildTextField(
                Icons.local_hospital, "Ambulance name", _nameController),
            _buildTextField(Icons.email, "Email", _emailController),
            _buildTextField(Icons.phone, "Hot-Line Number", _hotlineController),
            _buildTextField(Icons.confirmation_number, "Register Number",
                _registerController),
            _buildTextField(
                Icons.confirmation_number, "Location", _locationController),

            SizedBox(height: 16),
            Row(
              children: [
                Checkbox(
                  value: isChecked,
                  onChanged: (val) {
                    setState(() => isChecked = val!);
                  },
                ),
                Expanded(
                  child: Wrap(
                    children: [
                      Text("I agree to the medidoc "),
                      GestureDetector(
                        onTap: () {}, // Add your Terms of Service URL
                        child: Text(
                          "Terms of Service",
                          style: TextStyle(color: Colors.teal),
                        ),
                      ),
                      Text(" and "),
                      GestureDetector(
                        onTap: () {}, // Add your Privacy Policy URL
                        child: Text(
                          "Privacy Policy",
                          style: TextStyle(color: Colors.teal),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isChecked ? _saveAmbulanceDetails : null,
                child: Text("Save"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  padding: EdgeInsets.symmetric(vertical: 14),
                  shape: StadiumBorder(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
      IconData icon, String hintText, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.grey),
          hintText: hintText,
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
