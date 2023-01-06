import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sound_mode/permission_handler.dart';
import 'package:flutter/src/material/colors.dart';

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

showSnackBar(context, String description, String button_text, {Color col= Colors.white}) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(
      description,
      style: TextStyle(color: col),
    ),
    action: SnackBarAction(label: button_text, onPressed: () {}),
  ));
}
