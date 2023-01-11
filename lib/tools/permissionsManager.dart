import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';
import 'package:sound_mode/permission_handler.dart';
import 'package:app_settings/app_settings.dart';
import 'package:geolocator/geolocator.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

void request_contact_permission() async {
  await Permission.contacts.request();
}

void request_sms_permission() async {
  await Permission.sms.request();
}

void request_gps_permission() async {
  await Geolocator.requestPermission();
}

void request_notification_permission() async {
  AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
    if (!isAllowed) {
      // This is just a basic example. For real apps, you must show some
      // friendly dialog box before call the request method.
      // This is very important to not harm the user experience
      AwesomeNotifications().requestPermissionToSendNotifications();
    }
  });
}

//only for android
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
