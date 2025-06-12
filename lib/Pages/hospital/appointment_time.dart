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
  Map<String, dynamic> _availableTimeRangesPerDay = {};
  int? _selectedDayIndex;
  int? _selectedSlotIndex;

  @override
  void initState() {
    super.initState();
    // Load available days and time ranges from doctor object
    final doc = widget.doctor;
    if (doc['availableDays'] is List) {
      _availableDays = List<String>.from(doc['availableDays']);
    }
    if (doc['availableTimeRangesPerDay'] is Map) {
      _availableTimeRangesPerDay = Map<String, dynamic>.from(doc['availableTimeRangesPerDay']);
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
        child: Column(
          children: [
            Expanded(
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
                    _timeRangeDisplay(),
                    const SizedBox(height: 24),
                    _assignAssistantCard(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _saveButton(),
            ),
          ],
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
                            _selectedDayIndex != null ? _selectedDayIndex! : 0]
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
    return Column(
      children: [
        Text('Select Day',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: const Color.fromARGB(149, 0, 0, 0))),
        const SizedBox(height: 12),
        SizedBox(
          height: 60,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: _availableDays.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, i) {
              final dayName = _availableDays[i];
              final isSelected = _selectedDayIndex == i;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDayIndex = i;
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
        ),
      ],
    );
  }

  Widget _timeRangeDisplay() {
    if (_selectedDayIndex == null) {
      return const Text('Please select a day to see available times.');
    }
    final day = _availableDays[_selectedDayIndex!];
    final ranges = _availableTimeRangesPerDay[day];
    if (ranges == null || !(ranges is List) || ranges.isEmpty) {
      return Text('No time slots set for $day.');
    }
    return Column(
      children: [
        Text('Select Time Slot',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: const Color.fromARGB(149, 0, 0, 0))),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: List.generate(ranges.length, (i) {
            final slot = ranges[i];
            final slotStr = '${slot['from']} - ${slot['to']}';
            final isSelected = _selectedSlotIndex == i;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedSlotIndex = i;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.teal : Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(
                    color: isSelected ? Colors.teal : Colors.grey.shade300,
                    width: 2,
                  ),
                  boxShadow: isSelected
                      ? [BoxShadow(color: Colors.teal.shade50, blurRadius: 6)]
                      : [],
                ),
                child: Text(
                  slotStr,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.teal,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            );
          }),
        ),
      ],
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
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
    return Container(
      margin: const EdgeInsets.only(bottom: 24, top: 8),
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          if (_selectedDayIndex == null || _selectedSlotIndex == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Please select a day and a time slot.')),
            );
            return;
          }
          final user = FirebaseAuth.instance.currentUser;
          if (user == null) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('You must be logged in as a hospital.')),
            );
            return;
          }
          final hospitalDoc = await FirebaseFirestore.instance
              .collection('hospitaldetails')
              .doc(user.uid)
              .get();
          final hospitalData = hospitalDoc.data() ?? {};
          final hospitalId = user.uid;
          final hospitalName = hospitalData['name'] ?? 'Hospital';
          final doctorId = widget.doctor['id'] ?? widget.doctor['uid'] ?? '';
          final doctorName = widget.doctor['name'] ?? '';
          final selectedDay = _availableDays[_selectedDayIndex!];
          final selectedSlot = (_availableTimeRangesPerDay[selectedDay] as List)[_selectedSlotIndex!];
          try {
            await FirebaseFirestore.instance
                .collection('scheduleRequests')
                .add({
              'doctorId': doctorId,
              'doctorName': doctorName,
              'hospitalId': hospitalId,
              'hospitalName': hospitalName,
              'selectedDay': selectedDay,
              'selectedTimeRange': selectedSlot,
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
                  content: Text('Failed to send request: \\${e.toString()}')),
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
        child: const Text('Save',
         style: TextStyle(fontSize: 16,color: Colors.white),
         
         ),
      ),
    );
  }
}
