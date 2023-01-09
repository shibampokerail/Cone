import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:geolocator_android/geolocator_android.dart';
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
    double previous_seconds = 0;
    double previous_speed = 0;
    int count_stop_time = 0;

    final LocationSettings locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 0,
        // timeLimit: Duration(seconds: 20)
    );

    bool first_load = true;
    Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position? position) {
      if (position != null) {
        if (previous_latitude == 0 || previous_longitude == 0) {
          previous_longitude = position.longitude;
          previous_latitude = position.latitude;
          previous_seconds = DateTime.now().hour * 3600 +
              DateTime.now().minute * 60 +
              DateTime.now().second +(DateTime.now().millisecond/1000) + (DateTime.now().microsecond/1000000);
        } else {
          double distance = Geolocator.distanceBetween(previous_latitude,
              previous_longitude, position.latitude, position.longitude);
          double time = (DateTime.now().hour * 3600 +
                  DateTime.now().minute * 60 +
                  DateTime.now().second + (DateTime.now().millisecond/1000)+ (DateTime.now().microsecond/1000000)) -
              previous_seconds;
          speed =
              (distance * 0.00062137) / (time * 0.000277778); //in miles per hr
          print("distance:$distance time:$time speed:$speed");
          previous_seconds = DateTime.now().hour * 3600 +
              DateTime.now().minute * 60 +
              DateTime.now().second + (DateTime.now().millisecond/1000) + (DateTime.now().microsecond/1000000);
          previous_longitude = position.longitude;
          previous_latitude = position.latitude;
        }

      }
      setState(() {
        if (position != null && !first_load && speed < 200) {
          //this is for unrealistic values | unless you are driving a bugatti
          if (speed > 14) {
            //taking usain bolt's speed and this data "One estimate is that about 5 percent of pedestrians would die when struck by a vehicle traveling 20 mph at impact" by one.nhtsa.gov"
            //into reference (15mph is very fast even for runners)
            if (speed > 65) {
              driver_action = "Driving above speed limit.\n";
            } else {
              driver_action = "Driving under speed limit";
            }
            SafeDriving().turn_on();
          } else if (speed > 5) {
            driver_action = "running";
          } else if (speed > 1) {
            driver_action = "walking";
          } else {
            driver_action = "idle";
            if (previous_speed < 1){
              count_stop_time += 1;
              print("stop time $count_stop_time");
              if (count_stop_time==30){ //in 10 seconds
                SafeDriving().turn_off();
              }
            } else {
              count_stop_time ==0;
            }
          }
        } else {
          first_load = false;
          driver_action = "idle";
          speed = 0;
        }
        previous_speed = speed;
      });
      print(position == null
          ? 'Unknown'
          : '${position.latitude.toString()}, ${position.longitude.toString()}');
    }).onError((TimeoutException) {
      setState(() {
        driver_action = "idle";
        speed = 0;
      });
      // throw TimeoutException("Timeout Exception");
      get_current_location();
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
