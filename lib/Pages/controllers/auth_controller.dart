import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthController {
  void login(String email, String password) {
    // Implement login logic here
    print('Logging in with email: $email and password: $password');
  }

  void signUp() {
    // Implement sign-up logic here
    print('Navigating to sign-up page');
  }

  void signInWithGoogle() {
    // Implement Google sign-in logic here
    print('Signing in with Google');
  }

  void signInWithApple() {
    // Implement Apple sign-in logic here
    print('Signing in with Apple');
  }

  void signInWithFacebook() {
    // Implement Facebook sign-in logic here
    print('Signing in with Facebook');
  }

  void forgotPassword() {
    // Implement forgot password logic here
    print('Navigating to forgot password page');
  }

  Future<void> register(
      String name, String email, String password, String? role) async {
    if (name.isEmpty || email.isEmpty || password.isEmpty || role == null) {
      print('All fields are required');
      throw Exception('All fields are required');
    }
    if (!email.contains('@')) {
      print('Invalid email address');
      throw Exception('Invalid email address');
    }
    if (password.length < 6) {
      print('Password must be at least 6 characters long');
      throw Exception('Password must be at least 6 characters long');
    }
    print('Registering user with name: $name, email: $email, role: $role');
    try {
      // Create user in Firebase Auth
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await userCredential.user?.updateDisplayName(name);
      // Save user data to Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user?.uid)
          .set({
        'uid': userCredential.user?.uid ?? '',
        'name': name,
        'email': email,
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      print('Registration successful and user data saved to Firestore');
    } on FirebaseAuthException catch (e) {
      print('Registration failed: ${e.message}');
      throw Exception(e.message);
    } catch (e) {
      print('An error occurred: ${e.toString()}');
      throw Exception(e.toString());
    }
  }
}
