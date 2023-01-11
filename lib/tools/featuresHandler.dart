import 'dart:core';
import 'package:flutter/src/services/message_codec.dart'; //for PlatFormException
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sound_mode/sound_mode.dart';
import 'package:sound_mode/utils/ringer_mode_statuses.dart';
import 'package:new_app/tools/permissionsManager.dart';
import 'package:new_app/tools/AndroidSmsManager.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:new_app/custom_widgets/notifiers.dart';



class AutoReply {
  //returns true if autoreply is turned on
  Future<bool> is_running() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int _is_saved_auto = (prefs.getInt('is_saved_auto') ?? 0);
    if (_is_saved_auto == 1) {
      return true;
    } else {
      return false;
    }
  }
  void runIncomingSmsHandler(telephony) async {
    bool features_are_running = (await SafeDriving().is_running()) &&
        (await AutoReply().is_running());
    features_are_running
        ? foregroundMessageHandler(telephony, debug: true)
        : null;
  }
  //
  void turn_on() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('is_saved_auto', 1);

  }

  void turn_off() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('is_saved_auto', 0);
  }

  Future<String> get_saved_reply() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String saved_text = (prefs.getString(
          'saved_text') ?? //if no value is there in saved text then we assign default auto reply message to the counter
          "I am currently driving right now. I will get back to you later.");
    return saved_text;
  }


}

class SafeDriving {
  //changes the sound mode of the phone to do not disturb when normal and vice versa
  //https://pub.dev/packages/sound_mode >> ios usage
  //for ios implementation
  void _changeSoundMode() async {
    RingerModeStatus status;
    try {
      status = await SoundMode.setSoundMode(await SafeDriving().is_running()
          ? RingerModeStatus.silent
          : RingerModeStatus.normal);
    } on PlatformException {
      print('Do Not Disturb access permissions required!');
    }
  }

  Future<bool> is_running() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool _is_safe_driving_on = (prefs.getBool('is_safe_driving') ?? false);
    print("Safe Driving is " + (_is_safe_driving_on ? "On" : "Off"));
    return _is_safe_driving_on;
  }

  void turn_on() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    SafeDriving()._changeSoundMode();
    createNotification('SafeDriving Mode Is on', 'Tap this to turn off SafeDriving mode.');
    prefs.setBool('is_safe_driving', true);
  }

  void turn_off() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    AwesomeNotifications().dismiss(1);
    SafeDriving()._changeSoundMode();
    prefs.setBool('is_safe_driving', false);
  }

  void permission(context) {
    getDoNotDisturbPermission(context);
  }
}
