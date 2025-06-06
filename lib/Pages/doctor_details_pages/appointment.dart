import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AppointmentPage extends StatefulWidget {
  final Map<String, dynamic> doctor;
  final String day;
  final String date;
  final String time;
  final String hospitalName;
  final String hospitalId; // Add hospitalId from previous page
  final String patientName; // Add this

  const AppointmentPage({
    super.key,
    required this.doctor,
    required this.day,
    required this.date,
    required this.time,
    required this.hospitalName,
    required this.hospitalId, // Add hospitalId to constructor
    required this.patientName, // Add this
  });

  @override
  _AppointmentPageState createState() => _AppointmentPageState();
}

class _AppointmentPageState extends State<AppointmentPage> {
  String? reason;
  String selectedPaymentMethod = "VISA";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          'Appointment',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Doctor Info Card
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 36,
                          backgroundImage: widget.doctor['profileImageUrl'] !=
                                      null &&
                                  widget.doctor['profileImageUrl'] != ''
                              ? NetworkImage(widget.doctor['profileImageUrl'])
                              : (widget.doctor['image'] != null &&
                                          widget.doctor['image'] != ''
                                      ? NetworkImage(widget.doctor['image'])
                                      : const AssetImage(
                                          'assets/images/doctor1.jpg'))
                                  as ImageProvider,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.doctor['name'] ?? '',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.doctor['designation'] ?? '',
                                style: const TextStyle(
                                    fontSize: 13, color: Colors.grey),
                              ),
                              const SizedBox(height: 8.0),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 6, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF199A8E)
                                          .withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.star,
                                            size: 14, color: Color(0xFF199A8E)),
                                        const SizedBox(width: 4),
                                        Text(
                                          (widget.doctor['avgRating'] ??
                                                  widget.doctor['rating'] ??
                                                  '0')
                                              .toString(),
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: Color(0xFF199A8E),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  const Icon(Icons.location_on,
                                      size: 14, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Text(
                                    widget.doctor['hospital'] ?? '',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  /// Date
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Date",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        // Removed Change button
                      ],
                    ),
                    subtitle: Row(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(top: 12),
                          padding: const EdgeInsets.all(8),
                          width: 45,
                          height: 45,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE5F8F6),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.calendar_month_outlined,
                            color: Color(0xFF199A8E),
                            size: 30,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          _getFullDateTimeString(
                              widget.day, widget.date, widget.time),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),
                  const Divider(
                    height: 32,
                    color: Color.fromARGB(255, 240, 238, 238),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Hospital",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        // No change button for hospital
                      ],
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 12),
                            width: 45,
                            height: 45,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE5F8F6),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(
                              Icons.local_hospital,
                              color: Color(0xFF199A8E),
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              widget.hospitalName,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.teal,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Divider(
                    height: 32,
                    color: Color.fromARGB(255, 240, 238, 238),
                  ),
                  const SizedBox(height: 10),

                  /// Reason
                  // Removed misplaced declaration of 'reason'

                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    // leading: const Icon(Icons.sick, color: Color(0xFF199A8E)),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Reason",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        // Removed Change button
                      ],
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 12),
                            width: 45,
                            height: 45,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE5F8F6), // Light teal
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.edit_square,
                                  size: 20, color: Color(0xFF199A8E)),
                              onPressed: () {
                                TextEditingController controller =
                                    TextEditingController();

                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      backgroundColor: Colors.white,
                                      title: const Text("Enter Reason"),
                                      content: TextField(
                                        controller: controller,
                                        decoration: const InputDecoration(
                                          hintText: "Type reason here...",
                                          prefixIcon: Icon(Icons.edit),
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text("Cancel"),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            // Update the reason in state
                                            setState(() {
                                              reason = controller.text.trim();
                                            });
                                            Navigator.of(context).pop();
                                          },
                                          child: const Text("Save"),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              reason ?? "No reason provided",
                              style: const TextStyle(
                                fontSize: 16, // Increased font size
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),
                  const Divider(
                    height: 32,
                    color: Color.fromARGB(255, 240, 238, 238),
                  ),
                  const SizedBox(height: 10),

                  /// Payment Details
                  const Text(
                    "Payment Detail",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildPaymentRow("Consultation", "300.0 tk",
                      color: Colors.black, labelColor: Colors.grey),
                  _buildPaymentRow("Admin Fee 0.05%", "15.0 tk",
                      color: Colors.black, labelColor: Colors.grey),
                  _buildPaymentRow("Aditional Discount", "-",
                      color: Colors.black, labelColor: Colors.grey),

                  const Divider(
                    height: 15,
                    color: Color.fromARGB(255, 240, 238, 238),
                  ),
                  _buildPaymentRow("Total", "315.0 tk",
                      isBold: true, color: const Color(0xFF199A8E)),

                  const SizedBox(height: 24),
                  const Divider(
                    height: 32,
                    color: Color.fromARGB(255, 240, 238, 238),
                  ),

                  // Removed declaration from here
                  // Removed misplaced declaration of 'selectedPaymentMethod'
                  // Payment Method Selection
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    // leading:
                    //     const Icon(Icons.credit_card, color: Color(0xFF199A8E)),
                    title: const Text(
                      "Payment Method",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              selectedPaymentMethod,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 14,
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                String tempSelected = selectedPaymentMethod;

                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return StatefulBuilder(
                                      builder: (context, setStateDialog) {
                                        return AlertDialog(
                                          backgroundColor: Colors.white,
                                          title: const Text(
                                              "Select Payment Method"),
                                          content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              for (var method in [
                                                "BKash",
                                                "Nagad",
                                                "VISA",
                                                "Rocket"
                                              ])
                                                RadioListTile<String>(
                                                  title: Text(method),
                                                  value: method,
                                                  groupValue: tempSelected,
                                                  onChanged: (value) {
                                                    setStateDialog(() {
                                                      tempSelected = value!;
                                                    });
                                                  },
                                                ),
                                            ],
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text("Cancel"),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                setState(() {
                                                  selectedPaymentMethod =
                                                      tempSelected;
                                                });
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text("Save"),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                );
                              },
                              child: const Text(
                                "Change",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),

          /// Bottom Total and Booking Button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey, width: 0.1)),
              color: Colors.white,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  children: [
                    Text(
                      "Total",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      "315 tk",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  width: 200,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      await _addSerialToDatabase();
                      _showSuccessPopup(); // Show the success popup
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF199A8E),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: const Text(
                      "Booking",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _addSerialToDatabase() async {
    final serialData = {
      'doctorId': widget.doctor['id'] ?? widget.doctor['uid'] ?? '',
      'doctorName': widget.doctor['name'] ?? '',
      'doctorDesignation': widget.doctor['designation'] ?? '',
      'hospitalName': widget.hospitalName,
      'hospitalId': widget.hospitalId, // Use hospitalId from previous page
      'date': widget.date,
      'day': widget.day,
      'time': widget.time,
      'reason': reason ?? '',
      'paymentMethod': selectedPaymentMethod,
      'createdAt': FieldValue.serverTimestamp(),
      'patientName': widget.patientName, // Save patient name
    };
    await FirebaseFirestore.instance.collection('serial').add(serialData);
  }

  /// Helper for building payment rows
  Widget _buildPaymentRow(String label, String amount,
      {bool isBold = false, Color? color, Color? labelColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              )),
          Text(
            amount,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: color ?? Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  // Added a popup screen for successful booking
  void _showSuccessPopup() {
    showDialog(
      context: context,
      barrierDismissible:
          false, // Prevent dismissing the popup by tapping outside
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFE5F8F6), // Light teal background color
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 100,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Color(0xFF199A8E), // Teal color
                    size: 50,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  "Payment Successful",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Your payment has been successful,\n"
                  "you can have a consultation session\n"
                  "with your trusted doctor",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );

    // Close the popup after 5 seconds
    Future.delayed(const Duration(seconds: 5), () {
      Navigator.of(context).pop();
    });
  }

  String _getFullDateTimeString(String day, String date, String time) {
    final now = DateTime.now();
    int dayNum = int.tryParse(date) ?? now.day;
    final fullDate = DateTime(now.year, now.month, dayNum);
    final formatted =
        "${_getWeekdayName(day)}, ${fullDate.day.toString().padLeft(2, '0')} ${_getMonthName(fullDate.month)} ${fullDate.year}, $time";
    return formatted;
  }

  String _getWeekdayName(String shortDay) {
    switch (shortDay) {
      case 'Mon':
        return 'Monday';
      case 'Tue':
        return 'Tuesday';
      case 'Wed':
        return 'Wednesday';
      case 'Thu':
        return 'Thursday';
      case 'Fri':
        return 'Friday';
      case 'Sat':
        return 'Saturday';
      case 'Sun':
        return 'Sunday';
      default:
        return shortDay;
    }
  }

  String _getMonthName(int month) {
    const months = [
      '',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return months[month];
  }
}
