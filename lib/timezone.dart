import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'global_helper_functions.dart';
import 'timezones.dart';

class TimeZone extends StatefulWidget {
  final int timeOffSet;
  final int timeOffSetTime;
  final int isAutoTimeOffSet;

  final ValueChanged<int> parentAction;

  TimeZone({
    Key key,
    this.timeOffSet,
    this.timeOffSetTime,
    this.parentAction,
    this.isAutoTimeOffSet,
  }) : super(key: key);

  @override
  _TimeZoneState createState() => _TimeZoneState();
}

class _TimeZoneState extends State<TimeZone> {
  @override
  Widget build(BuildContext context) {
    int _localOffSet = 5;
    final int now = newTimeStamp();
    final int elapsedHours = ((now - widget.timeOffSetTime) / 3600).round();
    final String offSet = (widget.timeOffSet < 0)
        ? '(UTC${widget.timeOffSet})'
        : '(UTC+${widget.timeOffSet})';
    final double textHeight = 1.5;

    return Row(
      children: <Widget>[
        Expanded(
          flex: 7,
          child: InkWell(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Time Offset:',
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
                          text: (widget.timeOffSet != 2000)
                              ? '$offSet'
                              : 'INVALID',
                          style: TextStyle(
                            height: textHeight,
                            color: Colors.black,
                            fontSize: 16,
                          ),
                        ),
                        TextSpan(
                          text: (widget.timeOffSet != 2000) ? ' minutes, ' : '',
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
                          text: (widget.isAutoTimeOffSet == 1)
                              ? 'as of'
                              : 'MANUAL SETTING',
                          style: TextStyle(
                            height: textHeight,
                            color: candyApple,
                            fontSize: 16,
                          ),
                        ),
                        TextSpan(
                          text: (widget.isAutoTimeOffSet == 1)
                              ? ' $elapsedHours'
                              : '',
                          style: TextStyle(
                            height: textHeight,
                            color: Colors.black,
                            fontSize: 16,
                          ),
                        ),
                        TextSpan(
                          text: (widget.isAutoTimeOffSet == 1) ? ' hrs' : '',
                          style: TextStyle(
                            height: textHeight,
                            color: Colors.black,
                            fontSize: 16,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                        TextSpan(
                          text: (widget.isAutoTimeOffSet == 1) ? ' ago' : '',
                          style: TextStyle(
                            height: textHeight,
                            color: Colors.black,
                            fontSize: 16,
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
                    final FixedExtentScrollController scrollController =
                        FixedExtentScrollController(
                            initialItem: _getTimeZoneListIndex());
                    return AlertDialog(
                      backgroundColor: ivory,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(6.0)),
                      ),
                      content:
                          Column(mainAxisSize: MainAxisSize.min, children: <
                              Widget>[
                        ButtonTheme(
                          height: 75,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(6.0)),
                          ),
                          child: RaisedButton(
                            onPressed: () {
                              if (!mounted) {
                                return;
                              } else {
                                Navigator.of(context).pop();
                                if (_localOffSet != 5) {
                                  widget.parentAction(_localOffSet);
                                }
                              }
                            },
                            color: candyApple,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: <Widget>[
                                Icon(
                                  Icons.save,
                                  size: 48.0,
                                  color: Colors.white,
                                ),
                                Text(
                                  'save tz offset',
                                  style: TextStyle(
                                    height: textHeight,
                                    color: Colors.white,
                                    fontSize: 24,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Container(
                          height: (MediaQuery.of(context).size.height * .5),
                          child: CupertinoPicker(
                            scrollController: scrollController,
                            backgroundColor: ivory,
                            itemExtent: 100,
                            looping: true,
                            onSelectedItemChanged: (int index) {
                              if (!mounted) {
                                return;
                              } else {
                                setState(() {
                                  _localOffSet = timeZoneList[index]['offset'];
                                });
                              }
                            },
                            children: List<Widget>.generate(timeZoneList.length,
                                (int index) {
                              return Column(
                                children: <Widget>[
                                  Container(
                                    height: 10,
                                    color: ivory,
                                  ),
                                  Container(
                                    alignment: Alignment(0.0, 0.0),
                                    height: 80,
                                    width: (MediaQuery.of(context).size.width *
                                        .9),
                                    decoration: BoxDecoration(
                                      color: peacockBlue,
                                      border: Border.all(
                                        width: 2.0,
                                      ),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(6.0)),
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: <Widget>[
                                        Text(
                                          _parseTimeZoneOffSet(
                                              timeZoneList[index]['offset']),
                                          style: TextStyle(
                                            height: textHeight,
                                            color: Colors.white,
                                            fontSize: 24,
                                          ),
                                        ),
                                        Text(
                                          '${timeZoneList[index]['tz']}',
                                          style: TextStyle(
                                            height: textHeight,
                                            color: Colors.white,
                                            fontSize: 24,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    height: 10,
                                    color: ivory,
                                  ),
                                ],
                              );
                            }),
                          ),
                        ),
                      ]),
                    );
                  },
                );
              }),
        ),
        Expanded(
          flex: 3,
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  width: 1.0,
                  color: Colors.black,
                ),
              ),
            ),
            child: InkWell(
              child: Icon(
                Icons.info,
                size: 48.0,
                color: Colors.black,
              ),
              /*
              onTap: () {
                urlLaunch('https://en.wikipedia.org/wiki/List_of_time_zone_abbreviations');
              }
              */
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
                              'The timezone offset should be set and refreshed automatically, '
                              'by querying an api from teleport. However, because the api is '
                              'free, the query is only refreshed once a week.\n'
                              'Additionally, in some cases the result is invalid. Tap the '
                              'left side of TimeZone Widget to manually set the timezone offset.',
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
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(6.0)),
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
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceAround,
                                            children: <Widget>[
                                              Text(
                                                'List',
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
                                            'Of TimeZones',
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
                                      urlLaunch(
                                          'https://en.wikipedia.org/wiki/List_of_time_zone_abbreviations');
                                    }),
                              ),
                            ),
                          ],
                        ),
                      );
                    });
              },
            ),
          ),
        ),
      ],
    );
  }

  int _getTimeZoneListIndex() {
    // 2001 is a magic number which means auto
    // as in the tz offset is automatically set
    return timeZoneList.indexOf(timeZoneList.singleWhere((timeZone) =>
        timeZone['offset'] ==
        ((widget.isAutoTimeOffSet == 1) ? 2001 : widget.timeOffSet)));
  }

  String _parseTimeZoneOffSet(int offset) {
    if (offset < 2000) {
      return offset.toString();
    } else if (offset == 2000) {
      return 'INVALID';
    } else if (offset == 2001) {
      return 'AUTO';
    }
  }
}
