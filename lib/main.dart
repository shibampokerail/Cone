import 'package:flutter/material.dart';
import '/pages/route_manager.dart';
import 'package:new_app/tools/notificationsManager.dart';


void main() async{
  initialize_all_notifications();
  WidgetsFlutterBinding.ensureInitialized();
  runApp(RouteManager());
}

