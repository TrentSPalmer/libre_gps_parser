import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'global_helper_functions.dart';
import 'weather_forecast.dart';
import 'database_helper.dart';
import 'default_plataea_notes.dart';
import 'render_notes.dart';
import 'street_view.dart';
import 'edit_notes.dart';
import 'lnl_deg.dart';
import 'lnl_dec.dart';
import 'location.dart';
import 'elevation.dart';
import 'timezone.dart';
import 'settings.dart';
import 'about.dart';
import 'dart:convert';
import 'weather.dart';

void main() => runApp(MainApp());

class MainApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Libre Gps Parser',
      theme: ThemeData(
        primaryColor: navy,
      ),
      home: LatNLong(),
    );
  }
}

class LatNLong extends StatefulWidget {
  @override
  _LatNLongState createState() => _LatNLongState();
}

class _LatNLongState extends State<LatNLong> {
  // https://stackoverflow.com/a/32437518 <- to here for time zone api info
  final dbHelper = DatabaseHelper.instance;
  static const platform = const MethodChannel('app.channel.shared.data');
  // "static" variables are hard-coded into the class rather than instances
  static RegExp mapExp = RegExp(
      r'(https://maps.app.goo.gl/|https://maps.google.com/|https?://mapq.st/)(.*$)');
  String widgetMapLocation = "none";
  String latnLong = "none";
  String latnLongDMS = "none";
  int elevation = 0;
  int feetElevation = 0;
  int weatherLocationID = 0;
  int weatherCurrentDT = 1556104969;
  String weatherConditions = '';
  String weatherConditionsIcon = '01d';
  double weatherCurrentTemp = 0.1;
  double weatherCurrentPressure = 0.0;
  int weatherCurrentHumidity = 0;
  double weatherCurrentTempMin = 0.1;
  double weatherCurrentTempMax = 0.1;
  int weatherCurrentVisibility = 0;
  double weatherCurrentWindSpd = 0.1;
  int weatherCurrentWindDir = 0;
  int weatherCurrentSunrise = 1556104969;
  int weatherCurrentSunset = 1556104969;
  int timeOffSet = -1;
  int timeOffSetTime = -1;
  int isAutoTimeOffSet = 1;
  String weatherForeCast = "none";
  final double textHeight = 1.5;
  String notes = '';
  bool _useElev = false;
  bool _useWTHR = false;

  @override
  void initState() {
    super.initState();
    updateState();
  }

