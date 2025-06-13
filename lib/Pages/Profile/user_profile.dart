import 'package:appointnow/pages/index/homepage.dart';
import 'package:flutter/material.dart';
import 'package:appointnow/pages/auth/login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:appointnow/Pages/widgets/app_bottom_navigation_bar.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:appointnow/Pages/doctor/doctor_home.dart';
import 'package:appointnow/Pages/Profile/user_appoinments.dart';
// Make sure the import path is correct and matches the file where UserAppointmentsPage is defined.

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  int _currentIndex = 3;
  String? _userName;
  String? _profileImageUrl;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchUserName();
    _fetchProfileImageUrl();
  }

  Future<void> _fetchUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Fetch user data from Firestore using the logged-in user's UID
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      // You can access the user id as user.uid
      // Example: print('Current user id: ' + user.uid);
      setState(() {
        _userName = doc.data()?['name'] ?? 'No Name';
        _isLoading = false;
      });
    } else {
      setState(() {
        _userName = 'No Name';
        _isLoading = false;
      });
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
      });
    }
  }

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
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
    final resizedFile =
        await File('${file.parent.path}/resized_${file.uri.pathSegments.last}')
            .writeAsBytes(resizedBytes);

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
    final storagePath = await supabase.Supabase.instance.client.storage
        .from('appointnow')
        .upload(fileName, resizedFile);
    if (storagePath.isNotEmpty) {
      final imageUrl = supabase.Supabase.instance.client.storage
          .from('appointnow')
          .getPublicUrl(fileName);
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'profileImageUrl': imageUrl, 'profileImageName': fileName});
      setState(() {
        _profileImageUrl = imageUrl;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
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
                    GestureDetector(
                      onTap: _pickAndUploadImage,
                      child: CircleAvatar(
                        radius: 60,
                        backgroundImage: _profileImageUrl != null
                            ? NetworkImage(_profileImageUrl!)
                            : const AssetImage('assets/profile.jpg')
                                as ImageProvider,
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
                    const SizedBox(height: 10),
                    _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            _userName ?? '',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 25,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.bold,
                            ),
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
                child: StreamBuilder<DocumentSnapshot>(
                  stream: user != null
                      ? FirebaseFirestore.instance
                          .collection('users')
                          .doc(user.uid)
                          .snapshots()
                      : const Stream.empty(),
                  builder: (context, snapshot) {
                    // You can use snapshot.data to auto-refresh user info if needed
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        _buildListTile(Icons.favorite_border, 'My Saved',
                            iconSize: 20.0, iconColor: const Color(0xFF00B5A2)),
                        _buildListTile(Icons.calendar_today_outlined, 'Appointment',
                            iconSize: 20.0, iconColor: const Color(0xFF00B5A2)),
                        _buildListTile(Icons.payment_outlined, 'Payment Method',
                            iconSize: 20.0, iconColor: const Color(0xFF00B5A2)),
                        _buildListTile(Icons.question_answer_outlined, 'FAQs',
                            iconSize: 20.0, iconColor: const Color(0xFF00B5A2)),
                        _buildListTile(Icons.logout, 'Logout',
                            iconSize: 20.0, iconColor: Colors.red),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AppBottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == _currentIndex) return; // Prevent unnecessary navigation
          setState(() {
            _currentIndex = index;
          });
          switch (index) {
            case 0:
              _navigateToHome(context);
              break;
            case 3:
              break;
            default:
              break;
          }
        },
      ),
    );
  }

  // ✅ ADDED: Logout Dialog Function
  void showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          insetPadding:
              const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
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
                    Navigator.of(context).pop(); // Close the dialog
                    await FirebaseAuth.instance.signOut();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const LoginPage()),
                      (route) => false, // Removes all previous routes
                    );
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

  // Logout tile triggers dialog
  Widget _buildListTile(IconData icon, String title,
      {Color color = Colors.black, double iconSize = 24.0, Color? iconColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5.0),
      child: MouseRegion(
        onEnter: (_) => setState(() {}),
        onExit: (_) => setState(() {}),
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
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              if (title == 'Logout') {
                showLogoutDialog(context); // ✅ show dialog here
              } else if (title == 'Appointment') {
                final user = FirebaseAuth.instance.currentUser;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                      UserAppointmentsPage(userId: user?.uid ?? ''),
                  ),
                );
              } else {
                // TODO: Handle other tile taps
              }
            },
          ),
        ),
      ),
    );
  }

  void _navigateToHome(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final role = doc.data()?['role'] as String?;
      if (role == 'doctor') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Doctorhome()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    }
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
