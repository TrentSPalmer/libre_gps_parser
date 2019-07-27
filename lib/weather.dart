import 'package:flutter/material.dart';
import 'global_helper_functions.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

class Weather extends StatefulWidget {
  final String weatherConditions;
  final String weatherConditionsIcon;
  final int weatherLocationID;
  final double weatherCurrentTemp;
  final double weatherCurrentPressure;
  final int weatherCurrentHumidity;
  final double weatherCurrentTempMin;
  final double weatherCurrentTempMax;
  final int weatherCurrentVisibility;
  final double weatherCurrentWindSpd;
  final int weatherCurrentWindDir;
  final int weatherCurrentSunrise;
  final int weatherCurrentSunset;
  final int weatherCurrentDT;
  final int timeOffSet;
  final void Function() parentAction;

  Weather({
    Key key,
    this.weatherLocationID,
    this.weatherConditions,
    this.weatherConditionsIcon,
    this.weatherCurrentTemp,
    this.weatherCurrentPressure,
    this.weatherCurrentHumidity,
    this.weatherCurrentTempMin,
    this.weatherCurrentTempMax,
    this.weatherCurrentVisibility,
    this.weatherCurrentWindSpd,
    this.weatherCurrentWindDir,
    this.weatherCurrentSunrise,
    this.weatherCurrentSunset,
    this.weatherCurrentDT,
    this.timeOffSet,
    this.parentAction,
  }) : super(key: key);

  @override
  _WeatherState createState() => _WeatherState();
}

