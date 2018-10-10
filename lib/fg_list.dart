import 'dart:async';

import 'package:fluttagram/fg_main.dart';
import 'package:fluttagram/fg_stories.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import "package:pull_to_refresh/pull_to_refresh.dart";

class FgList extends StatelessWidget {
  RefreshController _controller = new RefreshController();
  Firestore _store = Firestore.instance;
  int _imgCount;
  static String name = FgMain.staticName;

  void _onRefresh(bool up) {
    if (up)
      new Future.delayed(const Duration(milliseconds: 2000)).then((val) {
        _controller.sendBack(true, RefreshStatus.completed);
        // refresher.sendStatus(RefreshStatus.completed);
      });
    else {
      new Future.delayed(const Duration(milliseconds: 2000)).then((val) {

      });
    }
  }

  Widget _headerCreate(BuildContext context, int mode) {
    return new ClassicIndicator(mode: mode);
  }

  Widget _footerCreate(BuildContext context, int mode) {
    return new ClassicIndicator(
      mode: mode,
      refreshingText: 'loading...',
      idleIcon: const Icon(Icons.arrow_upward),
      idleText: 'Loadmore...',
    );
  }

   Text _hasLikes(snapshot, int index) {
      List likes = (snapshot.data.documents[_imgCount-index-1])['likes'];
      if(likes.length == 0){
        return null;
      } else {
        return new Text(
          likes.length.toString() + " likes",
          style: TextStyle(fontWeight: FontWeight.bold),
        );
      }
  }

  _clickLikeButton(AsyncSnapshot<QuerySnapshot> snapshot,int index) async {
    //(snapshot.data.documents[_imgCount-index-1]).reference.collection('likes').document();



  }

  // ImageIcon _isLike(){}

  @override
  Widget build(BuildContext context) {
    var deviceSize = MediaQuery.of(context).size;

    return new StreamBuilder<QuerySnapshot>(
        stream: _store.collection('imgs').snapshots(),
        builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
          if(!snapshot.hasData) return const Text('loading...');
          _imgCount = snapshot.data.documents.length;
          // print(imgCount.toString()+'......................................................');

          return new SmartRefresher(
            enablePullDown: true,
              enablePullUp: false,
              controller: _controller,
              onRefresh:_onRefresh ,
              headerBuilder: _headerCreate,
              footerBuilder: _footerCreate,
              child: ListView.builder(
                itemCount: _imgCount,
                itemBuilder: (_, int index) => index < 0  // 0: hide stories  todo: 暂时用不上Stories
                    ? new SizedBox(
                  child: new FgStories(),
                  height: deviceSize.height * 0.15,
                ) : Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 8.0, 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              new Container(
                                height: 36.0,
                                width: 36.0,
                                decoration: new BoxDecoration(
                                  shape: BoxShape.circle,
                                  image: new DecorationImage(
                                      fit: BoxFit.fill,
                                      image: new NetworkImage(
                                          "https://pbs.twimg.com/profile_images/760249570085314560/yCrkrbl3.jpg")),
                                ),
                              ),
                              new SizedBox(
                                width: 10.0,
                              ),
                              new Text(
                                (snapshot.data.documents[_imgCount-index-1])['from'],
                                style: TextStyle(fontWeight: FontWeight.bold),
                              )
                            ],
                          ),
                          new IconButton(
                            icon: Icon(Icons.more_vert),
                            onPressed: null,
                          )
                        ],
                      ),
                    ),
                    Flexible(
                      fit: FlexFit.loose,
                      child: new Image.network(
                        (snapshot.data.documents[_imgCount-index-1])['img_url'],
                        fit: BoxFit.cover,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(0.0,0.0,12.0,0.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          new Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: <Widget>[
                              new IconButton(
                                icon: Icon(Icons.favorite_border),
                                onPressed: null,
                              ),
                              new SizedBox(
                                width: 1.0,
                              ),
                              new Icon(
                                Icons.chat_bubble_outline,
                              ),
                              new SizedBox(
                                width: 16.0,
                              ),
                              new Icon(Icons.send),
                            ],
                          ),
                          new Icon(Icons.bookmark_border)
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: _hasLikes(snapshot, index)
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16.0, .0, .0, .0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          new Container(
                            height: 24.0,
                            width: 24.0,
                            decoration: new BoxDecoration(
                              shape: BoxShape.circle,
                              image: new DecorationImage(
                                  fit: BoxFit.fill,
                                  image: new NetworkImage(
                                      "https://pbs.twimg.com/profile_images/760249570085314560/yCrkrbl3.jpg")),
                            ),
                          ),
                          new SizedBox(
                            width: 10.0,
                          ),
                          Expanded(
                            child: new TextField(
                              style: TextStyle(fontSize: 14.0, color: Colors.black87),
                              decoration: new InputDecoration(
                                border: InputBorder.none,
                                hintText: "Add a comment...",
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child:
                      Text((snapshot.data.documents[_imgCount-index-1])['time'], style: TextStyle(color: Colors.grey, fontSize: 11.0, fontWeight: FontWeight.bold)),
                    )
                  ],
                ),
              )
          );
        }
    );
  }
}
