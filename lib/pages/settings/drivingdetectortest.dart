import 'package:flutter/services.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator_android/geolocator_android.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:new_app/tools/featuresHandler.dart';
import 'package:new_app/custom_widgets/notifiers.dart';
import 'package:new_app/tools/speed_limit.dart';


class DetectDriving {
  String driver_action = "....";
  double speed = 0;
  double speed2 = 0;
  String state = "";

  final LocationSettings locationSettings = LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 0,
    // timeLimit: Duration(seconds: 20)
  );

  void get_current_location() async {
    double previous_latitude = 0;
    double previous_longitude = 0;
    int previous_seconds = 0;
    double previous_speed = 0;
    int count_stop_time = 0;
    int filter_out_first_two_data =
    0; //to clear out any anomalies that appear at the beginning
    int notification_count = 0;
    bool first_load = true;
    String current_state = "";

    Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position? position) async {
      if (filter_out_first_two_data < 2) {
        filter_out_first_two_data += 1;
        return;
      }

      if (position != null) {
        try {
          List<Placemark> location = await placemarkFromCoordinates(
              position.latitude, position.longitude);
          current_state =
              location.toList()[0].toString().split(",").toList()[5]
                  .toString()
                  .split(":")[1].replaceAll(" ", "");
        } on PlatformException {
          print("Could not find location");
        }
        print(current_state);
        if (previous_latitude == 0 || previous_longitude == 0) {
          previous_longitude = position.longitude;
          previous_latitude = position.latitude;
          previous_seconds = DateTime
              .now()
              .hour * 3600 +
              DateTime
                  .now()
                  .minute * 60 +
              DateTime
                  .now()
                  .second;
          // +(DateTime.now().millisecond / 1000) +
          // (DateTime.now().microsecond / 1000000)) -
        } else {
          double distance = Geolocator.distanceBetween(previous_latitude,
              previous_longitude, position.latitude, position.longitude);
          int time = (DateTime
              .now()
              .hour * 3600 +
              DateTime
                  .now()
                  .minute * 60 +
              DateTime
                  .now()
                  .second) -
              // +(DateTime.now().millisecond / 1000) +
              // (DateTime.now().microsecond / 1000000)) -
              previous_seconds;
          speed =
              (distance * 0.00062137) / (time * 0.000277778); //in miles per hr
          print("distance:$distance time:$time speed:$speed");
          previous_seconds = DateTime
              .now()
              .hour * 3600 +
              DateTime
                  .now()
                  .minute * 60 +
              DateTime
                  .now()
                  .second;
          // + (DateTime.now().millisecond / 1000) +
          // (DateTime.now().microsecond / 1000000);
          previous_longitude = position.longitude;
          previous_latitude = position.latitude;
        }
      }

      if (position != null && !first_load && speed < 200) {
        //this is for unrealistic values | unless you are driving a bugatti
        speed2 = position.speed * (0.00062137) / 0.000277778;
        state = current_state;
        if (speed > 14) {
          //taking usain bolt's top speed and this data "One estimate is that about 5 percent of pedestrians would die when struck by a vehicle traveling 20 mph at impact" by one.nhtsa.gov"
          //into reference (15mph is very fast even for runners)

          if (notification_count == 0) {
            createNotification('Are You Driving?',
                'Tap this to turn on SafeDriving mode.');
            notification_count = 1;
          }

          // bool speed_limit_crossed = is_above_speed_limit(state, speed);

          if (speed > speed_limit[state]!) {
            driver_action = "Driving above speed limit\n";
          } else {
            driver_action = "Driving under speed limit";
          }
        } else if (speed > 5) {
          driver_action = "going slow";
        } else if (speed > 2) {
          driver_action = "going to stop";
        } else {
          driver_action = "idle";
          if (previous_speed < 2) {
            count_stop_time += 1;
            // print("stop time $count_stop_time");
            if (count_stop_time == 40) {
              //~1min 20 seconds - 1 minute
              //Forbush said the typical light cycle is 120 seconds, meaning the longest you would ever sit at a red light is one and half to two minutes.
              SafeDriving().turn_off();
              count_stop_time = 0;
            }
          } else {
            count_stop_time == 0;
          }
        }
      } else {
        first_load = false;
        driver_action = "idle";
        speed = 0;
      }

      //
      // print(position == null
      // ? 'Unknown'
      //     : '${position.latitude.toString()}, ${position.longitude.toString()}'
      // );
    }).onError((TimeoutException) {
      driver_action = "idle";
      speed = 0;

      // throw TimeoutException("Timeout Exception");
      get_current_location();
    });
  }
}
