import 'package:flutter/material.dart';
import '../controllers/auth_controller.dart';
import 'package:appointnow/Pages/Auth/login.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with SingleTickerProviderStateMixin {
  final AuthController _authController = AuthController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _agreeToTerms = false;
  String? _selectedRole;

  // Animation controller for the check icon
  late final AnimationController _checkController;

  @override
  void initState() {
    super.initState();
    _checkController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _checkController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showRegisterSuccessPopup() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            Navigator.of(context).pop();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginPage()),
            );
          }
        });
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
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            padding: const EdgeInsets.all(25),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey.shade100,
                  ),
                  padding: const EdgeInsets.all(20),
                  child: const Icon(Icons.check,
                      size: 40, color: Color(0xFF009688)),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Welcome!",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Your account has been successfully registered\nPlease login to continue",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSuccessAndNavigate() async {
    _showRegisterSuccessPopup();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Set background to pure white
      appBar: AppBar(
        title: const Text('', style: TextStyle(color: Colors.black)),
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Logo at the top
                Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: Image.asset(
                    'assets/no.png',
                    width: 120,
                    height: 120,
                  ),
                ),
                // Name input
                TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    prefixIcon:
                        const Icon(Icons.person_outline, color: Colors.grey),
                    hintText: 'Enter your name',
                    hintStyle: const TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24.0),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24.0),
                      borderSide:
                          const BorderSide(color: Color(0xFF199A8E), width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Email input
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    prefixIcon:
                        const Icon(Icons.email_outlined, color: Colors.grey),
                    hintText: 'Enter your email',
                    hintStyle: const TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24.0),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24.0),
                      borderSide:
                          const BorderSide(color: Color(0xFF199A8E), width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Password input
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    prefixIcon:
                        const Icon(Icons.lock_outline, color: Colors.grey),
                    suffixIcon:
                        const Icon(Icons.visibility_off, color: Colors.grey),
                    hintText: 'Enter your password',
                    hintStyle: const TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24.0),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24.0),
                      borderSide:
                          const BorderSide(color: Color(0xFF199A8E), width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Confirm Password input
                TextField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    prefixIcon:
                        const Icon(Icons.lock_outline, color: Colors.grey),
                    suffixIcon:
                        const Icon(Icons.visibility_off, color: Colors.grey),
                    hintText: 'Confirm your password',
                    hintStyle: const TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24.0),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24.0),
                      borderSide:
                          const BorderSide(color: Color(0xFF199A8E), width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Role dropdown
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    prefixIcon:
                        const Icon(Icons.person_outline, color: Colors.grey),
                    hintText: 'Select your role',
                    hintStyle: const TextStyle(color: Colors.grey),
                    filled: true,
                    fillColor:
                        Colors.white, // Ensure dropdown background is white
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24.0),
                      borderSide: const BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24.0),
                      borderSide:
                          const BorderSide(color: Color(0xFF199A8E), width: 2),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'User', child: Text('User')),
                    DropdownMenuItem(value: 'Doctor', child: Text('Doctor')),
                    DropdownMenuItem(
                        value: 'Assistant', child: Text('Assistant')),
                    DropdownMenuItem(
                        value: 'Hospital', child: Text('Hospital')),
                    DropdownMenuItem(
                        value: 'Diagnosis', child: Text('Diagnosis')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedRole = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                // Terms and conditions
                Row(
                  children: [
                    Checkbox(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(5.0),
                      ),
                      activeColor: const Color(0xFF199A8E),
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
                            ),
                            TextSpan(
                              text: ' and ',
                              style: TextStyle(color: Colors.black),
                            ),
                            TextSpan(
                              text: 'Privacy Policy',
                              style: TextStyle(color: Color(0xFF199A8E)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Sign Up button
                ElevatedButton(
                  onPressed: () async {
                    if (_passwordController.text !=
                        _confirmPasswordController.text) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Passwords do not match!')),
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
                    if (_selectedRole == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please select a role!')),
                      );
                      return;
                    }
                    try {
                      await _authController.register(
                        _nameController.text,
                        _emailController.text,
                        _passwordController.text,
                        _selectedRole,
                      );
                      if (mounted) {
                        _showSuccessAndNavigate();
                      }
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content:
                                Text('Registration failed: \\${e.toString()}')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF199A8E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Text('Sign Up',
                      style: TextStyle(color: Colors.white)),
                ),
                const SizedBox(height: 16),
                // Login link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Do you already have an account? "),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LoginPage()),
                        );
                      },
                      child: const Text(
                        'Login',
                        style: TextStyle(
                          color: Color(0xFF199A8E),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
