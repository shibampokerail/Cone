import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sound_mode/permission_handler.dart';

AskDoNotDisturbPermission(BuildContext context) {

  Widget okButton = TextButton(
    child: Text("OK"),
    onPressed: () {

      PermissionHandler.openDoNotDisturbSetting();
      Navigator.pop(context);
    },
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    title: Text("Permission Access"),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
    content: Text(
        "In order to use our application you will need to grant access to Do not disturb."),
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