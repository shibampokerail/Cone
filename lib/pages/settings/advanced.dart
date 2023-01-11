import 'package:flutter/material.dart';
import 'package:new_app/custom_widgets/notifiers.dart';
import 'package:shared_preferences/shared_preferences.dart';


class AdvancedSettings extends StatefulWidget {
  const AdvancedSettings({Key? key}) : super(key: key);

  @override
  State<AdvancedSettings> createState() => _AdvancedSettingsState();
}

class _AdvancedSettingsState extends State<AdvancedSettings> {
  void safeDrivingAutomatic() async {

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
                fontSize: 20, color: Colors.black, fontWeight: FontWeight.normal),
          ),
          Switch(
              value: 0 == 0 ? false : true,
              activeColor: Colors.green,
              // after countless hours of scouring pub.dev and stackoverflow
              // i was finally able to request two permissions in a row in android
              // i don't know how and i don't want to get into it now
              onChanged: (value) async {
                alertDialogBox(context,"Turn on Auto SafeDriving?", "Only turn this feature on if you drive regularly. Anytime you are in a vehicle, Savedriving mode will turn on and your messages may get forwarded.");
                setState(() {});
              }),
        ]), Text(
          "This feature will turn on safedriving mode anytime you are driving a vehicle.",
          style: TextStyle(
            fontSize: 12,
            color: Colors.orange,
          ),
        ),
      ]),
    );
  }
}
