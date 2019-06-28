import 'package:flutter/material.dart';
import 'global_helper_functions.dart';
import 'package:share/share.dart';

final double textHeight = 1.5;

Row lnlDeg(String latnLongDMS) {
  List<String> _latNLong = ['x','y'];
  if ((latnLongDMS == 'none') || (latnLongDMS == null)) {
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
  } else if (!(latnLongDMS.contains(','))) {
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
    _latNLong = latnLongDMS.split(',');
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[
        IconButton(
          icon: Icon(Icons.share),
          tooltip: 'share link to another app',
          iconSize: 48,
          onPressed: () {
            Share.share(latnLongDMS);
          },
        ),
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Deg, Min, Sec',
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
      ],
    );
  }
}
