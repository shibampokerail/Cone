import 'package:flutter/material.dart';
import 'package:new_app/pages/settings/autoReply.dart';
import 'package:new_app/pages/home/index.dart';

//
// class AppDrawer extends StatelessWidget {
//
//   Widget _buildAppDrawer(BuildContext context) {
//     return ListView(
//       padding: EdgeInsets.zero,
//       children: [
//         const DrawerHeader(
//           decoration: BoxDecoration(
//             color: Colors.orange,
//           ),
//           child:Text('Settings',style: TextStyle(fontSize: 30, color: Colors.white),),
//         ),
//         ListTile(title:const Text("Auto-reply",style: TextStyle(fontSize: 20)), onTap: () {Navigator.push(
//             context,
//             MaterialPageRoute(builder: (context) => const AutoReply()));}),
//         ListTile(title:const Text("About",style: TextStyle(fontSize: 20)), onTap: () {}),
//         ListTile(title:const Text("Back",style: TextStyle(fontSize: 20)), onTap: () {Navigator.pop(context);})
//       ],
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     // TODO: implement build
//     return _buildAppDrawer(context);
//   }
//
//
// }