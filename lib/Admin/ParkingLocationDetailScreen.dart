import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_application_2/Admin/BookingInformationScreen.dart';
import 'package:flutter_application_2/Admin/UpdateParkingLocationScreen.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:dotted_border/dotted_border.dart';

import 'AdminParkingListPage.dart'; // Import for Dotted Border

class ParkingLocationDetailScreen extends StatefulWidget {

  final String parkingId; // New parameter
  final Map<String, dynamic> parkingData; // New parameter
  final String phoneNumber;

  const ParkingLocationDetailScreen({super.key, 
    required this.parkingId,
    required this.parkingData,
    required this.phoneNumber
  });

  @override
  _ParkingLocationScreenState createState() => _ParkingLocationScreenState(phoneNumber: phoneNumber);
}

class _ParkingLocationScreenState extends State<ParkingLocationDetailScreen> {
  final String phoneNumber;
  _ParkingLocationScreenState({required this.phoneNumber});

  int _current = 0;
  late List<String> imgList = [];

  // Dynamic checkbox states
  bool cctvChecked = true;
  bool cleaningServiceChecked = false;
  bool mechanicServiceChecked = false;
  late String parkingId; // New parameter
  late Map<String, dynamic> parkingData;
@override
  void initState() {
    // TODO: implement initState
    super.initState();
    // Access the parkingId and parkingData using widget
     parkingId = widget.parkingId;
     parkingData = widget.parkingData;

    // Print the parkingId and parkingData for debugging
    print("Parking Location ID: $parkingId");
    print("Parking Location Data: $parkingData");
    // Access the parkingImages list from parkingData
    List<dynamic> parkingImages = parkingData['parkingImages']??[];

    // Cast it to List<String> if needed
    List<String> imageUrls = parkingImages.cast<String>();
      setState(() {
        imgList=imageUrls;
      });
  // You can also perform any other initialization you need with these values
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Parking Location Details'),
        backgroundColor: Colors.green,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Image Carousel Slider
// Image Carousel Slider with adjusted autoplay and indicator
            Stack(
              children: [
                CarouselSlider(
                  options: CarouselOptions(
                    height: 200.0,
                    autoPlay: false,  // Autoplay disabled
                    enlargeCenterPage: true,
                    onPageChanged: (index, reason) {
                      setState(() {
                        _current = index;
                      });
                    },
                  ),
                  items: imgList.map((item) => GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(
                        builder: (_) {
                          return ImagePreviewScreen(
                              imgList: imgList, initialIndex: _current);
                        },
                      ));
                    },
                    child: Container(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0),
                        child: Image.network(item, fit: BoxFit.contain, width:double.infinity),
                      ),
                    ),
                  )).toList(),
                ),

                // Dots indicator with active blue color
                Positioned(
                  bottom: 10.0,
                  left: 0.0,
                  right: 0.0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: imgList.map((url) {
                      int index = imgList.indexOf(url);
                      return Container(
                        width: 8.0,
                        height: 8.0,
                        margin: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _current == index ? Colors.blue : Colors.grey,  // Active index color changed to blue
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),

            // Parking Location Info
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${parkingData['parkingName']??'Parking Name'}",
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.orange),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "${parkingData['parkingLocationAddress'] ??
                              'Location address not available'}",
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.info, color: Colors.orange),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () {
                          // Handle booking information action here
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BookingInformationScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          "View Booking Information",
                          style: TextStyle(
                              color: Colors.blue, decoration: TextDecoration.underline),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Parking Space Details with Dotted Border
                  DottedBorder(
                    borderType: BorderType.RRect,
                    radius: const Radius.circular(8),
                    dashPattern: const [6, 3],
                    color: Colors.grey,
                    strokeWidth: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Parking Space details",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, color: Colors.black),
                          ),
                          const SizedBox(height: 8),
                          _parkingSpaceDetailRow(
                              icon: Icons.motorcycle,
                              label: "Bike Parking Slots",
                              available: 0,
                              total: parkingData['bikeSlot']??'-'),
                          _parkingSpaceDetailRow(
                              icon: Icons.directions_car,
                              label: "Car Parking Slots",
                              available: 0,
                              total: parkingData['carSlot']??'-'),
                          _parkingPriceDetailRow(
                              icon: Icons.attach_money,
                              label: "Bike cost per hour",
                              price:parkingData['bikeSlotPerHour']??''),
                          _parkingSpaceDetailRow(
                              icon: Icons.ev_station,
                              label: "Electric Car Parking Slots",
                              available: 0,
                              total: parkingData['electricParkingSlot']??'-'),
                          _parkingPriceDetailRow(
                              icon: Icons.attach_money,
                              label: "Car cost per hour",
                              price: parkingData['carSlotPerHour']??''),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Parking Accessories with Dotted Border and Dynamic Checkboxes
                  DottedBorder(
                    borderType: BorderType.RRect,
                    radius: const Radius.circular(8),
                    dashPattern: const [6, 3],
                    color: Colors.grey,
                    strokeWidth: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Parking Accessories",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, color: Colors.black),
                          ),
                          const SizedBox(height: 8),
                          _parkingAccessoryCheckbox(
                              label: "CCTV", isChecked: parkingData['isCCTVChecked'] == "true",
                              isEditable: false
                          ),
                          _parkingAccessoryCheckbox(
                              label: "Cleaning Service",
                              isChecked: parkingData['isGarageChecked'] == "true",
                            isEditable: false
                          ),
                          _parkingAccessoryCheckbox(
                              label: "Mechanic Service",
                              isChecked: parkingData['isElectricChargeFacilityChecked'] == "true",
                              isEditable: false),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Buttons: Edit and Delete
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.edit),
                          label: const Text("Edit"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          onPressed: () {
                            // Handle edit action here
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => UpdateParkingLocationScreen(parkingId: parkingId,parkingData: parkingData,phoneNumber: phoneNumber,)),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ElevatedButton.icon(
                          icon: const Icon(Icons.delete),
                          label: const Text("Delete"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          onPressed: () {
                            // Handle delete action here
                            deleteParkingData(phoneNumber,parkingId);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  //--delete parking data
  Future<void> deleteParkingData(String mobileNumberID, String parkingDataDocID) async {
    try {
      _showLoadingDialog(context);
      // Reference to the specific document
      DocumentReference parkingDataDoc = FirebaseFirestore.instance
          .collection('CreateAddParkingData')
          .doc(parkingId);
        

      // Delete the document
      await parkingDataDoc.delete();

      print("Parking data deleted successfully.");
      // Ensure the loading dialog is closed
      if (Navigator.of(context, rootNavigator: true).canPop()) {
        Navigator.of(context, rootNavigator: true).pop();
      }
      //--calling  prev screen
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) =>  AdminParkingListPage(phoneNumber: mobileNumberID ,)),
      );

    } catch (e) {
      print("Error deleting parking data: $e");
      // Ensure the loading dialog is closed
      if (Navigator.of(context, rootNavigator: true).canPop()) {
        Navigator.of(context, rootNavigator: true).pop();
      }
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
                Text('Deleting Parking data Please wait...'), // Optional loading text
              ],
            ),
          ),
        );
      },
    );
  }
  // Widget for displaying parking space details with icon, label, and count
  Widget _parkingSpaceDetailRow({
    required IconData icon,
    required String label,
    required int available,
    required String total,
  }) {
    return Row(
      children: [
        Icon(icon, color: Colors.orange),
        const SizedBox(width: 8),
        Text("$label - ", style: const TextStyle(fontSize: 16, color: Colors.black)),
        Text("$available/$total", style: const TextStyle(fontSize: 16, color: Colors.green)),
      ],
    );
  }

  // Widget for displaying parking price details with icon and price
  Widget _parkingPriceDetailRow({
    required IconData icon,
    required String label,
    required String price,
  }) {
    return Row(
      children: [
        Icon(icon, color: Colors.orange),
        const SizedBox(width: 8),
        Text("$label - ", style: const TextStyle(fontSize: 16, color: Colors.black)),
        Text(price, style: const TextStyle(fontSize: 16, color: Colors.green)),
      ],
    );
  }

  // Widget for displaying dynamic checkboxes for parking accessories