class _WeatherState extends State<Weather> {
  @override
  Widget build(BuildContext context) {
    Map<String, String> updatedAt =
        get3WayTime(widget.weatherCurrentDT, widget.timeOffSet);
    Map<String, String> sunrise =
        get3WayTime(widget.weatherCurrentSunrise, widget.timeOffSet);
    Map<String, String> sunset =
        get3WayTime(widget.weatherCurrentSunset, widget.timeOffSet);
    final String windDirection = getDirection(widget.weatherCurrentWindDir);
    final int visibilityMeters = getMeters(widget.weatherCurrentVisibility);
    final double textHeight = 1.5;
    final double _deviceWidth = MediaQuery.of(context).size.width;
    final int _now = newTimeStamp();
    final int _staleness = (_now - widget.weatherCurrentDT);
    final bool _stale = (_staleness > 3600);

    Expanded _refresh() {
      return _stale
          ? Expanded(
              flex: 4,
              child: Container(
                child: IconButton(
                  icon: Icon(Icons.refresh),
                  tooltip: 'refresh weather',
                  iconSize: 60,
                  color: candyApple,
                  onPressed: () {
                    widget.parentAction();
                  },
                ),
              ),
            )
          : Expanded(child: Container());
    }

    Expanded _staleNotice() {
      return _stale
          ? Expanded(
              flex: 6,
              child: RichText(
                textAlign: TextAlign.justify,
                text: TextSpan(
                  children: <TextSpan>[
                    TextSpan(
                      text: 'The Current Weather Report is stale by more than ',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                    TextSpan(
                      text: '${(_staleness / 3600).floor()} ',
                      style: TextStyle(
                        color: candyApple,
                        fontSize: 16,
                      ),
                    ),
                    TextSpan(
                      text: 'hours',
                      style: TextStyle(
                        color: candyApple,
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    TextSpan(
                      text:
                          '. You probably want to check your network connection and then ',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                    TextSpan(
                      text: 'refresh',
                      style: TextStyle(
                        color: candyApple,
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    TextSpan(
                      text: '.',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : Expanded(child: Container());
    }

    Column _currentConditions() {
      return Column(
        children: <Widget>[
          Text(
            'Current Conditions:',
            style: TextStyle(
              height: textHeight,
              color: candyApple,
              fontSize: 16,
            ),
          ),
          Text(
            '${weatherConditions(widget.weatherConditions)}',
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
                  text: '${widget.weatherCurrentHumidity}%',
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

    Column _temps() {
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
                  text: '${widget.weatherCurrentTemp.round()}\u00B0',
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
                      ', ${(((widget.weatherCurrentTemp - 32) * 5) / 9).round()}\u00B0',
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
                  text: '${widget.weatherCurrentTempMin.round()}\u00B0',
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
                      ', ${(((widget.weatherCurrentTempMin - 32) * 5) / 9).round()}\u00B0',
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
                  text: '${widget.weatherCurrentTempMax.round()}\u00B0',
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
                      ', ${(((widget.weatherCurrentTempMax - 32) * 5) / 9).round()}\u00B0',
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

    Column _updateTime() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            'Updated at:',
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
                  text: 'There: ',
                  style: TextStyle(
                    height: textHeight,
                    color: candyApple,
                    fontSize: 16,
                  ),
                ),
                TextSpan(
                  text: '${updatedAt['There']}',
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
                  text: '${updatedAt['Here']}',
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
                  text: '${updatedAt['UTC']}',
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

    Column _wind() {
      return Column(
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
                  text: '${widget.weatherCurrentWindSpd.round()}',
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
                  text: '${(widget.weatherCurrentWindSpd * 1.60934).round()}',
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
                      ', ${(widget.weatherCurrentWindSpd * 0.868976).round()}',
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
                  text: '${widget.weatherCurrentWindDir}\u00B0, ',
                  style: TextStyle(
                    height: textHeight,
                    color: Colors.black,
                    fontSize: 16,
                  ),
                ),
                TextSpan(
                  text: '($windDirection)',
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

    Column _sunRise() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            'Sunrise:',
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
                  text: 'There: ',
                  style: TextStyle(
                    height: textHeight,
                    color: candyApple,
                    fontSize: 16,
                  ),
                ),
                TextSpan(
                  text: '${sunrise['There']}',
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
                  text: '${sunrise['Here']}',
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
                  text: '${sunrise['UTC']}',
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

    Column _sunSet() {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            'Sunset:',
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
                  text: 'There: ',
                  style: TextStyle(
                    height: textHeight,
                    color: candyApple,
                    fontSize: 16,
                  ),
                ),
                TextSpan(
                  text: '${sunset['There']}',
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
                  text: '${sunset['Here']}',
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
                  text: '${sunset['UTC']}',
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
                  text: '${widget.weatherCurrentPressure}',
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
                      '${(widget.weatherCurrentPressure * 29.53).round() / 1000}',
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
                      '${(widget.weatherCurrentPressure * 75.0062).round() / 100}',
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

    Column _visibility() {
      return Column(
        children: <Widget>[
          Text(
            'Visibility:',
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
                  text: '${widget.weatherCurrentVisibility}',
                  style: TextStyle(
                    height: textHeight,
                    color: Colors.black,
                    fontSize: 16,
                  ),
                ),
                TextSpan(
                  text: ' feet,',
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
                  text: '$visibilityMeters',
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
          RichText(
            text: TextSpan(
              children: <TextSpan>[
                TextSpan(
                  text: 'ID: ',
                  style: TextStyle(
                    height: textHeight,
                    color: candyApple,
                    fontSize: 16,
                  ),
                ),
                TextSpan(
                  text: '${widget.weatherLocationID}',
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
          imageUrl:
              'http://openweathermap.org/img/w/${widget.weatherConditionsIcon}.png',
        ),
      );
    }

    if (widget.weatherConditions == '') {
      return Container(
        margin: EdgeInsets.symmetric(
          vertical: 3,
          horizontal: 6,
        ),
        padding: myBoxPadding,
        decoration: myBoxDecoration(_stale ? Colors.grey : ivory),
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
      );
    } else if (_deviceWidth < 400) {
      return Container(
        margin: EdgeInsets.symmetric(
          vertical: 3,
          horizontal: 6,
        ),
        padding: myBoxPadding,
        decoration: myBoxDecoration(_stale ? Colors.grey : ivory),
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(
                top: 16.0,
                bottom: 2.0,
                right: 25.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  _refresh(),
                  _staleNotice(),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  _icon(),
                  _currentConditions(),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  _updateTime(),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  _temps(),
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
                  _visibility(),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  _sunRise(),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  _sunSet(),
                ],
              ),
            ),
          ],
        ),
      );
    } else if ((_deviceWidth >= 400) && (_deviceWidth < 650)) {
      return Container(
        margin: EdgeInsets.symmetric(
          vertical: 3,
          horizontal: 6,
        ),
        padding: myBoxPadding,
        decoration: myBoxDecoration(_stale ? Colors.grey : ivory),
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(
                top: 16.0,
                bottom: 2.0,
                right: 25.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  _refresh(),
                  _staleNotice(),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  _icon(),
                  _currentConditions(),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  _updateTime(),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  _temps(),
                  _wind(),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  _sunRise(),
                  _pressure(),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  _sunSet(),
                  _visibility(),
                ],
              ),
            ),
          ],
        ),
      );
    } else if ((_deviceWidth >= 650) && (_deviceWidth < 1000)) {
      return Container(
        margin: EdgeInsets.symmetric(
          vertical: 3,
          horizontal: 6,
        ),
        padding: myBoxPadding,
        decoration: myBoxDecoration(_stale ? Colors.grey : ivory),
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(
                top: 16.0,
                bottom: 2.0,
                right: 25.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  _refresh(),
                  _staleNotice(),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  _icon(),
                  _currentConditions(),
                  _temps(),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  _updateTime(),
                  _visibility(),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  _sunRise(),
                  _wind(),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  _sunSet(),
                  _pressure(),
                ],
              ),
            ),
          ],
        ),
      );
    } else if (_deviceWidth >= 1000) {
      return Container(
        margin: EdgeInsets.symmetric(
          vertical: 3,
          horizontal: 6,
        ),
        padding: myBoxPadding,
        decoration: myBoxDecoration(_stale ? Colors.grey : ivory),
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(
                top: 16.0,
                bottom: 2.0,
                right: 25.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: <Widget>[
                  _refresh(),
                  _staleNotice(),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  _icon(),
                  _currentConditions(),
                  _temps(),
                  _visibility(),
                  _updateTime(),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  _pressure(),
                  _sunRise(),
                  _sunSet(),
                  _wind(),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }

  Map<String, String> get3WayTime(int secondsFromEpoch, int timeOffSet) {
    DateTime utcTime =
        DateTime.fromMillisecondsSinceEpoch(secondsFromEpoch * 1000).toUtc();
    DateTime thereTime = utcTime.add(Duration(minutes: timeOffSet));
    DateTime hereTime = utcTime.toLocal();
    String there = (timeOffSet != 2000)
        ? DateFormat('EEEE MMMM d, HH:mm').format(thereTime)
        : 'UNKNOWN, INVALID';
    String here = DateFormat('EEEE MMMM d, HH:mm').format(hereTime);
    String utc = DateFormat('EEEE MMMM d, HH:mm').format(utcTime);
    return {
      'There': there,
      'Here': here,
      'UTC': utc,
    };
  }

  String getElapsedTimeString(int then, int now) {
    final int elapsedMin = ((now - then) / 60).round();
    final int elapsedHours = (elapsedMin / 60).floor();
    final int remainingMin = elapsedMin % 60;
    return (remainingMin < 10)
        ? elapsedHours.toString() + ':0' + remainingMin.toString()
        : elapsedHours.toString() + ':' + remainingMin.toString();
  }

  int getMeters(int feet) {
    return (feet != null) ? (feet * 0.3048).round() : null;
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
