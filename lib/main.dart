import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

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

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mobile Number Screen',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MobileNumberScreen(),
    );
  }
}

// import 'package:flutter/material.dart';

// void main() {
//   runApp(EditProfileApp());
// }

// class EditProfileApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: EditProfileScreen(),
//     );
//   }
// }

// class EditProfileScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         backgroundColor: Colors.green,
//         leading: IconButton(
//           icon: Icon(Icons.arrow_back),
//           onPressed: () {
//             // Handle back button press
//           },
//         ),
//         title: Text('Edit Profile'),
//       ),
//       body: SingleChildScrollView(
//         child: Column(
//           children: [
//             Container(
//               color: Colors.green,
//               height: 150,
//               child: Center(
//                 child: Stack(
//                   children: [
//                     CircleAvatar(
//                       radius: 50,
//                       backgroundColor: Colors.orangeAccent,
//                       child: Icon(
//                         Icons.person,
//                         size: 50,
//                         color: Colors.white,
//                       ),
//                     ),
//                     Positioned(
//                       bottom: 0,
//                       right: 0,
//                       child: CircleAvatar(
//                         radius: 20,
//                         backgroundColor: Colors.blue,
//                         child: Icon(
//                           Icons.edit,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Personal Details',
//                     style: TextStyle(
//                       fontSize: 18,
//                       fontWeight: FontWeight.bold,
//                       color: Colors.orange,
//                     ),
//                   ),
//                   SizedBox(height: 10),
//                   TextField(
//                     decoration: InputDecoration(
//                       labelText: 'Owner Name',
//                       prefixIcon: Icon(Icons.person),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: 10),
//                   TextField(
//                     decoration: InputDecoration(
//                       labelText: 'Email Address',
//                       prefixIcon: Icon(Icons.email),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: 10),
//                   TextField(
//                     decoration: InputDecoration(
//                       labelText: 'Mobile Number',
//                       prefixIcon: Icon(Icons.phone),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10),
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: 20),
//                   Center(
//                     child: ElevatedButton(
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.green,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                         padding: EdgeInsets.symmetric(
//                           horizontal: 50,
//                           vertical: 15,
//                         ),
//                       ),
//                       onPressed: () {
//                         // Handle save button press
//                       },
//                       child: Text(
//                         'SAVE',
//                         style: TextStyle(
//                           fontSize: 16,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//             Spacer(),
//             Container(
//               height: 150,
//               child: Image.asset(
//                   'assets/footer_image.png'), // Replace with your footer image asset
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
