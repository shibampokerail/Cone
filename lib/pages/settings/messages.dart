import 'package:flutter/material.dart';
import 'package:telephony/telephony.dart';

class Messages extends StatefulWidget {
  const Messages({Key? key}) : super(key: key);

  @override
  State<Messages> createState() => _MessagesState();
}

class _MessagesState extends State<Messages> {

  String sms = "";
  final Telephony telephony = Telephony.instance;

  Future<void> read_sms() async{
    // List<SmsConversation> messages = await telephony.getConversations(
    // );
    // print(messages.length);
    // print(messages[0]);
    // print(messages[1].snippet);
    // print(messages[2].snippet);
    // print(messages[3].snippet);
    List<SmsMessage> messages = await telephony.getInboxSms(columns: [SmsColumn.ADDRESS, SmsColumn.BODY]
    );
    print(messages[0].address.toString());
    print(messages[1].address.toString());
    print(messages[2].address.toString());
    print(messages[3].address.toString());
  }

  @override
  void initState() {
    read_sms();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(children: [
      Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(sms,
            style: TextStyle(
                fontSize: 35, color: Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    ],
    );
  }
}


