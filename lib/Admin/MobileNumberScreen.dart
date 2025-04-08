import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter_application_2/Admin/AdminParkingListPage.dart';
import 'AdminSignUpScreen.dart';
import 'OTPVerificationScreen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';

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

  // Function to show the loading dialog
  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible:
          false, // Prevent closing the dialog by tapping outside
      builder: (BuildContext context) {
        return const Dialog(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(), // The loading indicator
                SizedBox(width: 20),
                Text('Sending otp  Please wait...'), // Optional loading text
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> sendOtp() async {
// setState(() {
//     Navigator.push(
//           context,
//           MaterialPageRoute(
//               builder: (context) =>
//                   AdminParkingListPage(phoneNumber: '8885124727')),
//         );
// });

    _showLoadingDialog(context);
    String phoneNumber = _phoneController.text.trim();

    // Format phone number in E.164 format
    String formattedPhoneNumber = _countryCode + phoneNumber;
    var url = Uri.parse('https://spark-node.onrender.com/send-verification');

    Map<String, String> headers = {'Content-Type': 'application/json'};
// final msg = jsonEncode({"grant_type":"password","username":"******","password":"*****","scope":"offline_access"});
    final msg = json.encode({"phoneNumber": formattedPhoneNumber});
    var response = await http.post(url, headers: headers, body: msg);
    print(response.statusCode);
    if (response.statusCode == 200 || response.statusCode == 201) {
      setState(() {
        print('Otp sent  successfully : ${response.body}');
         Navigator.pop(context);
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
        // // Ensure the loading dialog is closed
        // if (Navigator.of(context, rootNavigator: true).canPop()) {
        //   Navigator.of(context, rootNavigator: true).pop();
        // }
      });
    } else {
      print('Failed tp fetch data');
      // Ensure the loading dialog is closed
      Navigator.pop(context);

      Fluttertoast.showToast(
        msg: "Failed to send otp please try again",
        toastLength: Toast.LENGTH_SHORT, // Duration: SHORT or LONG
        gravity: ToastGravity.BOTTOM, // Position: TOP, CENTER, or BOTTOM
        backgroundColor: Colors.black,
        textColor: Colors.white,
        fontSize: 16.0,
      );
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
                    'Welcome to Owner Parking',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Container(
                    child: Center(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            'Mobile Verification',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Container(
                              alignment: Alignment.center,
                              padding:
                                  const EdgeInsets.only(left: 50, right: 50),
                              child: const Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    'We need to text you the OTP to authenticate your account',
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 16),
                                    textAlign: TextAlign.center,
                                  )
                                ],
                              )),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  const Text(
                    'Enter Mobile Number',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 14,
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
                      onPressed: () {
                        sendOtp();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
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
