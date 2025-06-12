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
  final TextEditingController _aboutController = TextEditingController();
  String? _selectedDesignation;
  final List<String> _designationOptions = [
    'General',
    'Lungs',
    'Dentist',
    'Psychiatrist',
    'Covid-19',
    'Surgeon',
    'Cardiologist',
    'Allergy',
    'Neurologist',
    'Orthopedic',
    'Pediatrician',
    'Dermatologist',
    'ENT',
    'Ophthalmologist',
    'Gynecologist',
    'Urologist',
    'Oncologist',
    'Nephrologist',
    'Gastroenterologist',
    'Endocrinologist',
    'Other',
  ];

  bool _agreedToTerms = false;

  final List<bool> _selectedDays = List.generate(6, (i) => false); // Mon-Sat
  // Map to store multiple time ranges per day
  Map<String, List<Map<String, TimeOfDay?>>> _selectedTimeRangesPerDay = {};
  final List<String> _weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

  @override
  void initState() {
    super.initState();
    _fetchProfileImageUrl();
    _fetchDoctorDetailsAndAvailability();
    // Initialize time range map for each day
    for (final day in _weekDays) {
      _selectedTimeRangesPerDay[day] = [];
    }
  }

  Future<void> _fetchDoctorDetailsAndAvailability() async {
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
        _aboutController.text = data['about'] ?? '';
        final designation = data['designation'];
        if (_designationOptions.contains(designation)) {
          _selectedDesignation = designation;
        } else {
          _selectedDesignation = null;
        }
        // Restore available days
        if (data['availableDays'] != null && data['availableDays'] is List) {
          final List days = data['availableDays'];
          for (int i = 0; i < _weekDays.length; i++) {
            _selectedDays[i] = days.contains(_weekDays[i]);
          }
        }
        // Restore available time ranges per day (multiple slots)
        if (data['availableTimeRangesPerDay'] != null && data['availableTimeRangesPerDay'] is Map) {
          final Map rangesPerDay = data['availableTimeRangesPerDay'];
          for (final day in _weekDays) {
            final ranges = rangesPerDay[day];
            if (ranges is List) {
              _selectedTimeRangesPerDay[day] = ranges.map<Map<String, TimeOfDay?>>((range) {
                return {
                  'from': _parseTimeOfDay(range['from']),
                  'to': _parseTimeOfDay(range['to']),
                };
              }).toList();
            }
          }
        }
        setState(() {});
      }
    }
  }

  Future<void> _saveDoctorDetails() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Prepare selected days and times
    final selectedDays = <String>[];
    for (int i = 0; i < _selectedDays.length; i++) {
      if (_selectedDays[i]) selectedDays.add(_weekDays[i]);
    }
    // Prepare per-day time ranges (multiple slots)
    final Map<String, List<Map<String, String>>> selectedTimeRangesPerDay = {};
    for (final day in selectedDays) {
      final ranges = _selectedTimeRangesPerDay[day] ?? [];
      final validRanges = ranges.where((range) => range['from'] != null && range['to'] != null).toList();
      selectedTimeRangesPerDay[day] = validRanges.map((range) => {
        'from': _formatTimeOfDay(range['from']),
        'to': _formatTimeOfDay(range['to']),
      }).toList();
    }
    await FirebaseFirestore.instance
        .collection('doctordetails')
        .doc(user.uid)
        .set({
      'uid': user.uid,
      'name': _nameController.text.trim(),
      'email': _emailController.text.trim(),
      'phone': _phoneController.text.trim(),
      'registerNumber': _registerController.text.trim(),
      'designation': _selectedDesignation ?? _designationController.text.trim(),
      'about': _aboutController.text.trim(),
      'profileImageUrl': _profileImageUrl ?? '',
      'profileImageName': _profileImageName ?? '',
      'availableDays': selectedDays,
      'availableTimeRangesPerDay': selectedTimeRangesPerDay,
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
    _aboutController.dispose();
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
      // Update both users and doctordetails collections
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .update({'profileImageUrl': imageUrl, 'profileImageName': fileName});
      await FirebaseFirestore.instance
          .collection('doctordetails')
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
      return const AssetImage('assets/doctor.jpg');
    }
  }

  Widget _buildDaySelector() {
    return Wrap(
      spacing: 10,
      children: List.generate(_weekDays.length, (i) {
        return ChoiceChip(
          label: Text(_weekDays[i]),
          selected: _selectedDays[i],
          selectedColor: Colors.teal,
          labelStyle: TextStyle(
            color: _selectedDays[i] ? Colors.white : Colors.black,
            fontWeight: FontWeight.bold,
          ),
          onSelected: (selected) {
            setState(() {
              _selectedDays[i] = selected;
            });
          },
        );
      }),
    );
  }

  Widget _buildTimeRangeSelectorForDay(String day) {
    final ranges = _selectedTimeRangesPerDay[day] ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < ranges.length; i++)
          Row(
            children: [
              const Text('From:'),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: ranges[i]['from'] ?? TimeOfDay(hour: 9, minute: 0),
                  );
                  if (picked != null) {
                    setState(() {
                      ranges[i]['from'] = picked;
                      // If 'to' is before 'from', reset 'to'
                      if (ranges[i]['to'] != null && _compareTimeOfDay(ranges[i]['to']!, picked) <= 0) {
                        ranges[i]['to'] = null;
                      }
                    });
                  }
                },
                child: Text(ranges[i]['from'] != null ? _formatTimeOfDay(ranges[i]['from']) : 'Select'),
              ),
              const SizedBox(width: 16),
              const Text('To:'),
              const SizedBox(width: 8),
              ElevatedButton(
                onPressed: ranges[i]['from'] == null
                    ? null
                    : () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: ranges[i]['to'] ?? TimeOfDay(hour: ((ranges[i]['from']!.hour + 1) % 24), minute: ranges[i]['from']!.minute),
                        );
                        if (picked != null && _compareTimeOfDay(picked, ranges[i]['from']!) > 0) {
                          setState(() {
                            ranges[i]['to'] = picked;
                          });
                        }
                      },
                child: Text(ranges[i]['to'] != null ? _formatTimeOfDay(ranges[i]['to']) : 'Select'),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  setState(() {
                    ranges.removeAt(i);
                  });
                },
              ),
            ],
          ),
        TextButton.icon(
          onPressed: () {
            setState(() {
              ranges.add({'from': null, 'to': null});
            });
          },
          icon: const Icon(Icons.add, color: Colors.teal),
          label: const Text('Add Time Slot', style: TextStyle(color: Colors.teal)),
        ),
      ],
    );
  }

  int _compareTimeOfDay(TimeOfDay a, TimeOfDay b) {
    return a.hour == b.hour ? a.minute - b.minute : a.hour - b.hour;
  }

  TimeOfDay? _parseTimeOfDay(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) return null;
    final format = RegExp(r'^(\d{1,2}):(\d{2}) (AM|PM)\$');
    final match = format.firstMatch(timeStr);
    if (match != null) {
      int hour = int.parse(match.group(1)!);
      final int minute = int.parse(match.group(2)!);
      final String period = match.group(3)!;
      if (period == 'PM' && hour != 12) hour += 12;
      if (period == 'AM' && hour == 12) hour = 0;
      return TimeOfDay(hour: hour, minute: minute);
    }
    return null;
  }

  String _formatTimeOfDay(TimeOfDay? time) {
    if (time == null) return '';
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
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
              children: [
                const Text(
                  'About',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                TextButton(
                  onPressed: () async {
                    final about = await showDialog<String>(
                      context: context,
                      builder: (context) {
                        final controller =
                            TextEditingController(text: _aboutController.text);
                        return AlertDialog(
                          title: const Text('Edit About'),
                          content: TextField(
                            controller: controller,
                            maxLines: 5,
                            decoration: const InputDecoration(
                              hintText:
                                  'Write about yourself, specialization, etc.',
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () =>
                                  Navigator.pop(context, controller.text),
                              child: const Text('Save'),
                            ),
                          ],
                        );
                      },
                    );
                    if (about != null) {
                      setState(() {
                        _aboutController.text = about;
                      });
                    }
                  },
                  child: const Text(
                    'Change',
                    style: TextStyle(color: Colors.teal),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              _aboutController.text.isNotEmpty
                  ? _aboutController.text
                  : 'Write about yourself, specialization, etc.',
              style: const TextStyle(fontSize: 14, color: Colors.black87),
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
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: DropdownButtonFormField<String>(
                value: _selectedDesignation,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.work_outline),
                  hintText: 'Designation',
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding: const EdgeInsets.symmetric(vertical: 20),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
                items: _designationOptions
                    .map((designation) => DropdownMenuItem(
                          value: designation,
                          child: Text(designation),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedDesignation = value;
                  });
                },
              ),
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

            // Free Time & Day Section
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Available Days',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 8),
            _buildDaySelector(),
            const SizedBox(height: 16),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Available Time Slots',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 8),
            // Per-day time ranges
            for (int i = 0; i < _weekDays.length; i++)
              if (_selectedDays[i]) ...[
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    '${_weekDays[i]} Time Range',
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 6),
                _buildTimeRangeSelectorForDay(_weekDays[i]),
                const SizedBox(height: 12),
              ],
            const SizedBox(height: 30),

            // Save Button at the end
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
                  foregroundColor: Colors.white, // Ensures button text is white
                  textStyle: const TextStyle(color: Colors.white),
                ),
                child: const Text('Save',
                    style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 20),
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
