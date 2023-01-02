import 'package:flutter/material.dart';
import 'package:new_app/pages/settings/autoReply.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'package:sound_mode/sound_mode.dart';
import 'package:sound_mode/permission_handler.dart';
import 'package:app_settings/app_settings.dart';
import 'package:sound_mode/utils/ringer_mode_statuses.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool mainButtonPressed = false; //change this later for background process
  String _permissionStatus = "";

  //for putting the phone on silent | need to get notification permission for android 7.0 and above
  void getPermissionStatus() async {
    bool? permissionStatus = false;
    try {
      permissionStatus = await PermissionHandler.permissionsGranted;
      print(permissionStatus);
      if (permissionStatus == false) {
        displayAlertDialog(context);
      }
      permissionStatus = await PermissionHandler.permissionsGranted;
      print(permissionStatus);
    } catch (err) {
      print(err);
    }

    setState(() {
      _permissionStatus =
      permissionStatus! ? "Permissions Enabled" : "Permissions not granted";
    });
    print(_permissionStatus);
  }
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


  //loading the saved settings
  void loadSaved() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      mainButtonPressed = (prefs.getBool('is_safe_driving') ??
          false); //if no value is there in counter then we assign 0 to the counter
    });
  }

  @override
  void initState() {
    super.initState();
    loadSaved();
    getPermissionStatus();
  }

  //saving settings set by the user
  void saveSafeDrivingMode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.setBool('is_safe_driving', mainButtonPressed);
    });
  }

  int page_index = 0;
  final pages = [AutoReply()];

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

  Widget _homePage(BuildContext context) {
    return ListView(
      children: [
        Center(
          child: Text(
            "SafeDriving:" + (mainButtonPressed ? "On" : "Off"),
            style: TextStyle(
                fontSize: 35, color: Colors.black, fontWeight: FontWeight.bold),
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
                }                )


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
            page_index == 0 ? _homePage(context) : pages[page_index - 1]));
  }
}

displayAlertDialog(BuildContext context) {
  Widget okButton = TextButton(
    child: Text("OK"),
    onPressed: () {
      PermissionHandler.openDoNotDisturbSetting();
      Navigator.pop(context);},
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text("Permission Access"),
    content: Text("In order to use our application you will need to grant access to notification."),
    actions: [
      okButton,
    ],
  );

  // show the dialog
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    },
  );
}