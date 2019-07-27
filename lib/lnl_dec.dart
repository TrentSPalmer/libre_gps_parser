import 'package:android_intent/android_intent.dart';
import 'package:flutter/material.dart';
import 'global_helper_functions.dart';
import 'package:share/share.dart';

final double textHeight = 1.5;

Row lnlDec(String latnLong) {
  Future<void> _launchLnL() async {
    AndroidIntent intent = AndroidIntent(
      action: 'action_view',
      data: Uri.encodeFull('geo:$latnLong?z=12'),
      package: 'com.google.android.apps.maps',
    );
    await intent.launch();
  }

  List<String> _latNLong = ['x', 'y'];
  if ((latnLong == 'none') || (latnLong == null)) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Check Data Connection',
                style: TextStyle(
                  height: textHeight,
                  fontSize: 16,
                ),
              ),
              Text(
                'Probably Offline',
                style: TextStyle(
                  height: textHeight,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  } else if (!(latnLong.contains(','))) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                'Check Data Connection',
                style: TextStyle(
                  height: textHeight,
                  fontSize: 16,
                ),
              ),
              Text(
                'Probably Offline',
                style: TextStyle(
                  height: textHeight,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  } else {
    _latNLong = latnLong.split(',');
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        IconButton(
          icon: Icon(Icons.share),
          tooltip: 'share link to another app',
          iconSize: 48,
          onPressed: () {
            Share.share(latnLong);
          },
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Decimal',
              style: TextStyle(
                height: textHeight,
                color: candyApple,
                fontSize: 16,
              ),
            ),
            Text(
              _latNLong[0],
              style: TextStyle(
                height: textHeight,
                color: Colors.black,
                fontSize: 16,
              ),
            ),
            Text(
              _latNLong[1],
              style: TextStyle(
                height: textHeight,
                color: Colors.black,
                fontSize: 16,
              ),
            ),
          ],
        ),
        IconButton(
          icon: Icon(Icons.map),
          tooltip: 'share link to maps',
          iconSize: 48,
          onPressed: () {
            _launchLnL();
          },
        ),
      ],
    );
  }
}
