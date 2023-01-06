import 'dart:io';

//packages
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:telephony/telephony.dart';

//extension
import 'package:new_app/pages/settings/autoReply.dart';
import 'package:new_app/tools/permissionsManager.dart';
import 'package:new_app/tools/AndroidSmsManager.dart';
import 'package:new_app/tools/featuresHandler.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int page_index = 0;
  final pages = [AutoReplyPage()];

  final Telephony telephony = Telephony.instance;
  bool mainButtonPressed = false;

  @override
  void initState() {
    super.initState();
    loadSaved();
    getDoNotDisturbPermission(context);
    RunAutoReply();
  }

  void RunAutoReply() async {
    bool features_are_running = (await SafeDriving().is_turned_on()) &&
        (await AutoReply().is_turned_on());
    features_are_running
        ? foregroundMessageHandler(telephony, true, debug: true)
        : null;
  }

  //loading the saved settings for safe-driving
  void loadSaved() async {
    bool saved_setting = await SafeDriving().is_turned_on();
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
            visible: page_index == 0 ? true : false,
            //the main button is visible only in the homepage
            child: FloatingActionButton.large(
              //<-- SEE HERE
              backgroundColor:
                  mainButtonPressed ? Colors.lightGreen : Colors.red,
              onPressed: () => {
                setState(() {
                  mainButtonPressed = !mainButtonPressed;
                  mainButtonPressed
                      ? SafeDriving().turn_on()
                      : SafeDriving().turn_off();

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
