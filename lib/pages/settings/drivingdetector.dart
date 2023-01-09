import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:new_app/tools/featuresHandler.dart';
import 'package:new_app/tools/permissionsManager.dart';

class detectDriving extends StatefulWidget {
  const detectDriving({Key? key}) : super(key: key);

  @override
  State<detectDriving> createState() => _detectDrivingState();
}

class _detectDrivingState extends State<detectDriving> {
  String driver_action = "....";
  double speed = 0;
  void get_current_location() async {


    double previous_latitude = 0;
    double previous_longitude = 0;
    int previous_seconds = 0;

    final LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 100,
        timeLimit: Duration(seconds: 20));
    bool first_load = true;
    Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position? position) {
      if (position != null) {
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
          speed =
              (distance * 0.00062137) / (time * 0.000277778); //in miles per hr
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
        if (position != null && !first_load && speed < 200) {

          //this is for unrealistic values | unless you are driving a bugatti
          if (speed > 14) {
            //taking usain bolt's speed and this data "One estimate is that about 5 percent of pedestrians would die when struck by a vehicle traveling 20 mph at impact" by one.nhtsa.gov"
            //into reference (15mph is very fast even for runners)
            if (speed > 65){
              driver_action = "Driving above speed limit.\n";
            } else{
            driver_action = "Driving under speed limit";}
            SafeDriving().turn_on();
          } else if (speed > 5) {
            driver_action = "running";
          } else if (speed > 0) {
            driver_action = "walking";
          } else {
            driver_action = "idle";
          }
        } else {
          first_load = false;
          driver_action = "idle";
          speed = 0;
        }
      });
      print(position == null
          ? 'Unknown'
          : '${position.latitude.toString()}, ${position.longitude.toString()}');
    }).onError((TimeoutException){
      setState(() {
      driver_action = "idle";
      speed = 0;});
      throw TimeoutException("Timeout Exception");
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
              "Driver is " + driver_action + " \nSpeed:$speed",
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
