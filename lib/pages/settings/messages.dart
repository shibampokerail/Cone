import 'package:flutter/material.dart';
import 'dart:io';
import 'package:telephony/telephony.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';

const taskName = "replyIncomingMessages";

Future<void> replyIncomingMessages() async {
  print("I got visual!!");
  return;
  String sms = "";
  final Telephony telephony = Telephony.instance;

  SharedPreferences prefs = await SharedPreferences.getInstance();
  // List<SmsConversation> messages = await telephony.getConversations(
  // );
  // print(messages.length);
  // print(messages[0]);
  // print(messages[1].snippet);
  // print(messages[2].snippet);
  // print(messages[3].snippet);
  List<SmsMessage> messages =
      await telephony.getInboxSms(columns: [SmsColumn.ADDRESS, SmsColumn.BODY]);
  print(messages.length); // if length increases then

  int no_of_messages = prefs.getInt("no_of_messages") ?? 0;

  if (no_of_messages == 0) {
    prefs.setInt("no_of_messages", messages.length);
  }

  print(messages[0].address.toString()); //get the contact number and
  //check if the autoreply is on and safe driving mode is on

  int is_auto_reply_on = (prefs.getInt('is_saved_auto') ?? 0);
  bool is_safe_driving_mode_on = (prefs.getBool('is_safe_driving') ?? false);
  print("auto reply on:");
  print((prefs.getInt('is_saved_auto') ?? 0));

  no_of_messages = prefs.getInt("no_of_messages") ?? 0;
  print("no_of_messages: $no_of_messages");
  print("message.length:" + messages.length.toString());

  if (no_of_messages < messages.length) {
    if ((is_auto_reply_on == 1) && (is_safe_driving_mode_on)) {
      telephony.sendSms(
          to: messages[0].address.toString(),
          message: (prefs.getString(
                  'saved_text') ?? //if no value is there in saved text then we assign default auto reply message to the counter
              "I am currently driving right now. I will get back to you later."));
    }
  }
  prefs.setInt("no_of_messages", messages.length);
}

backgroundMessageHandler(SmsMessage message) async {
    final Telephony telephony = Telephony.instance;
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String phone_number =  message.address.toString();
    int is_auto_reply_on = (prefs.getInt('is_saved_auto') ?? 0);
    bool is_safe_driving_mode_on = (prefs.getBool('is_safe_driving') ?? false);
    if ((is_auto_reply_on == 1) && (is_safe_driving_mode_on)) {
      telephony.sendSms(
          to: phone_number,
          message: (prefs.getString(
              'saved_text') ?? //if no value is there in saved text then we assign default auto reply message to the counter
              "I am currently driving right now. I will get back to you later."));
    }
    print(phone_number);
}


// void callbackDispatcher() async {
//   Workmanager().executeTask((task, inputData) async {
//     switch (task) {
//       case "replyIncomingMessages":
//         replyIncomingMessages();
//     }
//     return Future.value(true);
//   });
// }

// void initBackgroundTask() async {
//   //try puting it in the initstate function
//   WidgetsFlutterBinding.ensureInitialized();
//   await Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
// }

// void runInBackground() async {
//   await Workmanager().registerPeriodicTask(
//       DateTime.now().second.toString(), taskName,frequency: Duration(minutes: 1));
//        //put battery constraints later
// }

class Messages extends StatefulWidget {
  const Messages({Key? key}) : super(key: key);

  @override
  State<Messages> createState() => _MessagesState();
}

class _MessagesState extends State<Messages> {
  String phone_number = "";
  final Telephony telephony = Telephony.instance;
  @override
  void initState() {
    super.initState();
    //for background process
    final inbox=telephony.getInboxSms();

  }

  @override
  Widget build(BuildContext context) {


    return ListView(
      children: [
        Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              "",
              style: TextStyle(
                  fontSize: 35,
                  color: Colors.black,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),TextButton(
          child: Text("Run background message reply!"),
          onPressed: () async {
            SharedPreferences prefs = await SharedPreferences.getInstance();


              telephony.listenIncomingSms(onNewMessage:(SmsMessage message){
                phone_number =  message.address.toString();
                int is_auto_reply_on = (prefs.getInt('is_saved_auto') ?? 0);
                bool is_safe_driving_mode_on = (prefs.getBool('is_safe_driving') ?? false);
                if ((is_auto_reply_on == 1) && (is_safe_driving_mode_on)) {
                  telephony.sendSms(
                      to: phone_number,
                      message: (prefs.getString(
                          'saved_text') ?? //if no value is there in saved text then we assign default auto reply message to the counter
                          "I am currently driving right now. I will get back to you later."));
                }
                print(phone_number);
              }, onBackgroundMessage:backgroundMessageHandler
              );

          },
        )
      ],
    );
  }
}
