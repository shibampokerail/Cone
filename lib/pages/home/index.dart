import 'dart:io';

//packages
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:sound_mode/sound_mode.dart';
import 'package:sound_mode/permission_handler.dart';
import 'package:sound_mode/utils/ringer_mode_statuses.dart';
import 'package:telephony/telephony.dart';

//extension
import 'package:new_app/pages/settings/autoReply.dart';
import 'package:new_app/tools/permissionsManager.dart';
import 'package:new_app/tools/AndroidSmsManager.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int page_index = 0;
  final pages = [AutoReply()];

  final Telephony telephony = Telephony.instance;
  bool mainButtonPressed = false;

  @override
  void initState() {
    super.initState();
    loadSaved();
    getDoNotDisturbPermission(context);
    IncomingMessageHandler();
  }

  void IncomingMessageHandler() async {
    bool features_are_running = await loadSaved();
    features_are_running ?
      foregroundMessageHandler(telephony, true, debug:true):
        null;
  }

  //changes the sound mode of the phone to do not disturb when normal and vice versa
  void _setSilentMode() async {
    //https://pub.dev/packages/sound_mode >> ios usage
    //for ios implementation

    RingerModeStatus status;

    try {
      status = await SoundMode.setSoundMode(mainButtonPressed
          ? RingerModeStatus.silent
          : RingerModeStatus.normal);
      // setState(() {
      //   _soundMode = status;
      // });
    } on PlatformException {
      print('Do Not Disturb access permissions required!');
    }
  }

  //loading the saved settings for safe-driving
  Future<bool> loadSaved() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      mainButtonPressed = (prefs.getBool('is_safe_driving') ??
          false); //if no value is there in counter then we assign 0 to the counter
    });

    int _is_saved_auto = (prefs.getInt('is_saved_auto') ?? 0);
    print("autoreply_feature:$_is_saved_auto");
    if (mainButtonPressed && (_is_saved_auto==1)){
      return true;
    } else
      {
        return false;
      }
  }

  //saving settings set by the user
  void saveSafeDrivingMode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.setBool('is_safe_driving', mainButtonPressed);
      bool a = prefs.getBool('is_safe_driving') ?? false;
      print(a);
      print(mainButtonPressed.toString());
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
            // for debug
            title: const Text("About", style: TextStyle(fontSize: 20)),
            onTap: () {
              setState(() {});
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
        Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "SafeDriving:" + (mainButtonPressed ? "On" : "Off"),
              style: TextStyle(
                  fontSize: 35,
                  color: Colors.black,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
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
            visible: page_index == 0 ? true : false, //the main button is visible only in the homepage
            child: FloatingActionButton.large(
              //<-- SEE HERE
              backgroundColor:
                  mainButtonPressed ? Colors.lightGreen : Colors.red,
              onPressed: () => {
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
            child: page_index == 0
                ? buildHomePage(context)
                : pages[page_index - 1]));
  }
}
