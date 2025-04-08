import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/Admin/AdminParkingListPage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'Admin/MobileNumberScreen.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  //await Firebase.initializeApp();

  try {
    await Firebase.initializeApp();
    print("Firebase vk initialized successfully!");
    // Initialize Firebase App Check
    await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.playIntegrity, // Play Integrity for Android
      appleProvider: AppleProvider.deviceCheck, // DeviceCheck for iOS
    );
  } catch (e) {
    print("Firebase vk initialization error: $e");
  }
  final prefs = await SharedPreferences.getInstance();
  final String? phoneNumberId = prefs.getString('phoneNumber');
  print('rere$phoneNumberId');
  runApp( MyApp(phoneNumber: phoneNumberId));
}

class MyApp extends StatelessWidget {
  final String? phoneNumber;

  const MyApp({super.key, required this.phoneNumber});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mobile Number Screen',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home:  phoneNumber != null ? AdminParkingListPage(phoneNumber: phoneNumber!) : const MobileNumberScreen(),
    );
  }
}

