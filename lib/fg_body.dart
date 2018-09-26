import 'package:fluttagram/fg_list.dart';
import 'package:flutter/material.dart';

class FgBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Flexible(child: FgList())
      ],
    );
  }
}
