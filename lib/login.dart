import 'package:flutter/material.dart';
import 'package:portfolioapp/manager/auth_manager.dart';
import 'package:portfolioapp/manager/web_manager.dart';
import 'package:provider/provider.dart';

/// Handles user login to backend api.
class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<StatefulWidget> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  String _username = "";
  String _password = "";

  /// Set username state
  void setUsername(String value) {
    setState(() {
      _username = value;
    });
  }

  /// Set password state
  void setPassword(String value) {
    setState(() {
      _password = value;
    });
  }

  /// Try to authenticate with provided username and password.
  /// If auth fails show dialog telling about faulty credentials.
  void logUserIn() async {
    WebManager webManager = WebManager();
    String? response = await webManager.logIn(_username, _password);

    if (response != null) {
      // set new state
      _setNewContext(response);
    } else {
      // Display dialog informing user of faulty credentials
      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          title: const Text('Login failed!'),
          content:
              const Text('Username or password was wrong! \n\nCheck input!'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(context, 'OK'),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  /// Set session id to AuthManager that backend has sent us.
  void _setNewContext(String sessionid) {
    context.read<AuthManager>().setJSessionID(sessionid);
  }

  @override
  Widget build(BuildContext context) {
    return AutofillGroup(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(children: [
            const Text(
              "Login",
              style: TextStyle(fontSize: 20),
            ),
            TextField(
              decoration: const InputDecoration(labelText: "Username"),
              autofillHints: const [AutofillHints.username],
              onChanged: (text) {
                setUsername(text);
              },
            ),
            TextField(
              obscureText: true,
              decoration: const InputDecoration(labelText: "Password"),
              autofillHints: const [AutofillHints.password],
              onChanged: (text) {
                setPassword(text);
              },
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: ElevatedButton(
                  onPressed: () {
                    logUserIn();
                  },
                  child: const Text("Login")),
            )
          ]),
        ),
      ),
    );
  }
}
