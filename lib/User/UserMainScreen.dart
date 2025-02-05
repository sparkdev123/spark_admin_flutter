import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/User/PaymentScreen.dart';
import 'package:flutter_paypal_payment/flutter_paypal_payment.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_place/google_place.dart';

class UserMainScreen extends StatefulWidget {
  late String phoneNumber;
  UserMainScreen({super.key, required this.phoneNumber});
  @override
  _UserMainScreenState createState() => _UserMainScreenState();
}

class _UserMainScreenState extends State<UserMainScreen> {
  GoogleMapController? _mapController;
  LatLng currentPosition = LatLng(0.0,0.0); // Default user location
  bool isExpanded = false; // For toggling the bottom sheet
  DraggableScrollableController _scrollController = DraggableScrollableController();
  TextEditingController _searchController = TextEditingController();
  late double addressLocationLattitude;
  late double addressLocationLongitude;
  late String phoneNumberId;
  late GooglePlace _googlePlace;

  BuildContext? _dialogContext; // Global variable to store dialog context


  @override
  void initState() {
    super.initState();
    phoneNumberId=widget.phoneNumber;
    _googlePlace = GooglePlace("AIzaSyBOIz0Xy_BkuDmhs1wPiqFQE2xEswVfNho"); // Initialize Google Place (replace with your Google API key)

    // Use WidgetsBinding to call the fetching function after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showLoadingDialog(context);
      _getCurrentLocation();
     // fetchDataFromFirestoreParkingList();

    });
   // _searchController.text = "Lat: ${currentPosition.latitude}, Long: ${currentPosition.longitude}"; // Set initial location in search bar
  }
  // Function to get current location and fetch address
  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Notify the user and redirect to settings
      print('Location services are disabled. Redirecting to settings...');
      await Geolocator.openLocationSettings();
      return Future.error('Location services are disabled.');
    }
    // Check for location permissions
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied, we cannot request permissions.');
    }

    // Get the current position
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

    // Reverse geocode to get address
    List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
    addressLocationLattitude=position.latitude;
    addressLocationLongitude=position.longitude;
    currentPosition=LatLng(addressLocationLattitude, addressLocationLongitude);
    Placemark place = placemarks[0];

    String address = "${place.street}, ${place.locality}, ${place.country}";
    //---calling fetching list
    fetchDataFromFirestoreParkingList2();
    //--end
    setState(() {
      _searchController.text = address;
      setState(() {
        currentPosition = LatLng(position.latitude, position.longitude);
        if (_mapController != null) {
          _mapController!.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: currentPosition,
                zoom: 17,
              ),
            ),
          );
        }
      });
    });
  }
  // Function to show the loading dialog
  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent closing the dialog by tapping outside
      builder: (BuildContext context) {
        _dialogContext = context; // Store dialog context

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
  void _closeLoadingDialog() {
    if (_dialogContext != null) {
      Navigator.of(_dialogContext!).pop();
      _dialogContext = null; // Reset the variable after closing
    }
  }
  List<Map<String, dynamic>> parkingList = [];
  int _currentIndex = 0;
  Future<void>  fetchDataFromFirestoreParkingList() async {
    var phoneNumberId="+919764791393";
    //_showLoadingDialog(context);
// Reference to the user's parkingData subcollection
    CollectionReference collectionRef = FirebaseFirestore.instance
        .collection('ParkingList');


    try {
      QuerySnapshot querySnapshot = await collectionRef.get();

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

      });

    } catch (e) {
      print("Error fetching data: $e");
    } finally {
      // Ensure the loading dialog is closed
      // if (Navigator.of(context, rootNavigator: true).canPop()) {
      //   Navigator.of(context, rootNavigator: true).pop();
      // }
    }
  }

  Future<void> fetchDataFromFirestoreParkingList2() async {
    var phoneNumberId = "+919764791393";

    // Get the user's current location
    // Position position = await Geolocator.getCurrentPosition(
    //     desiredAccuracy: LocationAccuracy.high);

    double userLat = currentPosition.latitude;
    double userLng = currentPosition.longitude;
    double radiusInKm = 5.0;

    // Reference to the Firestore collection
    CollectionReference collectionRef =
    FirebaseFirestore.instance.collection('ParkingList');

    try {
      QuerySnapshot querySnapshot = await collectionRef.get();

      List<Map<String, dynamic>> tempList = [];

      for (var doc in querySnapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;

        if (data.containsKey('location') && data['location'] != null) {
          GeoPoint location = data['location'];

          double parkingLat = location.latitude;
          double parkingLng = location.longitude;

          // Calculate distance between user and parking location
          double distance = Geolocator.distanceBetween(
              userLat, userLng, parkingLat, parkingLng) /
              1000; // Convert to km
         print("distance=="+distance.toString()+"=radious="+radiusInKm.toString());
          // Add only if within the 5 km radius
          if (distance <= radiusInKm) {
            tempList.add({
              'id': doc.id,
              'data': data,
              'distance': distance.toStringAsFixed(2) + " km"
            });
          }
        }
      }

      print("Filtered nearby parking: $tempList");
      // Close the dialog if it's still open

      setState(() {
          parkingList = tempList;

        });


    } catch (e) {
      print("Error fetching data: $e");

    }finally {
      // Ensure the dialog is closed without affecting navigation
      Future.delayed(Duration(milliseconds: 300), _closeLoadingDialog);
    }

  }
  @override


  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition:  CameraPosition(
              target:currentPosition,
              zoom: 17,
            ),
            markers: _buildMarkers(),
            onMapCreated: (controller) {
              _mapController = controller;
              _getCurrentLocation();
            },
          ),
          Positioned(
            top: 50,
            left: 10,
            right: 10,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(color: Colors.grey, blurRadius: 5, offset: Offset(0, 3)),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: "Search location...",
                  border: InputBorder.none,
                  suffixIcon: Icon(Icons.search),
                ),
                onChanged: (query) {
                  // Update the search logic if necessary
                },
              ),
            ),
          ),
          DraggableScrollableSheet(
            controller: _scrollController,
            initialChildSize: 0.24, // Bottom sheet starts at the bottom (small height)
            minChildSize: 0.24, // Min size when collapsed
            maxChildSize: 0.6, // Max size when expanded
            builder: (context, scrollController) {
              return Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                child: SingleChildScrollView(
                  controller: scrollController, // Enable scrolling for content
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            isExpanded = !isExpanded;
                          });
                          if (isExpanded) {
                            _scrollController.animateTo(
                              0.6, // Expand to max size
                              duration: Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          } else {
                            _scrollController.animateTo(
                              0.1, // Collapse to min size
                              duration: Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                        child: Icon(
                          isExpanded
                              ? Icons.keyboard_arrow_down
                              : Icons.keyboard_arrow_up,
                          size: 30,
                          color: Colors.white,
                        ),
                      ),
                      if (!isExpanded)
                        _buildCompactView(context)
                      else
                        _buildExpandedView(context),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
  Set<Marker> _buildMarkers() {
    Set<Marker> markers = {};
    print("currentPosition markers added: $currentPosition");

    // Marker for current location
    markers.add(
      Marker(
        markerId: const MarkerId('current_location'),
        position: currentPosition,
        infoWindow: const InfoWindow(title: "You are here"),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ),
    );

   //  Markers for parking locations
    for (int index = 0; index < parkingList.length; index++) {
      final parking = parkingList[index]['data'];
      final parkingId = parkingList[index]['id'];

      if (parking['location'] != null) {

        // double latitude = (parking['addressLocationLattitude'] as num).toDouble();
        // double longitude = (parking['addressLocationLongitude'] as num).toDouble();
        GeoPoint geoPoint = parking['location']; // assuming 'location' is the GeoPoint field
        double latitude = geoPoint.latitude;
        double longitude = geoPoint.longitude;
        print("latandlong="+latitude.toString()+"=="+longitude.toString());
        markers.add(
          Marker(
            markerId: MarkerId(parkingId),
            position: LatLng(latitude, longitude),

          ),
        );
      } else {
        print("Missing latitude or longitude for parking ID: $parkingId");
      }
    }
    print("Total markers added: ${markers.length}");

    return markers;
  }


  Widget _buildCompactView(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,  // Horizontal scrolling
      child: Row(
        children: List.generate(parkingList.length, (index) {
         // final parking = parkingList[index]; // Get parking data for each item
         // final parkingId = parkingList[index]['id'];
          final parking = parkingList[index]['data'];
          final parkingId = parkingList[index]['id'];

          // Access the parkingImages list from parkingData
          List<dynamic> parkingImages = parking['parkingImages'] ?? [];
          var bikeSlotPerHour= parking['bikeSlotPerHour'] ?? [];
          var carSlotPerHour= parking['carSlotPerHour'] ?? [];
          // Cast it to List<String> if needed
          List<String> imageUrls = parkingImages.cast<String>();
          // Get the bookingHistory array
          // Get the bookingHistory array
          List<dynamic> bookingHistory = parking['bookingHistory'] ?? [];
          // Filter only "Active" bookings
          List<dynamic> activeBookings = bookingHistory.where((booking) {
            return booking['status'] == 'Active';
          }).toList();

          int activeBookedSlotCount = activeBookings.length;
          int totalSlotAvailable = (int.tryParse(parking['bikeSlot'] ?? "0") ?? 0) +(int.tryParse(parking['carSlot'] ?? "0") ?? 0);

          //
          // List<dynamic> bookingHistory = parking['bookingHistory'] ?? [];
          //
          //
          // // Filter and count active bookings for Bike and Car
          // for (var booking in bookingHistory) {
          //   if (booking['status'] == 'Active') {
          //     if (booking['vehicle_type'] == 'Bike') {
          //       bikeBookedSlot++;
          //     } else if (booking['vehicle_type'] == 'Car') {
          //       carBookedSlot++;
          //     }
          //   }
          // }

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0), // Horizontal margin
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8, // Occupy 80% of the screen width
              child: Card(
                margin: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.network(
                      imageUrls[0],
                      fit: BoxFit.cover,
                      height: 150, // Set fixed height for the image
                      width: double.infinity, // Make image take full width
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        parking['parkingName'],
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text(parking['parkingLocationAddress']),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              print("activeBookedSlotCount="+activeBookedSlotCount.toString()+",totalSlotAvailable=="+totalSlotAvailable.toString());
                              if(activeBookedSlotCount < totalSlotAvailable){
                                // Handle booking spot action
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PaymentScreen(parkingId: parkingId,phoneNumber: phoneNumberId,bikeSlotPerHour: bikeSlotPerHour,carSlotPerHour: carSlotPerHour,),
                                  ),
                                );
                              }else{
                                Fluttertoast.showToast(
                                  msg: "Booking Slot is not Available at this moment!!",
                                  toastLength: Toast.LENGTH_SHORT, // Duration: SHORT or LONG
                                  gravity: ToastGravity.BOTTOM,    // Position: TOP, CENTER, or BOTTOM
                                  backgroundColor: Colors.black,
                                  textColor: Colors.white,
                                  fontSize: 16.0,
                                );
                              }

                            },
                            child: Text("Booking Spot"),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              // Handle go to direction action
                            },
                            child: Text("Go To Direction"),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }


  Widget _buildExpandedView(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildCompactView(context),
        const SizedBox(height: 8.0),
        const Text(
          "Parking Accessories",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            "• CCTV\n• Electric Charge Facility\n• Garage",
            style: TextStyle(color: Colors.white),
          ),
        ),
        const SizedBox(height: 8.0),
        const Text(
          "Parking Images",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        SizedBox(
          height: 100,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: parkingList.length, // This will now loop through all parking items
            itemBuilder: (context, index) {
             // final parking = parkingList[index];
              final parking = parkingList[index]['data'];
              // Access the parkingImages list from parkingData
              List<dynamic> parkingImages = parking['parkingImages'] ?? [];

              // Cast it to List<String> if needed
              List<String> imageUrls = parkingImages.cast<String>();
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Image.network(
                  imageUrls[0],
                  fit: BoxFit.cover,
                  width: 100,
                  height: 100,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8.0),
      ],
    );
  }
  paymentPayPal() async{
    Navigator.of(context).push(MaterialPageRoute(
      builder: (BuildContext context) => PaypalCheckoutView(
        sandboxMode: true,
        clientId: "AeZTelxE4Dstsf2HfqlLYFFrn_y6ejGbK8KDCEb7tw-Nj7CU50SYCQhvLRd0oak4squLqzXnCiH72k8C",
        secretKey: "",
        transactions: const [
          {
            "amount": {
              "total": '70',
              "currency": "USD",
              "details": {
                "subtotal": '70',
                "shipping": '0',
                "shipping_discount": 0
              }
            },
            "description": "The payment transaction description.",
            // "payment_options": {
            //   "allowed_payment_method":
            //       "INSTANT_FUNDING_SOURCE"
            // },
            "item_list": {
              "items": [
                {
                  "name": "Apple",
                  "quantity": 4,
                  "price": '5',
                  "currency": "USD"
                },
                {
                  "name": "Pineapple",
                  "quantity": 5,
                  "price": '10',
                  "currency": "USD"
                }
              ],

              // shipping address is not required though
              //   "shipping_address": {
              //     "recipient_name": "tharwat",
              //     "line1": "Alexandria",
              //     "line2": "",
              //     "city": "Alexandria",
              //     "country_code": "EG",
              //     "postal_code": "21505",
              //     "phone": "+00000000",
              //     "state": "Alexandria"
              //  },
            }
          }
        ],
        note: "Contact us for any questions on your order.",
        onSuccess: (Map params) async {
          print("onSuccess: $params");
        },
        onError: (error) {
          print("onError: $error");
          Navigator.pop(context);
        },
        onCancel: () {
          print('cancelled:');
        },
      ),
    ));
  }
}
