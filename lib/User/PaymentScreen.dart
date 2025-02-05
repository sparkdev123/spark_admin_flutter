import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_2/User/UserMainScreen.dart';
import 'package:flutter_paypal_payment/flutter_paypal_payment.dart';
import 'package:intl/intl.dart';

class PaymentScreen extends StatefulWidget {
  final String parkingId; // New parameter
  late String phoneNumber;
  late String bikeSlotPerHour;
  late String carSlotPerHour;

   PaymentScreen({super.key,
    required this.parkingId,
    required this.phoneNumber,
     required this.bikeSlotPerHour,
     required this.carSlotPerHour
  });
  @override
  _PaymentScreenState createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String selectedVehicleType = 'Car';
  TextEditingController vehicleNumberController = TextEditingController();
  TextEditingController vehicleModelController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  TextEditingController hoursController = TextEditingController();
  late String parkingId; // New parameter
  late String phoneNumber;
  late String bikeSlotPerHour;
  late String carSlotPerHour;
  late String notetext="";
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    parkingId = widget.parkingId;
    phoneNumber=widget.phoneNumber;
    bikeSlotPerHour=widget.bikeSlotPerHour;
    carSlotPerHour=widget.carSlotPerHour;
    notetext=carSlotPerHour;

  }
  @override
  void dispose() {
    // Dispose controllers to free up memory
    vehicleNumberController.dispose();
    vehicleModelController.dispose();
    dateController.dispose();
    hoursController.dispose();
    super.dispose();
  }

  void _selectDate() async {
    // Pick Date
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      // Pick Time after date selection
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        // Combine Date and Time
        DateTime finalDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        // Format Date and Time
        String formattedDateTime = DateFormat("dd-MM-yyyy, hh:mm a").format(finalDateTime);

        // Update UI
        dateController.text = formattedDateTime;
      }
    }
  }

  Future<void> _onPayment(BuildContext context,String parkingId, String phoneNumber, String vehicleNumber, String vehicleType, String vehicleModel, String pickdateTime, String duration) async{
    paymentPayPal(context,parkingId,phoneNumber,vehicleNumber,vehicleType,vehicleModel,pickdateTime,duration);

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Book Spot'),
        backgroundColor: Colors.green,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Book Spot Details',
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: vehicleNumberController,
              decoration: InputDecoration(
                labelText: 'Vehicle Number',
                hintText: 'Enter vehicle number',
                suffixText: '123',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              'Vehicle Type',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    title: Text('Car'),
                    leading: Radio(
                      value: 'Car',
                      groupValue: selectedVehicleType,
                      onChanged: (value) {
                        setState(() {
                          selectedVehicleType = value!;
                          if(selectedVehicleType=="Car"){
                           notetext=carSlotPerHour;
                          }else{
                            notetext=bikeSlotPerHour;
                          }
                        });
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: ListTile(
                    title: Text('Bike'),
                    leading: Radio(
                      value: 'Bike',
                      groupValue: selectedVehicleType,
                      onChanged: (value) {
                        setState(() {
                          selectedVehicleType = value!;
                          if(selectedVehicleType=="Car"){
                            notetext=carSlotPerHour;
                          }else{
                            notetext=bikeSlotPerHour;
                          }
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: vehicleModelController,
              decoration: InputDecoration(
                labelText: 'Vehicle Model Name',
                hintText: 'Enter vehicle model',
                prefixIcon: Icon(Icons.directions_car),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: dateController,
              decoration: InputDecoration(
                labelText: 'Select Date and Time',
                hintText: 'Pick a date and time',
                prefixIcon: Icon(Icons.calendar_today),
                border: OutlineInputBorder(),
              ),
              readOnly: true,
              onTap: _selectDate,
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: hoursController,
              decoration: InputDecoration(
                labelText: 'Select Hours',
                hintText: 'Enter duration in hours',
                prefixIcon: Icon(Icons.access_time),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 8.0),
            Text(
              'Note: $notetext /-Per Hour',
              style: TextStyle(color: Colors.green),
            ),
            SizedBox(height: 24.0),
            Text(
              'Contact Details',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.0),
            Row(
              children: [
                Icon(Icons.phone, color: Colors.orange),
                SizedBox(width: 8.0),
                Text(phoneNumber),
              ],
            ),
            SizedBox(height: 8.0),
            Row(
              children: [
                Icon(Icons.email, color: Colors.orange),
                SizedBox(width: 8.0),
                Text('Jhon@parking.com'),
              ],
            ),
            SizedBox(height: 8.0),
            Row(
              children: [
                Icon(Icons.location_on, color: Colors.orange),
                SizedBox(width: 8.0),
                Flexible(
                  child: Text(
                    'Broadway, Bloomington\nMN 55425, USA',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.0),
            Center(
              child: ElevatedButton(
                onPressed:() {
                  var vehicleNumber=vehicleNumberController.text;
                  var vehicleType=selectedVehicleType;
                  var vehicleModel=vehicleModelController.text;
                  var pickdateTime=dateController.text;
                  var duration=hoursController.text;
                  var totalPayment=0.0;
                  if(selectedVehicleType=="Car"){
                    totalPayment = (double.tryParse(duration) ?? 0.0) * (double.tryParse(carSlotPerHour) ?? 0.0);

                  }else{
                    totalPayment = (double.tryParse(duration) ?? 0.0) * (double.tryParse(bikeSlotPerHour) ?? 0.0);

                  }
                  print("TotalPayment="+totalPayment.toString());
                  print("veicleNumber="+vehicleNumber+",vehicleType="+vehicleType+",vehicleModel="+vehicleModel+",pickdateTime="+pickdateTime+",duration="+duration);

                  // Handle payment action here
                  if (vehicleNumberController.text.isEmpty ||
                      vehicleModelController.text.isEmpty ||
                      dateController.text.isEmpty ||
                      hoursController.text.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please fill all fields')),
                    );
                  }
                  else {
                    // Proceed with payment logic
                    _onPayment(context,parkingId,phoneNumber,vehicleNumber,vehicleType,vehicleModel,pickdateTime,duration);

                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                ),
                child: Text(
                  'Payment Now',
                  style: TextStyle(fontSize: 18.0),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  paymentPayPal(BuildContext context, String parkingId, String phoneNumber, String vehicleNumber, String vehicleType, String vehicleModel, String pickdateTime, String duration) async{
    _showLoadingDialog(context);

    var isPaymentDone=true;
    if(isPaymentDone){
      UpdateFirebaseParkingwithBookingData(context,parkingId,phoneNumber,vehicleNumber,vehicleType,vehicleModel,pickdateTime,duration);
    }
    // Navigator.of(context).push(MaterialPageRoute(
    //   builder: (BuildContext context) => PaypalCheckoutView(
    //     sandboxMode: true,
    //     clientId: "AeZTelxE4Dstsf2HfqlLYFFrn_y6ejGbK8KDCEb7tw-Nj7CU50SYCQhvLRd0oak4squLqzXnCiH72k8C",
    //     secretKey: "",
    //     transactions: const [
    //       {
    //         "amount": {
    //           "total": '70',
    //           "currency": "USD",
    //           "details": {
    //             "subtotal": '70',
    //             "shipping": '0',
    //             "shipping_discount": 0
    //           }
    //         },
    //         "description": "The payment transaction description.",
    //         // "payment_options": {
    //         //   "allowed_payment_method":
    //         //       "INSTANT_FUNDING_SOURCE"
    //         // },
    //         "item_list": {
    //           "items": [
    //             {
    //               "name": "Apple",
    //               "quantity": 4,
    //               "price": '5',
    //               "currency": "USD"
    //             },
    //             {
    //               "name": "Pineapple",
    //               "quantity": 5,
    //               "price": '10',
    //               "currency": "USD"
    //             }
    //           ],
    //
    //           // shipping address is not required though
    //           //   "shipping_address": {
    //           //     "recipient_name": "tharwat",
    //           //     "line1": "Alexandria",
    //           //     "line2": "",
    //           //     "city": "Alexandria",
    //           //     "country_code": "EG",
    //           //     "postal_code": "21505",
    //           //     "phone": "+00000000",
    //           //     "state": "Alexandria"
    //           //  },
    //         }
    //       }
    //     ],
    //     note: "Contact us for any questions on your order.",
    //     onSuccess: (Map params) async {
    //       print("onSuccess: $params");
    //     },
    //     onError: (error) {
    //       print("onError: $error");
    //       Navigator.pop(context);
    //     },
    //     onCancel: () {
    //       print('cancelled:');
    //     },
    //   ),
    // ));
  }
  Future<void> UpdateFirebaseParkingwithBookingData(BuildContext buildcontext, String parkingId, String phoneNumber, String vehicleNumber, String vehicleType, String vehicleModel, String pickdateTime, String duration) async {

    print('parkingId URLs: $parkingId');
    // Firestore document reference
    DocumentReference documentReference = FirebaseFirestore.instance
        .collection('ParkingList')
        .doc(parkingId);
// Get server timestamp separately
    Timestamp serverTimestamp = Timestamp.now();

    Map<String, dynamic> newBooking = {
      'userId': phoneNumber,
      'vehicle_number':vehicleNumber,
      'vehicle_type':vehicleType,
      'vehicle_model_name':vehicleModel,
      'pickedDateTime':pickdateTime,
      'duration': duration,
      'bookedAt': serverTimestamp,
      'status': 'Active'
    };
    // Data to update
    Map<String, dynamic> updatedData = {
      // 'documents': FieldValue.arrayUnion([
      //   'https://newdocumenturl.com'  // New URL to add to the documents array
      // ]),
      // Add other fields to update as needed
      'bookingHistory': FieldValue.arrayUnion([newBooking]),

    };


    try {
      await documentReference.update(updatedData);
      print("Firebase Data updated successfully");
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
      MaterialPageRoute(builder: (context) =>  UserMainScreen(phoneNumber: phoneNumber)),
    );
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
                Text('Booking in Progress Please wait...'), // Optional loading text
              ],
            ),
          ),
        );
      },
    );
  }

}
