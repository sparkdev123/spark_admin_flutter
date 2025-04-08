import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/Admin/MapScreen.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_place/google_place.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:open_filex/open_filex.dart';
import 'package:url_launcher/url_launcher.dart';

import 'AdminParkingListPage.dart';

class UpdateParkingLocationScreen extends StatefulWidget {
  final String parkingId; // New parameter
  final Map<String, dynamic> parkingData; // New parameter
  final String phoneNumber;

  const UpdateParkingLocationScreen({super.key, 
    required this.parkingId,
    required this.parkingData,
    required this.phoneNumber
  });
  @override
  _UpdateParkingLocationScreenState createState() => _UpdateParkingLocationScreenState(phoneNumberId: phoneNumber);
}


class _UpdateParkingLocationScreenState extends State<UpdateParkingLocationScreen> {
  late final String phoneNumberId;
  _UpdateParkingLocationScreenState({required this.phoneNumberId});

  final ImagePicker _picker = ImagePicker();
  List<File> parkingFileImages = [];
  List<File> documentsFileList = [];
  final TextEditingController _locationController = TextEditingController(); // Controller for location field
  late GooglePlace _googlePlace;
  // Create a TextEditingController parking name
  final TextEditingController _controllerParkingName = TextEditingController();
  final TextEditingController _controllerBikeSlot = TextEditingController();
  final TextEditingController _controllerBikeSlotPerHour = TextEditingController();
  final TextEditingController _controllerCarSlot = TextEditingController();
  final TextEditingController _controllerCarSlotPerHour = TextEditingController();
  final TextEditingController _controllerElectriParkingSlot = TextEditingController();
  final TextEditingController _controllerElectriParkingSlotPerHour = TextEditingController();
  // Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isCCTVChecked = false;
  bool _isElectricChargeFacilityChecked = false;
  bool _isGarageChecked = false;
  late String parkingId; // New parameter
  late Map<String, dynamic> parkingData;
  late List<String> imgUrlFromFireStoreList = [];
  late List<String> documentUrlsFromFireStoreList = [];

  List<dynamic> imgListCombined = [];
  List<dynamic> documentsListCombined = [];
  bool _isimageDeleted = false;
  bool _isdocumentsDeleted = false;
  late double addressLocationLattitude;
  late double addressLocationLongitude;

  @override
  void initState() {
    super.initState();
    _googlePlace = GooglePlace("AIzaSyBOIz0Xy_BkuDmhs1wPiqFQE2xEswVfNho"); // Initialize Google Place (replace with your Google API key)
    // Access the parkingId and parkingData using widget
    parkingId = widget.parkingId;
    parkingData = widget.parkingData;

    // Print the parkingId and parkingData for debugging
    print("update parking screen Parking Location ID: $parkingId");
    print("update parking screen Parking Location Data: $parkingData");
    setState(() {
      _isCCTVChecked=parkingData['isCCTVChecked'] == "true";
      _isElectricChargeFacilityChecked=parkingData['isElectricChargeFacilityChecked'] == "true";
      _isGarageChecked=parkingData['isGarageChecked'] == "true";
    });
    _controllerParkingName.text=parkingData['parkingName']??'Parking Name';
    _controllerBikeSlot.text=parkingData['bikeSlot']??'-';
    _controllerBikeSlotPerHour.text=parkingData['bikeSlotPerHour']??'-';
    _controllerCarSlot.text=parkingData['carSlot']??'-';
    _controllerCarSlotPerHour.text=parkingData['carSlotPerHour']??'-';
    _controllerElectriParkingSlot.text=parkingData['electricParkingSlot']??'-';
    _controllerElectriParkingSlotPerHour.text=parkingData['electricParkingSlotPerHour']??'-';
   _locationController.text=parkingData['parkingLocationAddress']??'';
     addressLocationLattitude=parkingData['addressLocationLattitude']??'';
     addressLocationLongitude=parkingData['addressLocationLongitude']??'';
    // Access the parkingImages list from parkingData
    List<dynamic> parkingImages = parkingData['parkingImages']??[];

    // Cast it to List<String> if needed
    List<String> imageUrls = parkingImages.cast<String>();
    setState(() {
      imgUrlFromFireStoreList=imageUrls;
    });
    imgListCombined.addAll(imgUrlFromFireStoreList);

    //--Documents fetching from firestore
    List<dynamic> documents = parkingData['documents']??[];

    // Cast it to List<String> if needed
    List<String> documentsUrls = documents.cast<String>();
    setState(() {
      documentUrlsFromFireStoreList=documentsUrls;
    });
    documentsListCombined.addAll(documentUrlsFromFireStoreList);

  }





