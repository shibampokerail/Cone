import 'package:flutter/material.dart';
import 'package:new_app/tools/featuresHandler.dart';
import 'package:awesome_notifications/awesome_notifications.dart';


//builds the homepage that displays the driving mode
class Homepage extends StatefulWidget {
  const Homepage({Key? key}) : super(key: key);

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  bool mainButtonPressed=false;

  @override
  void initState(){
    super.initState();
    loadSaved();
    AwesomeNotifications().dismiss(1);
    setState(() {});

  }
  void loadSaved()async {
    bool is_button_pressed =  await SafeDriving().is_running();
    setState(){
      mainButtonPressed = is_button_pressed;
    }

  }
  @override
  Widget build(BuildContext context) {
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
}
