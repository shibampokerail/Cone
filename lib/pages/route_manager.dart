import 'package:flutter/material.dart';
import 'package:new_app/pages/home/index.dart';
import 'package:new_app/pages/settings/autoReply.dart';

class RouteManager extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        initialRoute: "/",
        routes: {
          "/": (context) => Home(),
          "/AutoReply": (context) => AutoReply()
        });
  }
}
