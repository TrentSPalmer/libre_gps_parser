import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'database_helper.dart';
import 'dart:convert';

final EdgeInsets myBoxPadding = EdgeInsets.all(10.0);
final Color navy = Color(0xff00293C);
final Color peacockBlue = Color(0xff1e656d);
final Color ivory = Color(0xfff1f3ce);
final Color candyApple = Color(0xfff62a00);
final String weatherApiUrlPrefix =
    'https://api.openweathermap.org/data/2.5/weather?';
final String weatherForecastApiUrlPrefix =
    'https://api.openweathermap.org/data/2.5/forecast?';

Future<List<int>> refreshTimeOffSet(String mapLocation, String latLong) async {
  final dbHelper = DatabaseHelper.instance;
  final int _timeStamp = newTimeStamp();
  int _isAutoTimeOffset = await dbHelper.queryIsAutoTimeOffSet(mapLocation);
  String timeZoneApiUrl =
      'https://api.teleport.org/api/locations/$latLong/?embed=location:nearest-cities/location:nearest-city/city:timezone/tz:offsets-now';
  Response response;
  try {
    response = await get(timeZoneApiUrl);
  } catch (e) {
    print('$e in source file global_helper_functions.dart.getTimeOffSet');
  }
  if (response.statusCode == 200) {
    Map<String, dynamic> responseJson;
    int offSetMin = 2000;
    try {
      responseJson = jsonDecode(response.body);
      offSetMin = responseJson['_embedded']['location:nearest-cities'][0]
                    ['_embedded']['location:nearest-city']['_embedded']
                ['city:timezone']['_embedded']['tz:offsets-now']
            ['total_offset_min'] ??
        2000;
    } catch (e) {
      print('$e in source file global_helper_functions.dart.getTimeOffSet, can\'t assign  Map<String, dynamic> responseJson');
    }
    Map<String, dynamic> row = {
      DatabaseHelper.columnMapLocation: mapLocation,
      DatabaseHelper.columnTimeOffSet: offSetMin,
      DatabaseHelper.columnTimeOffSetTime: _timeStamp
    };
    await dbHelper.update(row);
    return ([offSetMin, _timeStamp, _isAutoTimeOffset]);
  } else {
    Map<String, dynamic> row = {
      DatabaseHelper.columnMapLocation: mapLocation,
      DatabaseHelper.columnTimeOffSet: 2000,
      DatabaseHelper.columnTimeOffSetTime: _timeStamp
    };
    await dbHelper.update(row);
    return ([2000, _timeStamp, _isAutoTimeOffset]);
  }
}

Future<List<int>> getTimeOffSet(String mapLocation, String latLong) async{
  final dbHelper = DatabaseHelper.instance;
  final int _timeStamp = newTimeStamp();
  int timeOffSetTime = await dbHelper.queryTimeOffSetTime(mapLocation);
  int _isAutoTimeOffset = await dbHelper.queryIsAutoTimeOffSet(mapLocation);
  if ((_timeStamp - timeOffSetTime) > 604800) {
    String timeZoneApiUrl =
        'https://api.teleport.org/api/locations/$latLong/?embed=location:nearest-cities/location:nearest-city/city:timezone/tz:offsets-now';
    Response response;
    try {
      response = await get(timeZoneApiUrl);
    } catch (e) {
      print('$e in source file global_helper_functions.dart.getTimeOffSet');
      int timeOffSet = await dbHelper.queryTimeOffSet(mapLocation);
      return ([timeOffSet, timeOffSetTime, _isAutoTimeOffset]);
    }
    if (response.statusCode == 200) {
      Map<String, dynamic> responseJson;
      int offSetMin = 2000;
      try {
        responseJson = jsonDecode(response.body);
        offSetMin = responseJson['_embedded']['location:nearest-cities'][0]
                      ['_embedded']['location:nearest-city']['_embedded']
                  ['city:timezone']['_embedded']['tz:offsets-now']
              ['total_offset_min'] ??
          2000;
      } catch (e) {
        print('$e in source file global_helper_functions.dart.getTimeOffSet, can\'t assign  Map<String, dynamic> responseJson');
      }
      Map<String, dynamic> row = {
        DatabaseHelper.columnMapLocation: mapLocation,
        DatabaseHelper.columnTimeOffSet: offSetMin,
        DatabaseHelper.columnTimeOffSetTime: _timeStamp
      };
      await dbHelper.update(row);
      return ([offSetMin, _timeStamp, _isAutoTimeOffset]);
    } else {
      Map<String, dynamic> row = {
        DatabaseHelper.columnMapLocation: mapLocation,
        DatabaseHelper.columnTimeOffSet: 2000,
        DatabaseHelper.columnTimeOffSetTime: _timeStamp
      };
      await dbHelper.update(row);
      return ([2000, _timeStamp, _isAutoTimeOffset]);
    }
  }
  int timeOffSet = await dbHelper.queryTimeOffSet(mapLocation);
  return ([timeOffSet, timeOffSetTime, _isAutoTimeOffset]);
}

