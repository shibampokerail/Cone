import 'package:sound_mode/sound_mode.dart';
import 'package:sound_mode/utils/ringer_mode_statuses.dart';
import 'package:flutter/src/services/message_codec.dart'; //for PlatFormException

class Device{
  sound_mode() async {
    RingerModeStatus status;
    status = await SoundMode.ringerModeStatus;
    return status;
  }
}
