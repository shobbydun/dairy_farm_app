import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RoleAuthService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> getUserRole(String userId) async {
    // Fetch user role from Firestore using userId (UID)
    DocumentSnapshot userDoc =
        await _firestore.collection('users').doc(userId).get();

    // Check if the document exists
    if (userDoc.exists) {
      return userDoc['role'] ?? 'guest'; // Return role or default to 'guest'
    } else {
      return 'guest'; // Document does not exist
    }
  }

  String getUserRoleSync() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // You can choose to cache the role or use a different method to get it
      return 'manager'; // Placeholder; implement async retrieval if needed
    }
    return 'guest'; // Default role
  }

  Future<String> getUsername(String userId) async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();
      if (userDoc.exists) {
        return userDoc['username'] ??
            'User'; // Default to 'User' if username is not found
      } else {
        return 'User'; // Default if user document does not exist
      }
    } catch (e) {
      print("Error fetching username: $e");
      return 'User'; // Default in case of error
    }
  }
}
