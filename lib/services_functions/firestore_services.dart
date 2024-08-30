import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class FirestoreServices extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final String userId;

  FirestoreServices(this.userId);

  // Method to fetch the user's farm name
  Future<String?> getFarmName() async {
    try {
      if (userId.isEmpty) {
        print("User ID is empty.");
        return null;
      }

      final docSnapshot = await _db.collection('users').doc(userId).get();

      if (!docSnapshot.exists) {
        print("Document does not exist for userId: $userId");
        return 'No farm Name';
      }

      final data = docSnapshot.data();
      if (data == null || !data.containsKey('farmName')) {
        print("Document does not contain 'farmName' field.");
        return 'No Business Name';
      }

      return data['farmName'] as String? ?? 'N/A';
    } catch (e) {
      print("Error fetching farm name: $e");
      return null;
    }
  }

  // Method to add a wage record
  Future<void> addWage(
      String name, String department, String date, String wage) async {
    try {
      await _db.collection('wages').add({
        'userId': userId,
        'employeeName': name,
        'department': department,
        'date': date,
        'wage': wage,
      });
    } catch (e) {
      print('Error adding wage record: $e');
      rethrow;
    }
  }

  // Method to fetch wages for the current user
  Future<List<Map<String, dynamic>>> getWages() async {
    try {
      final querySnapshot = await _db
          .collection('wages')
          .where('userId', isEqualTo: userId)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {'id': doc.id, ...data};
      }).toList();
    } catch (e) {
      print('Error fetching wages: $e');
      rethrow;
    }
  }

  // Method to delete a wage record
  Future<void> deleteWage(String wageId) async {
    try {
      final docSnapshot = await _db.collection('wages').doc(wageId).get();
      final data = docSnapshot.data();

      if (docSnapshot.exists && data != null && data['userId'] == userId) {
        await _db.collection('wages').doc(wageId).delete();
      } else {
        throw Exception('Permission denied or document does not exist');
      }
    } catch (e) {
      print('Error deleting wage record: $e');
      rethrow;
    }
  }

  // Method to update a wage record
  Future<void> updateWage(String wageId, Map<String, dynamic> updates) async {
    try {
      final docSnapshot = await _db.collection('wages').doc(wageId).get();
      final data = docSnapshot.data();

      if (docSnapshot.exists && data != null && data['userId'] == userId) {
        await _db.collection('wages').doc(wageId).update(updates);
      } else {
        throw Exception('Permission denied or document does not exist');
      }
    } catch (e) {
      print('Error updating wage record: $e');
      rethrow;
    }
  }

  // Add a machinery record
  Future<void> addMachinery(
      String name, String type, String condition, String dateAcquired) async {
    try {
      await _db.collection('machinery').add({
        'userId': userId,
        'name': name,
        'type': type,
        'condition': condition,
        'dateAcquired': dateAcquired,
      });
    } catch (e) {
      print('Error adding machinery record: $e');
      rethrow;
    }
  }

  // Fetch machinery records for the current user
  Future<List<Map<String, dynamic>>> getMachinery() async {
    try {
      final querySnapshot = await _db
          .collection('machinery')
          .where('userId', isEqualTo: userId)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {'id': doc.id, ...data};
      }).toList();
    } catch (e) {
      print('Error fetching machinery: $e');
      rethrow;
    }
  }

  // Delete a machinery record
  Future<void> deleteMachinery(String machineryId) async {
    try {
      final docSnapshot =
          await _db.collection('machinery').doc(machineryId).get();
      final data = docSnapshot.data();

      if (docSnapshot.exists && data != null && data['userId'] == userId) {
        await _db.collection('machinery').doc(machineryId).delete();
      } else {
        throw Exception('Permission denied or document does not exist');
      }
    } catch (e) {
      print('Error deleting machinery record: $e');
      rethrow;
    }
  }

  // Update a machinery record
  Future<void> updateMachinery(
      String machineryId, Map<String, dynamic> updates) async {
    try {
      final docSnapshot =
          await _db.collection('machinery').doc(machineryId).get();
      final data = docSnapshot.data();

      if (docSnapshot.exists && data != null && data['userId'] == userId) {
        await _db.collection('machinery').doc(machineryId).update(updates);
      } else {
        throw Exception('Permission denied or document does not exist');
      }
    } catch (e) {
      print('Error updating machinery record: $e');
      rethrow;
    }
  }

  // Add a feed record
  Future<void> addFeed(
      String name, String supplier, String quantity, String date) async {
    try {
      await _db.collection('feeds').add({
        'userId': userId,
        'name': name,
        'supplier': supplier,
        'quantity': quantity,
        'date': date,
      });
    } catch (e) {
      print('Error adding feed record: $e');
      rethrow;
    }
  }

  // Fetch feed records for the current user
  Future<List<Map<String, dynamic>>> getFeeds() async {
    try {
      final querySnapshot = await _db
          .collection('feeds')
          .where('userId', isEqualTo: userId)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {'id': doc.id, ...data};
      }).toList();
    } catch (e) {
      print('Error fetching feeds: $e');
      rethrow;
    }
  }

  // Delete a feed record
  Future<void> deleteFeed(String feedId) async {
    try {
      final docSnapshot = await _db.collection('feeds').doc(feedId).get();
      final data = docSnapshot.data();

      if (docSnapshot.exists && data != null && data['userId'] == userId) {
        await _db.collection('feeds').doc(feedId).delete();
      } else {
        throw Exception('Permission denied or document does not exist');
      }
    } catch (e) {
      print('Error deleting feed record: $e');
      rethrow;
    }
  }

  // Update a feed record
  Future<void> updateFeed(String feedId, Map<String, dynamic> updates) async {
    try {
      final docSnapshot = await _db.collection('feeds').doc(feedId).get();
      final data = docSnapshot.data();

      if (docSnapshot.exists && data != null && data['userId'] == userId) {
        await _db.collection('feeds').doc(feedId).update(updates);
      } else {
        throw Exception('Permission denied or document does not exist');
      }
    } catch (e) {
      print('Error updating feed record: $e');
      rethrow;
    }
  }

  // Method to add a medicine record
  Future<void> addMedicine(
      String name, String quantity, String expiryDate, String supplier) async {
    try {
      await _db.collection('medicines').add({
        'userId': userId,
        'name': name,
        'quantity': quantity,
        'expiryDate': expiryDate,
        'supplier': supplier,
      });
    } catch (e) {
      print('Error adding medicine: $e');
      rethrow;
    }
  }

  // Method to fetch all medicines for the current user
  Future<List<Map<String, dynamic>>> getMedicines() async {
    try {
      final querySnapshot = await _db
          .collection('medicines')
          .where('userId', isEqualTo: userId)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {'id': doc.id, ...data};
      }).toList();
    } catch (e) {
      print('Error fetching medicines: $e');
      rethrow;
    }
  }

  // Method to delete a medicine record
  Future<void> deleteMedicine(String medicineId) async {
    try {
      final docSnapshot =
          await _db.collection('medicines').doc(medicineId).get();
      final data = docSnapshot.data();

      if (docSnapshot.exists && data != null && data['userId'] == userId) {
        await _db.collection('medicines').doc(medicineId).delete();
      } else {
        throw Exception('Permission denied or document does not exist');
      }
    } catch (e) {
      print('Error deleting medicine: $e');
      rethrow;
    }
  }

  // Method to update a medicine record
  Future<void> updateMedicine(
      String medicineId, Map<String, dynamic> updates) async {
    try {
      final docSnapshot =
          await _db.collection('medicines').doc(medicineId).get();
      final data = docSnapshot.data();

      if (docSnapshot.exists && data != null && data['userId'] == userId) {
        await _db.collection('medicines').doc(medicineId).update(updates);
      } else {
        throw Exception('Permission denied or document does not exist');
      }
    } catch (e) {
      print('Error updating medicine: $e');
      rethrow;
    }
  }

  // Method to fetch user profile details
  Future<Map<String, dynamic>?> getProfile() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();
        return doc.data();
      }
    } catch (e) {
      print("Error fetching profile: $e");
    }
    return null;
  }

  // Method to update user profile details
  Future<void> updateProfile(Map<String, dynamic> updates) async {
    try {
      if (userId.isEmpty) {
        print("User ID is empty.");
        return;
      }

      await _db.collection('users').doc(userId).update(updates);
       // Notify listeners that the profile has been updated
      notifyListeners();
    } catch (e) {
      print("Error updating profile: $e");
    }
  }

  // Method to add farm details
  Future<void> addFarmDetails(Map<String, dynamic> farmDetails) async {
    try {
      if (userId.isEmpty) {
        print("User ID is empty.");
        return;
      }

      await _db.collection('farms').doc(userId).set(farmDetails);
    } catch (e) {
      print("Error adding farm details: $e");
    }
  }

  // Method to update farm details
  Future<void> updateFarmDetails(Map<String, dynamic> updates) async {
    try {
      if (userId.isEmpty) {
        print("User ID is empty.");
        return;
      }

      await _db.collection('farms').doc(userId).update(updates);
    } catch (e) {
      print("Error updating farm details: $e");
    }
  }

  // Method to delete farm details
  Future<void> deleteFarmDetails() async {
    try {
      if (userId.isEmpty) {
        print("User ID is empty.");
        return;
      }

      await _db.collection('farms').doc(userId).delete();
    } catch (e) {
      print("Error deleting farm details: $e");
    }
  }

  // Method to upload profile image
  Future<String?> uploadProfileImage(File image) async {
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child(DateTime.now().toString() + '.jpg');
      final uploadTask = storageRef.putFile(image);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print("Upload failed: $e");
      return null;
    }
  }

  // Method to pick an image from gallery or camera
  Future<File?> pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: source);

      if (pickedFile != null) {
        return File(pickedFile.path);
      }
    } catch (e) {
      print("Error picking image: $e");
    }
    return null;
  }

  // Method to update the profile image URL
  Future<void> updateProfileImageUrl(String imageUrl) async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .update({
          'profileImage': imageUrl,
        });
      }
    } catch (e) {
      print("Error updating profile image URL: $e");
    }
  }

  
}
