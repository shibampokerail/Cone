import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';
import 'package:new_app/tools/featuresHandler.dart';



void initialize_all_notifications(){
  AwesomeNotifications().initialize(
    // set the icon to null if you want to use the default app icon
      null,
      [
        NotificationChannel(
            channelGroupKey: 'basic_channel_group',
            channelKey: 'basic_channel',
            channelName: 'Basic notifications',
            channelDescription: 'Notification channel for all stuffs',
            defaultColor: Color(0xFF9D50DD),
            ledColor: Colors.white)
      ],

      debug: true
  );
}

class SafeDrivingNotificationController {
  void initialize_listeners(){
    AwesomeNotifications().setListeners(
        onActionReceivedMethod:         SafeDrivingNotificationController.onActionReceivedMethod,
        onNotificationCreatedMethod:    SafeDrivingNotificationController.onNotificationCreatedMethod,
        onNotificationDisplayedMethod:  SafeDrivingNotificationController.onNotificationDisplayedMethod,
        onDismissActionReceivedMethod:  SafeDrivingNotificationController.onDismissActionReceivedMethod
    );
  }

  /// Use this method to detect when a new notification or a schedule is created
  @pragma("vm:entry-point")
  static Future <void> onNotificationCreatedMethod(ReceivedNotification receivedNotification) async {
    // Your code goes here
    null;
  }

  /// Use this method to detect every time that a new notification is displayed
  @pragma("vm:entry-point")
  static Future <void> onNotificationDisplayedMethod(ReceivedNotification receivedNotification) async {
    // Your code goes here
    null;
  }

  /// Use this method to detect if the user dismissed a notification
  @pragma("vm:entry-point")
  static Future <void> onDismissActionReceivedMethod(ReceivedAction receivedAction) async {
    // Your code goes here
    null;
  }

  /// Use this method to detect when the user taps on a notification or action button
  @pragma("vm:entry-point")
  static Future <void> onActionReceivedMethod(ReceivedAction receivedAction) async {
    // Your code goes here

    // Navigate into pages, avoiding to open the notification details page over another details page already opened
    if (await SafeDriving().is_running()){
      SafeDriving().turn_off();
    } else {
      SafeDriving().turn_on();
    }

  }
}