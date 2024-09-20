// data_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DataService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User?> getCurrentUser() async {
    return _auth.currentUser;
  }

  Future<List<Map<String, dynamic>>> fetchCollectionData(String collectionName) async {
    try {
      User? user = await getCurrentUser();
      if (user != null) {
        QuerySnapshot snapshot = await _db
            .collection('farmers')
            .doc(user.uid)
            .collection(collectionName)
            .get();

        return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
      } else {
        print('User is not logged in');
        return [];
      }
    } catch (e) {
      print('Error fetching $collectionName data: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchMilkSalesData() => fetchCollectionData('milk_sales');
  Future<List<Map<String, dynamic>>> fetchArtificialInseminationData() => fetchCollectionData('artificial_insemination');
  Future<List<Map<String, dynamic>>> fetchCalfData() => fetchCollectionData('calf');
  Future<List<Map<String, dynamic>>> fetchCalvingData() => fetchCollectionData('calving');
  Future<List<Map<String, dynamic>>> fetchCattleData() => fetchCollectionData('cattle');
  Future<List<Map<String, dynamic>>> fetchCowSalesData() => fetchCollectionData('cow_sales');
  Future<List<Map<String, dynamic>>> fetchDeathsData() => fetchCollectionData('deaths');
  Future<List<Map<String, dynamic>>> fetchDehorningData() => fetchCollectionData('dehorning');
  Future<List<Map<String, dynamic>>> fetchDewormingData() => fetchCollectionData('deworming');
  Future<List<Map<String, dynamic>>> fetchFeedsData() => fetchCollectionData('feeds');
  Future<List<Map<String, dynamic>>> fetchHeatDetectionData() => fetchCollectionData('heat_detection');
  Future<List<Map<String, dynamic>>> fetchMachineryData() => fetchCollectionData('machinery');
  Future<List<Map<String, dynamic>>> fetchMedicineData() => fetchCollectionData('medicine');
  Future<List<Map<String, dynamic>>> fetchMilkProductionData() => fetchCollectionData('milk_production');
  Future<List<Map<String, dynamic>>> fetchMiscarriagesData() => fetchCollectionData('miscarriages');
  Future<List<Map<String, dynamic>>> fetchNaturalInseminationData() => fetchCollectionData('natural_insemination');
  Future<List<Map<String, dynamic>>> fetchPestControlData() => fetchCollectionData('pest_control');
  Future<List<Map<String, dynamic>>> fetchPregnanciesData() => fetchCollectionData('pregnancies');
  Future<List<Map<String, dynamic>>> fetchTreatmentsData() => fetchCollectionData('treatments');
  Future<List<Map<String, dynamic>>> fetchVaccinationsData() => fetchCollectionData('vaccinations');
  Future<List<Map<String, dynamic>>> fetchWorkersData() => fetchCollectionData('workers');

  // Example count fetches
  Future<int> fetchCattleCount() async {
    return (await fetchCollectionData('cattle')).length;
  }

  Future<int> fetchWorkersCount() async {
    return (await fetchCollectionData('workers')).length;
  }

  Future<int> fetchCalvesCount() async {
    return (await fetchCollectionData('calves')).length;
  }
}