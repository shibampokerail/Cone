import 'dart:core';
import 'package:flutter/src/services/message_codec.dart'; //for PlatFormException
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sound_mode/sound_mode.dart';
import 'package:sound_mode/utils/ringer_mode_statuses.dart';

class AutoReply {
  Future<bool> is_turned_on() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int _is_saved_auto = (prefs.getInt('is_saved_auto') ?? 0);
    if (_is_saved_auto == 1) {
      return true;
    } else {
      return false;
    }
  }

  void turn_on() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('is_saved_auto', 1);
  }

  void turn_off() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('is_saved_auto', 0);
  }
}

class SafeDriving {
  //changes the sound mode of the phone to do not disturb when normal and vice versa
  void _changeSoundMode() async {
    //https://pub.dev/packages/sound_mode >> ios usage
    //for ios implementation

    RingerModeStatus status;
    try {
      status = await SoundMode.setSoundMode(await SafeDriving().is_turned_on()
          ? RingerModeStatus.silent
          : RingerModeStatus.normal);
    } on PlatformException {
      print('Do Not Disturb access permissions required!');
    }
  }

  Future<bool> is_turned_on() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool _is_safe_driving_on = (prefs.getBool('is_safe_driving') ?? false);
    print("Safe Driving is " + (_is_safe_driving_on ? "On" : "Off"));
    return _is_safe_driving_on;
  }

  void turn_on() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    SafeDriving()._changeSoundMode();
    prefs.setBool('is_safe_driving', true);
  }

  void turn_off() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    SafeDriving()._changeSoundMode();
    prefs.setBool('is_safe_driving', false);
  }
}
