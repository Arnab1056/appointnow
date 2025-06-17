import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() => runApp(AmbulanceBookingApp());

class AmbulanceBookingApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: AmbulanceBookingPage(
        ambulanceData: {
          'name': 'City Ambulance',
          'location': 'Chattogram',
          'imageUrl': 'https://example.com/ambulance.jpg',
          'about': 'Lorem ipsum dolor sit amet, consectetur adipiscing elit.',
          'phone': '01**********',
          'category': 'Basic',
          'distance': '800m away',
        },
        avgRating: 4.5,
        totalRatings: 120,
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AmbulanceBookingPage extends StatefulWidget {
  final Map<String, dynamic> ambulanceData;
  final double avgRating;
  final int totalRatings;

  const AmbulanceBookingPage({
    Key? key,
    required this.ambulanceData,
    required this.avgRating,
    required this.totalRatings,
  }) : super(key: key);

  @override
  State<AmbulanceBookingPage> createState() => _AmbulanceBookingPageState();
}

class _AmbulanceBookingPageState extends State<AmbulanceBookingPage> {
  late TextEditingController categoryController;
  late TextEditingController addressController;
  late TextEditingController phoneController;
  late TextEditingController dateTimeController;

  final List<String> ambulanceCategories = [
    'Basic',
    'ICU',
    'AC',
    'Non-AC',
    'Freezer',
    'Patient Transport',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    categoryController =
        TextEditingController(text: widget.ambulanceData['category'] ?? '');
    addressController =
        TextEditingController(text: widget.ambulanceData['location'] ?? '');
    phoneController = TextEditingController();
    dateTimeController = TextEditingController();
  }

  @override
  void dispose() {
    categoryController.dispose();
    addressController.dispose();
    phoneController.dispose();
    dateTimeController.dispose();
    super.dispose();
  }

  Future<void> _bookAmbulance() async {
    if (categoryController.text.trim().isEmpty ||
        addressController.text.trim().isEmpty ||
        phoneController.text.trim().isEmpty ||
        dateTimeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields.')),
      );
      return;
    }
    final bookingData = {
      'ambulanceId': widget.ambulanceData['id'],
      'ambulanceName': widget.ambulanceData['name'],
      'category': categoryController.text,
      'address': addressController.text,
      'phone': phoneController.text,
      'dateTime': dateTimeController.text,
      'createdAt': FieldValue.serverTimestamp(),
    };
    await FirebaseFirestore.instance
        .collection('ambulancebooking')
        .add(bookingData);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Booking successful!')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ambulanceData = widget.ambulanceData;
    final avgRating = widget.avgRating;
    final totalRatings = widget.totalRatings;
    return Scaffold(
      appBar: AppBar(
        title: Text(ambulanceData['name'] ?? 'Ambulance'),
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context)),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ambulance card
            Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: Row(
                children: [
                  (ambulanceData['profileImageUrl'] != null &&
                          (ambulanceData['profileImageUrl'] as String)
                              .isNotEmpty)
                      ? ClipRRect(
                          borderRadius: BorderRadius.horizontal(
                              left: Radius.circular(16)),
                          child: Image.network(
                            ambulanceData['profileImageUrl'],
                            height: 100,
                            width: 100,
                            fit: BoxFit.cover,
                          ),
                        )
                      : Container(
                          height: 100,
                          width: 100,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.horizontal(
                                left: Radius.circular(16)),
                          ),
                          child: CircleAvatar(
                            radius: 32,
                            backgroundColor: Colors.teal[100],
                            child: Icon(Icons.local_hospital,
                                color: Colors.teal, size: 40),
                          ),
                        ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(ambulanceData['name'] ?? 'Ambulance Service',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 16)),
                          Text(ambulanceData['location'] ?? '',
                              style: TextStyle(color: Colors.grey)),
                          Row(
                            children: [
                              Icon(Icons.star, color: Colors.teal, size: 16),
                              SizedBox(width: 4),
                              Text(avgRating.toStringAsFixed(1),
                                  style: TextStyle(color: Colors.teal)),
                              SizedBox(width: 8),
                              Text('($totalRatings ratings)',
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 12)),
                              SizedBox(width: 12),
                              Icon(Icons.location_on,
                                  color: Colors.grey, size: 16),
                              SizedBox(width: 4),
                              Text(ambulanceData['distance'] ?? '',
                                  style: TextStyle(color: Colors.grey)),
                            ],
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(height: 20),
            // About section
            Text("About",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(height: 6),
            Text(
              ambulanceData['about'] ?? 'No description available.',
              style: TextStyle(color: Colors.grey[600]),
            ),
            if ((ambulanceData['about'] ?? '').length > 100)
              Text("Read more", style: TextStyle(color: Colors.teal)),
            SizedBox(height: 20),
            // Call Number
            Text("Call Number",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.phone, color: Colors.grey),
                SizedBox(width: 8),
                Text(
                  (ambulanceData['hotline'] ?? 'N/A').toString(),
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            SizedBox(height: 24),
            // Book Ambulance section
            Text("Book Ambulance",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white)),
            SizedBox(height: 16),
            // Category dropdown
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: DropdownButtonFormField<String>(
                value: ambulanceCategories.contains(categoryController.text)
                    ? categoryController.text
                    : null,
                items: ambulanceCategories
                    .map((cat) => DropdownMenuItem(
                          value: cat,
                          child: Text(cat),
                        ))
                    .toList(),
                onChanged: (val) {
                  setState(() {
                    categoryController.text = val ?? '';
                  });
                },
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.local_shipping, color: Colors.grey),
                  hintText: 'Category',
                  filled: true,
                  fillColor: Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            _buildInputField(Icons.location_on, "Address",
                controller: addressController),
            _buildInputField(Icons.phone_android, "Phone",
                controller: phoneController),
            _buildDateTimePickerField(),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _bookAmbulance,
                child: Text("Book Ambulance"),
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

  Widget _buildInputField(IconData icon, String hint,
      {TextEditingController? controller}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.grey),
          hintText: hint,
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

  Widget _buildDateTimePickerField() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: GestureDetector(
        onTap: () async {
          FocusScope.of(context).unfocus();
          DateTime? pickedDate = await showDatePicker(
            context: context,
            initialDate: DateTime.now(),
            firstDate: DateTime.now(),
            lastDate: DateTime.now().add(const Duration(days: 365)),
          );
          if (pickedDate != null) {
            TimeOfDay? pickedTime = await showTimePicker(
              context: context,
              initialTime: TimeOfDay.now(),
            );
            if (pickedTime != null) {
              final dt = DateTime(
                pickedDate.year,
                pickedDate.month,
                pickedDate.day,
                pickedTime.hour,
                pickedTime.minute,
              );
              dateTimeController.text =
                  '${pickedDate.year}-${pickedDate.month.toString().padLeft(2, '0')}-${pickedDate.day.toString().padLeft(2, '0')} '
                  '${pickedTime.format(context)}';
              setState(() {});
            }
          }
        },
        child: AbsorbPointer(
          child: TextField(
            controller: dateTimeController,
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.calendar_today, color: Colors.grey),
              hintText: "Date and Time",
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
