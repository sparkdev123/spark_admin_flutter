import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'OTPVerificationScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

class MobileNumberScreen extends StatefulWidget {
  const MobileNumberScreen({super.key});

  @override
  _MobileNumberScreenState createState() => _MobileNumberScreenState();
}

class _MobileNumberScreenState extends State<MobileNumberScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _phoneController = TextEditingController();
  String _countryCode = '+91'; // Default country code (for India)
  String _verificationId = '';
  // Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Method to add data to Firestore
  Future<void> addData() async {
    // Add a new document with auto-generated ID
    await _firestore.collection('users').add({
      'name': 'John Doe',
      'email': 'johndoe@example.com',
      'status':'Active',
      'created_at': FieldValue.serverTimestamp(),
    });
    print('Data added successfully!');
  }
  Future<void> getData() async {
    // Retrieve all documents from the 'users' collection
    QuerySnapshot querySnapshot = await _firestore.collection('users').get();

    // Iterate over each document and print the data
    for (var doc in querySnapshot.docs) {
      print(doc.data());
    }
  }
  // Send OTP function
  void _sendOTP() async {
    String phoneNumber = _phoneController.text.trim();

    // Format phone number in E.164 format
    String formattedPhoneNumber = _countryCode + phoneNumber;

    await _auth.verifyPhoneNumber(
      phoneNumber: formattedPhoneNumber,
      verificationCompleted: (PhoneAuthCredential credential) {
        // Handle when OTP is auto-retrieved
        print('verificationCompleted : $credential');

      },
      verificationFailed: (FirebaseAuthException e) {
        print('Verification failed: ${e.message}');
      },
      codeSent: (String verificationId, int? resendToken) {
        setState(() {
          _verificationId = verificationId;
        });
        // Navigate to OTP screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OTPVerificationScreen(
              phoneNumber: formattedPhoneNumber,
              verificationId: _verificationId,
            ),
          ),
        );
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        setState(() {
          _verificationId = verificationId;
        });
      },
    );
  }
  Future<void> sendOtp() async {
    String phoneNumber = _phoneController.text.trim();

    // Format phone number in E.164 format
    String formattedPhoneNumber = _countryCode + phoneNumber;
    var url = Uri.parse(
        'https://38c6-117-200-14-101.ngrok-free.app/send-verification');

    Map<String, String> headers = {'Content-Type': 'application/json'};
// final msg = jsonEncode({"grant_type":"password","username":"******","password":"*****","scope":"offline_access"});
    final msg = json.encode({"phoneNumber": formattedPhoneNumber});
    var response = await http.post(url, headers: headers, body: msg);
    print(response.statusCode);
    if (response.statusCode == 200 || response.statusCode == 201) {
      setState(() {
        print('Otp sent  successfully : ${response.body}');
       // _data = 'Data created successfully : ${response.body}';
        //--Navigate to OTP screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OTPVerificationScreen(
              phoneNumber: formattedPhoneNumber,
              verificationId: _verificationId,
            ),
          ),
        );
      });
    } else {
      print('Failed tp fetch data');
      setState(() {
        //_data = 'Failed to create data';
        print('Failed to send Otp');

      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green[100],
      body: Column(
        children: [
          Expanded(
            flex: 3,
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  color: Colors.green,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Parking',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Image.asset(
                        'assets/images/parkingCarLogo.png',
                        height: 150,
                      ),
                    ],
                  ),
                ),
                const Positioned(
                  top: 40,
                  left: 20,
                  child: Text(
                    '7:50',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 4,
            child: Container(
              padding: const EdgeInsets.all(16.0),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30.0),
                  topRight: Radius.circular(30.0),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Welcome to Parking',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Mobile Verification',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'We need to text you the OTP to authenticate your account',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Enter Mobile Number',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: CountryCodePicker(
                          onChanged: (countryCode) {
                            setState(() {
                              _countryCode = countryCode.dialCode ?? '+91';
                            });
                          },
                          initialSelection: 'IN',
                          favorite: const ['+91', 'IN'],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _phoneController,
                          decoration: InputDecoration(
                            hintText: 'Enter Mobile Number',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                          keyboardType: TextInputType.phone,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton(
                      onPressed:(){
                        //sendOtp();
                        //--Navigate to OTP screen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => OTPVerificationScreen(
                              phoneNumber: _phoneController.text,
                              verificationId: _verificationId,
                            ),
                          ),
                        );
                      } ,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 80, vertical: 15),
                      ),
                      child: const Text('Continue'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}