import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
class AmbulanceProfileEditPage extends StatefulWidget {
  @override
  _AmbulanceProfileEditPageState createState() => _AmbulanceProfileEditPageState();
}

class _AmbulanceProfileEditPageState extends State<AmbulanceProfileEditPage> {
  bool isChecked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ambulance Profile'),
        leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: () {}),
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
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage('assets/ambulance.jpg'), // Replace with your asset
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      radius: 14,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.camera_alt, size: 16),
                    ),
                  )
                ],
              ),
            ),
            SizedBox(height: 12),
            Text('Ambulance Name', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("About", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
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
              child: Text('Read more', style: TextStyle(color: Colors.teal, fontSize: 13)),
            ),
            SizedBox(height: 20),

            // Input fields
            _buildTextField(Icons.local_hospital, "Ambulance name"),
            _buildTextField(Icons.email, "Email"),
            _buildTextField(Icons.phone, "Hot-Line Number"),
            _buildTextField(Icons.confirmation_number, "Register Number"),
            _buildTextField(Icons.confirmation_number, "Location"),

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
                onPressed: isChecked ? () {} : null,
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

  Widget _buildTextField(IconData icon, String hintText) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
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
