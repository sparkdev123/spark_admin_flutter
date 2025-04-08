// import 'package:flutter/material.dart';

// class AccountScreen extends StatefulWidget {
//   @override
//   _AccountScreenState createState() => _AccountScreenState();
// }

// class _AccountScreenState extends State<AccountScreen> {
//   TextEditingController locationController = TextEditingController();
//   // final String googleApiKey = "AIzaSyAbG3uK5suqFpGaD0w9I59gLdiMJBueU3I"; // Replace with your API key

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Account Screen'),backgroundColor: Colors.green, elevation: 0),
//       body: Padding(
//         padding: EdgeInsets.all(16.0),
//         child: Column(
// children: [Text('Helloooooooo')],
//         )));
//         }
//         }





import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_application_2/Admin/accountHolderDetails_model.dart';
import 'package:flutter_application_2/Admin/account_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'Global/GlobalCardWidget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'UserModel.dart';
import 'package:uuid/uuid.dart';


// late SharedPreferences _prefs;

// void initState() {
//   SharedPreferences.getInstance().then(_prefs)
  
// }

// void getPhoneNumber(){
//     final prefs = await SharedPreferences.getInstance();
//   final String? phoneNumberId = prefs.getString('phoneNumber');
//   retunr phoneNumberId
// }

// class FirestoreService {
//   final CollectionReference accountCollection =
//       FirebaseFirestore.instance.collection('Accounts');

//   /// **📌 Create Account (Add to Firestore)**
//   Future<void> createAccount(Account account) async {
//     await accountCollection.doc(account.id).set(account.toJson());
//   }

//   /// **📌 Read Account (Fetch by ID)**
//   Future<Account?> getAccountById(String id) async {
//     var doc = await accountCollection.doc(id).get();
//     if (doc.exists) {
//       return Account.fromJson(doc.data() as Map<String, dynamic>);
//     }
//     return null;
//   }

//   /// **📌 Update Account (Edit Details)**
//   Future<void> updateAccount(String id, Map<String, dynamic> updatedData) async {
//     await accountCollection.doc(id).update(updatedData);
//   }

//   /// **📌 Delete Account (Remove from Firestore)**
//   Future<void> deleteAccount(String id) async {
//     await accountCollection.doc(id).delete();
//   }

//   /// **📌 Get All Accounts (Stream for Live Data)**
//   Stream<List<Account>> getAllAccounts() {
//     return accountCollection.snapshots().map((snapshot) {
//       return snapshot.docs.map((doc) {
//         return Account.fromJson(doc.data() as Map<String, dynamic>);
//       }).toList();
//     });
//   }
// }

// class AccountScreen extends StatefulWidget {
//   late String phoneNumber;
//  AccountScreen({super.key, required this.phoneNumber}); 
//   @override
//   _AccountScreenState createState() => _AccountScreenState();
// }

// class _AccountScreenState extends State<AccountScreen> {
//   final FirestoreService firestoreService = FirestoreService();
//   final TextEditingController nameController = TextEditingController();
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController balanceController = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Account Management")),
//       body: StreamBuilder<List<Account>>(
//         stream: firestoreService.getAllAccounts(),
//         builder: (context, snapshot) {
//           if (!snapshot.hasData) {
//             return Center(child: CircularProgressIndicator());
//           }

//           List<Account> accounts = snapshot.data!;

//           return ListView.builder(
//             itemCount: accounts.length,
//             itemBuilder: (context, index) {
//               Account account = accounts[index];
//               return ListTile(
//                 title: Text(account.name),
//                 subtitle: Text("Email: ${account.email} | Balance: ₹${account.balance}"),
//                 trailing: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     IconButton(
//                       icon: Icon(Icons.edit, color: Colors.blue),
//                       onPressed: () => showEditDialog(account),
//                     ),
//                     IconButton(
//                       icon: Icon(Icons.delete, color: Colors.red),
//                       onPressed: () => firestoreService.deleteAccount(account.id),
//                     ),
//                   ],
//                 ),
//               );
//             },
//           );
//         },
//       ),
//       floatingActionButton: FloatingActionButton(
//         child: Icon(Icons.add),
//         onPressed: () => showCreateDialog(),
//       ),
//     );
//   }

