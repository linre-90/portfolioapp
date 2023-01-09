library manager;

import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:portfolioapp/models/contact.dart';

/// Web manager creates http connection and provides methods to interact
/// with api.
class WebManager {
  final String _baseUrl = "https://jlind.xyz/contact/api/v1";

  /// Pings api to check if we have valid sessionid
  /// TODO: create protected ping endpoint to backend to reduce data usage
  Future<bool> pingApi(String? sessionid) async {
    // If sessionid is null we cannot be never authenticated.
    if (sessionid == null || sessionid == "null") {
      return false;
    }

    // send query to backend. If content type is text/html instead
    // of application/json we are not authenticated and require login.
    var response =
        await http.get(Uri.parse(_baseUrl), headers: {"Cookie": sessionid});
    String? contentType = response.headers["content-type"];

    if (contentType == null || contentType == "text/html;charset=UTF-8") {
      return false;
    }

    // We probably are authenticated... maybe... maybe it's Maybelline...
    return true;
  }

  /// Login to api with password and username.
  Future<String?> logIn(String username, String password) async {
    var response = await http.post(Uri.parse("https://jlind.xyz/login"),
        body: {"username": username, "password": password});

    // Check that address does not contain login?error statement.
    String? location = response.headers["location"];
    if (location != null && location.contains("login?error")) {
      return null;
    }
    // get session id from headers.
    // NOTE: this may fail in some point if there are other cookies set
    String? jsessionid = response.headers["set-cookie"];
    if (jsessionid != null) {
      List<String> parts = jsessionid.split(";");
      return parts[0];
    }
    return null;
  }

  /// Get all entries from portfolio api.
  Future<List<Contact>> getAll(String sessionid) async {
    var response =
        await http.get(Uri.parse(_baseUrl), headers: {"Cookie": sessionid});
    final List parsedList = json.decode(response.body);
    List<Contact> allContacts =
        parsedList.map((e) => Contact.fromJson(e)).toList();
    return allContacts;
  }

  /// Log user out
  Future<int> logOut(String sessionID) async {
    var response = await http.post(Uri.parse("https://jlind.xyz/logout"),
        headers: {"Cookie": sessionID}, body: {"value": "Sign out"});
    return response.statusCode;
  }

  /// Mark contact as read. Returns updated contact.
  Future<Contact> markAsRead(String sessionID, int contactID) async {
    var response = await http
        .put(Uri.parse("$_baseUrl/$contactID"), headers: {"Cookie": sessionID});
    return Contact.fromJson(json.decode(response.body));
  }

  /// Delete entry from database.
  Future<Contact> deleteById(String sessionID, Contact contact) async {
    await http.delete(Uri.parse("$_baseUrl/${contact.id}"),
        headers: {"Cookie": sessionID});
    return contact;
  }
}
