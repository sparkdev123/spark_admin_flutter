import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_2/User/UserMainScreen.dart';
import 'dart:async';
import 'package:http/http.dart' as http;

import 'AdminParkingListPage.dart';


class OTPVerificationScreen extends StatelessWidget {
  late String phoneNumber;
   OTPVerificationScreen({super.key, required this.phoneNumber, required String verificationId});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.green,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              // Action for back button
            },
          ),
          title: const Text(''),
          centerTitle: true,
          elevation: 0,
        ),
        backgroundColor: Colors.green,
        body:  OTPForm(phoneNumber: phoneNumber),
      ),
    );
  }
}

class OTPForm extends StatefulWidget {
  String phoneNumber;

   OTPForm({super.key,
  required this.phoneNumber

  });

  @override
  _OTPFormState createState() => _OTPFormState();
}

class _OTPFormState extends State<OTPForm> {
  final TextEditingController _otpController = TextEditingController();
  int _counter = 30;
  bool _resendEnabled = false;
  late String phoneNumberId;

  @override
  void initState() {
    super.initState();
    phoneNumberId=widget.phoneNumber;
    _startResendTimer();
  }

  void _startResendTimer() {
    _counter = 30;
    _resendEnabled = false;
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_counter > 0) {
        setState(() {
          _counter--;
        });
      } else {
        setState(() {
          _resendEnabled = true;
        });
        timer.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(30),
                topRight: Radius.circular(30),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'OTP Verification',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Please enter the OTP sent on the mobile number',
                  style: TextStyle(color: Colors.black),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                     Text(
                      phoneNumberId,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.green),
                      onPressed: () {
                        // Action for editing phone number
                      },
                    )
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(6, (index) {
                    return SizedBox(
                      width: 40,
                      child: TextField(
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(color: Colors.green),
                          ),
                        ),
                        onChanged: (value) {
                          if (value.length == 1 && index < 5) {
                            FocusScope.of(context).nextFocus();
                          }
                        },
                        textAlign: TextAlign.center,
                        inputFormatters: [LengthLimitingTextInputFormatter(1)],
                        keyboardType: TextInputType.number,
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 16),
                // const Text(
                //   'OTP not received?',
                //   style: TextStyle(color: Colors.black),
                // ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    // Action for verifying OTP
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) =>  Usermainscreen()),
                    );

                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 100),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Verify OTP',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
  Future<void> verifyOtp() async {
    String phoneNumber = phoneNumberId;

    // Format phone number in E.164 format
    var url = Uri.parse(
        'https://38c6-117-200-14-101.ngrok-free.app/verify-code');

    Map<String, String> headers = {'Content-Type': 'application/json'};
// final msg = jsonEncode({"grant_type":"password","username":"******","password":"*****","scope":"offline_access"});
    final msg = json.encode({"phoneNumber": phoneNumber,"code":78777});
    var response = await http.post(url, headers: headers, body: msg);
    print(response.statusCode);
    if (response.statusCode == 200 || response.statusCode == 201) {
      setState(() {
        print('Otp sent  successfully : ${response.body}');
        // _data = 'Data created successfully : ${response.body}';
        //--Navigate to OTP screen
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => OTPVerificationScreen(
        //       phoneNumber: formattedPhoneNumber,
        //       verificationId: _verificationId,
        //     ),
        //   ),
        // );
      });
    } else {
      print('Failed tp fetch data');
      setState(() {
        //_data = 'Failed to create data';
        print('Failed to send Otp');

      });
    }
  }

}
