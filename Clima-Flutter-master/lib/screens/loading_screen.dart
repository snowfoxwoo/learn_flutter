import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class LoadingScreen extends StatefulWidget {
  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override //INITIALIZE STAGE
  void initState() {
    super.initState();

    getLocation();
  }

  final LocationSettings locationSettings = LocationSettings(
    accuracy: LocationAccuracy.low,
    distanceFilter: 100,
  );

  void getLocation() async {
    Position position =
        await Geolocator.getCurrentPosition(locationSettings: locationSettings);

    print(position);
  }

  @override
  Widget build(BuildContext context) {
    //BUILD STAGE
    return Scaffold();
  }
}
