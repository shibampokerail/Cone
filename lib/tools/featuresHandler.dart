import 'package:shared_preferences/shared_preferences.dart';

class AutoReply{
  Future<bool> is_running() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int _is_saved_auto = (prefs.getInt('is_saved_auto') ??
          0);
    if (_is_saved_auto==1){
    return true;
      } else {
      return false;
    }
  }
}

