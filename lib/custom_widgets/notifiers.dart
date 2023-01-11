import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sound_mode/permission_handler.dart';
import 'package:flutter/src/material/colors.dart';
import 'package:awesome_notifications/awesome_notifications.dart';


alertDialogBox(BuildContext context, String title, String description) {
  Widget okButton = TextButton(
    child: Text("OK"),
    onPressed: () {},
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text(title),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
    content: Text(description),
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

showSnackBar(context, String description,
    {String button_text = "", bool button = false, Color color = Colors.white}) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(
      description,
      style: TextStyle(color: color),
    ),
    action: SnackBarAction(label: button_text, onPressed: () {}),
  ));
}

createNotification(String title, String description, {int id=1, channel_key="basic_channel", action_type = ActionType.Default}){
  AwesomeNotifications().createNotification(
    content: NotificationContent(
      id: id,
      channelKey: channel_key,
      title: title,
      body: description,
      actionType: ActionType.Default,
    ),
  );
}