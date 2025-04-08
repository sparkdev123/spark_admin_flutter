import 'package:flutter/material.dart';
import 'package:google_places_flutter/google_places_flutter.dart';

class LocationAutocompleteScreen extends StatefulWidget {
  @override
  _LocationAutocompleteScreenState createState() => _LocationAutocompleteScreenState();
}

class _LocationAutocompleteScreenState extends State<LocationAutocompleteScreen> {
  TextEditingController locationController = TextEditingController();
  // final String googleApiKey = "AIzaSyAbG3uK5suqFpGaD0w9I59gLdiMJBueU3I"; // Replace with your API key

final String googleApiKey = "AIzaSyCH5N1QmAM-J25YhyML6ZRpOSGxixdLG-0";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Location Auto-population")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            GooglePlaceAutoCompleteTextField(
              textEditingController: locationController,
              googleAPIKey: googleApiKey,
              inputDecoration: InputDecoration(
                hintText: "Enter Location",
                border: OutlineInputBorder(),
              ),
              debounceTime: 400, // Delay in ms before fetching results
              countries: ["IN", "US"], // Limit to specific countries (optional)
              isLatLngRequired: true, // Fetch latitude & longitude
              getPlaceDetailWithLatLng: (prediction) {
                print("Selected Place: ${prediction.description}");
                print("Latitude: ${prediction.lat}");
                print("Longitude: ${prediction.lng}");
              },
              itemClick: (prediction) {
                locationController.text = prediction.description!;
                locationController.selection = TextSelection.fromPosition(
                  TextPosition(offset: prediction.description!.length),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}