// Widget for displaying dynamic checkboxes for parking accessories
  Widget _parkingAccessoryCheckbox({
    required String label,
    required bool isChecked,
    bool isEditable = false, // New parameter to control editability
  }) {
    return CheckboxListTile(
      value: isChecked,
      title: Text(label, style: const TextStyle(fontSize: 16, color: Colors.black)),
      onChanged: isEditable ? (bool? value) {
        setState(() {
          // Allow change only if editable
          isChecked = value!;
        });
      } : null, // Disable interaction if not editable
      controlAffinity: ListTileControlAffinity.leading, // Position the checkbox on the leading side
    );
  }

}

// Image Preview Screen
class ImagePreviewScreen extends StatelessWidget {
  final List<String> imgList;
  final int initialIndex;

  const ImagePreviewScreen({super.key, required this.imgList, required this.initialIndex});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Preview'),
        backgroundColor: Colors.green,
      ),
      body: PhotoViewGallery.builder(
        itemCount: imgList.length,
        builder: (context, index) {
          return PhotoViewGalleryPageOptions(
            imageProvider: NetworkImage(imgList[index]),
            initialScale: PhotoViewComputedScale.contained,
            heroAttributes: PhotoViewHeroAttributes(tag: imgList[index]),
          );
        },
        pageController: PageController(initialPage: initialIndex),
      ),
    );
  }
}