// should be similar to getWeatherForeCast();
Future<String> getWeather(
    String mapLocation, String lattLong, bool stale) async {
  // https://dragosholban.com/2018/07/01/how-to-build-a-simple-weather-app-in-flutter
  final dbHelper = DatabaseHelper.instance;
  String weatherApiID = await getPreferenceOpenWeatherMapApiKey();
  if (weatherApiID == 'none?') {
    return null;
  } else {
    int weatherID = await dbHelper.queryWeatherID(mapLocation);
    if ((weatherID == null) || (stale == true)) {
      List<String> latLong = lattLong.split(',');
      String weatherApiUrl;
      if ((weatherID == null) || (weatherID < 0)) {
        weatherApiUrl =
            '${weatherApiUrlPrefix}lat=${latLong[0]}&lon=${latLong[1]}&units=imperial&appid=$weatherApiID';
      } else {
        weatherApiUrl =
            '${weatherApiUrlPrefix}id=$weatherID&units=imperial&appid=$weatherApiID';
      }
      try {
        Response response = await get(weatherApiUrl);
        if (response.statusCode == 200) {
          Map<String, dynamic> responseJson = jsonDecode(response.body);
          weatherID = (responseJson['id'] != 0) ? responseJson['id'] : generateFakeWeatherId(lattLong);
          Map<String, dynamic> row = {
            DatabaseHelper.columnMapLocation: mapLocation,
            DatabaseHelper.columnWeatherID: weatherID
          };
          await dbHelper.update(row);
          Map<String, dynamic> row2 = {
            DatabaseHelper.columnWeatherWeatherID: weatherID,
            DatabaseHelper.columnWeather: response.body
          };
          int weatherIDExists = await dbHelper.queryWeatherIDExists(weatherID);
          if (weatherIDExists == 0) {
            dbHelper.insertWeatherRow(row2);
          } else {
            dbHelper.updateWeathTbl(row2);
          }
          return response.body;
        }
      } catch(e) {
        print('$e, can\'t connect to openweathermap in global_helper_functions');
        weatherID ??= generateFakeWeatherId(lattLong); // assign if null
        String weather = await dbHelper.queryWeather(weatherID);
        return weather ?? 'NA';
      }
    } else {
      String weather = await dbHelper.queryWeather(weatherID);
      return weather ?? 'NA';
    }
  }
  return null;
}