//   /// **📌 Show Dialog to Add a New Account**
//   void showCreateDialog() {
//     nameController.clear();
//     emailController.clear();
//     balanceController.clear();

//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text("Add Account"),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             TextField(controller: nameController, decoration: InputDecoration(labelText: "Name")),
//             TextField(controller: emailController, decoration: InputDecoration(labelText: "Email")),
//             TextField(controller: balanceController, decoration: InputDecoration(labelText: "Balance"), keyboardType: TextInputType.number),
            
//           ],
//         ),
//         actions: [
//           TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
//           ElevatedButton(
//             child: Text("Save"),
//             onPressed: () {
//               var newAccount = Account(
//                 id: DateTime.now().millisecondsSinceEpoch.toString(),
//                 name: nameController.text,
//                 email: emailController.text,
//                 balance: double.parse(balanceController.text),
//               );

//               firestoreService.createAccount(newAccount);
//               Navigator.pop(context);
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   /// **📌 Show Dialog to Edit an Account**
//   void showEditDialog(Account account) {
//     nameController.text = account.name;
//     emailController.text = account.email;
//     balanceController.text = account.balance.toString();

//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text("Edit Account"),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             TextField(controller: nameController, decoration: InputDecoration(labelText: "Name")),
//             TextField(controller: emailController, decoration: InputDecoration(labelText: "Email")),
//             TextField(controller: balanceController, decoration: InputDecoration(labelText: "Balance"), keyboardType: TextInputType.number),
//           ],
//         ),
//         actions: [
//           TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
//           ElevatedButton(
//             child: Text("Update"),
//             onPressed: () {
//               firestoreService.updateAccount(account.id, {
//                 'name': nameController.text,
//                 'email': emailController.text,
//                 'balance': double.parse(balanceController.text),
//               });

//               Navigator.pop(context);
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }



// class FirestoreService {
//   final CollectionReference accountCollection =
//       FirebaseFirestore.instance.collection('Accounts');

//   /// **📌 Create Account (Add to Firestore)**
//   Future<void> createAccount(Account account) async {
//     await accountCollection.doc(account.id).set(account.toJson());
//   }

//   /// **📌 Read Account (Fetch by ID)**
//   Future<Account?> getAccountById(String id) async {
//     var doc = await accountCollection.doc(id).get();
//     if (doc.exists) {
//       return Account.fromJson(doc.data() as Map<String, dynamic>);
//     }
//     return null;
//   }

//   /// **📌 Update Account (Edit Details)**
//   Future<void> updateAccount(String id, Map<String, dynamic> updatedData) async {
//     await accountCollection.doc(id).update(updatedData);
//   }

//   /// **📌 Delete Account (Remove from Firestore)**
//   Future<void> deleteAccount(String id) async {
//     await accountCollection.doc(id).delete();
//   }

//   /// **📌 Get All Accounts (Stream for Live Data)**
//   Stream<List<Account>> getAllAccounts() {
//     return accountCollection.snapshots().map((snapshot) {
//       return snapshot.docs.map((doc) {
//         return Account.fromJson(doc.data() as Map<String, dynamic>);
//       }).toList();
//     });
//   }
// }

// class AccountScreen extends StatefulWidget {
//   @override
//   _AccountScreenState createState() => _AccountScreenState();
// }

// class _AccountScreenState extends State<AccountScreen> {
//   final FirestoreService firestoreService = FirestoreService();
//   final TextEditingController nameController = TextEditingController();
//   final TextEditingController emailController = TextEditingController();
//   final TextEditingController balanceController = TextEditingController();

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Account Management")),
//       body: StreamBuilder<List<Account>>(
//         stream: firestoreService.getAllAccounts(),
//         builder: (context, snapshot) {
//           if (!snapshot.hasData) {
//             return Center(child: CircularProgressIndicator());
//           }

//           List<Account> accounts = snapshot.data!;

