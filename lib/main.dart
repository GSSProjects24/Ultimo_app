import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:imin_printer/imin_printer.dart';
import 'package:imin_printer_example/pages/v1/home.dart';
import 'package:imin_printer_example/pages/v2/home.dart';

import 'Routes/route.dart';
import 'Routes/route_manager.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase before running the app
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final iminPrinter = IminPrinter();

  @override
  void initState() {
    super.initState(); // Always call super.initState() first
    getSdkVersion();
  }

  Future<void> getSdkVersion() async {
    await iminPrinter.getSdkVersion(); // Version fetching, but no effect on UI
  }

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      initialRoute: ValetParkingRoutes.splashRoute,
      onGenerateRoute: RouteManager.generateRoute,
      // home: NewHome(),
    );
  }
}
// home: NewHome(),