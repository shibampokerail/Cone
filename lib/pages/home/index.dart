import 'dart:io';

import 'package:flutter/material.dart';
import 'package:new_app/pages/settings/autoReply.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:sound_mode/sound_mode.dart';
import 'package:sound_mode/permission_handler.dart';
import 'package:sound_mode/utils/ringer_mode_statuses.dart';
import 'package:sms_advanced/sms_advanced.dart';
import 'package:new_app/features/permissions.dart';




class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int page_index = 0;
  final pages = [AutoReply()];

  @override
  void initState() {
    super.initState();
    loadSaved();
    getPermissionStatus();


  }

  bool mainButtonPressed = false; //change this later for background process
  String _permissionStatus = "";


  //for putting the phone on silent | need to get do not disturb permission for android 7.0 and above
  void getPermissionStatus() async {
    bool? permissionStatus = false;
    try {
      permissionStatus = await PermissionHandler.permissionsGranted;

      print("D0 not disturb:" + permissionStatus.toString());
      if (permissionStatus == false) {
        if (Platform.isAndroid){
          AskDoNotDisturbPermission(context);
        } else {
          print("IOS do not disturb settings not configured...");
        }

        //permission for sms is not invoked here because for some reason asks  automatically
      }
      permissionStatus = await PermissionHandler.permissionsGranted;
      print(permissionStatus);
      // AskContactPermission(context);
    } catch (err) {
      print(err);
    }


    setState(() {
      _permissionStatus =
      permissionStatus! ? "Permissions Enabled" : "Permissions not granted";
    });
    print(_permissionStatus);
  }

  //changes the sound mode of the phone to do not disturb when normal and vice versa
  void _setSilentMode() async {
    RingerModeStatus status;

    try {
      status = await SoundMode.setSoundMode(mainButtonPressed ? RingerModeStatus.silent : RingerModeStatus.normal);
      // setState(() {
      //   _soundMode = status;
      // });
    } on PlatformException {
      print('Do Not Disturb access permissions required!');
    }
  }

  //loading the saved settings for safe-driving
  void loadSaved() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      mainButtonPressed = (prefs.getBool('is_safe_driving') ??
          false); //if no value is there in counter then we assign 0 to the counter
    });
  }

  //saving settings set by the user
  void saveSafeDrivingMode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.setBool('is_safe_driving', mainButtonPressed);
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
            onTap: () {
              setState(() {
                page_index = 0;
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
            title: const Text("About", style: TextStyle(fontSize: 20)),
            onTap: () {}),
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
        Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "SafeDriving:" + (mainButtonPressed ? "On" : "Off"),
              style: TextStyle(
                  fontSize: 35, color: Colors.black, fontWeight: FontWeight.bold),
            ),


          ),
        ),
    // Text(threads[0].contact?.address ?? 'empty')
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
        ),
        drawer: Drawer(
          child: _buildAppDrawer(context),
        ),
        floatingActionButton: Visibility(
            visible: page_index == 0 ? true : false,
            child: FloatingActionButton.large(
              //<-- SEE HERE

              backgroundColor:
              mainButtonPressed ? Colors.lightGreen : Colors.red,
              onPressed: () =>
              {
                setState(() {
                  mainButtonPressed = !mainButtonPressed;
                  saveSafeDrivingMode();
                  _setSilentMode();
                })
              },
              child: Icon(
                Icons.power_settings_new,
                size: 40,
                color: Colors.white,
              ),
            )),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        body: Center(
            child:
            page_index == 0 ? buildHomePage(context) : pages[page_index - 1]
            ));
  }
}