//           return ListView.builder(
//             itemCount: accounts.length,
//             itemBuilder: (context, index) {
//               Account account = accounts[index];
//               return ListTile(
//                 title: Text(account.name),
//                 subtitle: Text("Email: ${account.email} | Balance: ₹${account.balance}"),
//                 trailing: Row(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     IconButton(
//                       icon: Icon(Icons.edit, color: Colors.blue),
//                       onPressed: () => showEditDialog(account),
//                     ),
//                     IconButton(
//                       icon: Icon(Icons.delete, color: Colors.red),
//                       onPressed: () => firestoreService.deleteAccount(account.id),
//                     ),
//                   ],
//                 ),
//               );
//             },
//           );
//         },
//       ),
//       floatingActionButton: FloatingActionButton(
//         child: Icon(Icons.add),
//         onPressed: () => showCreateDialog(),
//       ),
//     );
//   }

//   /// **📌 Show Dialog to Add a New Account**
//   void showCreateDialog() {
//     nameController.clear();
//     emailController.clear();
//     balanceController.clear();

//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text("Add Account"),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             TextField(controller: nameController, decoration: InputDecoration(labelText: "Name")),
//             TextField(controller: emailController, decoration: InputDecoration(labelText: "Email")),
//             TextField(controller: balanceController, decoration: InputDecoration(labelText: "Balance"), keyboardType: TextInputType.number),
            
//           ],
//         ),
//         actions: [
//           TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
//           ElevatedButton(
//             child: Text("Save"),
//             onPressed: () {
//               var newAccount = Account(
//                 id: DateTime.now().millisecondsSinceEpoch.toString(),
//                 name: nameController.text,
//                 email: emailController.text,
//                 balance: double.parse(balanceController.text),
//               );

//               firestoreService.createAccount(newAccount);
//               Navigator.pop(context);
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   /// **📌 Show Dialog to Edit an Account**
//   void showEditDialog(Account account) {
//     nameController.text = account.name;
//     emailController.text = account.email;
//     balanceController.text = account.balance.toString();

//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: Text("Edit Account"),
//         content: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             TextField(controller: nameController, decoration: InputDecoration(labelText: "Name")),
//             TextField(controller: emailController, decoration: InputDecoration(labelText: "Email")),
//             TextField(controller: balanceController, decoration: InputDecoration(labelText: "Balance"), keyboardType: TextInputType.number),
//           ],
//         ),
//         actions: [
//           TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
//           ElevatedButton(
//             child: Text("Update"),
//             onPressed: () {
//               firestoreService.updateAccount(account.id, {
//                 'name': nameController.text,
//                 'email': emailController.text,
//                 'balance': double.parse(balanceController.text),
//               });

//               Navigator.pop(context);
//             },
//           ),
//         ],
//       ),
//     );
//   }
// }








/// ******* My code ******
// String phoneNumber = '';
// String accountNumber = '';
// bool isEditClicked = false;

// class AccountScreen extends StatefulWidget {
//   @override
//   AccountScreenState createState() => AccountScreenState();
// }

// class AccountScreenState extends State<AccountScreen> {
  
//   //  late String phoneNumber;
//   // AccountScreenState({super.key, required this.phoneNumber});
 

//   @override

//   void initState() {
//     super.initState();
//     _loadValue();
//     print('Numbererr:$phoneNumber');
//   }

//    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

// Future<bool> fetchData() async {
//   try {
//          QuerySnapshot<Map<String, dynamic>> querySnapshot = 
//           await _firestore.collection('Admins')
//         .doc(phoneNumber)
//         .collection('CreateAccount').get();
//         var data2 = querySnapshot.docs.first;
        
//       print(data2['accountNumber']);
//       String acNumber = data2['accountNumber'];
//       accountNumber = acNumber.substring(acNumber.length - 4);
//       return querySnapshot.docs.isNotEmpty; // Returns true if data exi
//   } catch (e) {
//     return false;
//   }
// }

//  // Function to load value from SharedPreferences
//   Future<void> _loadValue() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     setState(() {
//       phoneNumber = prefs.getString('phoneNumber') ?? '';
//     });
//   }


