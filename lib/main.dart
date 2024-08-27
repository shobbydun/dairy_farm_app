import 'package:dairy_harbor/firebase_options.dart';
import 'package:dairy_harbor/pages/authentication/auth_page.dart';
import 'package:dairy_harbor/pages/authentication/login_or_register_page.dart';
import 'package:dairy_harbor/pages/authentication/login_page.dart';
import 'package:dairy_harbor/pages/authentication/register_page.dart';
import 'package:dairy_harbor/pages/dashboard/home_page.dart';
import 'package:dairy_harbor/pages/inventory/InventoryMainPage.dart';
import 'package:dairy_harbor/pages/inventory/adminstrative_wages.dart';
import 'package:dairy_harbor/pages/inventory/farm_machinery_page.dart';
import 'package:dairy_harbor/pages/inventory/feeds_page.dart';
import 'package:dairy_harbor/pages/inventory/medicine_page..dart';
import 'package:dairy_harbor/pages/inventory/notification_page.dart';
import 'package:dairy_harbor/pages/inventory/user_profile.dart';
import 'package:dairy_harbor/pages/manage_cattle/cattle_form.dart';
import 'package:dairy_harbor/pages/manage_cattle/cattle_list_page.dart';
import 'package:dairy_harbor/pages/manage_cattle/cattle_profile_page.dart';
import 'package:dairy_harbor/pages/manage_cattle/main_cattle_Page.dart';
import 'package:dairy_harbor/pages/milk/daily_production_page.dart';
import 'package:dairy_harbor/pages/milk/milk_distribution_sales.dart';
import 'package:dairy_harbor/pages/procedures/artificial_insemination_page.dart';
import 'package:dairy_harbor/pages/procedures/calving_page.dart';
import 'package:dairy_harbor/pages/procedures/dehorning_page.dart';
import 'package:dairy_harbor/pages/procedures/deworming_page.dart';
import 'package:dairy_harbor/pages/procedures/heat_detection_page.dart';
import 'package:dairy_harbor/pages/procedures/miscarriage_page.dart';
import 'package:dairy_harbor/pages/procedures/natural_insemination_page.dart';
import 'package:dairy_harbor/pages/procedures/pest_control_page.dart';
import 'package:dairy_harbor/pages/procedures/pregnancy_page.dart';
import 'package:dairy_harbor/pages/procedures/treatment_page.dart';
import 'package:dairy_harbor/pages/procedures/vaccination_page.dart';
import 'package:dairy_harbor/pages/reports/reports_page.dart';
import 'package:dairy_harbor/pages/workers/worker_list_page.dart';
import 'package:dairy_harbor/pages/workers/worker_profile_page.dart';
import 'package:dairy_harbor/services_functions/firestore_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

 
  User? get user => FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/home':
            final args = settings.arguments as Map<String, dynamic>? ?? {};
            final firestoreServices =
                args['firestoreServices'] as FirestoreServices?;
            if (firestoreServices == null) {
              print("Error: FirestoreServices argument is missing or invalid.");
              
              return MaterialPageRoute(
                  builder: (context) => AuthPage());
            }
            return MaterialPageRoute(
              builder: (context) => HomePage(
                barChartData: args['barChartData'] ?? _createBarChartData(),
                pieChartData: args['pieChartData'] ?? _createPieChartData(),
                lineChartData: args['lineChartData'] ?? _createLineChartData(),
                animate: args['animate'] ?? true,
                firestoreServices: firestoreServices,
                userId: args['userId'] ?? (user?.uid ?? ''),
                user: args['user'] as User? ?? user,
              ),
            );
          case '/manageCattle':
            return MaterialPageRoute(builder: (context) => CattleList());
          case '/reports':
            return MaterialPageRoute(builder: (context) => ReportsPage());
          case '/adminWages':
            return MaterialPageRoute(
                builder: (context) => AdministrativeWages());
          case '/machinery':
            return MaterialPageRoute(builder: (context) => FarmMachineryPage());
          case '/feeds':
            return MaterialPageRoute(builder: (context) => FeedsPage());
          case '/inventory':
            return MaterialPageRoute(builder: (context) => InventoryMainPage());
          case '/medicine':
            return MaterialPageRoute(builder: (context) => MedicinePage());
          case '/notification':
            return MaterialPageRoute(
                builder: (context) => NotificationScreen());
          case '/userProfile':
            return MaterialPageRoute(builder: (context) => UserProfile());
          case '/dailyProduction':
            return MaterialPageRoute(
                builder: (context) => MilkProductionPage());
          case '/milkDistribution':
            return MaterialPageRoute(
                builder: (context) => MilkDistributionSales());
          case '/signup':
            return MaterialPageRoute(
                builder: (context) => RegisterPage(onTap: () {}));
          case '/login':
            return MaterialPageRoute(builder: (context) => LoginPage());
          case '/loginOrRegister':
            return MaterialPageRoute(
                builder: (context) => LoginOrRegisterPage());
          case '/auth':
            return MaterialPageRoute(builder: (context) => AuthPage());
          case '/artificialInsemination':
            return MaterialPageRoute(
                builder: (context) => ArtificialInseminationPage());
          case '/calving':
            return MaterialPageRoute(builder: (context) => CalvingPage());
          case '/dehorning':
            return MaterialPageRoute(builder: (context) => DehorningPage());
          case '/deworming':
            return MaterialPageRoute(builder: (context) => DewormingPage());
          case '/heatDetection':
            return MaterialPageRoute(builder: (context) => HeatDetectionPage());
          case '/miscarriage':
            return MaterialPageRoute(builder: (context) => MiscarriagePage());
          case '/naturalInsemination':
            return MaterialPageRoute(
                builder: (context) => NaturalInseminationPage());
          case '/pestControl':
            return MaterialPageRoute(builder: (context) => PestControlPage());
          case '/pregnancy':
            return MaterialPageRoute(builder: (context) => PregnancyPage());
          case '/treatment':
            return MaterialPageRoute(builder: (context) => TreatmentPage());
          case '/vaccination':
            return MaterialPageRoute(builder: (context) => VaccinationPage());
          case '/workerList':
            return MaterialPageRoute(builder: (context) => WorkerListPage());
          case '/workerProfile':
            return MaterialPageRoute(builder: (context) => WorkerProfilePage());
          case '/editProfile':
            return MaterialPageRoute(builder: (context) => EditProfilePage());
          case '/CattlePage':
            return MaterialPageRoute(builder: (context) => CattlePage());
          case '/cattleProfile':
            return MaterialPageRoute(
                builder: (context) => CattleProfile(
                      index: 0,
                    ));
          case '/cattleListPage':
            return MaterialPageRoute(builder: (context) => CattleList());
          case '/cattleForm':
            return MaterialPageRoute(builder: (context) => CattleForm());

          default:
            return MaterialPageRoute(builder: (context) => AuthPage());
        }
      },
    );
  }

  List<BarChartGroupData> _createBarChartData() {
    return [
      BarChartGroupData(
        x: 0,
        barRods: [
          BarChartRodData(toY: 5000, color: Colors.blue),
        ],
      ),
      BarChartGroupData(
        x: 1,
        barRods: [
          BarChartRodData(toY: 2500, color: Colors.blue),
        ],
      ),
      BarChartGroupData(
        x: 2,
        barRods: [
          BarChartRodData(toY: 10000, color: Colors.blue),
        ],
      ),
      BarChartGroupData(
        x: 3,
        barRods: [
          BarChartRodData(toY: 7500, color: Colors.blue),
        ],
      ),
    ];
  }

  List<PieChartSectionData> _createPieChartData() {
    return [
      PieChartSectionData(value: 30, color: Colors.blue, title: '30%'),
      PieChartSectionData(value: 20, color: Colors.red, title: '20%'),
      PieChartSectionData(value: 25, color: Colors.green, title: '25%'),
      PieChartSectionData(value: 25, color: Colors.orange, title: '25%'),
    ];
  }

  List<LineChartBarData> _createLineChartData() {
    return [
      LineChartBarData(
        spots: [
          const FlSpot(0, 5000),
          const FlSpot(1, 2500),
          const FlSpot(2, 10000),
          const FlSpot(3, 7500),
        ],
        isCurved: true,
        color: Colors.blue,
        dotData: const FlDotData(show: true),
        belowBarData: BarAreaData(show: true),
      ),
    ];
  }
}
