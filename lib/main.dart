import 'package:flutter/material.dart';
import 'package:imin_printer/imin_printer.dart';
import 'package:imin_printer_example/pages/v1/home.dart';
import 'package:imin_printer_example/pages/v2/home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
    super.initState();
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
      home: NewHome(), // Always use NewHome
    );
  }
}
