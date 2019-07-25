import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'global_helper_functions.dart';
import 'database_helper.dart';
import 'dart:io';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  // String absoluteDBExportFileName = '';
  String _dbExportFileNameString = '';
  String elevationServer = "none";
  String openWeatherMapKey = "none??";
  String shortOWMAK = "none";
  final _dbExportFileNameController = TextEditingController();
  final _elevationServerController = TextEditingController();
  final _oWMKController = TextEditingController();
  bool _useElevation = false;
  bool _useWeather = false;
  double textHeight = 1.5;

  @override
  void initState() {
    super.initState();
    updateState();
  }

  @override
  Widget build(BuildContext context) {

    Future<void> _showDBImportDialog() async{
      Map<PermissionGroup, PermissionStatus> _storagePermissions;
      PermissionStatus _storagePermission = await PermissionHandler().checkPermissionStatus(PermissionGroup.storage);
      if (_storagePermission == PermissionStatus.denied) {
        _storagePermissions = await PermissionHandler().requestPermissions([PermissionGroup.storage]);
      }
      if ((_storagePermission == PermissionStatus.granted) || (_storagePermissions.toString() == PermissionStatus.granted.toString())) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: ivory,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(6.0)),
              ),
              title: Text(
                'You can import a\njson backup of\nyour database',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: candyApple,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.only(
                      top: 40,
                      bottom: 10,
                    ),
                    child: ButtonTheme(
                      height: 55,
                      padding: EdgeInsets.only(
                          top: 5,
                          right: 12,
                          bottom: 12,
                          left: 10
                      ),
                      child: RaisedButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(6.0)),
                        ),
                        color: peacockBlue,
                        child: Text(
                          'Select File',
                          style: TextStyle(
                            height: textHeight,
                            color: Colors.white,
                            fontSize: 24,
                          ),
                        ),
                        onPressed: () async{
                          String _filePath;
                          _filePath = await FilePicker.getFilePath(type: FileType.ANY);
                          Navigator.of(context).pop();
                          try {
                            String _importString = await File(_filePath).readAsString();
                            bool _imported = await importDataBase(_importString);
                            if (_imported) {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    backgroundColor: ivory,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(Radius.circular(6.0)),
                                    ),
                                    title: Text(
                                      'Importing From\n\'$_filePath\'\n Succeeded!',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: candyApple,
                                      ),
                                    ),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Container(
                                          margin: EdgeInsets.only(
                                            top: 40,
                                            bottom: 10,
                                          ),
                                          child: ButtonTheme(
                                            height: 55,
                                            padding: EdgeInsets.only(
                                                top: 5,
                                                right: 12,
                                                bottom: 12,
                                                left: 10
                                            ),
                                            child: RaisedButton(
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.all(Radius.circular(6.0)),
                                              ),
                                              color: peacockBlue,
                                              child: Text(
                                                'OK',
                                                style: TextStyle(
                                                  height: textHeight,
                                                  color: Colors.white,
                                                  fontSize: 24,
                                                ),
                                              ),
                                              onPressed: () async{
                                                Navigator.of(context).pop();
                                              }
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }
                              );
                            }
                          } catch(e) {
                            print(e);
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  backgroundColor: ivory,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(6.0)),
                                  ),
                                  title: Text(
                                    'Oops, something went wrong',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: candyApple,
                                    ),
                                  ),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Container(
                                        margin: EdgeInsets.only(
                                          top: 40,
                                          bottom: 10,
                                        ),
                                        child: ButtonTheme(
                                          height: 55,
                                          padding: EdgeInsets.only(
                                              top: 5,
                                              right: 12,
                                              bottom: 12,
                                              left: 10
                                          ),
                                          child: RaisedButton(
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(Radius.circular(6.0)),
                                            ),
                                            color: peacockBlue,
                                            child: Text(
                                              'OK',
                                              style: TextStyle(
                                                height: textHeight,
                                                color: Colors.white,
                                                fontSize: 24,
                                              ),
                                            ),
                                            onPressed: () async{
                                              Navigator.of(context).pop();
                                            }
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            );
                          }
                        }
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        );
      }
    }

    Future<void> _showDBExportDialog() async{
      Map<PermissionGroup, PermissionStatus> _storagePermissions;
      PermissionStatus _storagePermission = await PermissionHandler().checkPermissionStatus(PermissionGroup.storage);
      if (_storagePermission == PermissionStatus.denied) {
        _storagePermissions = await PermissionHandler().requestPermissions([PermissionGroup.storage]);
      }
      if ((_storagePermission == PermissionStatus.granted) || (_storagePermissions.toString() == PermissionStatus.granted.toString())) {
        Directory sdcard = await getExternalStorageDirectory();
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: ivory,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(6.0)),
              ),
              title: Text(
                'Export File Name?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: candyApple,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
               children: <Widget>[
                  Text(
                    'DataBase will be\nexported to json file.',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  TextField(
                    controller: _dbExportFileNameController,
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                    decoration: InputDecoration(
                      hintText: this._dbExportFileNameString,
                    ),
                    onChanged: (text) {
                      this._dbExportFileNameString = (text.length > 0) ? text : "libre_gps_parser.json";
                    },
                  ),
                  Container(
                    margin: EdgeInsets.only(
                      top: 40,
                      bottom: 10,
                    ),
                    child: ButtonTheme(
                      height: 55,
                      padding: EdgeInsets.only(
                          top: 5,
                          right: 12,
                          bottom: 12,
                          left: 10
                      ),
                      child: RaisedButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(6.0)),
                        ),
                        color: peacockBlue,
                        child: Text(
                          'Export',
                          style: TextStyle(
                            height: textHeight,
                            color: Colors.white,
                            fontSize: 24,
                          ),
                        ),
                        onPressed: () async{
                          _updatedbExportFileName();
                          final dbHelper = DatabaseHelper.instance;
                          String _dbExportString = await dbHelper.queryDBExport();
                          String _absoluteDBExportFileName = '${sdcard.path}/${this._dbExportFileNameString}';
                          File _file = File(_absoluteDBExportFileName);
                          File _result = await _file.writeAsString(_dbExportString);
                          Navigator.of(context).pop();
                          if (_result == null) {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  backgroundColor: ivory,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(6.0)),
                                  ),
                                  title: Text(
                                    'Writing To\n\'$_absoluteDBExportFileName\'\n(sdcard) Failed!',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: candyApple,
                                    ),
                                  ),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Container(
                                        margin: EdgeInsets.only(
                                          top: 40,
                                          bottom: 10,
                                        ),
                                        child: ButtonTheme(
                                          height: 55,
                                          padding: EdgeInsets.only(
                                              top: 5,
                                              right: 12,
                                              bottom: 12,
                                              left: 10
                                          ),
                                          child: RaisedButton(
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(Radius.circular(6.0)),
                                            ),
                                            color: peacockBlue,
                                            child: Text(
                                              'OK',
                                              style: TextStyle(
                                                height: textHeight,
                                                color: Colors.white,
                                                fontSize: 24,
                                              ),
                                            ),
                                            onPressed: () async{
                                              Navigator.of(context).pop();
                                            }
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            );
                          } else {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  backgroundColor: ivory,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(6.0)),
                                  ),
                                  title: Text(
                                    'Writing To\n\'$_absoluteDBExportFileName\'\n(sdcard) Succeeded!',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: candyApple,
                                    ),
                                  ),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Container(
                                        margin: EdgeInsets.only(
                                          top: 40,
                                          bottom: 10,
                                        ),
                                        child: ButtonTheme(
                                          height: 55,
                                          padding: EdgeInsets.only(
                                              top: 5,
                                              right: 12,
                                              bottom: 12,
                                              left: 10
                                          ),
                                          child: RaisedButton(
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.all(Radius.circular(6.0)),
                                            ),
                                            color: peacockBlue,
                                            child: Text(
                                              'OK',
                                              style: TextStyle(
                                                height: textHeight,
                                                color: Colors.white,
                                                fontSize: 24,
                                              ),
                                            ),
                                            onPressed: () async{
                                              Navigator.of(context).pop();
                                            }
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }
                            );
                          }
                        }
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
        );
      }
    }

    return WillPopScope(
      onWillPop: _popBack,
      child: Scaffold(
        backgroundColor: peacockBlue,
        appBar: AppBar(
          title: const Text('Settings'),
        ),
        body: ListView(
          children: <Widget>[
            Container(
              padding: myBoxPadding,
              decoration: myBoxDecoration(ivory),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Enable Elevation Api Server?',
                      style: TextStyle(
                        height: textHeight,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(15.0),
                    child: Transform.scale(
                      scale: 2,
                      child: Switch(
                        value: this._useElevation,
                        onChanged: (value) {
                          setPreferenceUseElevation(value).then((bool committed) {
                            setState(() {
                              this._useElevation = value;
                            });
                          });
                        },
                        activeTrackColor: peacockBlue,
                        activeColor: navy,
                        inactiveThumbColor: candyApple,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ((this._useElevation) ? Container(
              padding: myBoxPadding,
              decoration: myBoxDecoration(ivory),
              child: Column(
                children: [
                  Text(
                    'Open-Elevation Api Server to Use',
                  ),
                  Text(
                    'Current Value: ${this.elevationServer}',
                  ),
                  TextField(
                    controller: _elevationServerController,
                    decoration: InputDecoration(
                      hintText: this.elevationServer,
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(
                      top: 20.0,
                      bottom: 5.0,
                    ),
                    child: RaisedButton.icon(
                      label: Text(
                        "Update Elevation Server",
                      ),
                      icon: Icon(
                        Icons.refresh,
                        size: 50.0,
                      ),
                      color: candyApple,
                      onPressed: () {
                        _updateElevationServer();
                      },
                    ),
                  ),
                ],
              ),
            ) : Container()),
            Container(
              padding: myBoxPadding,
              decoration: myBoxDecoration(ivory),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Use OpenWeatherMap Weather?',
                      style: TextStyle(
                        height: textHeight,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(15.0),
                    child: Transform.scale(
                      scale: 2,
                      child: Switch(
                        value: this._useWeather,
                        onChanged: (value) {
                          setPreferenceUseWeather(value).then((bool committed) {
                            setState(() {
                              this._useWeather = value;
                            });
                          });
                        },
                        activeTrackColor: peacockBlue,
                        activeColor: navy,
                        inactiveThumbColor: candyApple,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            ((this._useWeather) ? Container(
              padding: myBoxPadding,
              decoration: myBoxDecoration(ivory),
              child: Column(
                children: [
                  Text(
                    'Open Weather Map Api Key to Use',
                  ),
                  Text(
                    'Current Value: ${this.shortOWMAK}...',
                  ),
                  TextField(
                    controller: _oWMKController,
                    decoration: InputDecoration(
                      hintText: '${this.shortOWMAK}...',
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(
                      top: 20.0,
                      bottom: 5.0,
                    ),
                    child: RaisedButton.icon(
                      label: Text(
                        "Update ... Api Key",
                      ),
                      icon: Icon(
                        Icons.refresh,
                        size: 50.0,
                      ),
                      color: candyApple,
                      onPressed: () {
                        _updateOpenWeatherMapApiKey();
                      },
                    ),
                  ),
                ],
              ),
            ) : Container()),
            Container(
              padding: myBoxPadding,
              decoration: myBoxDecoration(ivory),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: IconButton(
                        alignment: Alignment.center,
                        icon: Icon(
                          Icons.arrow_back,
                          color: candyApple,
                        ),
                        iconSize: 60.0,
                        onPressed: () {
                          _showDBExportDialog();
                        },
                      ),
                    ),
                    Expanded(
                      flex: 6,
                      child: Text(
                        'Export DataBase',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          height: textHeight,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: IconButton(
                        alignment: Alignment.center,
                        icon: Icon(
                          Icons.arrow_forward,
                          color: candyApple,
                        ),
                        iconSize: 60.0,
                        onPressed: () {
                          _showDBExportDialog();
                        },
                      ),
                    ),
                  ],
                ),
            ),
            Container(
              padding: myBoxPadding,
              decoration: myBoxDecoration(ivory),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: IconButton(
                        alignment: Alignment.center,
                        icon: Icon(
                          Icons.arrow_forward,
                          color: candyApple,
                        ),
                        iconSize: 60.0,
                        onPressed: () {
                          _showDBImportDialog();
                        },
                      ),
                    ),
                    Expanded(
                      flex: 6,
                      child: Text(
                        'Import DataBase',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          height: textHeight,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 2,
                      child: IconButton(
                        alignment: Alignment.center,
                        icon: Icon(
                          Icons.arrow_back,
                          color: candyApple,
                        ),
                        iconSize: 60.0,
                        onPressed: () {
                          _showDBImportDialog();
                        },
                      ),
                    ),
                  ],
                ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> updateState() async {
    String _evServer = await getPreferenceElevationServer();
    String _oWMK = await getPreferenceOpenWeatherMapApiKey();
    String _dbEFNS = await getPreferenceDBExportFileName();
    bool _useElev = await getPreferenceUseElevation();
    bool _useWTHR = await getPreferenceUseWeather();
    setState(() {
      this.elevationServer = _evServer;
      this.openWeatherMapKey = _oWMK;
      this._useElevation = _useElev;
      this._useWeather = _useWTHR;
      this.shortOWMAK = _oWMK.substring(0, 5);
      this._dbExportFileNameString = _dbEFNS;
    });
  }

  void _updatedbExportFileName() {
    String _dbEFNS = this._dbExportFileNameString;
    setPreferenceDBExportFileName(_dbEFNS).then((bool committed) {
      setState(() {
        this._dbExportFileNameString = _dbEFNS;
      });
    });
  }

  void _updateOpenWeatherMapApiKey() {
    String _oWMK = _oWMKController.text;
    if (_oWMK.length > 5) {
      setPreferenceOpenWeatherMapApiKey(_oWMK).then((bool committed) {
        if (_oWMK != this.openWeatherMapKey) {
          setState(() {
            this.openWeatherMapKey = _oWMK;
            this.shortOWMAK = _oWMK.substring(0, 5);
          });
        }
      });
      Navigator.pop(context, 2);
    }
  }

  void _updateElevationServer() {
    String _elevServer = _elevationServerController.text;
    RegExp _urlValidator = RegExp(r'^http[s]?://.+$');
    if (_urlValidator.hasMatch(_elevServer)) {
      setPreferenceElevationServer(_elevServer).then((bool committed) {
        if (_elevServer != this.elevationServer) {
          setState(() {
            this.elevationServer = _elevServer;
          });
        }
      });
      Navigator.pop(context, 1);
    }
  }

  Future<bool> _popBack() {
    Navigator.pop(context, 3);
    return Future.value(false);
  }

}
