import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_place/google_place.dart';
import 'package:http/http.dart' as http;

class MapScreen extends StatefulWidget {
  final Function(String,double,double) onUpdate; // Callback function to update the main screen
   final double locationlatitude;
  final double locationlongitude;

  const MapScreen({super.key, required this.onUpdate,required this.locationlatitude,required this.locationlongitude});
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController _mapController;
  LatLng? _currentLocation;
  LatLng? _searchedLocation;
  final Set<Marker> _markers = {};
  BitmapDescriptor? _currentLocationIcon;
  late double addressLocationLattitude;
  late double addressLocationLongitude;
  final TextEditingController _searchController = TextEditingController();
  late GooglePlace _googlePlace;
  // Method to update the data on MainScreen
  void _updateData() {
    widget.onUpdate(_searchController.text,addressLocationLattitude,addressLocationLongitude); // Call the callback with the updated data
  }
  @override
  void initState() {
    super.initState();
    _setCustomMarkers();
    // AIzaSyCH5N1QmAM-J25YhyML6ZRpOSGxixdLG-0
    // _googlePlace = GooglePlace("AIzaSyBOIz0Xy_BkuDmhs1wPiqFQE2xEswVfNho"); // Initialize Google Place (replace with your Google API key)
     _googlePlace = GooglePlace("AIzaSyBOIz0Xy_BkuDmhs1wPiqFQE2xEswVfNho");
    var latitude=widget.locationlatitude;
    var longitude=widget.locationlongitude;
    _getLocation(latitude,longitude);
  }

  // Set custom markers (e.g., for current location)
  Future<void> _setCustomMarkers() async {
    _currentLocationIcon = BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed);
  }

  // Fetch the current location of the user
  Future<void> _getLocation(double latitude, double longitude) async {
    try {
      bool isLocationServiceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!isLocationServiceEnabled) {
        print('Location services are disabled.');
        return;
      }

      LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        print('Location permission denied.');
        return;
      }



      setState(() {
        _currentLocation = LatLng(latitude,longitude);
        _markers.add(
          Marker(
            markerId: const MarkerId('current_location'),
            position: _currentLocation!,
            icon: _currentLocationIcon!,
            draggable: true,  // Allow marker to be draggable
            onDragEnd: (newPosition) {
              _updateAddressFromCoordinates(newPosition);  // Reverse geocode when marker is dragged
            },
          ),
        );
      });

      // Immediately update address from current location
      await _updateAddressFromCoordinates(_currentLocation!);

      // Move the map camera to current location
      _mapController.animateCamera(
        CameraUpdate.newLatLngZoom(_currentLocation!, 14.0),
      );
    } catch (e) {
      print('Error fetching current location: $e');
    }
  }

  // Function to reverse geocode a location (LatLng to Address)
  Future<void> _updateAddressFromCoordinates(LatLng location) async {
    addressLocationLattitude=location.latitude;
    addressLocationLongitude=location.longitude;
    try {
      final response = await http.get(
        Uri.parse('https://maps.googleapis.com/maps/api/geocode/json?latlng=${location.latitude},${location.longitude}&key=AIzaSyBOIz0Xy_BkuDmhs1wPiqFQE2xEswVfNho'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['results'].isNotEmpty) {
          final address = data['results'][0]['formatted_address'];

          setState(() {
            _searchController.text = address;  // Update the search bar with the new address
          });
          // Return the selected address when the map screen is closed
        //  Navigator.pop(context, address);
          _updateData();
        } else {
          print('No address found for this location.');
        }
      } else {
        throw Exception('Failed to load address');
      }
    } catch (e) {
      print('Error fetching address: $e');
    }
  }

  // Function to handle location search
  Future<void> _searchLocation(String query) async {
    try {
      final response = await http.get(
        Uri.parse('https://maps.googleapis.com/maps/api/geocode/json?address=$query&key=AIzaSyBOIz0Xy_BkuDmhs1wPiqFQE2xEswVfNho'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['results'].isNotEmpty) {
          final location = data['results'][0]['geometry']['location'];
          final LatLng searchedLocation = LatLng(location['lat'], location['lng']);

          setState(() {
            _searchedLocation = searchedLocation;
            _markers.add(
              Marker(
                markerId: const MarkerId('searched_location'),
                position: _searchedLocation!,
                draggable: true,  // Make the marker draggable
                onDragEnd: (newPosition) {
                  _updateAddressFromCoordinates(newPosition);  // Update address on marker drag
                },
              ),
            );
          });

          // Reverse geocode the searched location
          _updateAddressFromCoordinates(_searchedLocation!);

          // Move camera to the searched location
          _mapController.animateCamera(
            CameraUpdate.newLatLngZoom(_searchedLocation!, 14.0),
          );
        } else {
          print('No results found for the searched query.');
        }
      } else {
        throw Exception('Failed to load geocode data');
      }
    } catch (e) {
      print('Error searching location: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Map with Location Search'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search for a location',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    _searchLocation(_searchController.text);  // Search when the user presses search
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: GoogleMap(
              onMapCreated: (controller) {
                _mapController = controller;
              },
              initialCameraPosition: CameraPosition(
                target: _currentLocation ?? const LatLng(0, 0), // Default to (0, 0) if location is not available
                zoom: 14.0,
              ),
              markers: _markers,
              myLocationButtonEnabled: true,
              myLocationEnabled: true,
            ),
          ),
        ],
      ),
    );
  }
  @override
  void dispose() {
    // Perform any cleanup here
    super.dispose();
  }
}