// should be similar to getWeather();
Future<String> getWeatherForeCast(
    String mapLocation, String lattLong, bool stale) async {
  // https://dragosholban.com/2018/07/01/how-to-build-a-simple-weather-app-in-flutter
  final dbHelper = DatabaseHelper.instance;
  String weatherApiID = await getPreferenceOpenWeatherMapApiKey();
  if (weatherApiID == 'none?') {
    return null;
  } else {
    int weatherID = await dbHelper.queryWeatherID(mapLocation);
    if (weatherID == 0) {
      weatherID = generateFakeWeatherId(lattLong);
    }
    int weatherIDExists = await dbHelper.queryWeatherIDExists(weatherID);
    if (weatherIDExists == 0) { stale = true; }
    if ((weatherID == null) || (stale == true)) {
      List<String> latLong = lattLong.split(',');
      String weatherForeCastApiUrl;
      if ((weatherID == null) || (weatherID < 0)) {
        weatherForeCastApiUrl =
            '${weatherForecastApiUrlPrefix}lat=${latLong[0]}&lon=${latLong[1]}&units=imperial&appid=$weatherApiID';
      } else {
        weatherForeCastApiUrl =
            '${weatherForecastApiUrlPrefix}id=$weatherID&units=imperial&appid=$weatherApiID';
      }
      try {
      Response response = await get(weatherForeCastApiUrl);
        if (response.statusCode == 200) {
          Map<String, dynamic> responseJson = jsonDecode(response.body);
          weatherID = responseJson['city']['id'];
          weatherID ??= generateFakeWeatherId(lattLong);  // assign if null
          Map<String, dynamic> row = {
            DatabaseHelper.columnMapLocation: mapLocation,
            DatabaseHelper.columnWeatherID: weatherID
          };
          await dbHelper.update(row);
          Map<String, dynamic> row2 = {
            DatabaseHelper.columnWeatherWeatherID: weatherID,
            DatabaseHelper.columnWeatherForecast: response.body
          };
          int weatherIDExists = await dbHelper.queryWeatherIDExists(weatherID);
          if (weatherIDExists == 0) {
            dbHelper.insertWeatherRow(row2);
          } else {
            dbHelper.updateWeathTbl(row2);
          }
          return response.body;
        }
      } catch(e) {
        print('$e, probably cant connect to openweathermap... no network connection? global_helper_functions.getWeatherForeCast');
        weatherID ??= generateFakeWeatherId(lattLong); // assign if null
        String weatherForeCast = await dbHelper.queryWeatherForeCast(weatherID);
        return (weatherForeCast);
      }
    } else {
      String weatherForeCast = await dbHelper.queryWeatherForeCast(weatherID);
      return (weatherForeCast);
    }
  }
  return null;
}

BoxDecoration myBoxDecoration(Color color) {
  return BoxDecoration(
    color: color,
    border: Border.all(
      width: 2.0,
    ),
    borderRadius: BorderRadius.all(Radius.circular(6.0)),
    boxShadow: [
      BoxShadow(
        offset: Offset(2.0, 1.0),
        blurRadius: 1.0,
        spreadRadius: 1.0,
      )
    ],
  );
}

int newTimeStamp() {
  DateTime date = DateTime.now();
  return (date.millisecondsSinceEpoch / 1000).floor();
}

Future<String> parseMapUrl(String mapUrl) async {
  try {
    Response response = await get(mapUrl);
    RegExp gmapUrl = RegExp(
        r'https://www.google.com/(maps/preview)/(place)/([^/]*)/([^/]*)/data');
    String mapInfo = response.body;
    Match match = gmapUrl.firstMatch(mapInfo);
    String subMapInfo = match.group(4);
    RegExp subGmapUrl = RegExp(r'@([^,]*,[^,]*),([^,]*,[^,]*)');
    Match subMatch = subGmapUrl.firstMatch(subMapInfo);
    return subMatch.group(1);
  } catch(e) {
    print('$e can\'t connect to internet in global_helper_functions.parseMapUrl');
  }
}

Future<int> fetchElevation(String mapLocation) async {
  final dbHelper = DatabaseHelper.instance;
  String latLong = await dbHelper.queryLatNLong(mapLocation);
  if (latLong == 'NA') {
    return null;
  } else {
    String elevationServer = await getPreferenceElevationServer();
    String elevationApiUrl =
        elevationServer + '/api/v1/lookup\?locations\=' + latLong;
    Response response;
    try {
      response = await get(elevationApiUrl);
    } catch (e) {
      print('$e in source file global_helper_functions.dart.fetchElevation');
      return null;
    }
    if (response.statusCode == 200) {
      Map<String, dynamic> responseJson = jsonDecode(response.body);
      int elevation = responseJson['results'][0]['elevation'];
      return elevation;
    } else {
      return null;
    }
  }
}

String convertCoordinates(String latNLong) {
  try {
    List<String> latLong = latNLong.split(',');
    List<String> lat = latLong[0].split('.');
    List<String> long = latLong[1].split('.');
    String latMinSec = getMinSec(lat[1]);
    String longMinSec = getMinSec(long[1]);
    String gpsDMS =
        lat[0] + '\u00B0 ' + latMinSec + ',' + long[0] + '\u00B0 ' + longMinSec;
    return gpsDMS;
  } catch(e) {
      print('$e in source file global_helper_functions.convertCoordinates, function parameter probably not a valid latNLong string');
  }
}