//   Widget build(BuildContext context){
//     print('refniernfieronfoiref:$phoneNumber');
//     return FutureBuilder<bool> (future: fetchData(), builder: (context, snapshort) {
      
//       if (snapshort.connectionState == ConnectionState.waiting){
//         return CircularProgressIndicator();
//       } else if (snapshort.hasError || snapshort.data == false || isEditClicked == true) {
//         return  TestWidget(child: MyCustomForm()); 
//       } else {
//         return  TestWidget(child: PaymentWidget());
//       }
//     },);
// }
// }


// class TestWidget extends StatelessWidget {
// final Widget child;
// const TestWidget({super.key, required this.child});
//   @override
//    Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(title: Text('Account Screen'),backgroundColor: Colors.green), 
//         body: 
//         Center(child: Column(children: [
//           Container(
//   alignment: Alignment.topCenter,
//   height: 600,
//   width: MediaQuery.sizeOf(context).width - 30,
//   child:  Scrollbar(child: child)
// )
//         ],) 
//         ,) 
//   ); 
//  }
// }



// class PaymentWidget extends StatelessWidget {
  
//   @override
//   Widget build(BuildContext context) {
//     return Padding(padding: const EdgeInsets.all(16.0),
//     child: Column(
//       crossAxisAlignment:  CrossAxisAlignment.start,
//       children: [
//         Row(
//           children: [ 
//             Text('Payout', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
//             Spacer(),
//              IconButton(
//                       icon: Icon(Icons.edit, color: Colors.blue),
//                       onPressed: () {},
//                     ),
//                     IconButton(
//                       icon: Icon(Icons.delete, color: Colors.red),
//                       onPressed: () {},
//                     ),],),
       
//         Card(
//           elevation: 3,
//           child: ListTile(
//             leading: Icon(Icons.account_balance),
//             title: Text('Bank Account - XXXXXXXXXXXX$accountNumber'),
//             subtitle: Text('Earnings paid out weekly'),
//             trailing: Icon(Icons.arrow_forward_ios, size: 16),
//             onTap: () {},
//           ),
//         )
//       ],),
//     );
//   }
// }






// // Create a Form widget.
// class MyCustomForm extends StatefulWidget {
//   const MyCustomForm({super.key});

//   @override
//   MyCustomFormState createState() {
//     return MyCustomFormState();
//   }
// }

// // Create a corresponding State class.
// // This class holds data related to the form.
// class MyCustomFormState extends State<MyCustomForm> {

//   final _formKey = GlobalKey<FormState>();


//    final TextEditingController _controllerAccountHolderName = TextEditingController();
//    final TextEditingController _controllerRoutingNumber = TextEditingController();
//    final TextEditingController _controllerBankAccountNumber = TextEditingController();
//     final TextEditingController _controllerBankReEnterAccountNumber = TextEditingController();
//    final TextEditingController _controllerDateOfBirth = TextEditingController();
//    final TextEditingController _controllerAddress = TextEditingController();
//    final TextEditingController _controllerCity = TextEditingController();
//    final TextEditingController _controllerState = TextEditingController();
//    final TextEditingController _controllerPostalCode = TextEditingController();
//   @override
//   // SingleChildScrollView(
//   //       child: Padding(
//   //         padding: const EdgeInsets.all(16.0),
//   //         child:
//   Widget build(BuildContext context) {
//     // Build a Form widget using the _formKey created above.
//     return Form(
//       key: _formKey,
//       child: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//         SizedBox(height: 20),
//         Container(padding: EdgeInsets.fromLTRB(0, 0, 0, 20),child:  TextFormField(
//             validator: (value) {
//               if (value == null || value.isEmpty) {
//                 return 'Please enter some text';
//               }
//               return null;
//             },
//             controller: _controllerAccountHolderName,
//             decoration: const InputDecoration(
//               labelText: 'Account Holder name',
//               border: OutlineInputBorder(),
//             ),)
          
