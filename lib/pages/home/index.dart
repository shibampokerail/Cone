//packages
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:new_app/main.dart';
import 'package:telephony/telephony.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

//extension
import 'package:new_app/pages/settings/autoReply.dart';
import 'package:new_app/pages/settings/drivingdetectortest.dart';
import 'package:new_app/tools/featuresHandler.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int page_index = 0;
  final pages = [AutoReplyPage(),detectDriving()];

  final Telephony telephony = Telephony.instance;
  bool mainButtonPressed = false;

  @override
  void initState() {
    super.initState();
    loadSaved();
    SafeDriving().permission(context);
    AutoReply().runIncomingSmsHandler(telephony);
    AwesomeNotifications().dismiss(1);

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
            title: const Text("Detect Driving", style: TextStyle(fontSize: 20)),
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
            visible: page_index == 0 ? true : false,
            //the main button is visible only in the homepage
            child: FloatingActionButton.large(

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
            ? detectDriving()
                // ? buildHomePage(context)
                : pages[page_index - 1]));
  }
}
