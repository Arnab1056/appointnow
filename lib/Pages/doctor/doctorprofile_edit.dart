import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:image/image.dart' as img;

class DoctorProfileEdit extends StatefulWidget {
  const DoctorProfileEdit({super.key});

  @override
  State<DoctorProfileEdit> createState() => _DoctorProfileEditState();
}

class _DoctorProfileEditState extends State<DoctorProfileEdit> {
  String? _profileImageUrl;
  String? _profileImageName;
  bool _isLoading = true;
  final ImagePicker _picker = ImagePicker();

  // Controllers for form fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _registerController = TextEditingController();
  final TextEditingController _designationController = TextEditingController();

  bool _agreedToTerms = false;

  @override
  void initState() {
    super.initState();
    _fetchProfileImageUrl();
    _fetchDoctorDetails();
  }

  Future<void> _fetchDoctorDetails() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('doctordetails')
          .doc(user.uid)
          .get();
      final data = doc.data();
      if (data != null) {
        _nameController.text = data['name'] ?? '';
        _emailController.text = data['email'] ?? '';
        _phoneController.text = data['phone'] ?? '';
        _registerController.text = data['registerNumber'] ?? '';
        _designationController.text = data['designation'] ?? '';
      }
    }
  }

  Future<void> _saveDoctorDetails() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    await FirebaseFirestore.instance
        .collection('doctordetails')
        .doc(user.uid)
        .set({
      'uid': user.uid,
      'name': _nameController.text.trim(),
      'email': _emailController.text.trim(),
      'phone': _phoneController.text.trim(),
      'registerNumber': _registerController.text.trim(),
      'designation': _designationController.text.trim(),
      'profileImageUrl': _profileImageUrl ?? '', // Ensure this is set
      'profileImageName': _profileImageName ?? '',
      'timestamp': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile saved successfully!')),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _registerController.dispose();
    _designationController.dispose();
    super.dispose();
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
      // Delete previous image from Supabase Storage
      await supabase.Supabase.instance.client.storage
          .from('appointnow')
          .remove([prevImageName]);
    }

    final fileName =
        'profile_${user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    final storageResponse = await supabase.Supabase.instance.client.storage
        .from('appointnow')
        .uploadBinary(fileName, resizedBytes,
            fileOptions: const supabase.FileOptions(contentType: 'image/jpeg'));
    if (storageResponse.isNotEmpty) {
      final imageUrl = supabase.Supabase.instance.client.storage
          .from('appointnow')
          .getPublicUrl(fileName);
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'profileImageUrl': imageUrl, 'profileImageName': fileName});
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
      return const AssetImage('assets/doctor.jpg');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        centerTitle: true,
        title: const Text(
          'Doctor Profile',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            const SizedBox(height: 10),
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
            const SizedBox(height: 10),
            _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text(
                    'Doctor Name',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),

            const SizedBox(height: 20),

            // About Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  'About',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                Text(
                  'Change',
                  style: TextStyle(color: Colors.teal),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text:
                        'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. ',
                  ),
                  TextSpan(
                    text: 'Read more',
                    style: TextStyle(color: Colors.teal),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Form Fields
            CustomTextField(
              icon: Icons.person_outline,
              hint: 'Doctor name',
              controller: _nameController,
            ),
            CustomTextField(
              icon: Icons.email_outlined,
              hint: 'Email',
              controller: _emailController,
            ),
            CustomTextField(
              icon: Icons.phone_outlined,
              hint: 'Phone',
              controller: _phoneController,
            ),
            CustomTextField(
              icon: Icons.badge_outlined,
              hint: 'Register Number',
              controller: _registerController,
            ),
            CustomTextField(
              icon: Icons.work_outline,
              hint: 'Designation',
              controller: _designationController,
            ),
            const SizedBox(height: 10),

            // Terms Checkbox
            Row(
              children: [
                Checkbox(
                  value: _agreedToTerms,
                  onChanged: (val) {
                    setState(() {
                      _agreedToTerms = val ?? false;
                    });
                  },
                ),
                const Flexible(
                  child: Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(text: 'I agree to the medidoc '),
                        TextSpan(
                          text: 'Terms of Service',
                          style: TextStyle(color: Colors.teal),
                        ),
                        TextSpan(text: ' and '),
                        TextSpan(
                          text: 'Privacy Policy',
                          style: TextStyle(color: Colors.teal),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _agreedToTerms ? _saveDoctorDetails : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Save', style: TextStyle(fontSize: 16)),
              ),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

class CustomTextField extends StatelessWidget {
  final IconData icon;
  final String hint;
  final TextEditingController? controller;

  const CustomTextField(
      {super.key, required this.icon, required this.hint, this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          prefixIcon: Icon(icon),
          hintText: hint,
          filled: true,
          fillColor: Colors.grey[100],
          contentPadding: const EdgeInsets.symmetric(vertical: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
