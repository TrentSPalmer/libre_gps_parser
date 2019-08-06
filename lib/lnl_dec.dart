import 'package:android_intent/android_intent.dart';
import 'package:flutter/material.dart';
import 'global_helper_functions.dart';
import 'package:share/share.dart';

final double textHeight = 1.5;

Row lnlDec(String latnLong,BuildContext context) {

  Future<void> _launchLnLgMaps() async {
    AndroidIntent intent = AndroidIntent(
      action: 'action_view',
      data: Uri.encodeFull('geo:$latnLong?z=12'),
      package: 'com.google.android.apps.maps',
    );
    await intent.launch();
  }

  Future<void> _launchLnLqMaps() async {
    AndroidIntent intent = AndroidIntent(
      action: 'action_view',
      data: Uri.encodeFull('geo:$latnLong'),
      package: 'com.mapquest.android.ace',
    );
    await intent.launch();
  }

  Future<void> _launchLnL() async {
    bool _useShareToMapQuest = await getPreferenceUseShareToMapQuest();
    if (_useShareToMapQuest) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: ivory,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(6.0)),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          margin: EdgeInsets.only(
                            top: 40,
                            bottom: 10,
                          ),
                          child: Wrap(
                            runSpacing: 30,
                            alignment: WrapAlignment.center,
                            children: <Widget>[
                              Container(
                                margin: EdgeInsets.symmetric(
                                  horizontal: 15,
                                ),
                                child: ButtonTheme(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(6.0)),
                                  ),
                                  height: 75,
                                  child: RaisedButton(
                                      color: peacockBlue,
                                      child: Icon(
                                        Icons.arrow_back,
                                        size: 48.0,
                                        color: Colors.white,
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      }),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.symmetric(
                                  horizontal: 15,
                                ),
                                child: ButtonTheme(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(6.0)),
                                  ),
                                  height: 75,
                                  child: RaisedButton(
                                      color: peacockBlue,
                                      child: Text(
                                        "MapQuest",
                                        style: TextStyle(
                                          height: textHeight,
                                          color: Colors.white,
                                          fontSize: 24,
                                        ),
                                      ),
                                      onPressed: () {
                                        _launchLnLqMaps();
                                      }),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.symmetric(
                                  horizontal: 15,
                                ),
                                child: ButtonTheme(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(6.0)),
                                  ),
                                  height: 75,
                                  child: RaisedButton(
                                    color: peacockBlue,
                                    child: Text(
                                      "GoogleMaps",
                                      style: TextStyle(
                                        height: textHeight,
                                        color: Colors.white,
                                        fontSize: 24,
                                      ),
                                    ),
                                    onPressed: () {
                                      _launchLnLgMaps();
                                    }
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      );
    } else {
      await _launchLnLgMaps();
    }
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