  Future<String?> uploadImageFileToStorage(File file) async {
    try {
      // Create a unique file name using timestamp or any other method
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();

      // Upload the file to Firebase Storage
      Reference storageReference = FirebaseStorage.instance.ref('parking_images/$fileName');
      UploadTask uploadTask = storageReference.putFile(file);

      // Wait for the upload to complete and get the download URL
      TaskSnapshot snapshot = await uploadTask.whenComplete(() {});

      if (snapshot.state == TaskState.success) {
        String downloadUrl = await snapshot.ref.getDownloadURL();
        print("File uploaded successfully, URL: $downloadUrl");
        return downloadUrl; // Return the download URL of the uploaded file
      } else {
        print("Upload failed with state: ${snapshot.state}");
        return null;
      }
    } catch (e) {
      print("File upload error: $e");
      return null;
    }
  }
  Future<String?> uploadDocumentsFileToStorage(File file) async {
    try {
      // Create a unique file name using timestamp or any other method
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();

      // Upload the file to Firebase Storage
      Reference storageReference = FirebaseStorage.instance.ref('documents_file/$fileName');
      UploadTask uploadTask = storageReference.putFile(file);

      // Wait for the upload to complete and get the download URL
      TaskSnapshot snapshot = await uploadTask.whenComplete(() {});

      if (snapshot.state == TaskState.success) {
        String downloadUrl = await snapshot.ref.getDownloadURL();
        print("File uploaded successfully, URL: $downloadUrl");
        return downloadUrl; // Return the download URL of the uploaded file
      } else {
        print("Upload failed with state: ${snapshot.state}");
        return null;
      }
    } catch (e) {
      print("File upload error: $e");
      return null;
    }
  }
  Future<void> UpdateFirebaseParkingData(BuildContext buildcontext,String parkingName, String bikeSlot, String bikeSlotPerHour, String carSlot, String carSlotPerHour, String electricParkingSlot, String electricParkingSlotPerHour, String parkingLocationAddress, bool isCCTVChecked, bool isElectricChargeFacilityChecked, bool isGarageChecked, List<File> parkingImages, List<File> documents) async {
    List<String> imageUrls = [];
    List<String> documentsUrls = [];

    // Upload image files and replace file in the list with its URL
    for (int i = 0; i < imgListCombined.length; i++) {
      if (imgListCombined[i] is File) {
        // If it's a File, upload it to Firebase Storage
        String? imageUrl = await uploadImageFileToStorage(imgListCombined[i]);
        if (imageUrl != null) {
          imgListCombined[i] = imageUrl;  // Replace File with URL in the list
          imageUrls.add(imageUrl);  // Add URL to imageUrls list
        }
      } else if (imgListCombined[i] is String) {
        // If it's already a URL, just add it to the imageUrls list
        imageUrls.add(imgListCombined[i]);
      }
    }

    // Upload document files and replace file in the list with its URL
    for (int i = 0; i < documentsListCombined.length; i++) {
      if (documentsListCombined[i] is File) {
        // If it's a File, upload it to Firebase Storage
        String? docsUrl = await uploadDocumentsFileToStorage(documentsListCombined[i]);
        if (docsUrl != null) {
          documentsListCombined[i] = docsUrl;  // Replace File with URL in the list
          documentsUrls.add(docsUrl);  // Add URL to documentsUrls list
        }
      } else if (documentsListCombined[i] is String) {
        // If it's already a URL, just add it to the documentsUrls list
        documentsUrls.add(documentsListCombined[i]);
      }
    }

    print('Image URLs: $imageUrls');
    print('Document URLs: $documentsUrls');
    // Firestore document reference
    DocumentReference documentReference = FirebaseFirestore.instance
        .collection('CreateAddParkingData')
        .doc(parkingId);  // Replace with your actual document ID

    // Data to update
    Map<String, dynamic> updatedData = {
      // 'documents': FieldValue.arrayUnion([
      //   'https://newdocumenturl.com'  // New URL to add to the documents array
      // ]),
      // Add other fields to update as needed
      'parkingName': parkingName,
      'bikeSlot': bikeSlot,
      'bikeSlotPerHour':bikeSlotPerHour,
      'carSlot': carSlot,
      'carSlotPerHour': carSlotPerHour,
      'electricParkingSlot':electricParkingSlot,
      'electricParkingSlotPerHour': electricParkingSlotPerHour,
      if(parkingLocationAddress.isNotEmpty)
      'parkingLocationAddress':parkingLocationAddress,
      'isCCTVChecked':'$isCCTVChecked',
      'isElectricChargeFacilityChecked':'$isElectricChargeFacilityChecked',
      'isGarageChecked':'$isGarageChecked',
      if(parkingFileImages.isNotEmpty || _isimageDeleted)
      'parkingImages':imageUrls,
      if(documentsFileList.isNotEmpty || _isdocumentsDeleted)
      'documents':documentsUrls,
      'created_at': FieldValue.serverTimestamp(),
    };


    try {
      await documentReference.update(updatedData);
      print("Firebase Data updated successfully");
      _isimageDeleted=false;
      _isdocumentsDeleted=false;
    } catch (e) {
      print("Failed to update Firebase Data: $e");
    }

    //---closing showDialog box
    if (Navigator.of(buildcontext, rootNavigator: true).canPop()) {
      Navigator.of(buildcontext, rootNavigator: true).pop(); // Ensure dialog is closed

    }
    //---close current screen as well
    // Navigator.of(context).pop(); // Ensure dialog is closed
//--calling  prev screen
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) =>  AdminParkingListPage(phoneNumber: phoneNumberId,)),
    );
  }

  // Function to pick an image from camera or gallery
  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
   // parkingFileImages.clear();
    if (pickedFile != null) {
      setState(() {
        parkingFileImages.add(File(pickedFile.path));
      });
    }
    if(parkingFileImages.isNotEmpty){
      imgListCombined.add(parkingFileImages[parkingFileImages.length-1]);

    }
  }

  // Function to pick a document (any type)
  Future<void> _pickDocument() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'xls', 'xlsx', 'ppt', 'pptx', 'txt'],
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      setState(() {
        documentsFileList.add(file);
      });
      if(documentsFileList.isNotEmpty){
        documentsListCombined.add(documentsFileList[documentsFileList.length-1]);

      }
    }

  }


  void _showImagePreview(File image) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.black),
                  onPressed: () {
                    // Close the dialog
                    Navigator.of(context).pop();
                  },
                ),
              ),
              Expanded(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: FileImage(image),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  void _showImagePreviewFromUrl(String imageUrl) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          child: Column(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.black),
                  onPressed: () {
                    // Close the dialog
                    Navigator.of(context).pop();
                  },
                ),
              ),
              Expanded(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(imageUrl),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Function to view document when clicked
  void _viewDocument(File document) {
    if (document.path.endsWith('.pdf')) {
      // Open PDF viewer for PDF documents
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PDFViewerScreen(filePath: document.path),
        ),
      );
    } else {
      // For other document types, open with the default app on the device
      OpenFilex.open(document.path);
    }
  }
  void _viewDocumentFromUrl(String documentUrl) {
    if (documentUrl.endsWith('.pdf')) {
      // Open PDF viewer for PDF URLs
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PDFViewerScreen(filePath: documentUrl), // You might need to adjust how the PDFViewerScreen handles URLs
        ),
      );
    } else {
      // For other document types, open with the default app on the device
      _openUrl(documentUrl);
    }
  }