//           ),Container(padding: EdgeInsets.fromLTRB(0, 0, 0, 20),child:TextFormField(
//             validator: (value) {
//               if (value == null || value.isEmpty) {
//                 return 'Please enter some text';
//               }
//               return null;
//             },
//             keyboardType: TextInputType.number,
//             controller: _controllerRoutingNumber,
//             decoration: const InputDecoration(
//               labelText: 'Routing number *',
//               border: OutlineInputBorder(),
//             ),
//           ),),Container(padding: EdgeInsets.fromLTRB(0, 0, 0, 20),child: TextFormField(
//             keyboardType: TextInputType.number,
//             validator: (value) {
//               if (value == null || value.isEmpty) {
//                 return 'Please enter Routing number';
//               }
//               return null;
//             },
//             controller: _controllerBankAccountNumber,
//             decoration: const InputDecoration(
//               labelText: ' Account number',
//               border: OutlineInputBorder(),
//             ),
//           )),Container(padding: EdgeInsets.fromLTRB(0, 0, 0, 20),child: TextFormField(
//             validator: (value) {
//               if (value == null || value.isEmpty) {
//                 return 'Please enter Account number';
//               } 
//               print('account number: $_controllerBankAccountNumber');
//                if (value != _controllerBankAccountNumber.text) {
//                 return 'Account number is not same';
//               }
//               return null;
//             },
//              keyboardType: TextInputType.number,
//             controller: _controllerBankReEnterAccountNumber,
//             decoration: const InputDecoration(
//               labelText: ' Re enter Account number',
//               border: OutlineInputBorder(),
//             ),
//           )),  Container(child: Text('Date Of Birth :'),
//           ),
//           const MyDatePicker(),
//           SizedBox(height: 20),
//           Container(padding: EdgeInsets.fromLTRB(0, 0, 0, 20),child: 
//           TextFormField(
//             validator: (value) {
//               if (value == null || value.isEmpty) {
//                 return 'Please enter Address';
//               } 
//               return null;
//             },
            
//             controller: _controllerAddress,
//             decoration: const InputDecoration(
//               labelText: ' Address',
//               border: OutlineInputBorder(),
//             ),
//           )),
//           Container(padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
//           child: 
//           TextFormField(
//             validator: (value) {
//               if (value == null || value.isEmpty) {
//                 return 'Please enter City';
//               } 
//               return null;
//             },
            
//             controller: _controllerCity,
//             decoration: const InputDecoration(
//               labelText: ' City',
//               border: OutlineInputBorder(),
//             ),
//           )),Container(padding: EdgeInsets.fromLTRB(0, 0, 0, 20),child: 
//           TextFormField(
//             validator: (value) {
//               if (value == null || value.isEmpty) {
//                 return 'Please enter State';
//               } 
//               return null;
//             },
            
//             controller: _controllerState,
//             decoration: const InputDecoration(
//               labelText: ' State',
//               border: OutlineInputBorder(),
//             ),
//           )),Container(padding: EdgeInsets.fromLTRB(0, 0, 0, 20),
//           child: 
//           TextFormField(
//             validator: (value) {
//               if (value == null || value.isEmpty) {
//                 return 'Please enter State';
//               } 
//               return null;
//             },
            
//             controller: _controllerPostalCode,
//             decoration: const InputDecoration(
//               labelText: ' Postal Code',
//               border: OutlineInputBorder(),
//             ),
//           )),

//           const SizedBox(height: 30),
          
//           SizedBox(

//             child: Column(
             
//                mainAxisAlignment: MainAxisAlignment.center,
//               crossAxisAlignment: CrossAxisAlignment.center,
//               children: [
//                 SizedBox(
//                   width: MediaQuery.sizeOf(context).width - 70,
//                   height: 50,
//             child: ElevatedButton(
//               onPressed: () {
//                 // Validate returns true if the form is valid, or false otherwise.
//                 if (_formKey.currentState!.validate()) {
//                   // If the form is valid, display a snackbar. In the real world,
//                   // you'd often call a server or save the information in a database.
//                   // ScaffoldMessenger.of(context).showSnackBar(
//                   //   const SnackBar(content: Text('Processing Data')),
//                   // );
//                   addAccount(context, _controllerAccountHolderName.text, _controllerRoutingNumber.text, _controllerBankAccountNumber.text, _controllerAddress.text, _controllerState.text, _controllerCity.text, _controllerPostalCode.text);
//                 }
//               },
//                style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.black,
//                 foregroundColor: Colors.white,
//                 // padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
//                ),
              
