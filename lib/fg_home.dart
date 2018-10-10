import 'dart:io';

import 'package:fluttagram/fg_body.dart';
import 'package:fluttagram/fg_main.dart';
import 'package:fluttagram/main.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

FirebaseStorage _storage = FirebaseStorage.instance;
Firestore _store = Firestore.instance;

class FgHome extends StatelessWidget {
  static String name = FgMain.staticName;

  String _getDateTime (){
    var now = new DateTime.now();
    return (now.month.toString()
        + "-"
        + now.day.toString()
        + " "
        + now.hour.toString()
        + ":"
        + now.minute.toString());
  }

  int _getTimestamp(){
    return new DateTime.now().millisecondsSinceEpoch;
  }

  /*FgHome({Key key, @required this.name}) : super(key: key);

  String getName(){
    return name;
  }*/

  final topBar = new AppBar(
    titleSpacing: 1.6,
    backgroundColor: new Color(0xfff8faf8),
    centerTitle: false,
    elevation: 1.0,
    leading: new GestureDetector(
      onTap: () async {
        var image = await ImagePicker.pickImage(source: ImageSource.camera);
        StorageReference reference =
            _storage.ref().child("imgs/").child((image.hashCode).toString());
        StorageUploadTask uploadTask = reference.putFile(image);
        String imgUrl = (await uploadTask.future).downloadUrl.toString();
        var now = new DateTime.now();
        String time = now.month.toString()
            + "-"
            + now.day.toString()
            + " "
            + now.hour.toString()
            + ":"
            + now.minute.toString();

        _store.collection("imgs").document()
            .setData({'from':name, 'img_url':imgUrl, 'timestamp':now.millisecondsSinceEpoch, 'time':time, 'likes':0});
      },
      child: new Icon(Icons.photo_camera),
    ),
    title: const Text("Fluttagram"),
    actions: <Widget>[
      Padding(
        padding: const EdgeInsets.only(right: 20.0),
        child: Icon(Icons.live_tv),
      ),
      Padding(
        padding: const EdgeInsets.only(right: 12.0),
        child: Icon(Icons.scanner),
      )
    ],
  );

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: topBar,
        body: new FgBody(),
        bottomNavigationBar: new Container(
          color: Colors.white,
          height: 50.0,
          alignment: Alignment.center,
          child: new BottomAppBar(
            child: new Row(
              // alignment: MainAxisAlignment.spaceAround,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                new IconButton(
                  icon: Icon(
                    Icons.home,
                  ),
                  onPressed: () {},
                ),
                new IconButton(
                  icon: Icon(
                    Icons.search,
                  ),
                  onPressed: null,
                ),
                new IconButton(
                  icon: Icon(
                    Icons.add_circle_outline,
                  ),
                  onPressed: () async {
                    print(name);
                    var image = await ImagePicker.pickImage(
                        source: ImageSource.gallery);
                    StorageReference reference = _storage
                        .ref()
                        .child("imgs/")
                        .child((image.hashCode).toString());
                    StorageUploadTask uploadTask = reference.putFile(image);
                    String imgUrl = (await uploadTask.future).downloadUrl.toString();
                    var now = new DateTime.now();
                    String time = now.month.toString()
                        + "-"
                        + now.day.toString()
                        + " "
                        + now.hour.toString()
                        + ":"
                        + now.minute.toString();

                    _store.collection("imgs").document()
                        .setData({'from':name, 'img_url':imgUrl, 'timestamp':now.millisecondsSinceEpoch, 'time':time, 'likes':0});
                  },
                ),
                new IconButton(
                  icon: Icon(
                    Icons.favorite_border,
                  ),
                  onPressed: null,
                ),
                new IconButton(
                  icon: Icon(
                    Icons.perm_identity,
                  ),
                  onPressed: null,
                ),
              ],
            ),
          ),
        ));
  }
}
