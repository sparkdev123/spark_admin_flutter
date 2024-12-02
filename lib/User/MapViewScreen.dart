// MapView Screen with marker for current location and search
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_place/google_place.dart';
import 'package:geocoding/geocoding.dart';  // For reverse geocoding

class MapViewScreen extends StatefulWidget {
  const MapViewScreen({super.key});

  @override
  _MapViewScreenState createState() => _MapViewScreenState();
}

class _MapViewScreenState extends State<MapViewScreen> {
  late GoogleMapController _mapController;
  late LatLng _currentPosition;
  final Set<Marker> _markers = {};
  final TextEditingController _searchController = TextEditingController();
  late GooglePlace _googlePlace;

  @override
  void initState() {
    super.initState();
    _googlePlace = GooglePlace("AIzaSyAbG3uK5suqFpGaD0w9I59gLdiMJBueU3I");
    _checkLocationPermission();
  }

  // Get current location and display on map
  Future<void> _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    _currentPosition = LatLng(position.latitude, position.longitude);

    setState(() {
      _markers.add(
        Marker(
          markerId: const MarkerId("current_location"),
          position: _currentPosition,
          draggable: true,
          onDragEnd: (newPosition) {
            _updateAddressFromCoordinates(newPosition);
          },
          infoWindow: const InfoWindow(title: "Current Location"),
        ),
      );
    });
  }
  Future<void> _checkLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled, request the user to enable them.
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, handle appropriately.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can get the position.
    await _getCurrentLocation();
  }

  // Update address in search bar and return to previous screen
  Future<void> _updateAddressFromCoordinates(LatLng position) async {
    List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark place = placemarks[0];
    String address = "${place.street}, ${place.locality}, ${place.country}";

    setState(() {
      _searchController.text = address;
    });

    // Return the selected address when the map screen is closed
    Navigator.pop(context, address);
  }

  // Search location and move the marker
  Future<void> _searchLocation(String query) async {
    var result = await _googlePlace.autocomplete.get(query);
    if (result != null && result.predictions!!="") {
      var prediction = result.predictions!.first;
      var details = await _googlePlace.details.get(prediction.placeId!);
      if (details != null && details.result != null) {
        LatLng newLocation = LatLng(
          details.result!.geometry!.location!.lat!,
          details.result!.geometry!.location!.lng!,
        );

        setState(() {
          _markers.clear();
          _markers.add(
            Marker(
              markerId: const MarkerId("searched_location"),
              position: newLocation,
              draggable: true,
              onDragEnd: (newPosition) {
                _updateAddressFromCoordinates(newPosition);
              },
            ),
          );
          _mapController.animateCamera(CameraUpdate.newLatLng(newLocation));
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: const InputDecoration(hintText: 'Search Location'),
          onSubmitted: _searchLocation,
        ),
      ),
      body: GoogleMap(
        initialCameraPosition: const CameraPosition(target: LatLng(0, 0), zoom: 14),
        markers: _markers,
        onMapCreated: (controller) => _mapController = controller,
      ),
    );
  }
}