//--getfile name from docs url
  String _getFileNameFromUrl(String url) {
    // Create a Uri object from the URL
    final uri = Uri.parse(url);

    // Extract the path from the Uri
    final pathSegments = uri.pathSegments;

    // Get the last segment of the path as the filename
    String fileName = pathSegments.isNotEmpty ? pathSegments.last : '';

    // Optionally, you can further clean the filename if needed
    // For example, you can remove any query parameters
    if (fileName.contains('?')) {
      fileName = fileName.split('?').first; // Get the part before the '?'
    }

    return fileName;
  }

// Function to open URL using url_launcher
  void _openUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not open the document URL: $url';
    }
  }


  // Function to delete an image
  void _deleteImage(int index) {
    if (imgListCombined[index] is String) {
      // Remove from Firestore images (URLs)
      //imgUrlFromFireStoreList.removeAt(index);
      final imgUrl = imgListCombined[index];
      imgUrlFromFireStoreList.remove(imgUrl);
    } else if (imgListCombined[index] is File) {
      // Remove from local images (Files)
     // parkingFileImages.removeAt(index);
      // Find the corresponding index in the documentsFileList
      final imgFile = imgListCombined[index];
      parkingFileImages.remove(imgFile); // Safely remove by reference
    }

    // Update the combined list
    imgListCombined = [...imgUrlFromFireStoreList, ...parkingFileImages];

    // Refresh the UI (e.g., setState)
    setState(() {
      _isimageDeleted=true;
    });
  }


  // Function to delete a document
  void _deleteDocument(int index) {
    if (documentsListCombined[index] is String) {
     // documentUrlsFromFireStoreList.removeAt(index);
      // Find the corresponding index in the documentUrlsFromFireStoreList
      final documentUrl = documentsListCombined[index];
      documentUrlsFromFireStoreList.remove(documentUrl);
    } else if (documentsListCombined[index] is File) {
     // documentsFileList.removeAt(index);
      // Find the corresponding index in the documentsFileList
      final documentFile = documentsListCombined[index];
      documentsFileList.remove(documentFile); // Safely remove by reference
    }

    documentsListCombined = [...documentsFileList, ...documentUrlsFromFireStoreList];
    // Rebuild the combined list
    setState(() {
      _isdocumentsDeleted=true;
    });
  }

  // Function to get current location and fetch address
  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
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
    Placemark place = placemarks[0];

    String address = "${place.street}, ${place.locality}, ${place.country}";

    setState(() {
      _locationController.text = address;
    });
  }
