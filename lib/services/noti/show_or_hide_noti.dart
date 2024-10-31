import 'package:flutter/foundation.dart';

String _chatingWith = '';

class ShowOrHideNoti {
  // Use private variable with a clear type

  // Setter method to update `_chatingWith` field
  void setChatingWith(String chatWith) {
    debugPrint('Setting chating with: $chatWith');
    _chatingWith = chatWith;
  }

  // Getter method to access the current `chatingWith` value
  String get chatingWith => _chatingWith;

  // Method to decide whether to show or hide a notification based on `messageFrom`
  bool showOrHideNoti(String messageFrom) {
    debugPrint('Currently chating with: $_chatingWith');
    if (_chatingWith == messageFrom) {
      debugPrint('Hide notification');
      return true;
    } else {
      debugPrint('Show notification');
      return false;
    }
  }

  // Reset method to clear the `chatingWith` value
  void resetChatting() {
    _chatingWith = '';
    debugPrint('Reset chatingWith to an empty string');
  }
}
