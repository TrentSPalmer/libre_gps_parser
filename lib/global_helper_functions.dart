import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'database_helper.dart';
import 'dart:convert';

final EdgeInsets myBoxPadding = EdgeInsets.all(10.0);
final Color navy = Color(0xff00293C);
final Color peacock_blue = Color(0xff1e656d);
final Color ivory = Color(0xfff1f3ce);
final Color candy_apple = Color(0xfff62a00);
final String weatherApiUrlPrefix = 'https://api.openweathermap.org/data/2.5/weather?';
final String weatherForecastApiUrlPrefix = 'https://api.openweathermap.org/data/2.5/forecast?';

Future<String> getWeather(String mapLocation, String lat_Long) async {
  // https://dragosholban.com/2018/07/01/how-to-build-a-simple-weather-app-in-flutter
  final dbHelper = DatabaseHelper.instance;
  String weatherApiID = await getPreferenceOpenWeatherMapApiKey();
  if (weatherApiID == 'none?') { return null;}
  else {
    int weatherID = await dbHelper.queryWeatherID(mapLocation);
    if (weatherID == null) {
      List<String> latLong = lat_Long.split(',');
      String weatherApiUrl = '${weatherApiUrlPrefix}lat=${latLong[0]}&lon=${latLong[1]}&units=imperial&appid=${weatherApiID}';
      Response response = await get(weatherApiUrl);
      if (response.statusCode == 200) {
        Map<String, dynamic> responseJson = jsonDecode(response.body);
        weatherID = responseJson['id'];
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
    } else {
      String weather = await dbHelper.queryWeather(weatherID);
      return(weather);
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
    borderRadius: new BorderRadius.all(new Radius.circular(6.0)),
       boxShadow: [
            new BoxShadow(
              offset: new Offset(2.0, 1.0),
              blurRadius: 1.0,
              spreadRadius: 1.0,
            )
        ],
  );
}

int newTimeStamp() {
    DateTime date = new DateTime.now();
    return (date.millisecondsSinceEpoch / 1000).floor();
}

Future<String> parseMapUrl(String mapUrl) async {
  Response response = await get(mapUrl);
  RegExp gmapUrl = new RegExp(r'https://www.google.com/(maps/preview)/(place)/([^/]*)/([^/]*)/data');
  String mapInfo = response.body;
  Match match = gmapUrl.firstMatch(mapInfo);
  String subMapInfo = match.group(4);
  RegExp subGmapUrl = new RegExp(r'@([^,]*,[^,]*),([^,]*,[^,]*)');
  Match subMatch = subGmapUrl.firstMatch(subMapInfo);
  return subMatch.group(1);
}

Future<String> getPreferenceElevationServer() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String elevationServer = prefs.getString("elevationServer") ?? "https://example.com";
  return elevationServer;
}

Future<bool> setPreferenceElevationServer(String elevationServer) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString("elevationServer",elevationServer);
  return prefs.commit();
}

Future<String> getPreferenceOpenWeatherMapApiKey() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String apiKey = prefs.getString("openWeatherMapApiKey") ?? "none?";
  return apiKey;
}

Future<bool> setPreferenceOpenWeatherMapApiKey(String apiKey) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString("openWeatherMapApiKey",apiKey);
  return prefs.commit();
}

Future<int> fetchElevation(String mapLocation) async {
  final dbHelper = DatabaseHelper.instance;
  String latLong = await dbHelper.queryLatNLong(mapLocation);
  if (latLong == 'NA') { return null;}
  else {
    String elevationServer = await getPreferenceElevationServer();
    String elevationApiUrl = elevationServer + '/api/v1/lookup\?locations\=' + latLong;
    Response response = await get(elevationApiUrl);
    if (response.statusCode == 200) {
      Map<String, dynamic> responseJson = jsonDecode(response.body);
      int elevation = responseJson['results'][0]['elevation'];
      return elevation;
    } else {return null;}
  }
}

String convertCoordinates(String latNLong) {
  List<String> latLong = latNLong.split(',');
  List<String> lat = latLong[0].split('.');
  List<String> long = latLong[1].split('.');
  String latMinSec = getMinSec(lat[1]);
  String longMinSec = getMinSec(long[1]);
  String gpsDMS = lat[0] + '\u00B0 ' + latMinSec + ',' + long[0] + '\u00B0 ' + longMinSec;
  return gpsDMS;
}

String getMinSec(String numString) {
  String numString_x = '0.' + numString;
  double num = double.parse(numString_x);
  int mins = (num * 100 * 0.6).floor();
  double secs = ((((num * 100 * 0.6) % 1) * 100000 * .6).round() / 1000);
  String minSecs = mins.toString() + '\' ' + secs.toString();
  return minSecs;
}
