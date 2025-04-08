
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/Admin/AccountScreen.dart';
import 'package:flutter_application_2/Admin/CreateParkingLocationScreen.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_application_2/Admin/ParkingLocationDetailScreen.dart';
import 'package:flutter_application_2/Admin/SettingsScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import 'MobileNumberScreen.dart';

class AdminParkingListPage extends StatelessWidget {
  late String phoneNumber;
   AdminParkingListPage({super.key,required this.phoneNumber});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ParkingListScreen(phoneNumber: phoneNumber),
      debugShowCheckedModeBanner: false,
    );
  }
}

class ParkingListScreen extends StatefulWidget {
  String phoneNumber;


  ParkingListScreen({super.key,required this.phoneNumber});

  @override
  _ParkingListScreenState createState() => _ParkingListScreenState(phoneNumberId: phoneNumber);
}

class _ParkingListScreenState extends State<ParkingListScreen> {
  late String phoneNumberId;
  late String displayName="";
  late String emailId="";

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  _ParkingListScreenState({required this.phoneNumberId

  });
  List<Map<String, dynamic>> parkingList = [];
  int _currentIndex = 0; // For keeping track of the current image index

  Future<void> fetchDataFromFirestoreCreateAddParkingData() async {
    print("phonenumberId in admin parking  List screen=="+phoneNumberId);
    _showLoadingDialog(context);
// Reference to the user's parkingData subcollection
    // CollectionReference collectionRef = FirebaseFirestore.instance
    //     .collection('Admins')
    //     .doc(phoneNumberId)
    //     .collection('CreateAddParkingData');
   CollectionReference collectionRef = FirebaseFirestore.instance.collection('CreateAddParkingData');
   

    try {
      QuerySnapshot querySnapshot = await collectionRef.get();
        DocumentSnapshot doc = await collectionRef.doc(phoneNumberId).get();
    // Map<String, dynamic> data = doc.data() as Map<String, dynamic>;


      // Storing document id as the key and the document data as the value
      List<Map<String, dynamic>> tempList = querySnapshot.docs.map((doc) {
        return {
          'id': doc.id,  // Store the document ID
          'data': doc.data() as Map<String, dynamic>,  // Store the document data
        };
      }).toList();

      print("Fetched data: $tempList");
      // Update the state with the fetched data
      setState(() {
        parkingList = tempList;
        final isElectricChargeFacilityChecked = parkingList[0]['data']['isElectricChargeFacilityChecked'];
        print("isElectricChargeFacilityChecked"+isElectricChargeFacilityChecked);
      });

    } catch (e) {
      print("Error fetching data: $e");
    } finally {
      // Ensure the loading dialog is closed
      if (Navigator.of(context, rootNavigator: true).canPop()) {
        Navigator.of(context, rootNavigator: true).pop();
      }
    }
  }

  //--fetching signuptable data
  Future<void> fetchAdminSignUpData() async {
    try {
      // Reference to the specific document using the phone number as the document ID
      DocumentSnapshot document = await FirebaseFirestore.instance
          .collection('AdminSigUpTable')
          .doc(phoneNumberId)
          .get();

      // Check if the document exists
      if (document.exists) {
        // Retrieve data from the document
        Map<String, dynamic> data = document.data() as Map<String, dynamic>;

        // Access individual fields
        String email = data['email'] ?? '';
        String phone = data['phoneNumber'] ?? '';
        String name = data['displayName'] ?? '';

        // Print or use the retrieved data
        print('Email: $email');
        print('Phone Number: $phone');
        print('Display Name: $name');
        setState(() {
          displayName=name;
          emailId=email;
        });
      } else {
        print('Document does not exist.');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

// Function to show the loading dialog
  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent closing the dialog by tapping outside
      builder: (BuildContext context) {
        return const Dialog(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(), // The loading indicator
                SizedBox(width: 20),
                Text('Fetching Parking List data Please wait...'), // Optional loading text
              ],
            ),
          ),
        );
      },
    );
  }
