import 'package:flutter/material.dart';
import 'package:new_app/pages/home/appDrawer.dart';
import 'package:new_app/pages/settings/autoReply.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool mainButtonPressed = false; //change this later for background process
  String mode = "Off";
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
            })
            ,
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

  Widget _renderHome(BuildContext context) {
    return ListView(
      children: [
        Center(
          child: Text(
            "SafeDriving:" + mode,
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
                  if (mode == "Off") {
                    mode = "On";
                  } else {
                    mode = "Off";
                  }
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
                ? _renderHome(context)
                : pages[page_index - 1]));
  }
}
