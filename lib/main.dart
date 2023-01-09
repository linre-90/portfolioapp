import 'package:flutter/material.dart';
import "package:portfolioapp/loading_widget.dart";
import 'package:portfolioapp/manager/auth_manager.dart';
import 'package:portfolioapp/manager/web_manager.dart';
import "package:provider/provider.dart";
import "package:portfolioapp/login.dart";

import 'listing.dart';

/// main method
void main() {
  runApp(ChangeNotifierProvider(
    create: (context) => AuthManager(),
    child: const MyApp(),
  ));
}

/// Build material app.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'JL-admin',
      theme:
          ThemeData(primarySwatch: Colors.blue, brightness: Brightness.light),
      darkTheme: ThemeData(brightness: Brightness.dark),
      themeMode: ThemeMode.system,
      home: const Auth(),
    );
  }
}

/// User must authenticate first to use application backend api.
/// Auth serves widget of of received messages or login widget.
/// Whole app is consumer for AuthManager context.
class Auth extends StatelessWidget {
  const Auth({super.key});

  @override
  Widget build(BuildContext context) {
    return (Scaffold(
        appBar: AppBar(
          title: Image.asset(
            'assets/logo-nobgr.png',
            height: 48.0,
          ),
          actions: [
            PopupMenuButton(itemBuilder: (context) {
              return [
                const PopupMenuItem<int>(
                  value: -1,
                  child: Text("Logout"),
                ),
              ];
            }, onSelected: (value) async {
              if (value == -1) {
                await context.read<AuthManager>().logOut();
              }
            })
          ],
        ),
        body: Consumer<AuthManager>(
            builder: (context, auth, child) => FutureBuilder(
                future: WebManager()
                    .pingApi(context.read<AuthManager>().jsessionid),
                builder: (ctx, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    if (snapshot.data != null && snapshot.data == true) {
                      return const Listing();
                    } else {
                      return const Login();
                    }
                  } else {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Padding(
                            padding: EdgeInsets.all(15.0),
                            child:
                                Text("Loading...", textAlign: TextAlign.center),
                          ),
                          Spinner(),
                        ],
                      ),
                    );
                  }
                }))));
  }
}
