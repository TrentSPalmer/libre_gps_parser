import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'global_helper_functions.dart';

class Settings extends StatefulWidget {
  @override
  _SettingsState createState() => new _SettingsState();
}

class _SettingsState extends State<Settings> {
  String elevationServer = "none";
  String openWeatherMapKey = "none";
  String shortOWMAK = "none";
  final _elevationServerController = TextEditingController();
  final _oWMKController = TextEditingController();

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
        title: const Text('Settings'),
      ),
      body: new ListView(
          children: <Widget> [
            new Container(
                padding: myBoxPadding,
                decoration: myBoxDecoration(ivory),
                child: Column(
                  children: [
                    Text(
                        'Open-Elevation Api Server to Use',
                    ),
                    Text(
                        'Current Value: ' + this.elevationServer,
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
                          color: candy_apple,
                          onPressed: () { _updateElevationServer(); },
                      ),
                      ),
                    ],
                  ),
              ),
            new Container(
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
                          color: candy_apple,
                          onPressed: () { _updateOpenWeatherMapApiKey(); },
                      ),
                      ),
                    ],
                  ),
              ),
          ],
      ),
    );
  }

  Future<void> updateState() async {
    String evServer = await getPreferenceElevationServer();
    String oWMK = await getPreferenceOpenWeatherMapApiKey();
    if ((evServer != this.elevationServer) || (oWMK != this.openWeatherMapKey)) {
      setState((){
        this.elevationServer = evServer;
        this.openWeatherMapKey = oWMK;
        this.shortOWMAK = oWMK.substring(0,5);
      });
    }
  }

  void _updateOpenWeatherMapApiKey() {
    String oWMK = _oWMKController.text;
    if (oWMK.length > 0) {
      setPreferenceOpenWeatherMapApiKey(oWMK).then((bool committed) {
        if (oWMK != this.openWeatherMapKey) {
          setState((){
            this.openWeatherMapKey = oWMK;
            this.shortOWMAK = oWMK.substring(0,5);
          });
        }
      });
      Navigator.pop(context);
    }
  }

  void _updateElevationServer() {
    String elevServer = _elevationServerController.text;
    RegExp urlValidator = new RegExp(r'^http[s]?://.+$');
    if (urlValidator.hasMatch(elevServer)) {
      setPreferenceElevationServer(elevServer).then((bool committed) {
        if (elevServer != this.elevationServer) {
          setState((){
            this.elevationServer = elevServer;
          });
        }
      });
      Navigator.pop(context);
    }
  }

}
