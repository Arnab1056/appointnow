import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';  

class AddAssistantPage extends StatefulWidget {
  @override
  _AddAssistantPageState createState() => _AddAssistantPageState();
}

class _AddAssistantPageState extends State<AddAssistantPage> {
  bool agreeToTerms = false;
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(color: Colors.black),
        title: Text('Add Assistant', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: AssetImage('assets/assistant.jpg'), // Replace with your image
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      radius: 15,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.camera_alt, size: 18),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            Text("Assistant Name", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("About", style: TextStyle(fontWeight: FontWeight.bold)),
                TextButton(onPressed: () {}, child: Text("Change")),
              ],
            ),
            Text(
              "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam... ",
              style: TextStyle(color: Colors.grey[600]),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () {},
                child: Text("Read more", style: TextStyle(color: Colors.teal)),
              ),
            ),
            SizedBox(height: 10),
            buildTextField(Icons.person, "Enter assistant name", controller: _nameController),
            buildTextField(Icons.email, "Enter assistant email", controller: _emailController),
            buildPasswordField("Enter assistant password", true, controller: _passwordController),
            buildPasswordField("Confirm assistant password", false, controller: _confirmPasswordController),
            SizedBox(height: 10),
            Row(
              children: [
                Checkbox(
                  value: agreeToTerms,
                  onChanged: (value) {
                    setState(() {
                      agreeToTerms = value!;
                    });
                  },
                ),
                Expanded(
                  child: Wrap(
                    children: [
                      Text("I agree to the medidoc "),
                      GestureDetector(
                        onTap: () {},
                        child: Text("Terms of Service", style: TextStyle(color: Colors.teal)),
                      ),
                      Text(" and "),
                      GestureDetector(
                        onTap: () {},
                        child: Text("Privacy Policy", style: TextStyle(color: Colors.teal)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                if (!agreeToTerms) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('You must agree to the terms.')),
                  );
                  return;
                }
                final name = _nameController.text.trim();
                final email = _emailController.text.trim();
                final password = _passwordController.text;
                final confirmPassword = _confirmPasswordController.text;
                if (name.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('All fields are required.')),
                  );
                  return;
                }
                if (password != confirmPassword) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Passwords do not match.')),
                  );
                  return;
                }
                try {
                  final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
                    email: email,
                    password: password,
                  );
                  final hospitalId = FirebaseAuth.instance.currentUser?.uid;
                  // Add assistant details to 'assistants' collection
                  await FirebaseFirestore.instance.collection('assistants').doc(userCredential.user!.uid).set({
                    'name': name,
                    'email': email,
                    'hospitalId': hospitalId,
                    'createdAt': FieldValue.serverTimestamp(),
                    'about': '', // You can add about field if you want to collect it
                    'profileImageUrl': '', // Add image url if you implement image upload
                  });
                  // Also add to 'users' collection for login if needed
                  await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
                    'name': name,
                    'email': email,
                    'role': 'assistant',
                    'hospitalId': hospitalId,
                    'createdAt': FieldValue.serverTimestamp(),
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Assistant registered successfully!')),
                  );
                  Navigator.pop(context);
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Registration failed:  ${e.toString()}')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal,
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              ),
              child: Text("Save", style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTextField(IconData icon, String hint, {TextEditingController? controller}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          prefixIcon: Icon(icon),
          hintText: hint,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
        ),
      ),
    );
  }

  Widget buildPasswordField(String hint, bool isPassword, {TextEditingController? controller}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        obscureText: isPassword ? obscurePassword : obscureConfirmPassword,
        decoration: InputDecoration(
          prefixIcon: Icon(Icons.lock),
          hintText: hint,
          suffixIcon: IconButton(
            icon: Icon(
              (isPassword ? obscurePassword : obscureConfirmPassword)
                  ? Icons.visibility_off
                  : Icons.visibility,
            ),
            onPressed: () {
              setState(() {
                if (isPassword) {
                  obscurePassword = !obscurePassword;
                } else {
                  obscureConfirmPassword = !obscureConfirmPassword;
                }
              });
            },
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
        ),
      ),
    );
  }
}
