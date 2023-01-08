import 'package:flutter/material.dart';
import 'package:sound_mode/utils/ringer_mode_statuses.dart';
import 'package:telephony/telephony.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import 'package:new_app/tools/status.dart';
import 'package:new_app/tools/featuresHandler.dart';
const taskName = "replyIncomingMessages";

// Future<void> replyIncomingMessages() async {
//   print("I got visual!!");
//   return;
//   String sms = "";
//   final Telephony telephony = Telephony.instance;
//
//   SharedPreferences prefs = await SharedPreferences.getInstance();
//   // List<SmsConversation> messages = await telephony.getConversations(
//   // );
//   // print(messages.length);
//   // print(messages[0]);
//   // print(messages[1].snippet);
//   // print(messages[2].snippet);
//   // print(messages[3].snippet);
//   List<SmsMessage> messages =
//       await telephony.getInboxSms(columns: [SmsColumn.ADDRESS, SmsColumn.BODY]);
//   print(messages.length); // if length increases then
//
//   int no_of_messages = prefs.getInt("no_of_messages") ?? 0;
//
//   if (no_of_messages == 0) {
//     prefs.setInt("no_of_messages", messages.length);
//   }
//
//   print(messages[0].address.toString()); //get the contact number and
//   //check if the autoreply is on and safe driving mode is on
//
//   int is_auto_reply_on = (prefs.getInt('is_saved_auto') ?? 0);
//   bool is_safe_driving_mode_on = (prefs.getBool('is_safe_driving') ?? false);
//   print("auto reply on:");
//   print((prefs.getInt('is_saved_auto') ?? 0));
//
//   no_of_messages = prefs.getInt("no_of_messages") ?? 0;
//   print("no_of_messages: $no_of_messages");
//   print("message.length:" + messages.length.toString());
//
//   if (no_of_messages < messages.length) {
//     if ((is_auto_reply_on == 1) && (is_safe_driving_mode_on)) {
//       telephony.sendSms(
//           to: messages[0].address.toString(),
//           message: (prefs.getString(
//                   'saved_text') ?? //if no value is there in saved text then we assign default auto reply message to the counter
//               "I am currently driving right now. I will get back to you later."));
//     }
//   }
//   prefs.setInt("no_of_messages", messages.length);
// }


backgroundMessageHandler(SmsMessage message) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String phone_number =  message.address.toString();
    int is_auto_reply_on = (await AutoReply().is_running()) ? 1 : 0;
    bool is_safe_driving_mode_on = false;
    var sound_mode = await Device().sound_mode();
    if (sound_mode==RingerModeStatus.silent){
      is_safe_driving_mode_on = true;
    }
    print("autoreply:"+is_auto_reply_on.toString()+" Safedriving:"+is_safe_driving_mode_on.toString());

    if ((is_auto_reply_on == 1) && (is_safe_driving_mode_on)) {
      Telephony.backgroundInstance.sendSms(
          to: phone_number,
          message: (prefs.getString(
              'saved_text') ?? //if no value is there in saved text then we assign default auto reply message to the counter
              "I am currently driving right now. I will get back to you later."));
      print("replied to $phone_number");
    } else {
      print("did not reply to $phone_number");
    }

}

foregroundMessageHandler(telephony, {bool debug=false, bool runInBackground=true}) async {
  if (debug){
    print("foregroundMessageHandler is running");
    if (runInBackground){
      print("backgroundMessageHandler is running");
    }
  }
  SharedPreferences prefs = await SharedPreferences.getInstance();

  telephony.listenIncomingSms(onNewMessage:(SmsMessage message) async {
    String phone_number =  message.address.toString();
    String text=message.body.toString();
    Future<bool> is_auto_reply = AutoReply().is_running();
    Future<bool> is_safe_driving_mode = SafeDriving().is_running();
    bool is_safe_driving_mode_on = await is_safe_driving_mode;
    bool is_auto_reply_on =  await is_auto_reply;

    print(is_auto_reply_on.toString()+is_safe_driving_mode_on.toString());
    if ((is_auto_reply_on) && (is_safe_driving_mode_on)) {
      telephony.sendSms(
          to: phone_number,
          message: (prefs.getString(
              'saved_text') ?? //if no value is there in saved text then we assign default auto reply message to the counter
              "I am currently driving right now. I will get back to you later."));
      print("replied to text $text from:$phone_number");
    } else {
      print("received a text from $phone_number.");
    }

  },listenInBackground: runInBackground,
      onBackgroundMessage:backgroundMessageHandler
  );
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
//
// void runInBackground() async {
//   await Workmanager().registerPeriodicTask(
//       DateTime.now().second.toString(), taskName,frequency: Duration(minutes: 15));
//        //put battery constraints later
// }


//the widget below is returned for testing and debug purposes
class Messages extends StatefulWidget {
  const Messages({Key? key}) : super(key: key);

  @override
  State<Messages> createState() => _MessagesState();
}

class _MessagesState extends State<Messages> {

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
          child: Text("<Test>"),
          onPressed: () {
            //add debug function here
          },
        )
      ],
    );
  }
}
