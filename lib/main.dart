import 'package:flutter/material.dart';
import 'package:garbage_collection_system/screens/Driver/driver_dashboard.dart';
import 'package:garbage_collection_system/screens/Driver/pickup_points.dart';
import 'package:garbage_collection_system/screens/Driver/view_schedule.dart';
import 'package:garbage_collection_system/screens/collector/collector_dashboard.dart';
import 'package:garbage_collection_system/screens/collector/scan_qr.dart';
import 'package:garbage_collection_system/screens/company/addCompany.dart';
import 'package:garbage_collection_system/screens/company/add_driver.dart';
import 'package:garbage_collection_system/screens/company/add_schedule.dart';
import 'package:garbage_collection_system/screens/company/add_vehicle.dart';
import 'package:garbage_collection_system/screens/company/add_zone.dart';
import 'package:garbage_collection_system/screens/company/addplan.dart';
import 'package:garbage_collection_system/screens/company/companyDashBoard.dart' hide Companydashboard;
import 'package:garbage_collection_system/screens/company/generate_qrcode.dart';
import 'package:garbage_collection_system/screens/company/manage_driver_vehicles.dart';
import 'package:garbage_collection_system/screens/company/manage_plans.dart';
import 'package:garbage_collection_system/screens/company/Companies.dart';
import 'package:garbage_collection_system/screens/company/company_dashboard1.dart';
import 'package:garbage_collection_system/screens/company/manage_schedules.dart';
import 'package:garbage_collection_system/screens/company/manage_zones.dart';
import 'package:garbage_collection_system/screens/company/pickup_request.dart';
import 'package:garbage_collection_system/screens/company/viewDrivers.dart';
import 'package:garbage_collection_system/screens/company/viewSchedules.dart';
import 'package:garbage_collection_system/screens/company/view_Plans.dart';
import 'package:garbage_collection_system/screens/company/view_all_user.dart';
import 'package:garbage_collection_system/screens/company/view_all_zones.dart';
import 'package:garbage_collection_system/screens/company/view_collector.dart';
import 'package:garbage_collection_system/screens/company/view_complaints.dart';
import 'package:garbage_collection_system/screens/company/view_subscribers.dart';
import 'package:garbage_collection_system/screens/company/view_vehicles.dart';
import 'package:garbage_collection_system/screens/splash/splash2.dart';
import 'package:garbage_collection_system/screens/user/extra_pickups.dart';
import 'package:garbage_collection_system/screens/user/fileacomplaint.dart';
import 'package:garbage_collection_system/screens/user/profile.dart';
import 'package:garbage_collection_system/screens/user/subscription_status.dart';
import 'package:garbage_collection_system/screens/user/view_history.dart';

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
        '/manageDriverVehicles': (context) => const ManageDriverVehicles(),
        '/viewSubscribers': (context) => const ViewSubscribers(),
        '/subscriptionStatus': (context) => const SubscriptionStatus(),
        '/profile': (context) => const Profile(),
        '/extrapickup': (context) => const ExtraPickups(),
        '/viewHistory': (context) => const ViewHistory(),
        '/viewExtraPickupRequests': (context) => const ExtraRequestsScreen(),
        '/addvehicle': (context) => const AddVehicle(),
        '/viewvehicles': (context) => const ViewVehicles(),
        '/viewComplaints': (context) => const ViewComplaints(),
        '/manageSchedules': (context) => const ManageSchedules(),
        '/addSchedule':(context)=> const AddSchedule(),
        '/viewSchedules':(context)=> const Viewschedules(),
        '/driverDashboard':(context)=> const DriverDashboard(),
        '/todaysSchedule':(context)=> const ViewSchedule(),
        '/viewCollectors':(context)=> const ViewCollectorsScreen(),
        '/collectorDashboard':(context)=> const CollectorDashboard(),
        '/scanQR':(context)=> const ScanQr(),
        '/pickupPoints':(context)=> const PickupPoints(),
      },
    );
  }
}