@override
  void didUpdateWidget(covariant ParkingListScreen oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
    //fetchDataFromFirestoreCreateAddParkingData(); // Fetch data when widget is initialized
    print("didUpdateWidget method called");
  }
  @override
  void initState() {
    super.initState();
    phoneNumberId=widget.phoneNumber;
    // Use WidgetsBinding to call the fetching function after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      fetchAdminSignUpData();
      fetchDataFromFirestoreCreateAddParkingData();
    });   // Fetch data when widget is initialized

  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.green,
        title:  Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Hi,$displayName',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
            CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: Colors.orange),
            )
          ],
        ),
        automaticallyImplyLeading: true, // Shows back arrow
        // elevation: 0,
        // leading: IconButton(
        //   icon: const Icon(Icons.menu),
        //   onPressed: () {
        //     // Action for drawer or menu
        //     // Open the drawer
        //     // Use the GlobalKey to open the drawer
        //     _scaffoldKey.currentState?.openDrawer();
        //   },
        // ),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Drawer Header
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundImage: AssetImage('assets/images/parkingCarLogo.png'), // Replace with your image
                  ),
                  SizedBox(height: 10),
                  Text(
                    "$displayName",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  Text(
                    "$emailId",
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            // Menu Items
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Profile'),
              onTap: () {
                // Navigate or perform any action
                Navigator.pop(context);
              },
            ),   ListTile(
              leading: Icon(Icons.account_balance),
              title: Text('Account'),
              onTap: () {
                // Navigate or perform any action
                // Navigator.pop(context);
                //  Navigator.pop(context);
                // Navigator.push(context, MaterialPageRoute(builder: (context) => AccountScreen(phoneNumber: phoneNumberId)));

                   Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AccountScreen(phoneNumber: phoneNumberId))
                      );
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () {
                // Navigator.pop(context);
                // LocationAutocompleteScreen
                Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => LocationAutocompleteScreen())
                      );
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () {
                logout(context);
               // Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Parking Lists',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: parkingList.length,
              itemBuilder: (context, index) {
                final parkingId = parkingList[index]['id'];
                final parkingData = parkingList[index]['data'];

                // Access the parkingImages list from parkingData
                List<dynamic> parkingImages = parkingData['parkingImages'] ?? [];

                // Cast it to List<String> if needed
                List<String> imageUrls = parkingImages.cast<String>();

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: InkWell(
                    onTap: () {
                      // Action to perform on tap
                      print('Tapped on ${parkingData['parkingName']}');
                      // Navigate to a new screen, show a dialog, or perform any other action
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => ParkingLocationDetailScreen(parkingId: parkingId,parkingData: parkingData,phoneNumber: phoneNumberId,)),
                      );
                    },
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      elevation: 3,
                      child: Row(
                        children: [
                          Flexible(
                            flex: 3, // This takes 3 parts of the available space
                            child: ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(15),
                                bottomLeft: Radius.circular(15),
                              ),
                              child: imageUrls.isNotEmpty
                                  ? Stack(
                                alignment: Alignment.bottomCenter, // Align dots at the bottom center
                                children: [
                                  CarouselSlider(
                                    items: imageUrls.map((imageUrl) {
                                      return Image.network(
                                        imageUrl,
                                        width: double.infinity,
                                        height: 130,
                                        fit: BoxFit.fill,
                                      );
                                    }).toList(),
                                    options: CarouselOptions(
                                      height: 130,
                                      autoPlay: false,
                                      aspectRatio: 2.0,
                                      enlargeCenterPage: false,
                                      viewportFraction: 1.0,
                                      onPageChanged: (index, reason) {
                                        setState(() {
                                          _currentIndex = index; // Track the current index
                                        });
                                      },
                                    ),
                                  ),
                                  Positioned(
                                    bottom: 8, // Position dots higher above the bottom
                                    child: AnimatedSmoothIndicator(
                                      activeIndex: _currentIndex, // Dynamic dot based on the image
                                      count: imageUrls.length,
                                      effect: const ScrollingDotsEffect(
                                        activeDotColor: Colors.blue,
                                        dotHeight: 8,
                                        dotWidth: 8,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                                  : Image.network(
                                'https://dummyimage.com/350x250/33cc99/fff',
                                width: 100,
                                height: 100,
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),
                          Flexible(
                            flex: 7, // This takes 7 parts of the available space
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    parkingData['parkingName'] ?? 'Parking Name',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    parkingData['parkingLocationAddress'] ??
                                        'Location address not available',
                                    style: const TextStyle(fontSize: 14),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      const Icon(Icons.local_parking, color: Colors.orange, size: 16),
                                      const SizedBox(width: 4),
                                      Text(
                                          '${0}/${(int.tryParse(parkingData['bikeSlot']?? "0")?? 0 + (int.tryParse(parkingData['carSlot'] ?? "0") ?? 0))} Slots'),
                                      const SizedBox(width: 16),
                                      const Icon(Icons.check_circle, color: Colors.orange, size: 16),
                                      const SizedBox(width: 4),
                                      Text(parkingData['isElectricChargeFacilityChecked'] == "true"
                                          ? 'Yes'
                                          : 'No'),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),

          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) =>  CreateParkingLocationScreen(phoneNumber: phoneNumberId,)),
          );
        },
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
      ),
    );
  }
  Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('phoneNumber'); // Remove phone number
    print('User logged out!');
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const MobileNumberScreen()),
    );
  }

  Future<void> accountScreen(BuildContext context) async {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => AccountScreen(phoneNumber: phoneNumberId)),
    );
  }
}