// Navigate to the map view on clicking the TextFormField
  void _openMapView() async {
    // Navigate to map view and get updated address if marker changes
    var   destination =  const LatLng(17.4106,  78.4310);

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MapScreen(onUpdate: _updateData,locationlatitude: addressLocationLattitude,locationlongitude: addressLocationLongitude,),
      ),
    );

    if (result != null) {
      setState(() {
        _locationController.text = result;
      });
    }
  }
  void _updateData(String newData,double latitude,double longitude) {
    addressLocationLattitude=latitude;
    addressLocationLongitude=longitude;
    setState(() {
      _locationController.text = newData;// Update the state with the new data
    });
  }


  //--- updating firebase data base
  Future<void> updateFirebaseParkingData() async {
    // Firestore document reference
    DocumentReference documentReference = FirebaseFirestore.instance
        .collection('CreateAddParkingData')
        .doc(parkingId);  // Replace with your actual document ID

    // Data to update
    Map<String, dynamic> updatedData = {
      'bikeSlot': '25',  // New value for bikeSlot
      // 'documents': FieldValue.arrayUnion([
      //   'https://newdocumenturl.com'  // New URL to add to the documents array
      // ]),
      // Add other fields to update as needed
    };

    try {
      await documentReference.update(updatedData);
      print("Document updated successfully");
    } catch (e) {
      print("Failed to update document: $e");
    }
  }


  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controllerParkingName.dispose();
    _controllerBikeSlot.dispose();
    _controllerBikeSlotPerHour.dispose();
    _controllerCarSlot.dispose();
    _controllerCarSlotPerHour.dispose();
    _controllerElectriParkingSlot.dispose();
    _controllerElectriParkingSlotPerHour.dispose();
    _locationController.dispose();


    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Parking Location'),
        backgroundColor: Colors.green,

      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Parking Name & Location Input
              const Text("Update Parking Details", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 16),
              TextFormField(
                controller: _controllerParkingName,
                decoration: const InputDecoration(
                  labelText: 'Parking Name *',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: _openMapView, // Open map view on tap
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: _locationController,
                    decoration: const InputDecoration(
                      labelText: 'Parking Location *',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Parking Space Allotted Section
              const Text("Parking Space Allotted", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ParkingSpaceField(
                      label: 'Bike Slots',
                      icon: Icons.motorcycle,
                      textEditingController: _controllerBikeSlot,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ParkingSpaceField(
                      label: 'Per hrs',
                      textEditingController: _controllerBikeSlotPerHour,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ParkingSpaceField(
                      label: 'Car Slots',
                      icon: Icons.directions_car,
                      textEditingController: _controllerCarSlot,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ParkingSpaceField(
                      label: 'Per hrs',
                      textEditingController: _controllerCarSlotPerHour,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ParkingSpaceField(
                      label: 'Electric Parking Slots',
                      icon: Icons.electric_bike,
                      textEditingController: _controllerElectriParkingSlot,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ParkingSpaceField(
                      label: 'Per hrs',
                      textEditingController: _controllerElectriParkingSlotPerHour,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Parking Accessories Section
              const Text("Parking Accessories", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              Column(
                children: [
                  CheckboxListTile(
                    title: const Text("CCTV"),
                    value: _isCCTVChecked,
                    onChanged: (bool ? newValue) {
                    setState(() {
                      _isCCTVChecked=newValue!;
                    });
                    },
                  ),
                  CheckboxListTile(
                    title: const Text("Electric Charge Facility"),
                    value: _isElectricChargeFacilityChecked,
                    onChanged: (newValue) {
                      setState(() {
                        _isElectricChargeFacilityChecked=newValue!;
                      });

                    },
                  ),
                  CheckboxListTile(
                    title: const Text("Garage"),
                    value: _isGarageChecked,
                    onChanged: (newValue) {
                      setState(() {
                        _isGarageChecked=newValue!;
                      });

                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Parking Images Upload Section
              const Text("Parking Images *", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.camera_alt),
                    onPressed: () => _pickImage(ImageSource.camera),
                  ),
                  IconButton(
                    icon: const Icon(Icons.photo),
                    onPressed: () => _pickImage(ImageSource.gallery),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              // Horizontal List of Uploaded Images
              imgListCombined.isNotEmpty
                  ? SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: imgListCombined.length,
                  itemBuilder: (context, index) {
                    final item = imgListCombined[index];

                    return Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: GestureDetector(
                            onTap: () {
                              if (item is String) {
                                // It's a URL
                                _showImagePreviewFromUrl(item);
                              } else if (item is File) {
                                // It's a File
                                _showImagePreview(item);
                              }
                            },
                            child: item is String
                                ? Image.network(item) // Display Firestore image
                                : Image.file(item),    // Display newly added image
                          ),
                        ),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: GestureDetector(
                            onTap: () => _deleteImage(index),
                            child: const Icon(Icons.cancel, color: Colors.red),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              )
                  : const Text('No images selected'),


              const SizedBox(height: 16),

              // Documents Upload Section
              const Text("Documents *", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              IconButton(
                icon: const Icon(Icons.attach_file),
                onPressed: _pickDocument,
              ),
              const SizedBox(height: 8),
              // Horizontal List of Uploaded Documents
              documentsListCombined.isNotEmpty
                  ? SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: documentsListCombined.length,
                  itemBuilder: (context, index) {
                    final item = documentsListCombined[index];

                    return Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: GestureDetector(
                            onTap: () {
                              if (item is String) {
                                // It's a URL, open the document from URL
                                _viewDocumentFromUrl(item);
                              } else if (item is File) {
                                // It's a local file
                                _viewDocument(item);
                              }
                            },
                            child: Column(
                              children: [
                                const Icon(Icons.insert_drive_file, size: 50),
                                Text(
                                  item is String
                                      ? _getFileNameFromUrl(item) // Extract readable file name from URL // Extract file name from URL
                                      : item.path.split('/').last, // Extract file name from File
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: GestureDetector(
                            onTap: () => _deleteDocument(index),
                            child: const Icon(Icons.cancel, color: Colors.red),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              )
                  : const Text('No documents selected'),


              const SizedBox(height: 24),
              Center(
                child:ElevatedButton(
                  onPressed: () {
                    _showLoadingDialog(context);
                    String parkingName= _controllerParkingName.text;
                    String bikeSlot= _controllerBikeSlot.text;
                    String bikeSlotPerHour=_controllerBikeSlotPerHour.text;
                    String carSlot= _controllerCarSlot.text;
                    String carSlotPerHour= _controllerCarSlotPerHour.text;
                    String electricParkingSlot= _controllerElectriParkingSlot.text;
                    String electricParkingSlotPerHour= _controllerElectriParkingSlotPerHour.text;
                    String parkingLocationAddress=_locationController.text;

                    UpdateFirebaseParkingData(context,parkingName,bikeSlot,bikeSlotPerHour,carSlot,carSlotPerHour,electricParkingSlot,electricParkingSlotPerHour,parkingLocationAddress,_isCCTVChecked,_isElectricChargeFacilityChecked,_isGarageChecked,parkingFileImages,documentsFileList);

                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green, // Background color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0), // Rounded corners
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 15), // Padding
                  ),
                  child: const Text("Update Parking"),
                ) ,
              ),

            ],
          ),
        ),
      ),
    );
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
              Text('Updating Parking  Please wait...'), // Optional loading text
            ],
          ),
        ),
      );
    },
  );
}
// PDF Viewer for showing PDF documents
class PDFViewerScreen extends StatelessWidget {
  final String filePath;

  const PDFViewerScreen({super.key, required this.filePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("PDF Viewer"),
      ),
      body: PDFView(
        filePath: filePath,
      ),
    );
  }
}

// Reusable widget for Parking Space input fields
class ParkingSpaceField extends StatelessWidget {
  final String label;
  final IconData? icon;
  final TextEditingController? textEditingController;


  const ParkingSpaceField({super.key, required this.label, this.icon,this.textEditingController});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: textEditingController,
      keyboardType: TextInputType.number,  // Set number input type
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon) : null,
        border: const OutlineInputBorder(),
      ),
    );
  }
}