  @override
  Widget build(BuildContext context) {
    final double _deviceShortestSide = MediaQuery.of(context).size.shortestSide;

    Widget _timezone() {
      return TimeZone(
          parentAction: this._userTzOffset,
          timeOffSet: this.timeOffSet,
          timeOffSetTime: this.timeOffSetTime,
          isAutoTimeOffSet: this.isAutoTimeOffSet);
    }

    InkWell _delete() {
      return InkWell(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.delete,
              size: 48.0,
              color: candyApple,
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
                  title: Text(
                    'Really?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: candyApple,
                    ),
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        'Delete this location from',
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        'the face of the earth forever?',
                        textAlign: TextAlign.center,
                      ),
                      Container(
                        margin: EdgeInsets.only(
                          top: 40,
                          bottom: 10,
                        ),
                        child: Wrap(
                          runSpacing: 30,
                          children: <Widget>[
                            Container(
                              margin: EdgeInsets.symmetric(
                                horizontal: 15,
                              ),
                              child: ButtonTheme(
                                shape: RoundedRectangleBorder(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(6.0)),
                                ),
                                height: 75,
                                child: RaisedButton(
                                    color: peacockBlue,
                                    child: Text(
                                      "launch iCBMs!",
                                      style: TextStyle(
                                        height: textHeight,
                                        color: Colors.white,
                                        fontSize: 24,
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      _deleteLocation();
                                    }),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.symmetric(
                                horizontal: 15,
                              ),
                              child: ButtonTheme(
                                height: 75,
                                child: RaisedButton(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(6.0)),
                                    ),
                                    color: peacockBlue,
                                    child: Text(
                                      "oops! nvrmnd!",
                                      style: TextStyle(
                                        height: textHeight,
                                        color: Colors.white,
                                        fontSize: 24,
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    }),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              });
        },
      );
    }

    Row _editNotes() {
      return Row(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: InkWell(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.edit,
                    size: 48.0,
                    color: Colors.black,
                  ),
                ],
              ),
              onTap: () async {
                String _noteText = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => EditNotes(
                            mapLocation: this.widgetMapLocation,
                          )),
                );
                if ((_noteText != null) && (_noteText != this.notes)) {
                  setState(() {
                    this.notes = _noteText;
                  });
                }
              },
            ),
          ),
          ((this.notes.length > 0)
              ? Expanded(
                  flex: 5,
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
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Icon(
                            Icons.view_agenda,
                            size: 48.0,
                            color: Colors.black,
                          ),
                        ],
                      ),
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => RenderNotes(
                                    notes: this.notes,
                                  )),
                        );
                      },
                    ),
                  ),
                )
              : Container()),
        ],
      );
    }

    Container _top() {
      if (_deviceShortestSide < 400) {
        return Container(
          child: Column(
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(
                  left: 6,
                  top: 6,
                  right: 6,
                  bottom: 3,
                ),
                padding: myBoxPadding,
                decoration: myBoxDecoration(ivory),
                child: (this.latnLong != null)
                    ? lnlDec(this.latnLong)
                    : lnlDec('none'),
              ),
              IntrinsicHeight(
                child: Row(
                  children: <Widget>[
                    Expanded(
                      flex: 7,
                      child: Container(
                        margin: EdgeInsets.only(
                          left: 6,
                          top: 3,
                          right: 6,
                          bottom: 3,
                        ),
                        padding: myBoxPadding,
                        decoration: myBoxDecoration(ivory),
                        child: (this.latnLongDMS != null)
                            ? lnlDeg(this.latnLongDMS)
                            : lnlDeg('none'),
                      ),
                    ),
                  ],
                ),
              ),
              IntrinsicHeight(
                child: Row(
                  children: <Widget>[
                    Expanded(
                      flex: 5,
                      child: Container(
                        margin: EdgeInsets.only(
                          left: 6,
                          top: 3,
                          right: 3,
                          bottom: 3,
                        ),
                        padding: myBoxPadding,
                        decoration: myBoxDecoration(ivory),
                        child: _editNotes(),
                      ),
                    ),
                    Expanded(
                      flex: 5,
                      child: Container(
                        margin: EdgeInsets.only(
                          left: 3,
                          top: 3,
                          right: 6,
                          bottom: 3,
                        ),
                        padding: myBoxPadding,
                        decoration: myBoxDecoration(ivory),
                        child: streetView(this.latnLong),
                      ),
                    ),
                  ],
                ),
              ),
              IntrinsicHeight(
                child: Row(
                  children: <Widget>[
                    Expanded(
                      flex: 7,
                      child: Container(
                        margin: EdgeInsets.only(
                          left: 6,
                          top: 3,
                          right: 6,
                          bottom: 3,
                        ),
                        padding: myBoxPadding,
                        decoration: myBoxDecoration(ivory),
                        child: Location(
                          mapLocation: this.widgetMapLocation,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              IntrinsicHeight(
                child: Row(
                  children: <Widget>[
                    Expanded(
                      flex: 3,
                      child: Container(
                        margin: EdgeInsets.only(
                          left: 6,
                          top: 3,
                          right: 3,
                          bottom: 3,
                        ),
                        padding: myBoxPadding,
                        decoration: myBoxDecoration(ivory),
                        child: aboutApp(context),
                      ),
                    ),
                    ((this._useElev)
                        ? Expanded(
                            flex: 4,
                            child: Container(
                              margin: EdgeInsets.only(
                                left: 3,
                                top: 3,
                                right: 3,
                                bottom: 3,
                              ),
                              padding: myBoxPadding,
                              decoration: myBoxDecoration(ivory),
                              child: elevAtion(
                                  context, this.elevation, this.feetElevation),
                            ),
                          )
                        : Container()),
                    Expanded(
                      flex: 3,
                      child: Container(
                        margin: EdgeInsets.only(
                          left: 3,
                          top: 3,
                          right: 6,
                          bottom: 3,
                        ),
                        padding: myBoxPadding,
                        decoration: myBoxDecoration(ivory),
                        child: _delete(),
                      ),
                    ),
                  ],
                ),
              ),
              IntrinsicHeight(
                child: Row(
                  children: <Widget>[
                    ((this._useWTHR)
                        ? Expanded(
                            flex: 7,
                            child: Container(
                              margin: EdgeInsets.only(
                                left: 6,
                                top: 3,
                                right: 6,
                                bottom: 3,
                              ),
                              padding: myBoxPadding,
                              decoration: myBoxDecoration(ivory),
                              child: _timezone(),
                            ),
                          )
                        : Container()),
                  ],
                ),
              ),
            ],
          ),
        );
      } else if ((_deviceShortestSide >= 400) && (_deviceShortestSide < 650)) {
        return Container(
          child: Column(
            children: <Widget>[
              IntrinsicHeight(
                child: Row(
                  children: <Widget>[
                    Expanded(
                      flex: 7,
                      child: Container(
                        margin: EdgeInsets.only(
                          left: 6,
                          top: 6,
                          right: 3,
                          bottom: 3,
                        ),
                        padding: myBoxPadding,
                        decoration: myBoxDecoration(ivory),
                        child: (this.latnLongDMS != null)
                            ? lnlDeg(this.latnLongDMS)
                            : lnlDeg('none'),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Container(
                        margin: EdgeInsets.only(
                          left: 3,
                          top: 6,
                          right: 6,
                          bottom: 3,
                        ),
                        padding: myBoxPadding,
                        decoration: myBoxDecoration(ivory),
                        child: _delete(),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                margin: EdgeInsets.only(
                  left: 6,
                  top: 3,
                  right: 6,
                  bottom: 3,
                ),
                padding: myBoxPadding,
                decoration: myBoxDecoration(ivory),
                child: (this.latnLong != null)
                    ? lnlDec(this.latnLong)
                    : lnlDec('none'),
              ),
              IntrinsicHeight(
                child: Row(
                  children: <Widget>[
                    Expanded(
                      flex: 5,
                      child: Container(
                        margin: EdgeInsets.only(
                          left: 6,
                          top: 3,
                          right: 3,
                          bottom: 3,
                        ),
                        padding: myBoxPadding,
                        decoration: myBoxDecoration(ivory),
                        child: _editNotes(),
                      ),
                    ),
                    Expanded(
                      flex: 5,
                      child: Container(
                        margin: EdgeInsets.only(
                          left: 3,
                          top: 3,
                          right: 6,
                          bottom: 3,
                        ),
                        padding: myBoxPadding,
                        decoration: myBoxDecoration(ivory),
                        child: streetView(this.latnLong),
                      ),
                    ),
                  ],
                ),
              ),
              IntrinsicHeight(
                child: Row(
                  children: <Widget>[
                    Expanded(
                      flex: 7,
                      child: Container(
                        margin: EdgeInsets.only(
                          left: 6,
                          top: 3,
                          right: 3,
                          bottom: 3,
                        ),
                        padding: myBoxPadding,
                        decoration: myBoxDecoration(ivory),
                        child: Location(
                          mapLocation: this.widgetMapLocation,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Container(
                        margin: EdgeInsets.only(
                          left: 3,
                          top: 3,
                          right: 6,
                          bottom: 3,
                        ),
                        padding: myBoxPadding,
                        decoration: myBoxDecoration(ivory),
                        child: aboutApp(context),
                      ),
                    ),
                  ],
                ),
              ),
              IntrinsicHeight(
                child: Row(
                  children: <Widget>[
                    ((this._useElev)
                        ? Expanded(
                            flex: 3,
                            child: Container(
                              margin: EdgeInsets.only(
                                left: 6,
                                top: 3,
                                right: (this._useWTHR) ? 3 : 6,
                                bottom: 3,
                              ),
                              padding: myBoxPadding,
                              decoration: myBoxDecoration(ivory),
                              child: elevAtion(
                                  context, this.elevation, this.feetElevation),
                            ),
                          )
                        : Container()),
                    ((this._useWTHR)
                        ? Expanded(
                            flex: 7,
                            child: Container(
                              margin: EdgeInsets.only(
                                left: (this._useElev) ? 3 : 6,
                                top: 3,
                                right: 6,
                                bottom: 3,
                              ),
                              padding: myBoxPadding,
                              decoration: myBoxDecoration(ivory),
                              child: _timezone(),
                            ),
                          )
                        : Container()),
                  ],
                ),
              ),
            ],
          ),
        );
      } else if (_deviceShortestSide >= 650) {
        return Container(
          child: Column(
            children: <Widget>[
              IntrinsicHeight(
                child: Row(
                  children: <Widget>[
                    Expanded(
                      flex: 3,
                      child: Container(
                        margin: EdgeInsets.only(
                          left: 6,
                          top: 6,
                          right: 3,
                          bottom: 3,
                        ),
                        padding: myBoxPadding,
                        decoration: myBoxDecoration(ivory),
                        child: _editNotes(),
                      ),
                    ),
                    Expanded(
                      flex: 5,
                      child: Container(
                        margin: EdgeInsets.only(
                          left: 3,
                          top: 6,
                          right: 3,
                          bottom: 3,
                        ),
                        padding: myBoxPadding,
                        decoration: myBoxDecoration(ivory),
                        child: (this.latnLong != null)
                            ? lnlDec(this.latnLong)
                            : lnlDec('none'),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Container(
                        margin: EdgeInsets.only(
                          left: 3,
                          top: 6,
                          right: 6,
                          bottom: 3,
                        ),
                        padding: myBoxPadding,
                        decoration: myBoxDecoration(ivory),
                        child: _delete(),
                      ),
                    ),
                  ],
                ),
              ),
              IntrinsicHeight(
                child: Row(
                  children: <Widget>[
                    Expanded(
                      flex: 5,
                      child: Container(
                        margin: EdgeInsets.only(
                          left: 6,
                          top: 3,
                          right: 3,
                          bottom: 3,
                        ),
                        padding: myBoxPadding,
                        decoration: myBoxDecoration(ivory),
                        child: (this.latnLongDMS != null)
                            ? lnlDeg(this.latnLongDMS)
                            : lnlDeg('none'),
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Container(
                        margin: EdgeInsets.only(
                          left: 3,
                          top: 3,
                          right: 3,
                          bottom: 3,
                        ),
                        padding: myBoxPadding,
                        decoration: myBoxDecoration(ivory),
                        child: streetView(this.latnLong),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: Container(
                        margin: EdgeInsets.only(
                          left: 3,
                          top: 3,
                          right: 6,
                          bottom: 3,
                        ),
                        padding: myBoxPadding,
                        decoration: myBoxDecoration(ivory),
                        child: aboutApp(context),
                      ),
                    ),
                  ],
                ),
              ),
              IntrinsicHeight(
                child: Row(
                  children: <Widget>[
                    Expanded(
                      flex: 4,
                      child: Container(
                        margin: EdgeInsets.only(
                          left: 6,
                          top: 3,
                          right: 3,
                          bottom: 3,
                        ),
                        padding: myBoxPadding,
                        decoration: myBoxDecoration(ivory),
                        child: Location(
                          mapLocation: this.widgetMapLocation,
                        ),
                      ),
                    ),
                    ((this._useElev)
                        ? Expanded(
                            flex: 2,
                            child: Container(
                              margin: EdgeInsets.only(
                                left: 3,
                                top: 3,
                                right: (this._useWTHR) ? 3 : 6,
                                bottom: 3,
                              ),
                              padding: myBoxPadding,
                              decoration: myBoxDecoration(ivory),
                              child: elevAtion(
                                  context, this.elevation, this.feetElevation),
                            ),
                          )
                        : Container()),
                    ((this._useWTHR)
                        ? Expanded(
                            flex: 4,
                            child: Container(
                              margin: EdgeInsets.only(
                                left: 3,
                                top: 3,
                                right: 6,
                                bottom: 3,
                              ),
                              padding: myBoxPadding,
                              decoration: myBoxDecoration(ivory),
                              child: _timezone(),
                            ),
                          )
                        : Container()),
                  ],
                ),
              ),
            ],
          ),
        );
      }
    }

    return Scaffold(
      backgroundColor: peacockBlue,
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            floating: true,
            snap: false,
            pinned: false,
            expandedHeight: 50,
            leading: Builder(
              builder: (BuildContext context) {
                return IconButton(
                    icon: const Icon(Icons.settings), onPressed: _settings);
              },
            ),
            title: Text('Libre Gps Parser'),
            actions: <Widget>[
              IconButton(icon: const Icon(Icons.list), onPressed: _pushSaved),
            ],
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                _top(),
                ((this._useWTHR)
                    ? Weather(
                        weatherLocationID: this.weatherLocationID,
                        weatherConditions: this.weatherConditions,
                        weatherConditionsIcon: this.weatherConditionsIcon,
                        weatherCurrentTemp: this.weatherCurrentTemp,
                        weatherCurrentPressure: this.weatherCurrentPressure,
                        weatherCurrentHumidity: this.weatherCurrentHumidity,
                        weatherCurrentTempMin: this.weatherCurrentTempMin,
                        weatherCurrentTempMax: this.weatherCurrentTempMax,
                        weatherCurrentVisibility: this.weatherCurrentVisibility,
                        weatherCurrentWindSpd: this.weatherCurrentWindSpd,
                        weatherCurrentWindDir: this.weatherCurrentWindDir,
                        weatherCurrentSunrise: this.weatherCurrentSunrise,
                        weatherCurrentSunset: this.weatherCurrentSunset,
                        weatherCurrentDT: this.weatherCurrentDT,
                        timeOffSet: this.timeOffSet,
                        parentAction: this._refreshWeather,
                      )
                    : Container()),
                ((this._useWTHR)
                    ? WeatherForeCast(
                        weatherForeCast: this.weatherForeCast,
                        timeOffSet: this.timeOffSet,
                      )
                    : Container()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _settings() async {
    int newSetting = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => Settings()),
    );
    if (newSetting != null) {
      await _getUseElevPref();
    }
  }

  void _pushSaved() async {
    List<String> sortedMapLocations = await dbHelper.sortedMapLocations();
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return Scaffold(
            backgroundColor: peacockBlue,
            appBar: AppBar(
              title: const Text('Previous Locations'),
            ),
            body: _buildHistory(sortedMapLocations),
          );
        },
      ),
    );
  }

  Widget _buildHistory(List<String> sortedMapLocations) {
    return ListView.builder(
      itemCount: sortedMapLocations.length,
      itemBuilder: (BuildContext ctxt, int i) {
        return InkWell(
          onTap: () {
            selectMapLocation(sortedMapLocations[i]);
            Navigator.of(context).pop();
          },
          child: Card(
            margin: EdgeInsets.all(4.0),
            color: Colors.black,
            child: Card(
              margin: EdgeInsets.all(4.0),
              color: ivory,
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        sortedMapLocations[i],
                      ),
                    ),
                    Container(
                      child: Icon(
                        Icons.arrow_right,
                        size: 50.0,
                        color: candyApple,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> updateState() async {
    var sharedData = await platform.invokeMethod("getSharedText");
    if (sharedData != null && sharedData is String) {
      if (mapExp.hasMatch(sharedData)) {
        setState(() {
          this.widgetMapLocation = sharedData;
        });
      }
    } else if (sharedData == null) {
      sharedData = await dbHelper.queryNewestMapLocation();
      if (sharedData != null && sharedData is String) {
        setState(() {
          this.widgetMapLocation = sharedData;
        });
      }
    }
    await _createRowIfNeeded(sharedData);
    await _getUseElevPref();
    await _populateNotes(sharedData);
  }

  Future<void> _populateNotes(String mapLocation) async {
    String _notes = await dbHelper.queryNotes(mapLocation);
    if ((_notes != null) || (_notes != this.notes)) {
      if ((mapLocation.contains('Plataea')) && (_notes.length == 0)) {
        _notes = defaultPlataeaNotes;
      }
      setState(() {
        this.notes = _notes;
      });
    }
  }

  Future<void> _populateWeatherForeCast(
      String mapLocation, String latLong) async {
    if ((this._useWTHR) && (latLong != null)) {
      String weatherForeCast =
          await getWeatherForeCast(mapLocation, latLong, false);
      if (weatherForeCast == 'NA') {
        weatherForeCast = await getWeatherForeCast(mapLocation, latLong, true);
      }
      if (weatherForeCast != null) {
        setState(() {
          this.weatherForeCast = weatherForeCast;
        });
        Map<String, dynamic> weatherForeCastJson = jsonDecode(weatherForeCast);
        int _threeHoursAgo = (newTimeStamp() - 10800);
        if (weatherForeCastJson['list'][1]['dt'] < _threeHoursAgo) {
          weatherForeCast =
              await getWeatherForeCast(mapLocation, latLong, true);
          setState(() {
            this.weatherForeCast = weatherForeCast;
          });
        }
      }
    }
  }

  Future<void> _refreshWeather() async {
    await _populateWeather(this.widgetMapLocation, this.latnLong);
    await _populateWeatherForeCast(this.widgetMapLocation, this.latnLong);
  }

  Future<void> _populateWeather(String mapLocation, String latLong) async {
    if ((this._useWTHR) && (latLong != null)) {
      String weather = await getWeather(mapLocation, latLong, false);
      if (weather == 'NA') {
        weather = await getWeather(mapLocation, latLong, true);
      }
      if (weather != null) {
        Map<String, dynamic> weatherJson = jsonDecode(weather);
        _updateWeather(weatherJson, latLong);
        int timeStamp = newTimeStamp();
        if ((timeStamp - weatherJson['dt']) > 3600) {
          String _newweather = await getWeather(mapLocation, latLong, true);
          Map<String, dynamic> _newweatherJson = jsonDecode(_newweather);
          _updateWeather(_newweatherJson, latLong);
        }
      }
    }
  }

  Future<void> _updateWeather(
      Map<String, dynamic> weatherJson, String latLong) async {
    if (this._useWTHR) {
      int _weatherId = (weatherJson['id'] != 0)
          ? weatherJson['id']
          : generateFakeWeatherId(latLong);
      if ((_weatherId != this.weatherLocationID) ||
          (weatherJson['dt'] != this.weatherCurrentDT)) {
        double tempTemp = (weatherJson['main']['temp'] != null)
            ? (weatherJson['main']['temp']).toDouble()
            : 0;
        double tempPressure = (weatherJson['main']['pressure'] != null)
            ? (weatherJson['main']['pressure']).toDouble()
            : 0.0;
        int tempHumidity = (weatherJson['main']['humidity'] != null)
            ? (weatherJson['main']['humidity']).round()
            : 0;
        double tempTempMin = (weatherJson['main']['temp_min'] != null)
            ? (weatherJson['main']['temp_min']).toDouble()
            : 0;
        double tempTempMax = (weatherJson['main']['temp_max'] != null)
            ? (weatherJson['main']['temp_max']).toDouble()
            : 0;
        double tempWindSpd = (weatherJson['wind']['speed'] != null)
            ? (weatherJson['wind']['speed']).toDouble()
            : 0;
        int tempWindDir = (weatherJson['wind']['deg'] != null)
            ? (weatherJson['wind']['deg']).round()
            : 0;
        setState(() {
          this.weatherLocationID = _weatherId;
          this.weatherCurrentDT = weatherJson['dt'];
          this.weatherConditions = weatherJson['weather'][0]['description'];
          this.weatherConditionsIcon = weatherJson['weather'][0]['icon'];
          this.weatherCurrentTemp = tempTemp;
          this.weatherCurrentPressure = tempPressure;
          this.weatherCurrentHumidity = tempHumidity;
          this.weatherCurrentTempMin = tempTempMin;
          this.weatherCurrentTempMax = tempTempMax;
          this.weatherCurrentVisibility = weatherJson['visibility'];
          this.weatherCurrentWindSpd = tempWindSpd;
          this.weatherCurrentWindDir = tempWindDir;
          this.weatherCurrentSunrise = weatherJson['sys']['sunrise'];
          this.weatherCurrentSunset = weatherJson['sys']['sunset'];
        });
      }
    }
  }

  Future<void> _populateElevation(String mapLocation) async {
    if (this._useElev) {
      await dbHelper.queryElevation(mapLocation).then((int elev) {
        if (elev != this.elevation) {
          if (elev != null) {
            setState(() {
              this.elevation = elev;
              this.feetElevation = (elev * 3.28084).round();
            });
          }
        }
        if (elev == null) {
          final int timeStamp = newTimeStamp();
          updateElevation(timeStamp, mapLocation);
        }
      });
    }
  }

  Future<void> updateElevation(int timeStamp, String mapLocation) async {
    if (this._useElev) {
      await fetchElevation(mapLocation).then((int elev) {
        if (elev != null) {
          setState(() {
            this.elevation = elev;
            this.feetElevation = (elev * 3.28084).round();
          });
        } else {
          setState(() {
            this.elevation = null;
            this.feetElevation = null;
          });
        }
        Map<String, dynamic> row = {
          DatabaseHelper.columnMapLocation: mapLocation,
          DatabaseHelper.columnElevTime: timeStamp,
          DatabaseHelper.columnElev: elev
        };
        dbHelper.update(row);
      });
    }
  }

  Future<void> _populateLatNLong(String mapLocation) async {
    await dbHelper.queryLatNLong(mapLocation).then((String lattLong) {
      if (lattLong != 'NA') {
        _populateElevation(mapLocation);
        _populateWeather(mapLocation, lattLong);
        _populateWeatherForeCast(mapLocation, lattLong);
        _populateTimeOffSet(mapLocation, lattLong);
        if (lattLong != this.latnLong) {
          setState(() {
            this.latnLong = lattLong;
            this.latnLongDMS = convertCoordinates(lattLong);
          });
        }
      } else if (lattLong == 'NA') {
        final int timeStamp = newTimeStamp();
        _updateLatNLong(timeStamp, mapLocation);
      }
    });
  }

  Future<void> _updateLatNLong(int timeStamp, String mapLocation) async {
    String mapUrl = mapExp.stringMatch(mapLocation);
    await parseMapUrl(mapUrl).then((String lattLong) {
      setState(() {
        this.latnLong = lattLong;
        this.latnLongDMS = convertCoordinates(lattLong);
      });
      Map<String, dynamic> row = {
        DatabaseHelper.columnMapLocation: mapLocation,
        DatabaseHelper.columnLnlTime: timeStamp,
        DatabaseHelper.columnLatLong: lattLong
      };
      dbHelper.update(row);
      updateElevation(timeStamp, mapLocation);
      _populateWeather(mapLocation, lattLong);
      _populateWeatherForeCast(mapLocation, lattLong);
      _populateTimeOffSet(mapLocation, lattLong);
    });
  }

  Future<void> selectMapLocation(String mapLocation) async {
    int timesStamp = newTimeStamp();
    Map<String, dynamic> row = {
      DatabaseHelper.columnMapLocation: mapLocation,
      DatabaseHelper.columnViewTime: timesStamp
    };
    setState(() {
      this.widgetMapLocation = mapLocation;
      this.weatherConditions = '';
      this.weatherForeCast = 'none';
      this.timeOffSet = -1;
      this.timeOffSetTime = -1;
    });
    await dbHelper.update(row);
    await _getUseElevPref();
    await _populateNotes(mapLocation);
  }

  Future<void> _createRowIfNeeded(String mapLocation) async {
    final int rowExists = await dbHelper.queryRowExists(mapLocation);
    final int timeStamp = newTimeStamp();
    if (rowExists == 0) {
      Map<String, dynamic> row = {
        DatabaseHelper.columnMapLocation: mapLocation,
        DatabaseHelper.columnViewTime: timeStamp
      };
      await dbHelper.insert(row);
    }
  }

  Future<void> _deleteLocation() async {
    String _secondNewest = await dbHelper.querySecondNewestMapLocation();
    if (_secondNewest != 'none') {
      String locationToBeDeleted = this.widgetMapLocation;
      await selectMapLocation(_secondNewest);
      await dbHelper.delete(locationToBeDeleted);
    }
  }

  Future<void> _populateTimeOffSet(String mapLocation, String latLong) async {
    if ((this._useWTHR) && (latLong != null)) {
      List<int> _timeOffSet = await getTimeOffSet(mapLocation, latLong);
      setState(() {
        this.timeOffSet = _timeOffSet[0];
        this.timeOffSetTime = _timeOffSet[1];
        this.isAutoTimeOffSet = _timeOffSet[2];
      });
    }
  }

  Future<void> _userTzOffset(int offset) async {
    if (this._useWTHR) {
      if (offset > 1999) {
        // 2001 is magic number for auto
        List<int> _timeOffSet =
            await refreshTimeOffSet(this.widgetMapLocation, this.latnLong);
        setState(() {
          this.timeOffSet = _timeOffSet[0];
          this.timeOffSetTime = _timeOffSet[1];
          this.isAutoTimeOffSet = 1;
        });
        Map<String, dynamic> row = {
          DatabaseHelper.columnMapLocation: this.widgetMapLocation,
          DatabaseHelper.columnIsAutoTimeOffset: 1
        };
        await dbHelper.update(row);
      } else if (offset < 2000) {
        setState(() {
          this.timeOffSet = offset;
          this.isAutoTimeOffSet = 0;
        });
        Map<String, dynamic> row = {
          DatabaseHelper.columnMapLocation: this.widgetMapLocation,
          DatabaseHelper.columnTimeOffSet: offset,
          DatabaseHelper.columnIsAutoTimeOffset: 0
        };
        await dbHelper.update(row);
      }
    }
  }

  Future<void> _getUseElevPref() async {
    bool _useElevation = await getPreferenceUseElevation();
    if (_useElevation != _useElev) {
      setState(() {
        this._useElev = _useElevation;
      });
    }
    await _getUseWeatherPref();
  }

  Future<void> _getUseWeatherPref() async {
    bool _useWeather = await getPreferenceUseWeather();
    if (_useWeather != _useWTHR) {
      setState(() {
        this._useWTHR = _useWeather;
      });
    }
    await _populateLatNLong(this.widgetMapLocation);
  }
}