//               child: const Text('Submit'),
              
//             )),
//             ],)
           
           
//           ),
//         ],
//       ),),)
//     );
//   }
// }




//  Future<void> addAccount(BuildContext buildcontext,String accountHolderName, String accountRoutingNumber, String accountNumber, String address, String state, String city, String postalCode) async {
//     // Add a new document with auto-generated ID
//  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  
// // Reference to the user's main document
//     DocumentReference userDoc = _firestore.collection('Admins').doc(phoneNumber);
//     await userDoc.collection('CreateAccount').add({
//       'accountHolderName': accountHolderName,
//       'accountRoutingNumber': accountRoutingNumber,
//       'accountNumber':accountNumber,
//       'address': address,
//       'city': city,
//       'state':state,
//       'postalCode': postalCode,
//       'created_at': FieldValue.serverTimestamp(),
//     });
//     print('Data added successfully!');
//     //---closing showDialog box
//     if (Navigator.of(buildcontext, rootNavigator: true).canPop()) {
//       Navigator.of(buildcontext, rootNavigator: true).pop(); // Ensure dialog is closed

//     }
//   }

// Future<void> updateAccount(BuildContext buildcontext,String accountHolderName, String accountRoutingNumber, String accountNumber, String address, String state, String city, String postalCode) async {
//     // Add a new document with auto-generated ID
//  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  
// // Reference to the user's main document
//     DocumentReference userDoc = _firestore.collection('Admins').doc(phoneNumber);
//     await userDoc.collection('CreateAccount').update({
//       'accountHolderName': accountHolderName,
//       'accountRoutingNumber': accountRoutingNumber,
//       'accountNumber':accountNumber,
//       'address': address,
//       'city': city,
//       'state':state,
//       'postalCode': postalCode,
//       'created_at': FieldValue.serverTimestamp(),
//     });
//     print('Data added successfully!');
//     //---closing showDialog box
//     if (Navigator.of(buildcontext, rootNavigator: true).canPop()) {
//       Navigator.of(buildcontext, rootNavigator: true).pop(); // Ensure dialog is closed

//     }
//   }


//  Future<void> fetchDataFromFirestoreAccountData() async {
  
// // Reference to the user's parkingData subcollection

//     CollectionReference collectionRef = FirebaseFirestore.instance
//         .collection('Admins')
//         .doc('8885124727')
//         .collection('CreateAccount');
//    // CollectionReference collectionRef = FirebaseFirestore.instance.collection('CreateAddParkingData');

//     try {
//       QuerySnapshot querySnapshot = await collectionRef.get();

//       // Storing document id as the key and the document data as the value
//       List<Map<String, dynamic>> tempList = querySnapshot.docs.map((doc) {
//         return {
//           'id': doc.id,  // Store the document ID
//           'data': doc.data() as Map<String, dynamic>,  // Store the document data
//         };
//       }).toList();

//       // print("Fetched data: $tempList");
//       // // Update the state with the fetched data
//       // setState(() {
//       //   parkingList = tempList;
//       //   final isElectricChargeFacilityChecked = parkingList[0]['data']['isElectricChargeFacilityChecked'];
//       //   print("isElectricChargeFacilityChecked"+isElectricChargeFacilityChecked);
//       // });

//     } catch (e) {
//       print("Error fetching data: $e");
//     } finally {
//       // Ensure the loading dialog is closed
//       // if (Navigator.of(context, rootNavigator: true).canPop()) {
//       //   Navigator.of(context, rootNavigator: true).pop();
//       // }
//     }
//   }







// // Function to show the loading dialog
//   void _showLoadingDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       barrierDismissible: false, // Prevent closing the dialog by tapping outside
//       builder: (BuildContext context) {
//         return const Dialog(
//           child: Padding(
//             padding: EdgeInsets.all(20.0),
//             child: Row(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 CircularProgressIndicator(), // The loading indicator
//                 SizedBox(width: 20),
//                 Text('Fetching Parking List data Please wait...'), // Optional loading text
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
  
 

