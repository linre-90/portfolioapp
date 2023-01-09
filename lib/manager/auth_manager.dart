library manager;

import 'package:flutter/cupertino.dart';
import 'package:portfolioapp/manager/web_manager.dart';

/// Authentication manager who store sessionid until user logs out.
/// NOTE: does not receive any information if session gets old...
class AuthManager extends ChangeNotifier {
  String? jsessionid;

  /// Set session id state
  void setJSessionID(String sessionID) {
    jsessionid = sessionID;
    notifyListeners();
  }

  /// Return session id as string or String "null".
  String getSessionIDAsString() {
    if (jsessionid == null) {
      return "null";
    } else {
      return jsessionid.toString();
    }
  }

  /// Log user out.
  Future<void> logOut() async {
    if (jsessionid != null && jsessionid != "null") {
      int code = await WebManager().logOut(getSessionIDAsString());
      jsessionid = "null";
      notifyListeners();
    }
  }
}
