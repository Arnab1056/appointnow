import 'package:flutter/material.dart';

void main() => runApp(BookingConfirmApp());

class BookingConfirmApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BookingConfirmationPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class BookingConfirmationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Booking'),
        leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: () {}),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ambulance card
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.horizontal(left: Radius.circular(16)),
                    child: Image.asset(
                      'assets/ambulance.jpg', // Replace with your image path
                      height: 100,
                      width: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Ambulance Service", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text("Chattogram", style: TextStyle(color: Colors.grey)),
                          Row(
                            children: [
                              Icon(Icons.star, color: Colors.teal, size: 16),
                              SizedBox(width: 4),
                              Text("5.0", style: TextStyle(color: Colors.teal)),
                              SizedBox(width: 12),
                              Icon(Icons.location_on, color: Colors.grey, size: 16),
                              SizedBox(width: 4),
                              Text("800m away", style: TextStyle(color: Colors.grey)),
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

            _buildSectionTitle("Date", "Change"),
            ListTile(
              leading: Icon(Icons.calendar_today, color: Colors.teal),
              title: Text("Wednesday, Jun 23, 2025 | 02:00 PM"),
            ),

            _buildSectionTitle("Address", "Change"),
            ListTile(
              leading: Icon(Icons.pin_drop, color: Colors.teal),
              title: Text("Chittagong to Nowakhali"),
            ),

            _buildSectionTitle("Payment Detail"),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Column(
                children: [
                  _buildPriceRow("Ambulance", "300.0 tk"),
                  _buildPriceRow("Admin Fee 0.05%", "15.0 tk"),
                  _buildPriceRow("Additional Discount", "-"),
                  Divider(),
                  _buildPriceRow("Total", "315.0 tk", isBold: true),
                ],
              ),
            ),

            SizedBox(height: 16),
            _buildSectionTitle("Payment Method", "Change"),
            Card(
              margin: EdgeInsets.symmetric(horizontal: 8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: Icon(Icons.credit_card, color: Colors.blue),
                title: Text("VISA", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),

            Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                children: [
                  _buildPriceRow("Total", "315 tk", isBold: true),
                  SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {},
                      child: Text("Booking"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal,
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: StadiumBorder(),
                      ),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, [String? action]) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          if (action != null)
            Text(action, style: TextStyle(color: Colors.teal, fontSize: 14)),
        ],
      ),
    );
  }

  Widget _buildPriceRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: isBold ? TextStyle(fontWeight: FontWeight.bold) : null),
          Text(value, style: isBold ? TextStyle(fontWeight: FontWeight.bold, color: Colors.teal) : null),
        ],
      ),
    );
  }
}
