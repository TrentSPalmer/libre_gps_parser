import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'global_helper_functions.dart';
import 'database_helper.dart';
import 'weather.dart';
import 'settings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() => runApp(MainApp());

class MainApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Lat\'n Long Share',
      theme: new ThemeData(
        primaryColor: navy,
      ),
      home: LatNLong(),
    );
  }
}

class LatNLong extends StatefulWidget {
  @override
  _LatNLongState createState() => new _LatNLongState();
}

class _LatNLongState extends State<LatNLong> {
  // https://stackoverflow.com/a/32437518 <- to here for time zone api info
  final dbHelper = DatabaseHelper.instance;
  static const platform = const MethodChannel('app.channel.shared.data');
  RegExp gmapExp = new RegExp(r'(https://maps.app.goo.gl/)(.*$)');
  String widgetMapLocation = "none";
  String latnLong = "none";
  String latnLongDMS = "none";
  int elevation;
  int feetElevation;
  Map<String, dynamic> _weather = {
    "id":0,
    "weather":[
      {
        "description":"none",
        "icon":"none"
      }
    ],
    "main": {
      "temp":0,
      "pressure":0,
      "humidity":0,
      "temp_min":0,
      "temp_max":0
    },
    "visibility":0,
    "wind": {
      "speed":0,
      "deg":0
    },
    "dt":0,
    "sunrise":0,
    "sunset":0
  };

  @override
  void initState() {
    super.initState();
    updateState();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      backgroundColor: peacock_blue,
      appBar: new AppBar(
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
                icon: const Icon(Icons.settings), onPressed: _settings);
          },
        ),
        title: new Text('Lat N Long Share'),
        actions: <Widget>[
          new IconButton(icon: const Icon(Icons.list), onPressed: _pushSaved),
        ],
      ),
      body: SingleChildScrollView(
        child: new Container(
          padding: EdgeInsets.all(20.0),
          child: new Wrap(
            spacing: 20.0,
            runSpacing: 20.0,
            alignment: WrapAlignment.spaceAround,
            children: <Widget>[
              Container(
                padding: myBoxPadding,
                decoration: myBoxDecoration(ivory),
                child: Text(
                  'DD / DMS: \n(${this.latnLong})\n(${this.latnLongDMS})' ,
                ),
              ),
              Container(
                padding: myBoxPadding,
                decoration: myBoxDecoration(ivory),
                child: Text(
                  this.widgetMapLocation,
                ),
              ),
              Container(
                padding: myBoxPadding,
                decoration: myBoxDecoration(ivory),
                child: Text(
                  'elevation: ${this.feetElevation.toString()} feet, ${this.elevation.toString()} meters',
                ),
              ),
              Weather(weather: this._weather,),
            ],
          ),
        ),
      ),
    );
  }

  void _settings() {
    Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => Settings()),
    );
  }

  void _pushSaved() async {
    List<String> sorted_Map_Locations = await dbHelper.sortedMapLocations();
    await Navigator.of(context).push(
      new MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return new Scaffold(
            backgroundColor: peacock_blue,
            appBar: new AppBar(
              title: const Text('Previous Locations'),
            ),
            body: _buildHistory(sorted_Map_Locations),
          );
        },
      ),
    );
  }

  Widget _buildHistory(List<String> sorted_Map_Locations) {
    return new ListView.builder(
      itemCount: sorted_Map_Locations.length,
      itemBuilder: (BuildContext ctxt, int i) {
        return new InkWell(
          onTap: () {
            selectMapLocation(sorted_Map_Locations[i]);
            Navigator.of(context).pop();
          },
          child: new Card(
            margin: EdgeInsets.all(4.0),
            color: Colors.black,
            child: new Card(
              margin: EdgeInsets.all(4.0),
              color: ivory,
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        sorted_Map_Locations[i],
                      ),
                    ),
                    Container(
                      child: new Icon(
                        Icons.arrow_right,
                        size: 50.0,
                        color: candy_apple,
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
      if (gmapExp.hasMatch(sharedData)) {
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
    await _Create_Row_If_Needed(sharedData);
    await _populateLatNLong(sharedData);
  }

  Future<void> _populateWeather(String mapLocation, String latLong) async {
    String weather = await getWeather(mapLocation,latLong);
    if (weather != null) {
      Map<String, dynamic> weatherJson = jsonDecode(weather);
      if (weatherJson != this._weather) {
        setState(() {
          this._weather = weatherJson;
        });
      }
    }
  }

  Future<void> _populateElevation(String mapLocation) async {
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

  Future<void> updateElevation(int timeStamp, String mapLocation) async {
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


  Future<void> _populateLatNLong(String mapLocation) async {
    await dbHelper.queryLatNLong(mapLocation).then((String lat_long) {
      if ((lat_long != this.latnLong) && (lat_long != 'NA')) {
        _populateElevation(mapLocation);
        _populateWeather(mapLocation, lat_long);
        setState(() {
          this.latnLong = lat_long;
          this.latnLongDMS = convertCoordinates(lat_long);
        });
      }
      if (lat_long == 'NA') {
        final int timeStamp = newTimeStamp();
        updateLatNLong(timeStamp, mapLocation);
      }
    });
  }

  Future<void> updateLatNLong(int timeStamp, String mapLocation) async {
    String mapUrl = gmapExp.stringMatch(mapLocation);
    await parseMapUrl(mapUrl).then((String lat_long) {
      setState(() {
        this.latnLong = lat_long;
        this.latnLongDMS = convertCoordinates(lat_long);
      });
      Map<String, dynamic> row = {
        DatabaseHelper.columnMapLocation: mapLocation,
        DatabaseHelper.columnLnlTime: timeStamp,
        DatabaseHelper.columnLatLong: lat_long
      };
      dbHelper.update(row);
      updateElevation(timeStamp, mapLocation);
      _populateWeather(mapLocation, lat_long);
    });
  }

  Future<void> selectMapLocation(String mapLocation) async {
    int time_Stamp = newTimeStamp();
    Map<String, dynamic> row = {
      DatabaseHelper.columnMapLocation: mapLocation,
      DatabaseHelper.columnViewTime: time_Stamp
    };
    setState(() {
      this.widgetMapLocation = mapLocation;
    });
    await dbHelper.update(row);
    await _populateLatNLong(mapLocation);
  }

  Future<void> _Create_Row_If_Needed(String mapLocation) async {
    final int rowExists = await dbHelper.queryRowExists(mapLocation);
    final int timeStamp = newTimeStamp();
    if (rowExists == 0) {
      Map<String, dynamic> row = {
        DatabaseHelper.columnMapLocation: mapLocation,
        DatabaseHelper.columnViewTime: timeStamp
      };
      final id = await dbHelper.insert(row);
    }
  }
}