String getMinSec(String numString) {
  String numStringX = '0.' + numString;
  double num = double.parse(numStringX);
  int mins = (num * 100 * 0.6).floor();
  double secs = ((((num * 100 * 0.6) % 1) * 100000 * .6).round() / 1000);
  String minSecs = mins.toString() + '\' ' + secs.toString();
  return minSecs;
}


String weatherConditions(String weatherConditions) {
  int numSpaces = (' '.allMatches(weatherConditions)).length;
  if (numSpaces > 1) {
    int firstSpace = weatherConditions.indexOf(' ');
    int secondSpace = (weatherConditions.indexOf(' ', firstSpace + 1));
    return weatherConditions.replaceRange(secondSpace, (secondSpace + 1), '\n').toUpperCase();
  } else {
    return weatherConditions.toUpperCase();
  }
}

Future<void> urlLaunch(String url) async{
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

int generateFakeWeatherId(String latLong) {
  List<String> _latLongParts = latLong.split(',');
  List<String> _shortLat = _latLongParts[0].split('.');
  List<String> _shortLong = _latLongParts[1].split('.');
  String _fakeIDString = _shortLat[0].replaceFirst('-','8') + _shortLong[0].replaceFirst('-','8');
  // you know a weatherID is fake because it is less than zero
  return (0 - int.parse(_fakeIDString));
}

Future<String> getPreferenceElevationServer() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String elevationServer =
      prefs.getString("elevationServer") ?? "https://example.com";
  return elevationServer;
}

Future<bool> setPreferenceElevationServer(String elevationServer) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool committed = await prefs.setString("elevationServer", elevationServer);
  return (committed);
}

Future<String> getPreferenceOpenWeatherMapApiKey() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String apiKey = prefs.getString("openWeatherMapApiKey") ?? "none?";
  return apiKey;
}

Future<bool> setPreferenceOpenWeatherMapApiKey(String apiKey) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool committed = await prefs.setString("openWeatherMapApiKey", apiKey);
  return (committed);
}

Future<bool> getPreferenceUseElevation() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool _useElev = prefs.getBool("useElevation") ?? false;
  return _useElev;
}

Future<bool> setPreferenceUseElevation(bool useElev) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool committed = await prefs.setBool("useElevation", useElev);
  return (committed);
}

Future<bool> getPreferenceUseWeather() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool _useElev = prefs.getBool("useWeather") ?? false;
  return _useElev;
}

Future<bool> setPreferenceUseWeather(bool useWeather) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool committed = await prefs.setBool("useWeather", useWeather);
  return (committed);
}

Future<String> getPreferenceDBExportFileName() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String dbExportFileName = prefs.getString("dbExportFileName") ?? "libre_gps_parser.json";
  return (dbExportFileName.length > 0) ? dbExportFileName : "libre_gps_parser.json";
}

Future<bool> setPreferenceDBExportFileName(String dbExportFileName) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool committed = await prefs.setString("dbExportFileName", dbExportFileName);
  return (committed);
}

Future<bool> importDataBase(String importString) {
  final dbHelper = DatabaseHelper.instance;
  final int _timeStamp = newTimeStamp();
  List<dynamic> _importJson = jsonDecode(importString);
  int _importJsonLength = _importJson.length;
  for (int i = 0; i < _importJsonLength; i++) {
    dbHelper.queryRowExists(_importJson[i]['mapLocation']).then((int rowExists) {
      if (rowExists == 0) {
        Map<String, dynamic> row = {
          DatabaseHelper.columnMapLocation: _importJson[i]['mapLocation'],
        };
        if (_importJson[i]['notes'] != null) {
          row['notes'] = _importJson[i]['notes'];
        } 
        if (_importJson[i]['isAutoTimeOffset'] == 0) {
          row['timeOffSet'] = _importJson[i]['timeOffSet'];
          row['timeOffSetTime'] = _timeStamp;
          row['isAutoTimeOffset'] = _importJson[i]['isAutoTimeOffset'];
        } 
        dbHelper.insert(row);
      }
    });
  }
  return Future.value(true);
}
