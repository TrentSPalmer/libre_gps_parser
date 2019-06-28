import 'package:flutter/material.dart';
import 'global_helper_functions.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'dart:convert';

class WeatherForeCast extends StatefulWidget {
  final String weatherForeCast;
  final int timeOffSet;

  WeatherForeCast({
    Key key,
    this.weatherForeCast,
    this.timeOffSet,
  }) : super(key: key);

  @override
  _WeatherForeCastState createState() => _WeatherForeCastState();
}

class _WeatherForeCastState extends State<WeatherForeCast> {
  final double textHeight = 1.5;
  
  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> foreCastJson;
    final double _deviceWidth = MediaQuery.of(context).size.width;

    List<Container> createForeCast(List<dynamic> foreCastList) {
      return foreCastList.map((foreCast) {
        Map<String, String> foreCastTime =
            get3WayTime(foreCast['dt'], widget.timeOffSet);

        Column _conditions() {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                'Forecast: ',
                style: TextStyle(
                  height: textHeight,
                  color: candyApple,
                  fontSize: 16,
                ),
              ),
              Text(
                '${weatherConditions(foreCast['weather'][0]['description'])}',
                style: TextStyle(
                  height: textHeight,
                  color: Colors.black,
                  fontSize: 18,
                ),
              ),
              RichText(
                text: TextSpan(
                  children: <TextSpan>[
                    TextSpan(
                      text: 'Humidity: ',
                      style: TextStyle(
                        height: textHeight,
                        color: candyApple,
                        fontSize: 16,
                      ),
                    ),
                    TextSpan(
                      text: '${foreCast['main']['humidity']}%',
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
          );
        }

        Container _icon() {
          return Container(
            width: 100,
            child: CachedNetworkImage(
              imageUrl: 'https://openweathermap.org/img/w/${foreCast['weather'][0]['icon']}.png',
            ),
          );
        }

        Column _wind() {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              RichText(
                text: TextSpan(
                  children: <TextSpan>[
                    TextSpan(
                      text: 'Wind: ',
                      style: TextStyle(
                        height: textHeight,
                        color: candyApple,
                        fontSize: 16,
                      ),
                    ),
                    TextSpan(
                      text: '${foreCast['wind']['speed'].round()}',
                      style: TextStyle(
                        height: textHeight,
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                    TextSpan(
                      text: 'mph',
                      style: TextStyle(
                        height: textHeight,
                        color: Colors.black,
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    TextSpan(
                      text: ',',
                      style: TextStyle(
                        height: textHeight,
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              RichText(
                text: TextSpan(
                  children: <TextSpan>[
                    TextSpan(
                      text:
                          '${getKilometers(foreCast['wind']['speed'].toDouble())}',
                      style: TextStyle(
                        height: textHeight,
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                    TextSpan(
                      text: 'kph',
                      style: TextStyle(
                        height: textHeight,
                        color: Colors.black,
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    TextSpan(
                      text:
                          ', ${getKnots(foreCast['wind']['speed'].toDouble())}',
                      style: TextStyle(
                        height: textHeight,
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                    TextSpan(
                      text: 'knots',
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
                      text: 'From: ',
                      style: TextStyle(
                        height: textHeight,
                        color: candyApple,
                        fontSize: 16,
                      ),
                    ),
                    TextSpan(
                      text:
                          '${foreCast['wind']['deg'].round()}\u00B0, ',
                      style: TextStyle(
                        height: textHeight,
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                    TextSpan(
                      text:
                          '(${getDirection(foreCast['wind']['deg'].round())})',
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
          );
        }
        
        Column _temp() {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              RichText(
                // temp
                text: TextSpan(
                  children: <TextSpan>[
                    TextSpan(
                      text: 'Temp: ',
                      style: TextStyle(
                        height: textHeight,
                        color: candyApple,
                        fontSize: 16,
                      ),
                    ),
                    TextSpan(
                      text:
                          '${foreCast['main']['temp'].round()}\u00B0',
                      style: TextStyle(
                        height: textHeight,
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                    TextSpan(
                      text: 'F',
                      style: TextStyle(
                        height: textHeight,
                        color: Colors.black,
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    TextSpan(
                      text:
                          ', ${getCelcius(foreCast['main']['temp'].toDouble())}\u00B0',
                      style: TextStyle(
                        height: textHeight,
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                    TextSpan(
                      text: 'C',
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
                // temp_min
                text: TextSpan(
                  children: <TextSpan>[
                    TextSpan(
                      text: 'Min: ',
                      style: TextStyle(
                        height: textHeight,
                        color: candyApple,
                        fontSize: 16,
                      ),
                    ),
                    TextSpan(
                      text:
                          '${foreCast['main']['temp_min'].round()}\u00B0',
                      style: TextStyle(
                        height: textHeight,
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                    TextSpan(
                      text: 'F',
                      style: TextStyle(
                        height: textHeight,
                        color: Colors.black,
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    TextSpan(
                      text:
                          ', ${getCelcius(foreCast['main']['temp_min'].toDouble())}\u00B0',
                      style: TextStyle(
                        height: textHeight,
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                    TextSpan(
                      text: 'C',
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
                // temp_max
                text: TextSpan(
                  children: <TextSpan>[
                    TextSpan(
                      text: 'Max: ',
                      style: TextStyle(
                        height: textHeight,
                        color: candyApple,
                        fontSize: 16,
                      ),
                    ),
                    TextSpan(
                      text:
                          '${foreCast['main']['temp_max'].round()}\u00B0',
                      style: TextStyle(
                        height: textHeight,
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                    TextSpan(
                      text: 'F',
                      style: TextStyle(
                        height: textHeight,
                        color: Colors.black,
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    TextSpan(
                      text:
                          ', ${getCelcius(foreCast['main']['temp_max'].toDouble())}\u00B0',
                      style: TextStyle(
                        height: textHeight,
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                    TextSpan(
                      text: 'C',
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
          );
        }

        Column _time() {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              RichText(
                text: TextSpan(
                  children: <TextSpan>[
                    TextSpan(
                      text: 'There: ',
                      style: TextStyle(
                        height: textHeight,
                        color: candyApple,
                        fontSize: 16,
                      ),
                    ),
                    TextSpan(
                      text: '${foreCastTime['There']}',
                      style: TextStyle(
                        height: textHeight,
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              RichText(
                text: TextSpan(
                  children: <TextSpan>[
                    TextSpan(
                      text: 'Here: ',
                      style: TextStyle(
                        height: textHeight,
                        color: candyApple,
                        fontSize: 16,
                      ),
                    ),
                    TextSpan(
                      text: '${foreCastTime['Here']}',
                      style: TextStyle(
                        height: textHeight,
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              RichText(
                text: TextSpan(
                  children: <TextSpan>[
                    TextSpan(
                      text: 'UTC: ',
                      style: TextStyle(
                        height: textHeight,
                        color: candyApple,
                        fontSize: 16,
                      ),
                    ),
                    TextSpan(
                      text: '${foreCastTime['UTC']}',
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
          );
        }

        Column _pressure() {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              RichText(
                text: TextSpan(
                  children: <TextSpan>[
                    TextSpan(
                      text: 'Pressure: ',
                      style: TextStyle(
                        height: textHeight,
                        color: candyApple,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              RichText(
                text: TextSpan(
                  children: <TextSpan>[
                    TextSpan(
                      text: '${foreCast['main']['pressure']}',
                      style: TextStyle(
                        height: textHeight,
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                    TextSpan(
                      text: 'mb',
                      style: TextStyle(
                        height: textHeight,
                        color: Colors.black,
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    TextSpan(
                      text: ', ',
                      style: TextStyle(
                        height: textHeight,
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              RichText(
                text: TextSpan(
                  children: <TextSpan>[
                    TextSpan(
                      text:
                          '${getinHg(foreCast['main']['pressure'].toDouble())}',
                      style: TextStyle(
                        height: textHeight,
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                    TextSpan(
                      text: 'inHg',
                      style: TextStyle(
                        height: textHeight,
                        color: Colors.black,
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    TextSpan(
                      text: ',',
                      style: TextStyle(
                        height: textHeight,
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              RichText(
                text: TextSpan(
                  children: <TextSpan>[
                    TextSpan(
                      text:
                          '${getmmHg(foreCast['main']['pressure'].toDouble())}',
                      style: TextStyle(
                        height: textHeight,
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                    TextSpan(
                      text: 'mmHg',
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
          );
        }

        Column _sea() {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              RichText(
                text: TextSpan(
                  children: <TextSpan>[
                    TextSpan(
                      text: 'Sea Level: ',
                      style: TextStyle(
                        height: textHeight,
                        color: candyApple,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              RichText(
                text: TextSpan(
                  children: <TextSpan>[
                    TextSpan(
                      text: '${foreCast['main']['sea_level']}',
                      style: TextStyle(
                        height: textHeight,
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                    TextSpan(
                      text: 'mb',
                      style: TextStyle(
                        height: textHeight,
                        color: Colors.black,
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    TextSpan(
                      text: ', ',
                      style: TextStyle(
                        height: textHeight,
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              RichText(
                text: TextSpan(
                  children: <TextSpan>[
                    TextSpan(
                      text:
                          '${getinHg(foreCast['main']['sea_level'].toDouble())}',
                      style: TextStyle(
                        height: textHeight,
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                    TextSpan(
                      text: 'inHg',
                      style: TextStyle(
                        height: textHeight,
                        color: Colors.black,
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    TextSpan(
                      text: ',',
                      style: TextStyle(
                        height: textHeight,
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              RichText(
                text: TextSpan(
                  children: <TextSpan>[
                    TextSpan(
                      text:
                          '${getmmHg(foreCast['main']['sea_level'].toDouble())}',
                      style: TextStyle(
                        height: textHeight,
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                    TextSpan(
                      text: 'mmHg',
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
          );
        }

        Column _ground() {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              RichText(
                text: TextSpan(
                  children: <TextSpan>[
                    TextSpan(
                      text: 'Ground Level: ',
                      style: TextStyle(
                        height: textHeight,
                        color: candyApple,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              RichText(
                text: TextSpan(
                  children: <TextSpan>[
                    TextSpan(
                      text: '${foreCast['main']['grnd_level']}',
                      style: TextStyle(
                        height: textHeight,
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                    TextSpan(
                      text: 'mb',
                      style: TextStyle(
                        height: textHeight,
                        color: Colors.black,
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    TextSpan(
                      text: ', ',
                      style: TextStyle(
                        height: textHeight,
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              RichText(
                text: TextSpan(
                  children: <TextSpan>[
                    TextSpan(
                      text:
                          '${getinHg(foreCast['main']['grnd_level'].toDouble())}',
                      style: TextStyle(
                        height: textHeight,
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                    TextSpan(
                      text: 'inHg',
                      style: TextStyle(
                        height: textHeight,
                        color: Colors.black,
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    TextSpan(
                      text: ',',
                      style: TextStyle(
                        height: textHeight,
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              RichText(
                text: TextSpan(
                  children: <TextSpan>[
                    TextSpan(
                      text:
                          '${getmmHg(foreCast['main']['grnd_level'].toDouble())}',
                      style: TextStyle(
                        height: textHeight,
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                    TextSpan(
                      text: 'mmHg',
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
          );
        }

        if (_deviceWidth < 400) {
          return Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  width: 1.0,
                  color: Colors.black,
                ),
              ),
            ),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      _icon(),
                      _conditions(),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      _time(),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      _temp(),
                      _wind(),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      _pressure(),
                      _sea(),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      _ground(),
                    ],
                  ),
                ),
              ],
            ),
          );
        } else if ((_deviceWidth >= 400) && (_deviceWidth < 650)) {
          return Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  width: 1.0,
                  color: Colors.black,
                ),
              ),
            ),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      _icon(),
                      _conditions(),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      _time(),
                      _temp(),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      _pressure(),
                      _sea(),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      _ground(),
                      _wind(),
                    ],
                  ),
                ),
              ],
            ),
          );
        } else if ((_deviceWidth >= 650) && (_deviceWidth < 1000)) {
          return Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  width: 1.0,
                  color: Colors.black,
                ),
              ),
            ),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      _icon(),
                      _conditions(),
                      _temp(),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      _time(),
                      _wind(),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      _pressure(),
                      _sea(),
                      _ground(),
                    ],
                  ),
                ),
              ],
            ),
          );
        } else if (_deviceWidth >= 1000) {
          return Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  width: 1.0,
                  color: Colors.black,
                ),
              ),
            ),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      _icon(),
                      _conditions(),
                      _temp(),
                      _time(),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      _wind(),
                      _pressure(),
                      _sea(),
                      _ground(),
                    ],
                  ),
                ),
              ],
            ),
          );
        }
      }).toList();
    }

    try {
      foreCastJson = jsonDecode(widget.weatherForeCast);
      return Container(
        margin: EdgeInsets.symmetric(
            vertical: 3,
            horizontal: 6,
        ),
        decoration: myBoxDecoration(ivory),
        padding: EdgeInsets.all(5.0),
        child: Column(
          children: createForeCast(foreCastJson['list']),
        ),
      );
    } catch(e) {
      return Container(
        margin: EdgeInsets.symmetric(
            vertical: 3,
            horizontal: 6,
        ),
        padding: myBoxPadding,
        decoration: myBoxDecoration(ivory),
        child: Wrap(
          spacing: 20.0,
          children: <Widget>[
            Text(
              'Pending...',
              style: TextStyle(height: textHeight),
            ),
          ],
        ),
      );
    }
  }

  double getinHg(double mBar) {
    return (mBar != null) ? ((mBar * 29.53).round() / 1000.0) : null;
  }

  double getmmHg(double mBar) {
    return (mBar != null) ? ((mBar * 75.0062).round() / 100.0) : null;
  }

  int getKnots(double miles) {
    return (miles != null) ? (miles * 0.8689).round() : null;
  }

  int getKilometers(double miles) {
    return (miles != null) ? (miles * 1.60934).round() : null;
  }

  int getCelcius(double fahrenheit) {
    return (fahrenheit != null) ? (((fahrenheit - 32) * 5) / 9).round() : null;
  }

  Map<String, String> get3WayTime(int secondsFromEpoch, int timeOffSet) {
    DateTime utcTime =
        DateTime.fromMillisecondsSinceEpoch(secondsFromEpoch * 1000).toUtc();
    DateTime thereTime = utcTime.add(Duration(minutes: timeOffSet));
    DateTime hereTime = utcTime.toLocal();
    String there = (timeOffSet != 2000) ? DateFormat('EEEE MMMM d, HH:mm').format(thereTime) : 'UNKNOWN, INVALID';
    String here = DateFormat('EEEE MMMM d, HH:mm').format(hereTime);
    String utc = DateFormat('EEEE MMMM d, HH:mm').format(utcTime);
    return {
      'There': there,
      'Here': here,
      'UTC': utc,
    };
  }

  String getDirection(int direction) {
    if ((direction < 22.5) || (direction >= 337.5)) {
      return "N";
    } else if ((direction >= 22.5) && (direction < 67.5)) {
      return "NE";
    } else if ((direction >= 67.5) && (direction < 112.5)) {
      return "E";
    } else if ((direction >= 112.5) && (direction < 157.5)) {
      return "SE";
    } else if ((direction >= 157.5) && (direction < 202.5)) {
      return "S";
    } else if ((direction >= 202.5) && (direction < 247.5)) {
      return "SW";
    } else if ((direction >= 247.5) && (direction < 292.5)) {
      return "W";
    } else if ((direction >= 292.5) && (direction < 337.5)) {
      return "NW";
    }
    return "none";
  }
}
