import 'package:shared_preferences/shared_preferences.dart';

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

  }
}

class Safedriving {
  Future<bool> is_turned_on() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool _is_safe_driving_on = (prefs.getBool('is_safe_driving') ?? false);
    if (_is_safe_driving_on) {
      return true;
    } else {
      return false;
    }
  }
   void turn_on() async {

   }
}
