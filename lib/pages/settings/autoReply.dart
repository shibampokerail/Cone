import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:app_settings/app_settings.dart';
import 'package:new_app/tools/permissionsManager.dart';
import 'package:new_app/tools/AndroidSmsManager.dart';

class AutoReplyPage extends StatefulWidget {
  const AutoReplyPage({Key? key}) : super(key: key);

  @override
  State<AutoReplyPage> createState() => _AutoReplyState();
}

class _AutoReplyState extends State<AutoReplyPage> {
  int _is_saved_auto = 0;
  bool is_safe_driving_mode_on = false;
  String reply_text = "";
  String user_input_text = "";
  final msgController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadSaved();
    loadSavedText();
  }

  void loadSaved() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    is_safe_driving_mode_on = (prefs.getBool('is_safe_driving') ?? false);

    if (!is_safe_driving_mode_on) {
      //if safe driving mode is on
      prefs.setInt('is_saved_auto', 0);
    }

    setState(() {
      _is_saved_auto = (prefs.getInt('is_saved_auto') ??
          0); //if no value is there then we assign 0
    });
  }

  void loadSavedText() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      user_input_text = (prefs.getString(
              'saved_text') ?? //if no value is there in saved text then we assign default auto reply message to the counter
          "I am currently driving right now. I will get back to you later.");
    });
  }

  //save whether auto reply is on 0 means off 1 is on
  void saveAuto() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    Map<Permission, PermissionStatus> statuses = await [
      Permission.sms,
      Permission.contacts,
      //add more permission to request here.
    ].request();

    setState(() {
      bool is_safe_driving = (prefs.getBool('is_safe_driving') ?? false);

      if (!is_safe_driving) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'SafeDriving mode off',
              style: TextStyle(color: Colors.redAccent),
            ),
          ),
        );
        return;
      }

      _is_saved_auto = (prefs.getInt('is_saved_auto') ?? 0);
      if (statuses[Permission.sms] == PermissionStatus.granted &&
          statuses[Permission.contacts] == PermissionStatus.granted) {
        if (_is_saved_auto == 1) {
          _is_saved_auto = 0;
          prefs.setInt('is_saved_auto', 0);
        } else {
          _is_saved_auto = 1;
          prefs.setInt('is_saved_auto', 1);
        }
      } else {
        //if permissions are denied then reset the permissions
        prefs.setInt('is_saved_auto', 0);
        _is_saved_auto = 0;
      }
    });
  }

  void saveText() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      prefs.setString('saved_text', reply_text);
    });
  }

  bool is_auto = false;

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text(
                "Auto Reply",
                style: TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                    fontWeight: FontWeight.normal),
              ),
              Switch(
                  value: _is_saved_auto == 0 ? false : true,
                  activeColor: Colors.green,
                  // after countless hours of scouring pub.dev and stackoverflow
                  // i was finally able to request two permissions in a row in android
                  onChanged: (value) async {


                    Map<Permission, PermissionStatus> statuses = await [
                      Permission.sms,
                      Permission.contacts,
                      //add more permission to request here.
                    ].request();
                    //if any of the permissions are denied then the auto-reply feature will not turn on
                    if (statuses[Permission.sms] == PermissionStatus.granted &&
                        statuses[Permission.contacts] ==
                            PermissionStatus.granted) {
                      //do nothing
                    } else {
                      Map<Permission, PermissionStatus> statuses = await [
                        Permission.sms,
                        Permission.contacts,
                        //add more permission to request here.
                      ].request();
                    }

                    setState(() {
                      if ((statuses[Permission.sms] ==
                              PermissionStatus.granted) &&
                          (statuses[Permission.contacts] ==
                              PermissionStatus.granted)) {
                        if (is_safe_driving_mode_on) {
                          _is_saved_auto = _is_saved_auto == 0 ? 1 : 0;
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'SafeDriving mode off',
                                style: TextStyle(color: Colors.redAccent),
                              ),
                            ),
                          );
                          return;
                        }
                      } else {
                       NotifyPermissionsNotGranted(context);
                      }
                    });
                    // contact and sms permissions requested in the section above
                    saveAuto();
                  })
            ]),
            Text(
              "This feature will send automated messages to any incoming SMS when SafeDriving mode is on.",
              style: TextStyle(
                fontSize: 12,
                color: Colors.orange,
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Form(
                key: _formKey,
                child: Column(children: [
                  Visibility(
                      visible: _is_saved_auto == 0 ? false : true,
                      child: TextFormField(
                        enabled: _is_saved_auto == 0 ? false : true,
                        keyboardType: TextInputType.multiline,
                        minLines: 4,
                        maxLines: 4,
                        maxLength: 100,
                        decoration: InputDecoration(
                          labelText: "Custom Message",
                          hintText: "Current auto reply : " + user_input_text,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(25.0),
                          ),
                        ),
                        controller: msgController,
                        onChanged: (String value) {
                          setState(() {
                            reply_text = Text(msgController.text).toString();
                          });
                        },
                        validator: (value) {
                          if (value == null ||
                              value.isEmpty ||
                              value.length < 8) {
                            return 'Please enter at least 8 characters';
                          }
                          return null;
                        },
                      )),
                  SizedBox(
                    height: 30,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: MaterialButton(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50)),
                      minWidth: double.infinity,
                      onPressed: !(_is_saved_auto == 0 ? false : true)
                          ? null
                          : () {
                              // Validate returns true if the form is valid, or false otherwise.
                              if (_formKey.currentState!.validate()) {
                                // If the form is valid, display a snackbar. In the real world,
                                // you'd often call a server or save the information in a database.
                                reply_text = msgController.text.toString();
                                saveText();

                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text('New custom message set!')),
                                );
                              }
                            },
                      child: Text(
                        "Confirm",
                      ),
                      color: Colors.orange,
                      textColor: Colors.white,
                    ),
                  )
                ]))
          ],
        ));
  }
}