// class FireStoreServices {
//   final CollectionReference accountCollectionRef = FirebaseFirestore.instance.collection('Admin').doc('8885124727').collection('CreateAccount');
  
//     Future<void> createAccount(AccountModel account) async {
//       await accountCollectionRef.doc(account.accountHolderName).set(account.toJson());
//     }
    
//    Stream<List<Account>> getAllAccounts() {
//     return accountCollectionRef.snapshots().map((snapshot) {
//       return snapshot.docs.map((doc) {
//         return Account.fromJson(doc.data() as Map<String, dynamic>);
//       }).toList();
//     });
//   }
// }

 

// //  Future<AccountModel?> fetchAccount() async {
// //  var querySnapshot = await FirebaseFirestore.instance
// //       .collection('Admin')
// //       .doc('8885124727')
// //       .collection('CreateAccount')
// //       .get();

// //   if (querySnapshot.docs.isNotEmpty) {
// //     var firstDoc = querySnapshot.docs.first; // Get first document
// //      return AccountModel.fromJson(firstDoc.data());
// //   } else {
// //     print("No documents found!");
// //   }
// //   return null;
// // }


// Future<void> updateAccountData(String userId, String newName) async {
//   await FirebaseFirestore.instance.collection('Admin').doc('8885124727').collection('CreateAccount').doc().update({
//     'name': newName,
//   });
// }


// String phoneNumber = '';
// class AccountScreen extends StatelessWidget {
//   late String phoneNumber;
//   AccountScreen({super.key, required phoneNumber});
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: UserScreen(),
//     );
//   }
// }


String phoneNumber = '';
class AccountScreen extends StatefulWidget {
  late String phoneNumber;
  AccountScreen({super.key, required phoneNumber});
   UserScreenState createState() => UserScreenState();
}
 bool isEditClicked = false;

class UserScreenState extends State<AccountScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final FirebaseService _firebaseService = FirebaseService();
 void initState() {
    super.initState();
    _loadValue();
  }
 Future<void> _loadValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      phoneNumber = prefs.getString('phoneNumber') ?? '';
      print('nofreferphone$phoneNumber');
    });
  }

   Future<void> savePhoneNumber(String phoneNumber) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('phoneNumber', phoneNumber); // Save phone number
  }
 @override
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Account Screen'),
        backgroundColor: Colors.green, 
        elevation: 0,
      ),  
      body: StreamBuilder<List<UserModel>>(
        stream: _firebaseService.getUsers(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var users = snapshot.data!;
          
          // If no user exists, show the form directly
          if (users.isEmpty) {
            return UserFormScreen();
          } else if (isEditClicked == true) {
            return UserFormScreen(user: users.first);
          }

          var user = users.first; // Assuming only one user is stored
          var lastDigitAccountNumber = user.bankAccountNumber.substring(user.bankAccountNumber.length - 4);

          return Padding(padding: const EdgeInsets.all(16.0),
    child: Column(
      crossAxisAlignment:  CrossAxisAlignment.start,
      children: [
        Row(
          children: [ 
            Text('Payout', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),),
            Spacer(),
             IconButton(
                      icon: Icon(Icons.edit, color: Colors.blue),
                      onPressed: () {
                        setState(() {
                           isEditClicked = true;
                        });
                      
                      },
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        _firebaseService.deleteUser(user.id);
                      },
                    ),],),
       
        Card(
          elevation: 3,
          child: ListTile(
            leading: Icon(Icons.account_balance),
            title: Text('Bank Account - XXXXXXXXXXXX$lastDigitAccountNumber'),
            subtitle: Text('Earnings paid out weekly'),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {},
          ),
        )
      ],),
    );
        },
      ),
    );
  }
}

class UserFormScreen extends StatefulWidget {
  final UserModel? user;
  UserFormScreen({this.user});

  @override
  _UserFormScreenState createState() => _UserFormScreenState();
}

