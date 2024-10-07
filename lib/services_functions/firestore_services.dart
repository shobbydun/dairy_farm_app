import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class FirestoreServices extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final String userId;
  final Future<String?> adminEmailFuture;
  String? _adminEmail;

  FirestoreServices(this.userId, this.adminEmailFuture) {
    _fetchAdminEmail();
  }

  Future<void> _fetchAdminEmail() async {
    if (!_isDisposed) {
      _adminEmail = await adminEmailFuture;
      if (!_isDisposed) notifyListeners();
    }
  }

  bool _isDisposed = false;

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  // Method to fetch the user's farm name
  Future<String?> getFarmName() async {
    try {
      if (userId.isEmpty) {
        print("User ID is empty.");
        return '';
      }

      final docSnapshot = await _db.collection('users').doc(userId).get();

      if (!docSnapshot.exists) {
        print("Document does not exist for userId: $userId");
        return 'No farm Name';
      }

      final data = docSnapshot.data();
      if (data == null || !data.containsKey('farmName')) {
        print("Document does not contain 'farmName' field.");
        return 'No farm Name';
      }

      return data['farmName'] as String? ?? 'N/A';
    } catch (e) {
      print("Error fetching farm name: $e");
      return '';
    }
  }

// Method to add a wage record
  Future<void> addWage(
      String name, String department, String date, String wage) async {
    if (_adminEmail != null) {
      try {
        await FirebaseFirestore.instance
            .collection('wages')
            .doc(_adminEmail)
            .collection('entries')
            .add({
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
  }

// Method to fetch wages for the current admin
  Future<List<Map<String, dynamic>>> getWages() async {
    if (_adminEmail != null) {
      try {
        final querySnapshot = await FirebaseFirestore.instance
            .collection('wages')
            .doc(_adminEmail)
            .collection('entries')
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
    return [];
  }

// Method to delete a wage record
  Future<void> deleteWage(String wageId) async {
    if (_adminEmail != null) {
      try {
        await FirebaseFirestore.instance
            .collection('wages')
            .doc(_adminEmail)
            .collection('entries')
            .doc(wageId)
            .delete();
      } catch (e) {
        print('Error deleting wage record: $e');
        rethrow;
      }
    }
  }

// Method to update a wage record
  Future<void> updateWage(String wageId, Map<String, dynamic> updates) async {
    if (_adminEmail != null) {
      try {
        await FirebaseFirestore.instance
            .collection('wages')
            .doc(_adminEmail)
            .collection('entries')
            .doc(wageId)
            .update(updates);
      } catch (e) {
        print('Error updating wage record: $e');
        rethrow;
      }
    }
  }

  // Add a machinery record
  Future<void> addMachinery(String name, String type, String condition,
      String dateAcquired, double buyCost, double maintenanceCost) async {
    if (_adminEmail != null) {
      try {
        await FirebaseFirestore.instance
            .collection('machinery')
            .doc(_adminEmail)
            .collection('entries')
            .add({
          'name': name,
          'type': type,
          'condition': condition,
          'dateAcquired': dateAcquired,
          'buyCost': buyCost,
          'maintenanceCost': maintenanceCost,
        });
      } catch (e) {
        print('Error adding machinery record: $e');
        rethrow;
      }
    }
  }

// Fetch machinery records for the current admin
  Future<List<Map<String, dynamic>>> getMachinery() async {
    if (_adminEmail != null) {
      try {
        final querySnapshot = await FirebaseFirestore.instance
            .collection('machinery')
            .doc(_adminEmail)
            .collection('entries')
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
    return [];
  }

// Delete a machinery record
  Future<void> deleteMachinery(String machineryId) async {
    if (_adminEmail != null) {
      try {
        await FirebaseFirestore.instance
            .collection('machinery')
            .doc(_adminEmail)
            .collection('entries')
            .doc(machineryId)
            .delete();
      } catch (e) {
        print('Error deleting machinery record: $e');
        rethrow;
      }
    }
  }

// Update a machinery record
  Future<void> updateMachinery(
      String machineryId, Map<String, dynamic> updates) async {
    if (_adminEmail != null) {
      try {
        await FirebaseFirestore.instance
            .collection('machinery')
            .doc(_adminEmail)
            .collection('entries')
            .doc(machineryId)
            .update(updates);
      } catch (e) {
        print('Error updating machinery record: $e');
        rethrow;
      }
    }
  }

  // Add a feed record
// Add a feed record
  Future<void> addFeed(String name, String supplier, String quantity,
      String date, double cost) async {
    if (_adminEmail != null) {
      try {
        DateTime dateTime = DateTime.parse(date); // Convert to DateTime
        await FirebaseFirestore.instance
            .collection('feeds')
            .doc(_adminEmail)
            .collection('entries')
            .add({
          'name': name,
          'supplier': supplier,
          'quantity': quantity,
          'date': Timestamp.fromDate(dateTime), // Store as Timestamp
          'cost': cost,
        });
      } catch (e) {
        print('Error adding feed record: $e');
        rethrow;
      }
    }
  }

// Fetch feed records for the current admin
  Future<List<Map<String, dynamic>>> getFeeds() async {
    if (_adminEmail != null) {
      try {
        final querySnapshot = await FirebaseFirestore.instance
            .collection('feeds')
            .doc(_adminEmail)
            .collection('entries')
            .get();

        return querySnapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;

          // If date is a String, convert it to Timestamp
          if (data['date'] is String) {
            data['date'] = Timestamp.fromDate(DateTime.parse(data['date']));
          }

          // Convert Timestamp to String for display
          if (data['date'] is Timestamp) {
            data['date'] = (data['date'] as Timestamp)
                .toDate()
                .toIso8601String()
                .split('T')[0]; // Format to 'yyyy-MM-dd'
          }

          return {'id': doc.id, ...data};
        }).toList();
      } catch (e) {
        print('Error fetching feeds: $e');
        rethrow;
      }
    }
    return [];
  }

// Delete a feed record
  Future<void> deleteFeed(String feedId) async {
    if (_adminEmail != null) {
      try {
        await FirebaseFirestore.instance
            .collection('feeds')
            .doc(_adminEmail)
            .collection('entries')
            .doc(feedId)
            .delete();
      } catch (e) {
        print('Error deleting feed record: $e');
        rethrow;
      }
    }
  }

// Update a feed record
  Future<void> updateFeed(String feedId, Map<String, dynamic> updates) async {
    if (_adminEmail != null) {
      try {
        // Check if the updates contain a date and convert if it's a string
        if (updates['date'] is String) {
          updates['date'] = Timestamp.fromDate(DateTime.parse(updates['date']));
        }

        await FirebaseFirestore.instance
            .collection('feeds')
            .doc(_adminEmail)
            .collection('entries')
            .doc(feedId)
            .update(updates);
      } catch (e) {
        print('Error updating feed record: $e');
        rethrow;
      }
    }
  }

  // Method to add a medicine record
  Future<void> addMedicine(String name, String quantity, String expiryDate,
      String supplier, double cost) async {
    if (_adminEmail != null) {
      print("Adding medicine: $name, $quantity, $expiryDate, $supplier, $cost");
      try {
        await FirebaseFirestore.instance
            .collection('medicines')
            .doc(_adminEmail)
            .collection('entries')
            .add({
          'name': name,
          'quantity': quantity,
          'expiryDate': expiryDate,
          'supplier': supplier,
          'cost': cost,
        });
        print("Medicine added successfully.");
      } catch (e) {
        print('Error adding medicine: $e');
      }
    } else {
      print("Admin email is null. Cannot add medicine.");
    }
  }

// Method to fetch all medicines for the current admin
  Future<Map<String, dynamic>?> getMedicines(String medicineId) async {
    if (_adminEmail != null) {
      try {
        final medicineSnapshot = await FirebaseFirestore.instance
            .collection('medicines')
            .doc(_adminEmail)
            .collection('entries')
            .doc(medicineId)
            .get();

        if (medicineSnapshot.exists) {
          return medicineSnapshot.data() as Map<String, dynamic>;
        } else {
          print("Medicine with ID $medicineId not found.");
        }
      } catch (e) {
        print("Error fetching medicine: $e");
      }
    } else {
      print("Admin email is null");
    }
    return null;
  }

  // Method to calculate total wages for the current admin
  Future<double> getTotalWages() async {
    if (_adminEmail != null) {
      try {
        final querySnapshot = await FirebaseFirestore.instance
            .collection('wages')
            .doc(_adminEmail)
            .collection('entries')
            .get();

        double totalWages = 0.0;

        for (var doc in querySnapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;
          if (data.containsKey('wage')) {
            totalWages += double.tryParse(data['wage'].toString()) ?? 0.0;
          }
        }

        return totalWages;
      } catch (e) {
        print('Error calculating total wages: $e');
        return 0.0;
      }
    }
    return 0.0;
  }

// Method to delete a medicine record
  Future<void> deleteMedicine(String medicineId) async {
    if (_adminEmail != null) {
      try {
        await FirebaseFirestore.instance
            .collection('medicines')
            .doc(_adminEmail)
            .collection('entries')
            .doc(medicineId)
            .delete();
      } catch (e) {
        print('Error deleting medicine: $e');
        rethrow;
      }
    }
  }

// Method to update a medicine record
  Future<void> updateMedicine(
      String medicineId, Map<String, dynamic> updates) async {
    if (_adminEmail != null) {
      try {
        await FirebaseFirestore.instance
            .collection('medicines')
            .doc(_adminEmail)
            .collection('entries')
            .doc(medicineId)
            .update(updates);
      } catch (e) {
        print('Error updating medicine: $e');
        rethrow;
      }
    }
  }

  // Method to fetch user profile details
  Future<Map<String, dynamic>?> getProfile() async {
    try {
      if (userId.isEmpty) {
        print("User ID is empty.");
        return null;
      }

      final doc = await _db.collection('users').doc(userId).get();
      return doc.data();
    } catch (e) {
      print("Error fetching profile: $e");
      return null;
    }
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
    if (_adminEmail != null) {
      try {
        await FirebaseFirestore.instance
            .collection('farms')
            .doc(_adminEmail)
            .set(farmDetails);
      } catch (e) {
        print("Error adding farm details: $e");
      }
    }
  }

// Method to update farm details
  Future<void> updateFarmDetails(Map<String, dynamic> updates) async {
    if (_adminEmail != null) {
      try {
        await FirebaseFirestore.instance
            .collection('farms')
            .doc(_adminEmail)
            .update(updates);
      } catch (e) {
        print("Error updating farm details: $e");
      }
    }
  }

// Method to delete farm details
  Future<void> deleteFarmDetails() async {
    if (_adminEmail != null) {
      try {
        await FirebaseFirestore.instance
            .collection('farms')
            .doc(_adminEmail)
            .delete();
      } catch (e) {
        print("Error deleting farm details: $e");
      }
    }
  }

  // Method to upload profile image
  Future<String?> uploadProfileImage(File image) async {
    try {
      final storageRef = _storage
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
      if (userId.isEmpty) {
        print("User ID is empty.");
        return;
      }

      await _db.collection('users').doc(userId).update({
        'profileImage': imageUrl,
      });
    } catch (e) {
      print("Error updating profile image URL: $e");
    }
  }

  // Method to fetch a single medicine by its ID
  Future<Map<String, dynamic>?> getMedicine(String medicineId) async {
    if (_adminEmail != null) {
      try {
        final docSnapshot = await FirebaseFirestore.instance
            .collection('medicines')
            .doc(_adminEmail)
            .collection('entries')
            .doc(medicineId)
            .get();
        if (docSnapshot.exists) {
          return {'id': docSnapshot.id, ...docSnapshot.data()!};
        } else {
          print('Medicine not found');
          return null;
        }
      } catch (e) {
        print('Error fetching medicine: $e');
        return null;
      }
    }
    return null;
  }
}
