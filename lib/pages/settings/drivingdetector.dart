import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:new_app/tools/permissionsManager.dart';

class detectDriving extends StatefulWidget {
  const detectDriving({Key? key}) : super(key: key);

  @override
  State<detectDriving> createState() => _detectDrivingState();
}

class _detectDrivingState extends State<detectDriving> {
  String driver_action = "....";

  double previous_latitude = 0;
  double previous_longitude = 0;
  int previous_seconds = 0;
  double speed = 0;

  void get_current_location() async {
    final LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 100,
    );
    bool first_load = false;
    var positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((Position? position) {
      if (position != null) {
        first_load = false;
        if (previous_latitude == 0 || previous_longitude == 0) {
          previous_longitude = position.longitude;
          previous_latitude = position.latitude;
          previous_seconds = DateTime.now().hour * 3600 +
              DateTime.now().minute * 60 +
              DateTime.now().second;
        } else {
          double distance = Geolocator.distanceBetween(previous_latitude,
              previous_longitude, position.latitude, position.longitude);
          int time = (DateTime.now().hour * 3600 +
                  DateTime.now().minute * 60 +
                  DateTime.now().second) -
              previous_seconds;
          speed = (distance * 0.00062137) / (time * 0.000277778);
          print("distance:$distance time:$time speed:$speed");
          previous_seconds = DateTime.now().hour * 3600 +
              DateTime.now().minute * 60 +
              DateTime.now().second;
          previous_longitude = position.longitude;
          previous_latitude = position.latitude;
        }
      }
      print(DateTime.now().hour * 3600 +
          DateTime.now().minute * 60 +
          DateTime.now().second);
      setState(() {
        if (position != null && !first_load) {
          if (speed > 16) {
            //taking usain bolt's speed and this data "One estimate is that about 5 percent of pedestrians would die when struck by a vehicle traveling 20 mph at impact" by one.nhtsa.gov"
            //into reference
            driver_action = "Driving";
          } else if (speed > 5) {
            driver_action = "running";
          } else if (speed > 0) {
            driver_action = "walking";
          } else {
            driver_action = "sitting";
          }
        }
      });
      print(position == null
          ? 'Unknown'
          : '${position.latitude.toString()}, ${position.longitude.toString()}');
    });
    
  }

  @override
  void initState() {
    super.initState();
    request_gps_permission();
    get_current_location();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "Driver is " + driver_action + " \n Speed:$speed",
              style: TextStyle(
                  fontSize: 35,
                  color: Colors.black,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
        TextButton(
            onPressed: () {
              get_current_location();
            },
            child: Text("Change"))
      ],
    );
  }
}
