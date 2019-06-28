import 'package:flutter/material.dart';
import 'global_helper_functions.dart';

final double textHeight = 1.5;

InkWell elevAtion(BuildContext context, int elevation, int feetElevation) {
  return InkWell(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          'Elevation: ',
          style: TextStyle(
            height: textHeight,
            color: candyApple,
            fontSize: 16,
          ),
        ),
        RichText(
          text: TextSpan(
            children: <TextSpan>[
              TextSpan(
                text: feetElevation.toString(),
                style: TextStyle(
                  height: textHeight,
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
              TextSpan(
                text: ' feet, ',
                style: TextStyle(
                  height: textHeight,
                  color: Colors.black,
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
        RichText(
          text: TextSpan(
            children: <TextSpan>[
              TextSpan(
                text: elevation.toString(),
                style: TextStyle(
                  height: textHeight,
                  color: Colors.black,
                  fontSize: 16,
                ),
              ),
              TextSpan(
                text: ' meters',
                style: TextStyle(
                  height: textHeight,
                  color: Colors.black,
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ],
    ),
    onTap: () {
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
                Text(
                  'You have to set up an Open-Elevation Api Server, and specify this in ' 
                  'settings. The instructions are a little bit out-dated, but it\'s not '
                  'too difficult to muddle through and set something up on a vps or '
                  'RaspberryPi or whatever.\n\n'
                  'A \$5 Digital Ocean Droplet doesn\'t have enough disk space, but '
                  'a \$5 LightSail instance does.',
                  textAlign: TextAlign.center,
                ),
                Container(
                  margin: EdgeInsets.only(
                    top: 40,
                    bottom: 10,
                  ),
                  child: ButtonTheme(
                    height: 75,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(6.0)),
                    ),
                    child: RaisedButton(
                      color: peacockBlue,
                      child: Column(
                        children: <Widget>[
                          Container(
                            width: 150,
                            margin: EdgeInsets.only(
                              top: 10,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: <Widget>[
                                Text(
                                  'github',
                                  style: TextStyle(
                                    height: textHeight,
                                    color: Colors.white,
                                    fontSize: 24,
                                  ),
                                ),
                                Icon(
                                  Icons.open_in_browser,
                                  size: 48,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(
                              bottom: 15,
                            ),
                            child: Text(
                              'open-elevation',
                              style: TextStyle(
                                height: textHeight,
                                color: Colors.white,
                                fontSize: 24,
                              ),
                            ),
                          ),
                        ],
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        urlLaunch('https://github.com/Jorl17/open-elevation/blob/master/docs/host-your-own.md');
                      }
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      );
    },
  );
}
