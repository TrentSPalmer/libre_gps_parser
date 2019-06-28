import 'package:android_intent/android_intent.dart';
import 'package:flutter/material.dart';
import 'global_helper_functions.dart';

final double textHeight = 1.5;

InkWell streetView(String latnLong) {
  return InkWell(
    onTap: () {
      AndroidIntent _intent = AndroidIntent(
        action: 'action_view',
        data: Uri.encodeFull('google.streetview:cbll=$latnLong'),
        package: 'com.google.android.apps.maps');
      _intent.launch();
    },
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Align(
          child: Container(
            width: 50,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Street',
                  style: TextStyle(
                    height: textHeight,
                    color: candyApple,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'View',
                  style: TextStyle(
                    height: textHeight,
                    color: candyApple,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
        Icon(
          Icons.streetview,
          size: 48.0,
          color: Colors.black,
        ),
      ],
    ),
  );
}
