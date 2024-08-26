import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreServices {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String userId;

  FirestoreServices( this.userId,);


  // Method to fetch the business name
  Future<String?> getBusinessName() async {
    try {
      if (userId.isEmpty) {
        print("User ID is empty.");
        return null;
      }

      final docSnapshot = await _db.collection('users').doc(userId).get();

      if (!docSnapshot.exists) {
        print("Document does not exist for userId: $userId");
        return 'No Business Name';
      }

      final data = docSnapshot.data();
      if (data == null || !data.containsKey('businessName')) {
        print("Document does not contain 'businessName' field.");
        return 'No Business Name';
      }

      return data['businessName'] as String? ?? 'N/A';
    } catch (e) {
      print("Error fetching business name: $e");
      return null;
    }
  }

}