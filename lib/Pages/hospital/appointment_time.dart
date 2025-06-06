import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ScheduleTimePage extends StatefulWidget {
  final Map<String, dynamic> doctor;
  const ScheduleTimePage({super.key, required this.doctor});

  @override
  State<ScheduleTimePage> createState() => _ScheduleTimePageState();
}

class _ScheduleTimePageState extends State<ScheduleTimePage> {
  List<String> _availableDays = [];
  List<String> _availableTimeSlots = [];
  List<int> _selectedDays = [];
  List<int> _selectedTimes = [];

  @override
  void initState() {
    super.initState();
    // Load available days and times from doctor object
    final doc = widget.doctor;
    if (doc['availableDays'] is List) {
      _availableDays = List<String>.from(doc['availableDays']);
    }
    if (doc['availableTimeSlots'] is List) {
      _availableTimeSlots = List<String>.from(doc['availableTimeSlots']);
    }
  }

  //--------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const BackButton(color: Colors.black),
        centerTitle: true,
        title: const Text(
          'Schedule Time',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert, color: Colors.black),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _doctorCard(),
              const SizedBox(height: 20),
              _daysStrip(),
              const SizedBox(height: 12),
              const Divider(thickness: 1),
              const SizedBox(height: 12),
              _timeGrid(context),
              const SizedBox(height: 24),
              _assignAssistantCard(),
              const SizedBox(height: 40),
              _saveButton(),
            ],
          ),
        ),
      ),
    );
  }

  // ——————————————————— Widgets ————————————————————

  Widget _doctorCard() {
    final doctor = widget.doctor;
    return Card(
      margin: EdgeInsets.zero,
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: doctor['profileImageUrl'] != null &&
                      doctor['profileImageUrl'].toString().isNotEmpty
                  ? Image.network(
                      doctor['profileImageUrl'],
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                    )
                  : (doctor['image'] != null &&
                          doctor['image'].toString().isNotEmpty
                      ? Image.network(
                          doctor['image'],
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                        )
                      : Image.asset(
                          'assets/images/doctor1.jpg',
                          width: 70,
                          height: 70,
                          fit: BoxFit.cover,
                        )),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(doctor['name'] ?? '',
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(doctor['designation'] ?? '',
                      style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.teal.shade50,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        child: Row(
                          children: [
                            const Icon(Icons.star,
                                size: 14, color: Colors.teal),
                            const SizedBox(width: 2),
                            Text(
                              (doctor['avgRating'] != null &&
                                      doctor['avgRating'] > 0)
                                  ? doctor['avgRating'].toStringAsFixed(1)
                                  : (doctor['rating'] != null &&
                                          doctor['rating'] is num)
                                      ? (doctor['rating'] as num)
                                          .toStringAsFixed(1)
                                      : 'No rating',
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.teal),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('• ${doctor['hospital'] ?? ''}',
                          style: const TextStyle(
                              fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              width: 60,
              height: 70,
              decoration: BoxDecoration(
                color: Colors.teal,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _availableDays.isNotEmpty
                        ? _availableDays[
                            _selectedDays.isNotEmpty ? _selectedDays.last : 0]
                        : 'N/A',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _daysStrip() {
    return SizedBox(
      height: 84,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _availableDays.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, i) {
          final dayName = _availableDays[i];
          final isSelected = _selectedDays.contains(i);
          return GestureDetector(
            onTap: () {
              setState(() {
                if (isSelected) {
                  _selectedDays.remove(i);
                } else {
                  _selectedDays.add(i);
                }
              });
            },
            child: Container(
              width: 60,
              decoration: BoxDecoration(
                color: isSelected ? Colors.teal : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: isSelected ? Colors.teal : Colors.grey.shade300),
                boxShadow: isSelected
                    ? [BoxShadow(color: Colors.teal.shade100, blurRadius: 6)]
                    : [],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(dayName,
                      style: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey[600],
                          fontSize: 18,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _timeGrid(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _availableTimeSlots.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 3.1,
      ),
      itemBuilder: (context, i) {
        final isSelected = _selectedTimes.contains(i);
        Color bg = isSelected ? Colors.teal : Colors.white;
        Color txt = isSelected ? Colors.white : Colors.black;
        return GestureDetector(
          onTap: () {
            setState(() {
              if (isSelected) {
                _selectedTimes.remove(i);
              } else {
                _selectedTimes.add(i);
              }
            });
          },
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(30),
              border: Border.all(
                color: isSelected ? Colors.teal : Colors.grey.shade300,
              ),
            ),
            child: Text(
              _availableTimeSlots[i],
              style: TextStyle(fontSize: 13, color: txt),
            ),
          ),
        );
      },
    );
  }

  Widget _assignAssistantCard() {
    return GestureDetector(
      onTap: () {}, // TODO: navigation
      child: Container(
        width: 110,
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.grey.shade200,
                blurRadius: 8,
                offset: const Offset(0, 4))
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.medical_services_outlined, size: 40, color: Colors.teal),
            SizedBox(height: 12),
            Text(
              'Assign\nAssistant',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13),
            )
          ],
        ),
      ),
    );
  }

  Widget _saveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          if (_selectedDays.isEmpty || _selectedTimes.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content:
                      Text('Please select at least one day and time slot.')),
            );
            return;
          }

          // Get current hospital info from FirebaseAuth
          final user = FirebaseAuth.instance.currentUser;
          if (user == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('You must be logged in as a hospital.')),
            );
            return;
          }

          // Fetch hospital details from Firestore
          final hospitalDoc = await FirebaseFirestore.instance
              .collection('hospitaldetails')
              .doc(user.uid)
              .get();
          final hospitalData = hospitalDoc.data() ?? {};
          final hospitalId = user.uid;
          final hospitalName = hospitalData['name'] ?? 'Hospital';

          final doctorId = widget.doctor['id'] ?? widget.doctor['uid'] ?? '';
          final doctorName = widget.doctor['name'] ?? '';

          final selectedDays =
              _selectedDays.map((i) => _availableDays[i]).toList();
          final selectedTimes =
              _selectedTimes.map((i) => _availableTimeSlots[i]).toList();

          try {
            await FirebaseFirestore.instance
                .collection('scheduleRequests')
                .add({
              'doctorId': doctorId,
              'doctorName': doctorName,
              'hospitalId': hospitalId,
              'hospitalName': hospitalName,
              'selectedDays': selectedDays,
              'selectedTimes': selectedTimes,
              'status': 'pending',
              'createdAt': FieldValue.serverTimestamp(),
            });
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Schedule request sent to doctor.')),
            );
            Navigator.pop(context);
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text('Failed to send request: ${e.toString()}')),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.teal,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: const Text('Save', style: TextStyle(fontSize: 16)),
      ),
    );
  }
}
