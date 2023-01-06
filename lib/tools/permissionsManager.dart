import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:sound_mode/permission_handler.dart';
import 'package:app_settings/app_settings.dart';

void contact_permission() async {
  Permission contac_perm = await Permission.contacts;
  var cntct_permission = await contac_perm.request();
}

void sms_permission() async {
  Permission message_perm = await Permission.sms;
  var msg_permission = await message_perm.request();
}

AskDoNotDisturbPermission(BuildContext context) {
  Widget okButton = TextButton(
    child: Text("OK"),
    onPressed: () {
      PermissionHandler
          .openDoNotDisturbSetting(); //this is from the sound_mode library
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

//for putting the phone on silent | need to get do not disturb permission for android 7.0 and above
void getDoNotDisturbPermission(context) async {
  bool? permissionStatus = false;
  try {
    permissionStatus = await PermissionHandler.permissionsGranted;

    print("D0 not disturb:" + permissionStatus.toString());
    if (permissionStatus == false) {
      AskDoNotDisturbPermission(context);

      //permission for sms is not invoked here because for some reason asks  automatically
    }
    permissionStatus = await PermissionHandler.permissionsGranted;
    print(permissionStatus);
    // AskContactPermission(context);
  } catch (err) {
    print(err);
  }

  // setState(() {
  //   _permissionStatus =
  //   permissionStatus! ? "Permissions Enabled" : "Permissions not granted";
  // });
  // print(_permissionStatus);
}

NotifyPermissionsNotGranted(context) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
        content: Text(
          'Permissions not granted',
          style: TextStyle(color: Colors.redAccent),
        ),
        action: SnackBarAction(
            label: 'Settings', onPressed: AppSettings.openAppSettings)),
  );
}
