// https://github.com/tekartik/sqflite/blob/master/sqflite/doc/migration_example.md
import 'dart:io';
import 'dart:convert';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static final String _databaseName = "LibreGpsParser.db";
  static final int _databaseVersion = 4;

  static final String table = 'gmaplocations';
  static final String weatherTable = 'weather';

  static final String columnMapLocation = 'mapLocation';
  static final String columnLatLong = 'latLong';
  static final String columnLnlTime = 'lnlTime';
  static final String columnViewTime = 'viewTime';
  static final String columnElev = 'elev';
  static final String columnElevTime = 'elevTime';
  static final String columnWeatherID = 'weatherID';
  static final String columnTimeOffSet = 'timeOffSet';
  static final String columnTimeOffSetTime = 'timeOffSetTime';

  static final String columnWeatherWeatherID = 'weatherID';
  static final String columnWeather = 'weather';
  static final String columnWeatherForecast = 'weatherForecast';
  static final String columnNotes = 'notes';

  // is the timeOffSet automatically set by consulting teleport api
  // (not manually set by spinner)
  static final String columnIsAutoTimeOffset = 'isAutoTimeOffset';  

  // make this a singleton class
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // only have a single app-wide reference to the database
  static Database _database;
  Future<Database> get database async {
    if (_database != null) return _database;
    // lazily instantiate the db the first time it is accessed
    _database = await _initDatabase();
    return _database;
  }

  // this opens the database (and creates it if it doesn't exist)
  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(
      documentsDirectory.path,
      _databaseName
    );
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  // sqflite seems to be able to figure out the versions
  // automatically?
  // you can only ADD one column at a time?
  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if ((oldVersion == 1) || (oldVersion == 2)) {
      await db.execute('''ALTER TABLE $table ADD $columnIsAutoTimeOffset INT''');
      await db.execute('''ALTER TABLE $table ADD $columnNotes TEXT''');
    } else if (oldVersion == 3) {
      await db.execute('''ALTER TABLE $table ADD $columnNotes TEXT''');
    }
  }

  // SQL code to create the database table
  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $table (
            $columnMapLocation VARCHAR UNIQUE,
            $columnLatLong TEXT,
            $columnLnlTime INT,
            $columnViewTime INT,
            $columnElev INT,
            $columnElevTime INT,
            $columnWeatherID INT,
            $columnTimeOffSet INT, 
            $columnTimeOffSetTime INT,
            $columnIsAutoTimeOffset INT,
            $columnNotes TEXT
          )
          ''');
    await db.execute('''
          CREATE TABLE $weatherTable (
            $columnWeatherWeatherID INT UNIQUE ON CONFLICT REPLACE,
            $columnWeather TEXT,
            $columnWeatherForecast TEXT
          )
          ''');
  }

  Future<int> insert(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(table, row);
  }

  Future<int> insertWeatherRow(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(weatherTable, row);
  }

  Future<List<Map<String, dynamic>>> queryAllRows() async {
    Database db = await instance.database;
    return await db.query(table);
  }

  Future<int> queryRowCount() async {
    Database db = await instance.database;
    return Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM $table'));
  }

  Future<int> queryRowExists(String mapLocation) async {
    String depostrophedMapLocation = mapLocation.replaceAll('\'', '\'\'');
    Database db = await instance.database;
    return Sqflite.firstIntValue(await db.rawQuery(
        'SELECT EXISTS (SELECT $columnMapLocation FROM $table WHERE $columnMapLocation=\'$depostrophedMapLocation\')'));
  }

  Future<int> queryWeatherIDExists(int weatherID) async {
    Database db = await instance.database;
    return Sqflite.firstIntValue(await db.rawQuery(
        'SELECT EXISTS (SELECT $columnWeatherWeatherID FROM $weatherTable WHERE $columnWeatherWeatherID=\'$weatherID\')'));
  }

  Future<String> queryNewestMapLocation() async {
    Database db = await instance.database;
    List<Map> result = await db.rawQuery(
        'SELECT $columnMapLocation FROM $table ORDER BY $columnViewTime DESC LIMIT 1');
    return (result.length == 0)
        ? 'Plataea\nGreece\nhttps://maps.app.goo.gl/1NW9z'
        : result[0]['mapLocation'];
  }

  Future<String> querySecondNewestMapLocation() async {
    Database db = await instance.database;
    List<Map> result = await db.rawQuery(
        'SELECT $columnMapLocation FROM $table ORDER BY $columnViewTime DESC LIMIT 2');
    return (result.length == 2)
        ? result[1]['mapLocation']
        : 'none';
  }


  Future<List<String>> sortedMapLocations() async {
    Database db = await instance.database;
    var result = await db.rawQuery(
        'SELECT $columnMapLocation FROM $table ORDER BY $columnViewTime DESC');
    List<String> resultList = List<String>();
    for (var i = 0; i < result.length; i++) {
      resultList.add(result[i]['mapLocation']);
    }
    return resultList;
  }

  Future<String> queryLatNLong(String mapLocation) async {
    Database db = await instance.database;
    List<Map> result = await db.rawQuery(
        'SELECT $columnLatLong FROM $table WHERE $columnMapLocation = ?',
        [mapLocation]);
    return (result[0]['latLong'] == null) ? 'NA' : result[0]['latLong'];
  }

  Future<String> queryNotes(String mapLocation) async {
    Database db = await instance.database;
    List<Map> result = await db.rawQuery(
        'SELECT $columnNotes FROM $table WHERE $columnMapLocation = ?',
        [mapLocation]);
    return result[0]['notes'] ?? '';
  }

  Future<String> queryWeather(int weatherID) async {
    Database db = await instance.database;
    List<Map> result = await db.rawQuery(
        'SELECT $columnWeather FROM $weatherTable WHERE $columnWeatherWeatherID = ?',
        [weatherID]);
    return (result.length > 0) ? result[0]['weather'] : 'NA';
  }

  Future<String> queryWeatherForeCast(int weatherID) async {
    Database db = await instance.database;
    List<Map> result = await db.rawQuery(
        'SELECT $columnWeatherForecast FROM $weatherTable WHERE $columnWeatherWeatherID = ?',
        [weatherID]);
    return result[0]['weatherForecast'] ?? 'NA';
  }

  Future<int> queryElevation(String mapLocation) async {
    Database db = await instance.database;
    List<Map> result = await db.rawQuery(
        'SELECT $columnElev FROM $table WHERE $columnMapLocation = ?',
        [mapLocation]);
    return result[0]['elev'];
  }

  Future<int> queryIsAutoTimeOffSet(String mapLocation) async {
    Database db = await instance.database;
    List<Map> result = await db.rawQuery(
        'SELECT $columnIsAutoTimeOffset FROM $table WHERE $columnMapLocation = ?',
        [mapLocation]);
    return result[0]['isAutoTimeOffset'] ?? 1;
  }

  Future<int> queryTimeOffSetTime(String mapLocation) async {
    Database db = await instance.database;
    List<Map> result = await db.rawQuery(
        'SELECT $columnTimeOffSetTime FROM $table WHERE $columnMapLocation = ?',
        [mapLocation]);
    return result[0]['timeOffSetTime'] ??
        -1; // returns -1 if result[0]['timeOffSetTime'] is null
  }

  Future<int> queryTimeOffSet(String mapLocation) async {
    Database db = await instance.database;
    List<Map> result = await db.rawQuery(
        'SELECT $columnTimeOffSet FROM $table WHERE $columnMapLocation = ?',
        [mapLocation]);
    return result[0]['timeOffSet'] ??
        -1; // returns -1 if result[0]['timeOffSet'] is null
  }

  Future<int> queryWeatherID(String mapLocation) async {
    Database db = await instance.database;
    List<Map> result = await db.rawQuery(
        'SELECT $columnWeatherID FROM $table WHERE $columnMapLocation = ?',
        [mapLocation]);
    return result[0]['weatherID'];
  }

  Future<int> update(Map<String, dynamic> row) async {
    Database db = await instance.database;
    String mapLocation = row[columnMapLocation];
    return await db.update(table, row,
        where: '$columnMapLocation = ?', whereArgs: [mapLocation]);
  }

  Future<int> updateWeathTbl(Map<String, dynamic> row) async {
    Database db = await instance.database;
    int weatherID = row[columnWeatherWeatherID];
    return await db.update(weatherTable, row,
        where: '$columnWeatherWeatherID = ?', whereArgs: [weatherID]);
  }

  Future<int> delete(String ml) async {
    Database db = await instance.database;
    return await db
        .delete(table, where: '$columnMapLocation = ?', whereArgs: [ml]);
  }

  Future<String> queryDBExport() async{
    Database db = await instance.database;
    List<Map> result = await db.rawQuery('SELECT $columnMapLocation,$columnNotes,$columnIsAutoTimeOffset,$columnTimeOffSet FROM $table');
    return(jsonEncode(result));
  }
}
