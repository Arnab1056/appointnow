import 'package:flutter/material.dart';
import '../controllers/auth_controller.dart';
import 'package:appointnow/Pages/Auth/login.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final AuthController _authController = AuthController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _agreeToTerms = false;
  String? _selectedRole;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up', style: TextStyle(color: Colors.black)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.person_outline,
                    color: Color.fromARGB(255, 139, 136, 136)),
                hintText: 'Enter your name',
                border: OutlineInputBorder(
                  borderSide: const BorderSide(
                      color: Color.fromARGB(255, 185, 183, 183)),
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.email_outlined,
                    color: Color.fromARGB(255, 139, 136, 136)),
                hintText: 'Enter your email',
                border: OutlineInputBorder(
                  borderSide: const BorderSide(
                      color: Color.fromARGB(255, 185, 183, 183)),
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.lock_outline,
                    color: Color.fromARGB(255, 139, 136, 136)),
                suffixIcon: const Icon(Icons.visibility_off,
                    color: Color.fromARGB(255, 139, 136, 136)),
                hintText: 'Enter your password',
                border: OutlineInputBorder(
                  borderSide: const BorderSide(
                      color: Color.fromARGB(255, 185, 183, 183)),
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _confirmPasswordController,
              obscureText: true,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.lock_outline,
                    color: Color.fromARGB(255, 139, 136, 136)),
                suffixIcon: const Icon(Icons.visibility_off,
                    color: Color.fromARGB(255, 139, 136, 136)),
                hintText: 'Confirm your password',
                border: OutlineInputBorder(
                  borderSide: const BorderSide(
                      color: Color.fromARGB(255, 185, 183, 183)),
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.person_outline,
                    color: Color.fromARGB(255, 139, 136, 136)),
                hintText: 'Select your role',
                border: OutlineInputBorder(
                  borderSide: const BorderSide(
                      color: Color.fromARGB(255, 185, 183, 183)),
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
              items: const [
                DropdownMenuItem(value: 'User', child: Text('User')),
                DropdownMenuItem(value: 'Doctor', child: Text('Doctor')),
                DropdownMenuItem(value: 'Assistant', child: Text('Assistant')),
                DropdownMenuItem(value: 'Hospital', child: Text('Hospital')),
                DropdownMenuItem(value: 'Diagnosis', child: Text('Diagnosis')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedRole = value;
                });
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Checkbox(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  activeColor: const Color(0xFF199A8E),
                  // checkColor: Colors.white,
                  value: _agreeToTerms,
                  onChanged: (value) {
                    setState(() {
                      _agreeToTerms = value!;
                    });
                  },
                ),
                Expanded(
                  child: RichText(
                    text: const TextSpan(
                      text: 'I agree to the appointnow ',
                      style: TextStyle(color: Colors.black),
                      children: [
                        TextSpan(
                          text: 'Terms of Service',
                          style: TextStyle(color: Color(0xFF199A8E)),
                          // Add navigation logic here
                        ),
                        TextSpan(
                          text: ' and ',
                          style: TextStyle(color: Colors.black),
                        ),
                        TextSpan(
                          text: 'Privacy Policy',
                          style: TextStyle(color: Color(0xFF199A8E)),
                          // Add navigation logic here
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (_passwordController.text !=
                    _confirmPasswordController.text) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Passwords do not match!')),
                  );
                  return;
                }
                if (!_agreeToTerms) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('You must agree to the terms!')),
                  );
                  return;
                }
                _authController.register(
                  _nameController.text,
                  _emailController.text,
                  _passwordController.text,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(25, 154, 142, 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                minimumSize: const Size(double.infinity, 50),
              ),
              child:
                  const Text('Sign Up', style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Do you already have an account? "),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => LoginPage()),
                    );
                  },
                  child: const Text(
                    'Login',
                    style: TextStyle(
                      color: Color(0xFF199A8E),
                      // decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
