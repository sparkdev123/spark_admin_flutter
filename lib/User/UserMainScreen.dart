import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';



class Usermainscreen extends StatefulWidget {
  @override
  _ParkingMapScreenState createState() => _ParkingMapScreenState();
}

class _ParkingMapScreenState extends State<Usermainscreen> {
  GoogleMapController? _mapController;
  LatLng? _currentLocation;
  String _currentAddress = "Fetching location...";
  int _currentParkingIndex = 0;
  Map<MarkerId, Marker> _markers = {};
  double _bottomSheetSize = 0.3; // Initial bottom sheet size

  // Sample Parking Data
  List<Map<String, dynamic>> parkingData = [
    {
      'id': '1',
      'name': 'Parking A',
      'address': '123 Main St, City A',
      'image': 'https://via.placeholder.com/150',
      'bikeParking': true,
      'price': '\$5/hr',
      'latLng': LatLng(44.9778, -93.2650),
    },
    {
      'id': '2',
      'name': 'Parking B',
      'address': '456 Main St, City B',
      'image': 'https://via.placeholder.com/150',
      'bikeParking': false,
      'price': '\$10/3hrs',
      'latLng': LatLng(44.9637, -93.2678),
    },
  ];

  @override
  void initState() {
    super.initState();
    _fetchCurrentLocation();
    _initializeMarkers();
  }

  // Fetch current location
  Future<void> _fetchCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        _currentAddress = "Location services are disabled.";
      });
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          _currentAddress = "Location permissions are denied.";
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        _currentAddress =
        "Location permissions are permanently denied. Enable them in settings.";
      });
      return;
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    setState(() {
      _currentLocation = LatLng(position.latitude, position.longitude);
    });

    List<Placemark> placemarks =
    await placemarkFromCoordinates(position.latitude, position.longitude);
    if (placemarks.isNotEmpty) {
      setState(() {
        _currentAddress =
        "${placemarks[0].name}, ${placemarks[0].locality}, ${placemarks[0].country}";
      });
    }

    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(_currentLocation!, 15),
    );
  }

  // Initialize markers for parking locations
  void _initializeMarkers() {
    for (int i = 0; i < parkingData.length; i++) {
      final parking = parkingData[i];
      final markerId = MarkerId(parking['id']);
      final marker = Marker(
        markerId: markerId,
        position: parking['latLng'],
        infoWindow: InfoWindow(title: parking['name']),
        onTap: () {
          setState(() {
            _currentParkingIndex = i;
          });
        },
      );
      _markers[markerId] = marker;
    }
  }

  // Add current location marker
  void _addCurrentLocationMarker() {
    if (_currentLocation != null) {
      final markerId = MarkerId('currentLocation');
      final marker = Marker(
        markerId: markerId,
        position: _currentLocation!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: InfoWindow(title: "Your Location"),
      );
      _markers[markerId] = marker;
    }
  }

  void _toggleBottomSheet() {
    setState(() {
      // Toggle between initial size and expanded size
      _bottomSheetSize = _bottomSheetSize == 0.3 ? 0.6 : 0.3;
    });
  }

  @override
  Widget build(BuildContext context) {
    _addCurrentLocationMarker();

    return Scaffold(
      body: Stack(
        children: [
          // Google Map
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentLocation ?? LatLng(44.9778, -93.2650),
              zoom: 12,
            ),
            onMapCreated: (controller) {
              _mapController = controller;
            },
            markers: _markers.values.toSet(),
          ),

          // Search Bar
          Positioned(
            top: 50,
            left: 10,
            right: 10,
            child: TextField(
              controller: TextEditingController(text: _currentAddress),
              readOnly: true,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                prefixIcon: Icon(Icons.search),
                hintText: 'Fetching location...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // Bottom Sheet
          // Bottom Sheet
          DraggableScrollableSheet(
            initialChildSize: 0.3,
            minChildSize: 0.3,
            maxChildSize: 0.6,
            builder: (context, scrollController) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: Column(
                  children: [
                    // Expand/Collapse Arrow
                    GestureDetector(
                      onTap: _toggleBottomSheet,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Icon(
                          _bottomSheetSize == 0.3
                              ? Icons.keyboard_arrow_up
                              : Icons.keyboard_arrow_down,
                          size: 30,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    // Parking List (Horizontal Scroll)
                    if (_bottomSheetSize == 0.3)
                      Expanded(
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.all(10.0),
                          itemCount: parkingData.length,
                          itemBuilder: (context, index) {
                            final parking = parkingData[index];

                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _currentParkingIndex = index;
                                });
                                _mapController?.animateCamera(
                                  CameraUpdate.newLatLngZoom(
                                    parking['latLng'],
                                    15,
                                  ),
                                );
                              },
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.85,
                                margin: EdgeInsets.only(right: 10),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black12,
                                      blurRadius: 4,
                                      offset: Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Parking Image with "Filling Fast" Tag
                                    Stack(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.vertical(
                                              top: Radius.circular(10)),
                                          child: Image.network(
                                            parking['image'],
                                            height: 150,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                        Positioned(
                                          top: 5,
                                          left: 5,
                                          child: Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: Colors.orange,
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                            child: Text(
                                              "Filling Fast",
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 10),

                                    // Parking Details
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            parking['name'],
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: Colors.black87,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          SizedBox(height: 5),
                                          Text(
                                            parking['address'],
                                            style: TextStyle(
                                              color: Colors.black54,
                                              fontSize: 12,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          SizedBox(height: 5),
                                          Row(
                                            children: [
                                              Icon(Icons.pedal_bike,
                                                  size: 16, color: Colors.orange),
                                              SizedBox(width: 5),
                                              Text(
                                                parking['bikeParking']
                                                    ? "Bike Parking"
                                                    : "No Bike Parking",
                                                style: TextStyle(
                                                  color: Colors.black54,
                                                  fontSize: 12,
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
                          },
                        ),
                      ),

                    // Accessories and Parking Images (Visible on Expand)
                    if (_bottomSheetSize > 0.3)
                      Expanded(
                        child: SingleChildScrollView(
                          controller: scrollController,
                          padding: EdgeInsets.all(10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Accessories Section
                              Text(
                                "Parking Accessories",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 10),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  Column(
                                    children: [
                                      Icon(Icons.security, color: Colors.white),
                                      SizedBox(height: 5),
                                      Text(
                                        "CCTV",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      Icon(Icons.ev_station, color: Colors.white),
                                      SizedBox(height: 5),
                                      Text(
                                        "Charging",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    children: [
                                      Icon(Icons.garage, color: Colors.white),
                                      SizedBox(height: 5),
                                      Text(
                                        "Garage",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(height: 20),

                              // Parking Images
                              Text(
                                "Parking Images",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        "https://via.placeholder.com/100",
                                        height: 80,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 10),
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        "https://via.placeholder.com/100",
                                        height: 80,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),

        ],
      ),
    );
  }
}
