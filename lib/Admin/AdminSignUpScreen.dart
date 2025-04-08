import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'AdminParkingListPage.dart';

class AdminSignUpScreen extends StatefulWidget {
  late String phoneNumber;
  AdminSignUpScreen({super.key, required this.phoneNumber});

  @override
  _EmailVerificationScreenState createState() =>
      _EmailVerificationScreenState();
}

class _EmailVerificationScreenState extends State<AdminSignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  bool _isEmailValid = false;
  bool _isLoading = false;
  late String phoneNumberId;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    phoneNumberId = widget.phoneNumber;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex =
        RegExp(r"^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$");
    if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  void _validateForm() {
    setState(() {
      _isEmailValid = _formKey.currentState?.validate() ?? false;
    });
  }

  Future<void> _sendVerificationEmail(User user) async {
    try {
      await user.sendEmailVerification();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'A verification email has been sent to ${user.email}. Please check your inbox.'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send verification email: $e'),
        ),
      );
    }
  }

  Future<void> savePhoneNumber(String phoneNumber) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('phoneNumber', phoneNumber); // Save phone number
    print('Phone number saved: $phoneNumber');
  }

  Future<void> _signUp() async {
    var email = _emailController.text.trim();
    var displayName = _nameController.text.trim();

    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      if (await _checkEmailVerificationAndSavePhone()) {
        // Email is verified, now save phone number
        final phoneNumber = phoneNumberId;
        FirebaseAuth auth = FirebaseAuth.instance;

        User? user = auth.currentUser!;
        // Save to Firestore (or your preferred database)
        await FirebaseFirestore.instance
            .collection('AdminSigUpTable')
            .doc(phoneNumber)
            .set({
          'email': user.email,
          'phoneNumber': phoneNumber,
          'displayName': displayName,
        });
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('signUp Done successfully!')),
        );
        savePhoneNumber(phoneNumber);
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  AdminParkingListPage(phoneNumber: phoneNumberId)),
        );
      } else {
        try {
          // Attempt to create a user
          final auth = FirebaseAuth.instance;

          UserCredential userCredential =
              await auth.createUserWithEmailAndPassword(
            email: email,
            password: 'SecurePassword123!', // Use proper password input
          );

          User? user = userCredential.user;

          if (user != null && !user.emailVerified) {
            await _sendVerificationEmail(user);
          }
        } on FirebaseAuthException catch (e) {
          if (e.code == 'email-already-in-use') {
            // Handle existing email securely
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                    'The email is already in use. Please verified the link sent on your registered email.'),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Signup failed: ${e.message}'),
              ),
            );
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('An unexpected error occurred: $e'),
            ),
          );
        } finally {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  Future<bool> _checkEmailVerificationAndSavePhone() async {
    FirebaseAuth auth = FirebaseAuth.instance;

    User? user = auth.currentUser;

    if (user != null) {
      try {
        await user.reload(); // Refresh user to get updated status
        user = auth.currentUser!; // Reload user instance

        if (user.emailVerified) {
          return true;
        } else {
          print('Email is not verified yet.');

          return false;
        }
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          print('User not found: ${e.message}');
          // ScaffoldMessenger.of(context).showSnackBar(
          //   SnackBar(content: Text('User not found. Please sign up.')),
          // );
        } else {
          print('Unexpected error: ${e.message}');
          // ScaffoldMessenger.of(context).showSnackBar(
          //   SnackBar(content: Text('An error occurred: ${e.message}')),
          // );
        }
        return false;
      } catch (e) {
        print('Error: $e');
        return false;
      }
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign Up'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'First Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    value?.isEmpty ?? true ? 'First name is required' : null,
              ),
              SizedBox(height: 16.0),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
                onChanged: (value) => _validateForm(),
                validator: _validateEmail,
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _isEmailValid && !_isLoading ? _signUp : null,
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('Sign Up'),
              ),
              SizedBox(height: 16.0),
                 ElevatedButton(
                onPressed: (){
                   signupData();
        // Save to Firestore (or your preferred database)
       
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('signUp Done successfully!')),
        );
        
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  AdminParkingListPage(phoneNumber: phoneNumberId)),
        );
                },
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('Skip and update'),
              ),
            ],
          ),
        ),
      ),
    );
  }
  void signupData() async {
        final phoneNumber = phoneNumberId;
        print('phoneNum$phoneNumber');
        FirebaseAuth auth = FirebaseAuth.instance;
        savePhoneNumber(phoneNumber);
     User? user = auth.currentUser!;
 await FirebaseFirestore.instance
            .collection('AdminSigUpTable')
            .doc(phoneNumber)
            .set({
          'email': user.email,
          'phoneNumber': phoneNumber,
          'displayName': user.displayName,
        });
       
  }
}
