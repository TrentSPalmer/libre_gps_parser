import 'package:flutter/material.dart';
import 'package:android_intent/android_intent.dart';
import 'package:share/share.dart';
import 'global_helper_functions.dart';

class Location extends StatefulWidget {
  final String mapLocation;

  Location({
    Key key,
    this.mapLocation,
  }) : super(key: key);
  @override
  _LocationState createState() => _LocationState();
}

class _LocationState extends State<Location> {
  @override
  Widget build(BuildContext context) {
    final double textHeight = 1.5;
    List<String> locationStringList = _getlocationStringList(widget.mapLocation);

    Future<void> _launchUrl() async{
      AndroidIntent intent = AndroidIntent(
          action: 'action_view',
          data: Uri.encodeFull(locationStringList[locationStringList.length - 1]),
      );
      await intent.launch();
    }

    List<Container> createLocation(List<String> location) {
        return location.map((line) {
          line = (line.length < 25) ? line :
              (line.substring(0,20) + '.....' );
          return Container(
              child: Text(
                  line,
                  style: TextStyle(
                    height: textHeight,
                    fontSize: 16.0,
                  ),
              ),
          );
        }).toList();
    } 

    try {
      return Row(
        children: <Widget>[
          Expanded(
            flex: 3,
            child: IconButton(
              icon: Icon(Icons.share),
              tooltip: 'share link to another app',
              iconSize: 48,
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      backgroundColor: ivory,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(6.0)),
                      ),
                      title: Text(
                        'Sharing Options',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: candyApple,
                        ),
                      ),
                      content: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                            IconButton(
                              icon: Icon(Icons.share),
                              tooltip: 'share link to another app',
                              iconSize: 48,
                              onPressed: () {
                                Navigator.of(context).pop();
                                Share.share(widget.mapLocation);
                              },
                            ),
                          IconButton(
                            icon: Icon(Icons.map),
                            tooltip: 'share link to maps',
                            iconSize: 48,
                            onPressed: () {
                              Navigator.of(context).pop();
                              _launchUrl();
                            },
                          ),
                        ],
                      ),
                    );
                  }
                );
              },
            ),
          ),
          Expanded(
            flex: 7,
            child: InkWell(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: createLocation(locationStringList),
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
                          Container(
                              margin: EdgeInsets.only(
                                bottom: 25,
                              ),
                            child: Text(
                              widget.mapLocation,
                              textAlign: TextAlign.center,
                            ),
                          ),
                          RaisedButton(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.all(Radius.circular(6.0)),
                            ),
                            color: peacockBlue,
                            child: Container(
                              margin: EdgeInsets.only(
                                top: 12,
                                bottom: 20,
                              ),
                              child: Text(
                                  'ok',
                                  style: TextStyle(
                                  height: textHeight,
                                  color: Colors.white,
                                  fontSize: 24,
                                ),
                              ),
                            ),
                            onPressed: () {
                              Navigator.of(context).pop();
                            }
                          ),
                        ],
                      ),
                    );
                  }
                );
              },
            ),
          ),
        ],
      );
    } catch(e) {
      print('$e, probably could not call createLocation(locationStringList)');
      return Wrap(
        spacing: 20.0,
        children: <Widget>[
          Text(
            'Pending...',
            style: TextStyle(height: textHeight),
          ),
        ],
      );

    }
  }

  List<String> _getlocationStringList(String mapLocation) {
    List<String> stringList;
    try {
      stringList = mapLocation.split('\n');
    } catch(e) {
      print('$e in source file location.dart._getlocationStringList::first_try');
    }
    if (stringList.length < 2) {
      return ['','pending...',''];
    } else {
      try {
        if (stringList[1].contains(stringList[0])) {
          stringList.removeAt(0);
        }
      } catch(e) {
        print('$e in source file location.dart._getlocationStringList::second_try');
      }
      // split up long address lines on the second to last comma
      for (int i=0; i<stringList.length; i++) {
        int numCommas = (','.allMatches(stringList[i])).length;
        if (numCommas > 1) {
          String currentLine = stringList[i];
          stringList.removeAt(i);
          int commaCount = 0;
          for (int j=0; j<currentLine.length; j++) {
            if (currentLine[j] == ',') {
              commaCount += 1;
              if (commaCount == (numCommas -1)) {
                String firstHalf = currentLine.substring(0,j+1);
                String secondHalf = currentLine.substring(j+2);
                stringList.insert(i, firstHalf);
                stringList.insert(i+1, secondHalf);
              }
            }
          }
        }
      }
      return stringList;
    }
  }
}