class _UserFormScreenState extends State<UserFormScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  final _formKey = GlobalKey<FormState>();

  late TextEditingController nameController;
  late TextEditingController dayController;
  late TextEditingController monthController;
  late TextEditingController yearController;
  late TextEditingController bankAccountController;
  late TextEditingController routingController;
  late TextEditingController addressController;
  late TextEditingController cityController;
  late TextEditingController stateController;
  late TextEditingController postalCodeController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.user?.name ?? '');
    dayController = TextEditingController(text: widget.user?.dobDay ?? '');
    monthController = TextEditingController(text: widget.user?.dobMonth ?? '');
    yearController = TextEditingController(text: widget.user?.dobYear ?? '');
    bankAccountController = TextEditingController(text: widget.user?.bankAccountNumber ?? '');
    routingController = TextEditingController(text: widget.user?.routingNumber ?? '');
    addressController = TextEditingController(text: widget.user?.address ?? '');
    cityController = TextEditingController(text: widget.user?.city ?? '');
    stateController = TextEditingController(text: widget.user?.state ?? '');
    postalCodeController = TextEditingController(text: widget.user?.postalCode ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: Text(widget.user == null ? 'Add User' : 'Edit User')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(controller: nameController, decoration: InputDecoration(labelText: 'Name')),
              Row(
                children: [
                  Expanded(child: TextFormField(controller: dayController, decoration: InputDecoration(labelText: 'Day'))),
                  SizedBox(width: 5),
                  Expanded(child: TextFormField(controller: monthController, decoration: InputDecoration(labelText: 'Month'))),
                  SizedBox(width: 5),
                  Expanded(child: TextFormField(controller: yearController, decoration: InputDecoration(labelText: 'Year'))),
                ],
              ),
              TextFormField(controller: bankAccountController, decoration: InputDecoration(labelText: 'Bank Account Number')),
              TextFormField(controller: routingController, decoration: InputDecoration(labelText: 'Routing Number')),
              TextFormField(controller: addressController, decoration: InputDecoration(labelText: 'Address')),
              TextFormField(controller: cityController, decoration: InputDecoration(labelText: 'City')),
              TextFormField(controller: stateController, decoration: InputDecoration(labelText: 'State')),
              TextFormField(controller: postalCodeController, decoration: InputDecoration(labelText: 'Postal Code')),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  var newUser = UserModel(
                    id: widget.user?.id ?? const Uuid().v4(),
                    name: nameController.text,
                    dobDay: dayController.text,
                    dobMonth: monthController.text,
                    dobYear: yearController.text,
                    bankAccountNumber: bankAccountController.text,
                    routingNumber: routingController.text,
                    address: addressController.text,
                    city: cityController.text,
                    state: stateController.text,
                    postalCode: postalCodeController.text,
                  );
                  _firebaseService.saveUser(newUser);
                  // Navigator.pop(context);
                  isEditClicked = false;
           if (Navigator.of(context, rootNavigator: true).canPop()) {
                 Navigator.of(context, rootNavigator: true).pop(); // Ensure dialog is closed
              }
                },
                child: Text('Submit'),
              ),Container(child: () {
                  if (isEditClicked == true) {
                     ElevatedButton(
                onPressed: () {
                  isEditClicked = false;
                },
                child: Text('Cencel'),
              );
                  }
              }()
              ),
            ],
          ),
        ),
      ),
    );
  }
}



class FirebaseService {  
  final CollectionReference userCollection =
      // FirebaseFirestore.instance.collection('Admins').doc('8885124727').collection('CreateAccount');
       FirebaseFirestore.instance.collection('Admins');

  // Create or update user
  Future<void> saveUser(UserModel user) async {
    await userCollection.doc(phoneNumber).collection('CreateAccount').doc(user.id).set(user.toJson());
  }

  // Read users
  Stream<List<UserModel>> getUsers() {
    return userCollection.doc(phoneNumber).collection('CreateAccount').snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => UserModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    });
  }

  // Delete user
  Future<void> deleteUser(String id) async {
    await userCollection.doc(phoneNumber).collection('CreateAccount').doc(id).delete();
  }
}