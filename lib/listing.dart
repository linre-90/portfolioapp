import 'package:flutter/material.dart';
import 'package:portfolioapp/contact_widget.dart';
import 'package:portfolioapp/loading_widget.dart';
import 'package:portfolioapp/manager/auth_manager.dart';
import 'package:portfolioapp/manager/web_manager.dart';
import "package:portfolioapp/models/contact.dart";
import 'package:provider/provider.dart';

/// Renders all contacts found from backend api with widget ContactWidget.
class Listing extends StatefulWidget {
  const Listing({super.key});

  @override
  State<StatefulWidget> createState() => _Listing();
}

class _Listing extends State<Listing> {
  List<Contact>? _contacts;

  Future<bool> _onBackButtonPressed() async {
    await context.read<AuthManager>().logOut();
    return true;
  }

  /// Fetch all entries when pulled top to bottom
  Future<void> swipeUpdate() async {
    List<Contact> update = await WebManager()
        .getAll(context.read<AuthManager>().getSessionIDAsString());
    setContacts(update);
  }

  /// Update _contacts state.
  void setContacts(List<Contact> contacts) {
    setState(() {
      _contacts = contacts;
    });
  }

  /// Updates single contact and replaces old state completely.
  void updateSingleContact(Contact contact) {
    int? index = _contacts?.indexWhere((element) => element.id == contact.id);
    if (index != null) {
      List<Contact> temp = _contacts!;
      temp[index] = contact;
      setContacts(temp);
    }
  }

  /// Deletes single entry and replaces old state completely.
  void deleteSingleContact(Contact contact) {
    int? index = _contacts?.indexWhere((element) => element.id == contact.id);
    if (index != null) {
      List<Contact> temp = _contacts!;
      temp.removeAt(index);
      setContacts(temp);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => _onBackButtonPressed(),
      child: (FutureBuilder(
          future: WebManager()
              .getAll(context.read<AuthManager>().getSessionIDAsString()),
          builder: (ctx, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: RefreshIndicator(
                  onRefresh: () async {
                    return swipeUpdate();
                  },
                  child: ListView(children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0, 3, 0, 3),
                      child: Text(
                          "Last fetch: ${DateTime.now().toLocal().toString()}",
                          style: const TextStyle(
                              fontSize: 10, fontStyle: FontStyle.italic)),
                    ),
                    const Divider(),
                    ...snapshot.data!
                        .map((e) => ContactWidget(
                            e, updateSingleContact, deleteSingleContact))
                        .toList(),
                  ]),
                ),
              );
            }
            return const Spinner();
          })),
    );
  }
}
