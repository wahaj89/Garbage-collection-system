import 'package:flutter/material.dart';
import 'package:garbage_collection_system/screens/company/addCompany.dart';
import 'package:garbage_collection_system/screens/company/add_driver.dart';
import 'package:garbage_collection_system/screens/company/add_zone.dart';
import 'package:garbage_collection_system/screens/company/addplan.dart';
import 'package:garbage_collection_system/screens/company/companyDashBoard.dart' hide Companydashboard;
import 'package:garbage_collection_system/screens/company/generate_qrcode.dart';
import 'package:garbage_collection_system/screens/company/manage_plans.dart';
import 'package:garbage_collection_system/screens/company/Companies.dart';
import 'package:garbage_collection_system/screens/company/company_dashboard1.dart';
import 'package:garbage_collection_system/screens/company/manage_zones.dart';
import 'package:garbage_collection_system/screens/company/viewDrivers.dart';
import 'package:garbage_collection_system/screens/company/view_Plans.dart';
import 'package:garbage_collection_system/screens/company/view_all_user.dart';
import 'package:garbage_collection_system/screens/company/view_all_zones.dart';
import 'package:garbage_collection_system/screens/splash/splash2.dart';
import 'package:garbage_collection_system/screens/user/fileacomplaint.dart';

import 'screens/splash/splash.dart';
import 'screens/auth/loginscreen.dart';
import 'screens/auth/signupscreen.dart';
import 'screens/User/newuserdashboard.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const Splash(),
        '/login': (context) => const Loginscreen(),
        '/signup': (context) => const Signupscreen(),
        '/newUserDashboard': (context) => const Newuserdashboard(),
        '/addcompany': (context) => Addcompany(),
        '/viewcompanies': (context) => const Viewcompanyservices(),
        '/splash2': (context) => const Splash2(),
        '/companyAdminDashboard': (context) => const Companydashboard(),
        '/viewdrivers': (context) => const Viewdrivers(),
        '/filecomplaint': (context) => const Fileacomplaint(),
        '/addDriver': (context) => const AddDriver(),
        '/viewusers': (context) => const ViewAllUser(),
        '/addPlan': (context) => const Addplan(),
        '/companyDashboard': (context) => const CompanyDashboard1(),
        '/managePlans': (context) => const Companydashboard(),
        '/generateQRCode': (context) => const GenerateBagsScreen(),
        '/viewPlans': (context) => const ViewPlans(),
        '/managezones': (context) => const ManageZones(),
        '/addzone': (context) => const AddZone(),
        '/viewzones': (context) => const ViewAllZones(),
      },
    );
  }
}
