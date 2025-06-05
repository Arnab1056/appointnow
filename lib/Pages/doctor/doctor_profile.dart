import 'package:appointnow/Pages/doctor/doctorprofile_edit.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:appointnow/Pages/widgets/app_bottom_navigation_bar.dart';
import 'package:appointnow/Pages/doctor/doctor_home.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class DoctorProfilePage extends StatefulWidget {
  const DoctorProfilePage({super.key});

  @override
  State<DoctorProfilePage> createState() => _DoctorProfilePageState();
}

class _DoctorProfilePageState extends State<DoctorProfilePage> {
  int _currentIndex = 3;
  String? _doctorName;
  String? _specialization;
  String? _profileImageUrl;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDoctorProfile();
  }

  Future<void> _fetchDoctorProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      setState(() {
        _doctorName = doc.data()?['name'] ?? 'No Name';
        _specialization = doc.data()?['specialization'] ?? 'Specialist';
        _profileImageUrl = doc.data()?['profileImageUrl'];
        _isLoading = false;
      });
    } else {
      setState(() {
        _doctorName = 'No Name';
        _specialization = 'Specialist';
        _isLoading = false;
      });
    }
  }

  // Pick and upload new profile image
  Future<void> _pickProfileImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final file = File(pickedFile.path);
    // Optionally resize image here if needed
    final fileName =
        'doctor_profile_${user.uid}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    // Upload to your storage (implement as needed)
    // For now, just update Firestore with a fake URL
    await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
      'profileImageUrl': file.path, // Replace with real URL after upload
    });
    setState(() {
      _profileImageUrl = file.path;
    });
  }

  // Show dialog to edit profile
  void _showEditProfileDialog() {
    final nameController = TextEditingController(text: _doctorName);
    final specController = TextEditingController(text: _specialization);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Profile'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: specController,
                decoration: const InputDecoration(labelText: 'Specialization'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(user.uid)
                      .update({
                    'name': nameController.text.trim(),
                    'specialization': specController.text.trim(),
                  });
                  setState(() {
                    _doctorName = nameController.text.trim();
                    _specialization = specController.text.trim();
                  });
                }
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00B5A2),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF00B5A2), Color(0xFF00B5A2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundImage: _profileImageUrl != null
                              ? NetworkImage(_profileImageUrl!)
                              : const AssetImage('assets/profile.jpg')
                                  as ImageProvider,
                        ),
                        Positioned(
                          bottom: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: _pickProfileImage,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.1),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(6),
                              child: const Icon(Icons.camera_alt,
                                  color: Colors.teal, size: 24),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _doctorName ?? '',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 25,
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  GestureDetector(
                                    onTap: _showEditProfileDialog,
                                    child: const Icon(Icons.edit,
                                        color: Colors.white, size: 20),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _specialization ?? '',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                    const SizedBox(height: 180),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                height: 400,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 25),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    _buildListTile(
                      Icons.calendar_today_outlined,
                      'My Appointments',
                      onTap: () {
                        // TODO: Handle My Appointments tap
                      },
                    ),
                    _buildListTile(
                      Icons.edit,
                      'Edit Profile',
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const DoctorProfileEdit(), // from doctorprofile_edit.dart
                          ),
                        );
                      },
                    ),
                    _buildListTile(Icons.payment_outlined, 'Payment Method'),
                    _buildListTile(Icons.question_answer_outlined, 'FAQs'),
                    _buildListTile(Icons.logout, 'Logout',
                        iconColor: Colors.red),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == _currentIndex) return;
          setState(() {
            _currentIndex = index;
          });
          switch (index) {
            case 0:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const Doctorhome()),
              );
              break;
            case 3:
              // Already on profile
              break;
            default:
              break;
          }
        },
      ),
    );
  }

  // Update _buildListTile to accept onTap parameter and trailingWidget optional:
  Widget _buildListTile(IconData icon, String title,
      {Color color = Colors.black,
      double iconSize = 24.0,
      Color? iconColor,
      Widget? trailingWidget,
      VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: ListTile(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          leading: Container(
            width: 43.0,
            height: 43.0,
            decoration: BoxDecoration(
              color: const Color(0xFFE5F8F6),
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Icon(icon,
                color: iconColor ?? const Color(0xFF00B5A2), size: iconSize),
          ),
          title: Text(title,
              style: TextStyle(fontWeight: FontWeight.normal, color: color)),
          trailing:
              trailingWidget ?? const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: onTap ??
              () {
                if (title == 'Logout') {
                  _showLogoutDialog(context);
                } else if (title == 'Edit Profile') {
                  // This is now handled by the passed onTap
                } else {
                  // TODO: Handle other tile taps
                }
              },
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            padding: const EdgeInsets.all(20),
            width: MediaQuery.of(context).size.width * 0.8,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.teal.withOpacity(0.1),
                  radius: 30,
                  child: const Icon(Icons.logout, size: 30, color: Colors.teal),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Are you sure to log out of your account?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await FirebaseAuth.instance.signOut();
                    Navigator.pushNamedAndRemoveUntil(
                        context, '/', (route) => false);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 12),
                  ),
                  child: const Text("Log Out",
                      style: TextStyle(color: Colors.white)),
                ),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: const Text(
                    "Cancel",
                    style: TextStyle(color: Colors.teal, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
