// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'account_model.dart'; // Import the Account model

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