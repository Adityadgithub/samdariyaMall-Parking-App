import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:samdriya/SplashScreen.dart';
import 'package:samdriya/provider/VehicleCheckIn_controller.dart';
import 'package:url_launcher/url_launcher.dart';

void main() async {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => VehicleCheckIn_Controller(),
      builder: (context, child) => MaterialApp(
        home: SplashScreen(),
      ),
    );
  }
}
