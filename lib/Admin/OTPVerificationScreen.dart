import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_2/Admin/AdminSignUpScreen.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:async';
import 'package:http/http.dart' as http;

import 'AdminParkingListPage.dart';

class OTPVerificationScreen extends StatelessWidget {
  late String phoneNumber;
  OTPVerificationScreen(
      {super.key, required this.phoneNumber, required String verificationId});

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
        body: OTPForm(phoneNumber: phoneNumber),
      ),
    );
  }
}

class OTPForm extends StatefulWidget {
  String phoneNumber;

  OTPForm({super.key, required this.phoneNumber});

  @override
  _OTPFormState createState() => _OTPFormState();
}

class _OTPFormState extends State<OTPForm> {
  int _counter = 30;
  bool _resendEnabled = false;
  late String phoneNumberId;
// List of TextEditingControllers for each TextField
  final List<TextEditingController> _controllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  @override
  void initState() {
    super.initState();
    phoneNumberId = widget.phoneNumber;
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
  void dispose() {
    // Dispose controllers to avoid memory leaks
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  // Function to get the OTP value
  String _getOTPValue() {
    return _controllers.map((controller) => controller.text).join();
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
                        controller: _controllers[index], // Assign controller
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
                          } else if (value.isEmpty && index > 0) {
                            FocusScope.of(context)
                                .previousFocus(); // Move focus to previous field
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
                    verifyOtp();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 100),
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
                Text('Verifying  otp  Please wait...'), // Optional loading text
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> verifyOtp() async {
    _showLoadingDialog(context);
    String phoneNumber = phoneNumberId;
    // Get the OTP value
    final enteredOtp = _getOTPValue();
    print("Entered OTP: $enteredOtp");
    // Format phone number in E.164 format
    var url = Uri.parse('https://spark-node.onrender.com/verify-code');

    Map<String, String> headers = {'Content-Type': 'application/json'};
// final msg = jsonEncode({"grant_type":"password","username":"******","password":"*****","scope":"offline_access"});
    final msg = json.encode({"phoneNumber": phoneNumber, "code": enteredOtp});
    var response = await http.post(url, headers: headers, body: msg);
    print(response.statusCode);
    if (response.statusCode == 200 || response.statusCode == 201) {
      setState(() {
        Fluttertoast.showToast(
          msg: "otp verified  Successfully...",
          toastLength: Toast.LENGTH_SHORT, // Duration: SHORT or LONG
          gravity: ToastGravity.BOTTOM, // Position: TOP, CENTER, or BOTTOM
          backgroundColor: Colors.black,
          textColor: Colors.white,
          fontSize: 16.0,
        );

        print('Otp verified  successfully : ${response.body}');
        // _data = 'Data created successfully : ${response.body}';
        if (Navigator.of(context, rootNavigator: true).canPop()) {
          Navigator.of(context, rootNavigator: true).pop();
        }
        //--Navigate to admin parking list screen
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  AdminSignUpScreen(phoneNumber: phoneNumberId)),
        );
      });
    } else {
      print('Failed tp fetch data');
      // Ensure the loading dialog is closed
      // Ensure the loading dialog is closed
      if (Navigator.of(context, rootNavigator: true).canPop()) {
        Navigator.of(context, rootNavigator: true).pop();
      }
      Fluttertoast.showToast(
        msg: "otp verified  failed  please try again",
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
}
