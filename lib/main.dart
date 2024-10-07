import 'package:cloud_firestore/cloud_firestore.dart';
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
import 'package:dairy_harbor/pages/manage_cattle/main_cattle_page.dart';
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
import 'package:dairy_harbor/roles_management/PendingApprovalPage.dart';
import 'package:dairy_harbor/roles_management/dynamic_role_home.dart';
import 'package:dairy_harbor/roles_management/roleAuthService.dart';
import 'package:dairy_harbor/roles_management/rolePermissions.dart';
import 'package:dairy_harbor/services_functions/firestore_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    print("Firebase initialization error: $e");
  }

  runApp(
    MultiProvider(
      providers: [
        StreamProvider<User?>(
          create: (context) => FirebaseAuth.instance.authStateChanges(),
          initialData: null,
        ),
        ChangeNotifierProxyProvider<User?, FirestoreServices>(
          create: (context) =>
              FirestoreServices('', getAdminEmailFromFirestore()),
          update: (context, user, firestoreServices) {
            return FirestoreServices(
                user?.uid ?? '', getAdminEmailFromFirestore());
          },
        ),
      ],
      child: const MyApp(),
    ),
  );
}

// Define the function outside of the MyApp class
Future<String?> getAdminEmailFromFirestore() async {
  try {
    final adminSnapshot = await FirebaseFirestore.instance
        .collection('users')
        .where('role', isEqualTo: 'admin')
        .limit(1)
        .get();

    if (adminSnapshot.docs.isNotEmpty) {
      return adminSnapshot.docs.first['email'];
    }
    print("No admin found");
  } catch (e) {
    print("Error fetching admin email: $e");
  }
  return null;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static Future<String?> getAdminEmailFromFirestore() async {
    try {
      final adminSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'admin')
          .limit(1)
          .get();

      if (adminSnapshot.docs.isNotEmpty) {
        return adminSnapshot.docs.first['email'];
      }
      print("No admin found");
    } catch (e) {
      print("Error fetching admin email: $e");
    }
    return null;
  }

  User? get user => FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      onGenerateRoute: (settings) {
        final userRole = RoleAuthService().getUserRoleSync();
        switch (settings.name) {
          case '/home':
            return _buildHomePage(settings);
          case '/milkSales':
            return _buildAsyncRouteForMilkSales(settings);
          case '/dailyProduction':
            return _buildAsyncRoute(settings);
          case '/cattleForm':
            return _buildAsyncRouteCattleForm(settings);
          case '/cattleListPage':
            return _buildAsyncRouteCattleList(settings);
          case '/artificialInsemination':
            return _buildAsyncRouteAI(settings);

          case '/calving':
            return _buildAsyncRouteCalving(settings);

          case '/dehorning':
            return _buildAsyncRouteDehorning(settings);

          case '/deworming':
            return _buildAsyncRouteDeworming(settings);
          case '/miscarriage':
            return _buildAsyncRouteMiscarriages(settings);

          case '/naturalInsemination':
            return _buildAsyncRouteNaturalI(settings);

          case '/pestControl':
            return _buildAsyncRoutePestControl(settings);

          case '/pregnancy':
            return _buildAsyncRoutePregnancy(settings);

          case '/treatment':
            return _buildAsyncRouteTreatment(settings);

          case '/vaccination':
            return _buildAsyncRouteVaccination(settings);

          case '/medicine':
            return _buildAsyncRouteMedicine(settings);

          case '/feeds':
            return _buildAsyncRouteFeeds(context);

          case '/machinery':
            return _buildAsyncRouteMachinery(context);

          case '/adminWages':
            return _buildAsyncRouteAdminAddWages(context);

          case '/inventory':
            return _buildAsyncRouteInventoryMainPage(context);

          case '/workerList':
            return _buildAsyncRouteEmployeeList(context);
            case '/reports':
            return _buildAsyncRouteReports(context);
            
          case '/notification':
            return _buildPageIfAuthorized(
                userRole, NotificationScreen(), settings.arguments);
          case '/userProfile':
            return _buildPageIfAuthorized(
                userRole, UserProfile(), settings.arguments);
          case '/signup':
            return _buildMaterialPageRoute(RegisterPage(onTap: () {}));
          case '/login':
            return _buildMaterialPageRoute(LoginPage());
          case '/loginOrRegister':
            return _buildMaterialPageRoute(const LoginOrRegisterPage());
          case '/auth':
            return _buildMaterialPageRoute(AuthPage());
          case '/dynamic_role_home':
            return _buildMaterialPageRoute(DynamicRoleHome());
          case '/heatDetection':
            return _buildPageIfAuthorized(
                userRole, HeatDetectionPage(), settings.arguments);
          case '/workerProfile':
            return _buildWorkerProfilePage(settings);
          case '/editProfile':
            return _buildPageIfAuthorized(
                userRole, EditProfilePage(), settings.arguments);
          case '/CattlePage':
            return _buildPageIfAuthorized(
                userRole, CattlePage(), settings.arguments);
          case '/cattleProfile':
            return _buildCattleProfilePage(settings);
          case '/cattleEditPage':
            return _buildEditCattlePage(settings);
          default:
            return _buildMaterialPageRoute(AuthPage());
        }
      },
    );
  }

  MaterialPageRoute _buildMaterialPageRoute(Widget page) {
    return MaterialPageRoute(builder: (context) => page);
  }

  MaterialPageRoute _buildAsyncRoute(RouteSettings settings) {
    final adminEmailFuture = getAdminEmailFromFirestore();
    return MaterialPageRoute(
      builder: (context) =>
          MilkProductionPage(adminEmailFuture: adminEmailFuture),
    );
  }

  MaterialPageRoute _buildAsyncRouteCattleForm(RouteSettings settings) {
    final adminEmailFuture = getAdminEmailFromFirestore();
    return MaterialPageRoute(
      builder: (context) => CattleForm(adminEmailFuture: adminEmailFuture),
    );
  }

  MaterialPageRoute _buildAsyncRouteCattleList(RouteSettings settings) {
    final adminEmailFuture = getAdminEmailFromFirestore();
    return MaterialPageRoute(
      builder: (context) => CattleList(adminEmailFuture: adminEmailFuture),
    );
  }

  MaterialPageRoute _buildAsyncRouteAI(RouteSettings settings) {
    final adminEmailFuture = getAdminEmailFromFirestore();
    return MaterialPageRoute(
      builder: (context) =>
          ArtificialInseminationPage(adminEmailFuture: adminEmailFuture),
    );
  }

  MaterialPageRoute _buildAsyncRouteDehorning(RouteSettings settings) {
    final adminEmailFuture = getAdminEmailFromFirestore();
    return MaterialPageRoute(
      builder: (context) => DehorningPage(adminEmailFuture: adminEmailFuture),
    );
  }

  MaterialPageRoute _buildAsyncRouteCalving(RouteSettings settings) {
    final adminEmailFuture = getAdminEmailFromFirestore();
    return MaterialPageRoute(
      builder: (context) => CalvingPage(adminEmailFuture: adminEmailFuture),
    );
  }

  MaterialPageRoute _buildAsyncRouteDeworming(RouteSettings settings) {
    final adminEmailFuture = getAdminEmailFromFirestore();
    return MaterialPageRoute(
      builder: (context) => DewormingPage(adminEmailFuture: adminEmailFuture),
    );
  }

  MaterialPageRoute _buildAsyncRouteMiscarriages(RouteSettings settings) {
    final adminEmailFuture = getAdminEmailFromFirestore();
    return MaterialPageRoute(
      builder: (context) => MiscarriagePage(adminEmailFuture: adminEmailFuture),
    );
  }

  MaterialPageRoute _buildAsyncRouteNaturalI(RouteSettings settings) {
    final adminEmailFuture = getAdminEmailFromFirestore();
    return MaterialPageRoute(
      builder: (context) =>
          NaturalInseminationPage(adminEmailFuture: adminEmailFuture),
    );
  }

  MaterialPageRoute _buildAsyncRoutePestControl(RouteSettings settings) {
    final adminEmailFuture = getAdminEmailFromFirestore();
    return MaterialPageRoute(
      builder: (context) => PestControlPage(adminEmailFuture: adminEmailFuture),
    );
  }

  MaterialPageRoute _buildAsyncRoutePregnancy(RouteSettings settings) {
    final adminEmailFuture = getAdminEmailFromFirestore();
    return MaterialPageRoute(
      builder: (context) => PregnancyPage(adminEmailFuture: adminEmailFuture),
    );
  }

  MaterialPageRoute _buildAsyncRouteTreatment(RouteSettings settings) {
    final adminEmailFuture = getAdminEmailFromFirestore();
    return MaterialPageRoute(
      builder: (context) => TreatmentPage(adminEmailFuture: adminEmailFuture),
    );
  }

  MaterialPageRoute _buildAsyncRouteVaccination(RouteSettings settings) {
    final adminEmailFuture = getAdminEmailFromFirestore();
    return MaterialPageRoute(
      builder: (context) => VaccinationPage(adminEmailFuture: adminEmailFuture),
    );
  }

  MaterialPageRoute _buildAsyncRouteMedicine(RouteSettings settings) {
    final adminEmailFuture = getAdminEmailFromFirestore();
    return MaterialPageRoute(
      builder: (context) => MedicinePage(adminEmailFuture: adminEmailFuture),
    );
  }

  MaterialPageRoute _buildAsyncRouteFeeds(BuildContext context) {
    final adminEmailFuture = getAdminEmailFromFirestore();
    final firestoreServices = Provider.of<FirestoreServices>(context,
        listen: false); // Use listen: false

    return MaterialPageRoute(
      builder: (context) => FeedsPage(
        adminEmailFuture: adminEmailFuture,
        firestoreServices: firestoreServices,
      ),
    );
  }

  MaterialPageRoute _buildAsyncRouteMachinery(BuildContext context) {
    final adminEmailFuture = getAdminEmailFromFirestore();

    return MaterialPageRoute(
      builder: (context) => FarmMachineryPage(
        adminEmailFuture: adminEmailFuture,
      ),
    );
  }

  MaterialPageRoute _buildAsyncRouteAdminAddWages(BuildContext context) {
    final adminEmailFuture = getAdminEmailFromFirestore();

    return MaterialPageRoute(
      builder: (context) => AdministrativeWages(
        adminEmailFuture: adminEmailFuture,
      ),
    );
  }

  MaterialPageRoute _buildAsyncRouteInventoryMainPage(BuildContext context) {
    final adminEmailFuture = getAdminEmailFromFirestore();

    return MaterialPageRoute(
      builder: (context) => InventoryMainPage(
        adminEmailFuture: adminEmailFuture,
      ),
    );
  }

  MaterialPageRoute _buildAsyncRouteEmployeeList(BuildContext context) {
    final adminEmailFuture = getAdminEmailFromFirestore();

    return MaterialPageRoute(
      builder: (context) => WorkerListPage(
        adminEmailFuture: adminEmailFuture,
      ),
    );
  }
  
   MaterialPageRoute _buildAsyncRouteReports(BuildContext context) {
    final adminEmailFuture = getAdminEmailFromFirestore();

    return MaterialPageRoute(
      builder: (context) => ReportsPage(
        adminEmailFuture: adminEmailFuture,
      ),
    );
  }

  MaterialPageRoute _buildAsyncRouteForMilkSales(RouteSettings settings) {
    final adminEmailFuture = getAdminEmailFromFirestore();
    return MaterialPageRoute(
      builder: (context) => MilkDistributionSales(
        adminEmailFuture: adminEmailFuture,
        arguments: settings.arguments,
      ),
    );
  }

  MaterialPageRoute _buildHomePage(RouteSettings settings) {
    final args = settings.arguments as Map<String, dynamic>? ?? {};
    final firestoreServices = args['firestoreServices'] as FirestoreServices?;
    final adminEmailFuture =
        getAdminEmailFromFirestore(); // Get admin email future

    if (firestoreServices == null) {
      print("Error: FirestoreServices argument is missing or invalid.");
      return _buildMaterialPageRoute(AuthPage());
    }

    return MaterialPageRoute(
      builder: (context) => HomePage(
        animate: args['animate'] ?? true,
        firestoreServices: firestoreServices,
        userId: args['userId'] ?? (user?.uid ?? ''),
        user: args['user'] as User? ?? user,
        adminEmailFuture: adminEmailFuture,
      ),
    );
  }

  MaterialPageRoute _buildWorkerProfilePage(RouteSettings settings) {
    final args = settings.arguments as Map<String, dynamic>? ?? {};
    final workerId = args['workerId'] as String?;

    if (workerId == null) {
      return _buildMaterialPageRoute(AuthPage());
    }

    // Assuming you have a method to get the admin email future.
    Future<String?> adminEmailFuture =
        getAdminEmailFromFirestore(); // Your method to fetch admin email

    return MaterialPageRoute(
      builder: (context) => WorkerProfilePage(
        workerId: workerId,
        adminEmailFuture: adminEmailFuture, // Pass it here
      ),
    );
  }

  MaterialPageRoute _buildCattleProfilePage(RouteSettings settings) {
    final args = settings.arguments as Map<String, dynamic>? ?? {};
    final cattleId = args['cattleId'] as String?;
    //final index = args['index'] as int? ?? 0;

    // Fetch admin email future
    final adminEmailFuture = args['adminEmailFuture'] as Future<String?>;

    if (cattleId == null) {
      return _buildMaterialPageRoute(AuthPage());
    }

    return _buildMaterialPageRoute(CattleProfilePage(
      cattleId: cattleId,
      //index: index,
      adminEmailFuture: adminEmailFuture,
    ));
  }

  MaterialPageRoute _buildEditCattlePage(RouteSettings settings) {
    final args = settings.arguments as Map<String, dynamic>? ?? {};
    final cattleId = args['cattleId'] as String?;
    final initialData = args['initialData'] as Map<String, dynamic>? ?? {};

    // Fetch admin email future
    final adminEmailFuture = getAdminEmailFromFirestore();

    if (cattleId == null) {
      return _buildMaterialPageRoute(AuthPage());
    }

    return MaterialPageRoute(
      builder: (context) => EditCattlePage(
        cattleId: cattleId,
        initialData: initialData, // Pass initialData
        adminEmailFuture: adminEmailFuture, // Pass the admin email future
      ),
    );
  }

  MaterialPageRoute _buildPageIfAuthorized(
      String userRole, Widget page, Object? arguments) {
    if (page is PendingApprovalPage) {
      return MaterialPageRoute(builder: (context) => page);
    }

    if (userRole == 'admin') {
      return MaterialPageRoute(builder: (context) => page);
    }

    if (canAccessPage(userRole, page.runtimeType.toString())) {
      return MaterialPageRoute(builder: (context) => page);
    } else {
      return MaterialPageRoute(builder: (context) => AuthPage());
    }
  }
}
