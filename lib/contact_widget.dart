import 'package:flutter/material.dart';
import 'package:portfolioapp/manager/auth_manager.dart';
import 'package:portfolioapp/manager/web_manager.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'models/contact.dart';

/// Widget that renders single contact from api backend.<br><br>
/// "updateListing, deleteUpdate" are callback methods passed from parent
/// to trigger re-render.
class ContactWidget extends StatelessWidget {
  final Contact contact;
  final Function updateListing;
  final Function deleteUpdate;

  const ContactWidget(this.contact, this.updateListing, this.deleteUpdate,
      {super.key});

  /// Method to open email application
  Future<void> _launchUrl(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      throw 'Could not launch $url';
    }
  }

  /// Method to handle deleting contacts.
  void _handleDelete(String sessionID) async {
    Contact deleted = await WebManager().deleteById(sessionID, contact);
    deleteUpdate(deleted);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        showDialog(
            context: context,
            builder: (BuildContext context) {
              // AlertDialog confirms from user delete entry or not
              return AlertDialog(
                title: const Text("Confirm remove",
                    style: TextStyle(color: Colors.red)),
                content: Text(
                  "Contact info with headline \n'${contact.headline}.\n\n'ID '${contact.id}' is about be removed!",
                ),
                actions: [
                  TextButton(
                    child: const Text(
                      'No',
                      style: TextStyle(color: Colors.green),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                  TextButton(
                    child: const Text(
                      'Yes',
                      style: TextStyle(color: Colors.red),
                    ),
                    onPressed: () {
                      _handleDelete(
                          context.read<AuthManager>().getSessionIDAsString());
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            });
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text("Name: ${contact.name}"),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text("Date: ${contact.date}"),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text("Headline: ${contact.headline}"),
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text("Message:"),
          ),
          ExpansionTile(
            title: Text(
              "${contact.message.substring(0, 30)}...",
              style: const TextStyle(fontStyle: FontStyle.italic, fontSize: 12),
            ),
            children: [Text(contact.message)],
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Text("Read:",
                    style: TextStyle(
                        color: contact.read ? Colors.green : Colors.red)),
                IconButton(
                    onPressed: () async {
                      Contact updatedContact = await WebManager().markAsRead(
                          context.read<AuthManager>().getSessionIDAsString(),
                          contact.id);
                      updateListing(updatedContact);
                    },
                    icon: contact.read
                        ? const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                          )
                        : const Icon(
                            Icons.radio_button_unchecked,
                            color: Colors.red,
                          ))
              ],
            ),
          ),
          TextButton(
              onPressed: () {
                _launchUrl("mailto:${contact.email}");
              },
              child: Text(contact.email)),
          const Divider()
        ],
      ),
    );
  }
}
