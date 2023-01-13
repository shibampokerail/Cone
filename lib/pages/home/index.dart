//packages
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:new_app/main.dart';
import 'package:telephony/telephony.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:geolocator_android/geolocator_android.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:workmanager/workmanager.dart';

//extensions
import 'package:new_app/pages/settings/autoReply.dart';
import 'package:new_app/pages/settings/advanced.dart';
import 'package:new_app/tools/featuresHandler.dart';
import 'package:new_app/tools/notificationsManager.dart';
import 'package:new_app/tools/speed_limit.dart';
import 'package:new_app/pages/settings/drivingdetectortest.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int page_index = 0;
  final pages = [AutoReplyPage(), AdvancedSettings()];

  final Telephony telephony = Telephony.instance;
  bool mainButtonPressed = false;

  String driver_action = "....";
  double speed = 0;
  double speed2 = 0;
  String state = "";

  // ask for location lettings on first launch
  final LocationSettings locationSettings = LocationSettings(
    accuracy: LocationAccuracy.high,
    distanceFilter: 0,
    // timeLimit: Duration(seconds: 20)
  );

  @override
  void initState() {
    super.initState();

    loadSaved();
    SafeDriving().permission(context);
    AutoReply().runIncomingSmsHandler(telephony);
    AwesomeNotifications().requestPermissionToSendNotifications();
    SafeDrivingNotificationController().initialize_listeners();
    AwesomeNotifications().dismiss(1);
    get_current_location();
    DetectDriving().get_current_location();
  }



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
      bool is_safedriving_automatic = await SafeDriving().is_automatic();
      if (filter_out_first_two_data < 2) {
        filter_out_first_two_data += 1;
        return;
      }

      if (position != null) {
        try {
          List<Placemark> location = await placemarkFromCoordinates(
              position.latitude, position.longitude);
          current_state = location
              .toList()[0]
              .toString()
              .split(",")
              .toList()[5]
              .toString()
              .split(":")[1]
              .replaceAll(" ", "");
        } on PlatformException {
          print("Could not find location");
        }
        print(current_state);
        if (previous_latitude == 0 || previous_longitude == 0) {
          previous_longitude = position.longitude;
          previous_latitude = position.latitude;
          previous_seconds = DateTime.now().hour * 3600 +
              DateTime.now().minute * 60 +
              DateTime.now().second;
          // +(DateTime.now().millisecond / 1000) +
          // (DateTime.now().microsecond / 1000000)) -
        } else {
          double distance = Geolocator.distanceBetween(previous_latitude,
              previous_longitude, position.latitude, position.longitude);
          int time = (DateTime.now().hour * 3600 +
                  DateTime.now().minute * 60 +
                  DateTime.now().second) -
              // +(DateTime.now().millisecond / 1000) +
              // (DateTime.now().microsecond / 1000000)) -
              previous_seconds;
          speed =
              (distance * 0.00062137) / (time * 0.000277778); //in miles per hr
          print("distance:$distance time:$time speed:$speed");
          previous_seconds = DateTime.now().hour * 3600 +
              DateTime.now().minute * 60 +
              DateTime.now().second;
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
          setState(() {
            if (is_safedriving_automatic) {
              mainButtonPressed = true;
              SafeDriving().turn_on();
            }
          });
          if (notification_count == 0) {
            //run this in background mode
            // createNotification('Are You Driving?',
            //     'Tap this to turn on SafeDriving mode.');
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
            if (count_stop_time == 5) {
              //~1min 20 seconds - 1 minute
              //Forbush said the typical light cycle is 120 seconds, meaning the longest you would ever sit at a red light is one and half to two minutes.
              if (is_safedriving_automatic) {
                SafeDriving().turn_off();
              }
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
      loadSaved();
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

  //loading the saved settings for safe-driving
  void loadSaved() async {
    bool saved_setting = await SafeDriving().is_running();
    setState(() {
      mainButtonPressed = saved_setting;
    });
  }

  //builds the settings app drawer with home auto reply and others (use hero??)
  Widget _buildAppDrawer(BuildContext context) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        const DrawerHeader(
          decoration: BoxDecoration(
            color: Colors.orange,
          ),
          child: Text(
            'Settings',
            style: TextStyle(fontSize: 30, color: Colors.white),
          ),
        ),
        ListTile(
            title: const Text("Home", style: TextStyle(fontSize: 20)),
            onTap: () async {
              bool saved_setting = await SafeDriving().is_running();
              setState(() {
                mainButtonPressed = saved_setting;
                page_index = 0;
                AwesomeNotifications().dismiss(1);
              });
              Navigator.pop(context);
            }),
        ListTile(
            title: const Text("Auto-reply", style: TextStyle(fontSize: 20)),
            onTap: () {
              setState(() {
                page_index = 1;
              });
              Navigator.pop(context);
            }),
        ListTile(
            // for debug
            title: const Text("Advanced", style: TextStyle(fontSize: 20)),
            onTap: () {
              setState(() {
                page_index = 2;
              });
              Navigator.pop(context);
            }),
        ListTile(
            title: const Text("Back", style: TextStyle(fontSize: 20)),
            onTap: () {
              Navigator.pop(context);
            })
      ],
    );
  }

  //builds the homepage that displays the driving mode
  Widget buildHomePage(BuildContext context) {
    return ListView(
      children: [
        SizedBox(height:25),
        Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "SafeDriving:" + (mainButtonPressed ? "On" : "Off"),
              style: TextStyle(
                  fontSize: 40,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,

              ),
            ),
          ),
        ),
        SizedBox(height:120),
        Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text("Safety Points"
              ,
              style: TextStyle(
                  fontSize: 30,
                  color: Colors.indigo,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
        Center(
          child: Text("0",  style: TextStyle(
              fontSize: 130,
              color: Colors.lightGreen,
              fontWeight: FontWeight.bold)),
        ),
        MaterialButton(height: 20,onPressed: (){},)
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("CONE"),
          centerTitle: true,
          backgroundColor: Colors.orange,
          elevation: 0,
        ),
        backgroundColor: Colors.white,
        drawer: Drawer(
          child: _buildAppDrawer(context),
        ),
        floatingActionButton: Visibility(
            visible: page_index == 0 ? true : false,
            //the main button is visible only in the homepage
            child: FloatingActionButton.large(
              elevation: 0,
              backgroundColor:
                  mainButtonPressed ? Colors.lightGreen : Colors.red,
              onPressed: () async {
                bool safedriving_mode = await SafeDriving().is_running();
                bool auto_reply_mode = await AutoReply().is_running();
                setState(() {
                  mainButtonPressed = !mainButtonPressed;
                  mainButtonPressed
                      ? SafeDriving().turn_on()
                      : SafeDriving().turn_off();
                  auto_reply_mode
                      ? AutoReply().turn_on()
                      : AutoReply().turn_off();
                });
                AutoReply().runIncomingSmsHandler(telephony);
              },
              child: Icon(
                Icons.power_settings_new,
                size: 40,
                color: Colors.white,
              ),
            )),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        body: Center(
            child: page_index == 0
                ?
                // AdvancedSettings()
                buildHomePage(context)
                : pages[page_index - 1]));
  }
}
