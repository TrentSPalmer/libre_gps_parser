import 'package:flutter/material.dart';
import 'global_helper_functions.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  String elevationServer = "none";
  String openWeatherMapKey = "none??";
  String shortOWMAK = "none";
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
          ],
        ),
      ),
    );
  }

  Future<void> updateState() async {
    String _evServer = await getPreferenceElevationServer();
    String _oWMK = await getPreferenceOpenWeatherMapApiKey();
    bool _useElev = await getPreferenceUseElevation();
    bool _useWTHR = await getPreferenceUseWeather();
    setState(() {
      this.elevationServer = _evServer;
      this.openWeatherMapKey = _oWMK;
      this._useElevation = _useElev;
      this._useWeather = _useWTHR;
      this.shortOWMAK = _oWMK.substring(0, 5);
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
