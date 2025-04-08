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
import 'Global/GlobalCardWidget.dart';
import 'AdminParkingListPage.dart';

class CreateParkingLocationScreen extends StatefulWidget {
  late String phoneNumber;

   CreateParkingLocationScreen({super.key,required this.phoneNumber});

  @override
  _CreateParkingLocationScreenState createState() => _CreateParkingLocationScreenState(phoneNumber: phoneNumber);
}

class _CreateParkingLocationScreenState extends State<CreateParkingLocationScreen> {
  String phoneNumber;
  _CreateParkingLocationScreenState({required this.phoneNumber

  });
  final ImagePicker _picker = ImagePicker();
  List<File> parkingImages = [];
  List<File> documents = [];
  final TextEditingController _locationController = TextEditingController(); // Controller for location field
  late GooglePlace _googlePlace;
  late double addressLocationLattitude;
  late double addressLocationLongitude;

  // Firestore instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Future<List<String>> uploadFiles(List<File> files, String folder) async {
    List<String> downloadUrls = [];

    for (File file in files) {
      // Use a unique file name for each file
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference ref = FirebaseStorage.instance.ref().child('$folder/$fileName');

      // Upload file to Firebase Storage
      UploadTask uploadTask = ref.putFile(file);

      // Wait for the upload to complete and get the download URL
      TaskSnapshot taskSnapshot = await uploadTask;
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();

      // Add the download URL to the list
      downloadUrls.add(downloadUrl);
    }

    return downloadUrls;  // Return the list of download URLs
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

  Future<void> addCreateParkingData(BuildContext buildcontext,String parkingName, String bikeSlot, String bikeSlotPerHour, String carSlot, String carSlotPerHour, String electricParkingSlot, String electricParkingSlotPerHour, String parkingLocationAddress, bool isCCTVChecked, bool isElectricChargeFacilityChecked, bool isGarageChecked, List<File> parkingImages, List<File> documents) async {
    // Add a new document with auto-generated ID
    List<String> imageUrls = [];
    List<String> documentsUrls = [];

    // Upload each images file and get the URL
    for (File file in parkingImages) {
      String? imageUrl = await uploadImageFileToStorage(file);
      if (imageUrl != null) {
        imageUrls.add(imageUrl); // Add URL to the list
      }
    }
    // Upload each Documents  file and get the URL
    for (File file in documents) {
      String? docsUrl = await uploadDocumentsFileToStorage(file);
      if (docsUrl != null) {
        documentsUrls.add(docsUrl); // Add URL to the list
      }
    }
// Reference to the user's main document
await FirebaseFirestore.instance
            .collection('CreateAddParkingData').add({
                'parkingName': parkingName,
      'bikeSlot': bikeSlot,
      'bikeSlotPerHour':bikeSlotPerHour,
      'carSlot': carSlot,
      'carSlotPerHour': carSlotPerHour,
      'electricParkingSlot':electricParkingSlot,
      'electricParkingSlotPerHour': electricParkingSlotPerHour,
      'parkingLocationAddress':parkingLocationAddress,
      'isCCTVChecked':'$isCCTVChecked',
      'isElectricChargeFacilityChecked':'$isElectricChargeFacilityChecked',
      'isGarageChecked':'$isGarageChecked',
      'parkingImages':imageUrls,
      'documents':documentsUrls,
      'addressLocationLattitude':addressLocationLattitude,
      'addressLocationLongitude':addressLocationLongitude,
      'created_at': FieldValue.serverTimestamp(),
            });
          

    print('Data added successfully!');
    //---closing showDialog box
    if (Navigator.of(buildcontext, rootNavigator: true).canPop()) {
      Navigator.of(buildcontext, rootNavigator: true).pop(); // Ensure dialog is closed

    }
  //---close current screen as well
   // Navigator.of(context).pop(); // Ensure dialog is closed
//--calling  prev screen
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) =>  AdminParkingListPage(phoneNumber: phoneNumber)),
    );
  }
  @override
  void initState() {
    super.initState();
    _googlePlace = GooglePlace("AIzaSyBOIz0Xy_BkuDmhs1wPiqFQE2xEswVfNho"); // Initialize Google Place (replace with your Google API key)
    _getCurrentLocation(); // Automatically fetch current location
  }
  // Function to pick an image from camera or gallery
  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        parkingImages.add(File(pickedFile.path));
      });
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
        documents.add(file);
      });
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

  // Function to delete an image
  void _deleteImage(int index) {
    setState(() {
      parkingImages.removeAt(index);
    });
  }

  // Function to delete a document
  void _deleteDocument(int index) {
    setState(() {
      documents.removeAt(index);
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
    addressLocationLattitude=position.latitude;
    addressLocationLongitude=position.longitude;
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
  // Create a TextEditingController parking name
  final TextEditingController _controllerParkingName = TextEditingController();
  final TextEditingController _controllerBikeSlot = TextEditingController();
  final TextEditingController _controllerBikeSlotPerHour = TextEditingController();
  final TextEditingController _controllerCarSlot = TextEditingController();
  final TextEditingController _controllerCarSlotPerHour = TextEditingController();
  final TextEditingController _controllerElectriParkingSlot = TextEditingController();
  final TextEditingController _controllerElectriParkingSlotPerHour = TextEditingController();


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
  bool _isCCTVChecked = false;
  bool _isElectricChargeFacilityChecked = false;
  bool _isGarageChecked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Parking Location'),
        backgroundColor: Colors.green,

      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Parking Name & Location Input
              const Text("Add Parking Details", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
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
              parkingImages.isNotEmpty
                  ? SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: parkingImages.length,
                  itemBuilder: (context, index) {
                    return Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: GestureDetector(
                            onTap: () => _showImagePreview(parkingImages[index]),
                            child: Image.file(parkingImages[index]),
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
              documents.isNotEmpty
                  ? SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: documents.length,
                  itemBuilder: (context, index) {
                    return Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: GestureDetector(
                            onTap: () => _viewDocument(documents[index]),
                            child: Column(
                              children: [
                                const Icon(Icons.insert_drive_file, size: 50),
                                Text(documents[index].path.split('/').last),
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

                    addCreateParkingData(context,parkingName,bikeSlot,bikeSlotPerHour,carSlot,carSlotPerHour,electricParkingSlot,electricParkingSlotPerHour,parkingLocationAddress,_isCCTVChecked,_isElectricChargeFacilityChecked,_isGarageChecked,parkingImages,documents);

                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green, // Background color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0), // Rounded corners
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 15), // Padding
                  ),
                  child: const Text(
                    "Create Add Parking",
                    style: TextStyle(fontSize: 16), // Text styling
                  ),
                ),

              )
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
              Text('Adding Parking Please wait...'), // Optional loading text
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