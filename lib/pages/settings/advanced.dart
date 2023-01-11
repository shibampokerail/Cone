import 'package:flutter/material.dart';
import 'package:new_app/custom_widgets/notifiers.dart';
import 'package:new_app/tools/featuresHandler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdvancedSettings extends StatefulWidget {
  const AdvancedSettings({Key? key}) : super(key: key);

  @override
  State<AdvancedSettings> createState() => _AdvancedSettingsState();
}

class _AdvancedSettingsState extends State<AdvancedSettings> {
  bool automatic = false;

  loadSaved() async {
    bool is_automatic = await SafeDriving().is_automatic();
    setState(() {
      automatic = is_automatic;
    });
  }
  @override
  void initState(){
    super.initState();
    loadSaved();
  }
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: ListView(padding: EdgeInsets.zero, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(
            "Automatic SafeDriving Mode",
            style: TextStyle(
                fontSize: 20,
                color: Colors.black,
                fontWeight: FontWeight.normal),
          ),
          Switch(
              value: automatic,
              activeColor: Colors.green,
              // after countless hours of scouring pub.dev and stackoverflow
              // i was finally able to request two permissions in a row in android
              // i don't know how and i don't want to get into it now
              onChanged: (value) async {
                if (value) {
                  alertDialogBox(context, "Auto SafeDriving",
                      "Only rely on this feature on if you always drive. Anytime you are in a vehicle, Savedriving mode will turn on and your messages may get forwarded.");
                  SafeDriving().turn_on_automatic();
                } else {
                  SafeDriving().turn_off_automatic();
                }
                setState(() {
                  automatic = !automatic;
                });
              }),
        ]),
        Text(
          "This feature will turn on  and off safedriving mode anytime you are in a moving vehicle.",
          style: TextStyle(
            fontSize: 12,
            color: Colors.orange,
          ),
        ),
        SizedBox(
          height: 15,
        ),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Text(
            "Notifications",
            style: TextStyle(
                fontSize: 20,
                color: Colors.black,
                fontWeight: FontWeight.normal),
          ),
          Switch(
              value: 0 == 0 ? false : true,
              activeColor: Colors.green,
              // after countless hours of scouring pub.dev and stackoverflow
              // i was finally able to request two permissions in a row in android
              // i don't know how and i don't want to get into it now
              onChanged: (value) async {
                alertDialogBox(context, "Turn on Auto SafeDriving?",
                    "Only turn this feature on if you drive regularly. Anytime you are in a vehicle, Savedriving mode will turn on and your messages may get forwarded.");
                setState(() {});
              }),
        ]),
      ]),
    );
  }
}
