import 'dart:async';
import 'dart:convert' show json;
import 'package:fluttagram/fg_main.dart';

import "package:http/http.dart" as http;
import 'dart:io';

import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttagram/fg_home.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';


FirebaseAuth _auth = FirebaseAuth.instance;

GoogleSignIn _googleSignIn = GoogleSignIn(scopes: <String>[
  'email',
  'https://www.googleapis.com/auth/contacts.readonly',
]);

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SignIn(),
    ),
  );
}

class SignIn extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _MyApp();
}

class _MyApp extends State<SignIn> {
  // This widget is the root of your application.
  static GoogleSignInAccount _currentUser;
  String _contactText;
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();

    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount account) {
      setState(() {
        _currentUser = account;
      });
      if (_currentUser != null) {
        _handleGetContact();
      }
    });
    _googleSignIn.signInSilently();
  }

  Future<Null> _handleGetContact() async {
    setState(() {
      _contactText = "Loading contact info...";
    });
    final http.Response response = await http.get(
      'https://people.googleapis.com/v1/people/me/connections'
          '?requestMask.includeField=person.names',
      headers: await _currentUser.authHeaders,
    );
    if (response.statusCode != 200) {
      setState(() {
        _contactText = "People API gave a ${response.statusCode} "
            "response. Check logs for details.";
      });
      print('People API ${response.statusCode} response: ${response.body}');
      return;
    }
    final Map<String, dynamic> _data = json.decode(response.body);
    final String namedContact = _pickFirstNamedContact(_data);
    setState(() {
      if (namedContact != null) {
        _contactText = "I see you know $namedContact!";
      } else {
        _contactText = "No contacts to display.";
      }
    });
  }

  String _pickFirstNamedContact(Map<String, dynamic> data) {
    final List<dynamic> connections = data['connections'];
    final Map<String, dynamic> contact = connections?.firstWhere(
      (dynamic contact) => contact['names'] != null,
      orElse: () => null,
    );
    if (contact != null) {
      final Map<String, dynamic> name = contact['names'].firstWhere(
        (dynamic name) => name['displayName'] != null,
        orElse: () => null,
      );
      if (name != null) {
        return name['displayName'];
      }
    }
    return null;
  }

  Future<Null> _handleSignIn() async {
    try {
      await _googleSignIn.signIn();
    } catch (error) {
      print(error);
    }
  }

  Future<Null> _handleSignOut() async {
    _googleSignIn.disconnect();
  }

  _launchURL(String url) async {
    // const url = s;
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  void _showInSnackBar(String value) {
    Scaffold.of(context).showSnackBar(new SnackBar(content: new Text(value)));
  }

  Widget _buildBody() {
    if (_currentUser != null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          ListTile(
            leading: GoogleUserCircleAvatar(
              identity: _currentUser,
            ),
            title: Text(_currentUser.displayName),
            subtitle: Text(_currentUser.email),
          ),
          const Text(
            "Signed in successfully.",
            style: TextStyle(fontFamily: 'AvenyTMedium', fontSize: 22.0),
          ),
          Text(
            _contactText,
            style: TextStyle(fontFamily: 'AvenyTMedium', fontSize: 20.0),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              RaisedButton(
                child: const Text('REFRESH'),
                onPressed: _handleGetContact,
              ),
              RaisedButton(
                child: const Text('SIGN OUT'),
                onPressed: _handleSignOut,
              ),
            ],
          ),
          RaisedButton(
            color: Colors.blueAccent,
            child: const Text(
              'START EXPLORING',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () {
              String name = _currentUser.displayName;
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => FgMain(name: name)
              )
              );
            },
          )
        ],
      );
    } else {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        // mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            // mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Text(
                "\nFluttagram",
                style: TextStyle(
                  fontFamily: 'Billabong',
                  fontSize: 48.0,
                ),
              ),
              const Text(
                "\n\nSign up to see photos and videos from your friends.\n",
                style: TextStyle(
                    color: Colors.grey,
                    fontFamily: 'AvenyTRegular',
                    fontSize: 16.4),
              ),
              RaisedButton(
                color: Colors.blueAccent,
                child: const Text(
                  '   SIGN IN WITH YOUR GOOGLE ACCOUNT   ',
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: _handleSignIn,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Expanded(
                    child: Image(image: AssetImage('images/line_grey.png')),
                  ),
                  const Text(
                    "OR",
                    style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.bold,
                        fontSize: 14.0),
                  ),
                  Expanded(
                    child: Image(image: AssetImage('images/line_grey.png')),
                  ),
                ],
              ),
              const Text(
                "\nDownload and use the genuine Instagram App",
                style: TextStyle(
                    color: Colors.blueAccent,
                    fontFamily: 'AvenyTMedium',
                    fontSize: 17.0),
              )
            ],
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              GestureDetector(
                onTap: () {
                  _launchURL(
                      'https://play.google.com/store/apps/details?id=com.instagram.android');
                },
                child: Image(
                  image: AssetImage('images/google_play.png'),
                  height: 72.0,
                  fit: BoxFit.fitHeight,
                ),
              ),
              GestureDetector(
                onTap: () {
                  _launchURL(
                      'https://itunes.apple.com/us/app/instagram/id389801252?mt=8');
                },
                child: Image(
                  image: AssetImage('images/app_store.png'),
                  height: 72.0,
                  fit: BoxFit.fitHeight,
                ),
              ),
            ],
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: ConstrainedBox(
      constraints: const BoxConstraints.expand(),
      child: _buildBody(),
    ));
  }
}
