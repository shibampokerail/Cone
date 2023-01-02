import 'package:flutter/material.dart';
import 'package:new_app/pages/settings/autoReply.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool mainButtonPressed = false; //change this later for background process

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
  }

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
              onPressed: () => {
                setState(() {
                  mainButtonPressed = !mainButtonPressed;
                  saveSafeDrivingMode();
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
                page_index == 0 ? _homePage(context) : pages[page_index - 1]));
  }
}
