import 'package:android_intent/android_intent.dart';
import 'package:flutter/material.dart';
import 'global_helper_functions.dart';

InkWell aboutApp(BuildContext context) {
  return InkWell(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          'About',
          style: TextStyle(
            color: candyApple,
          ),
        ),
        Icon(
          Icons.info,
          size: 48.0,
          color: Colors.black,
        ),
      ],
    ),
    onTap: () {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          final double textHeight = 1.5;
          Future<void> _launchLicense() async{
            AndroidIntent intent = AndroidIntent(
                action: 'action_view',
                data: Uri.encodeFull('https://github.com/TrentSPalmer/libre_gps_parser/blob/master/LICENSE'),
            );
            await intent.launch();
          }
          return AlertDialog(
            backgroundColor: ivory,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(6.0)),
            ),
            title: Text(
              'Libre Gps Parser',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: candyApple,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Version: 0.1.1\n',
                          style: TextStyle(
                            color: candyApple,
                          ),
                        ),
                        Text(
                          'The essence of Libre Gps Parser, is to parse gps coordinates from '
                          'a map link that you share from the Google Maps Application. '
                          'After that you can use the gps coordinates to make api calls for '
                          'weather, elevation, and timezoneoffset.\n\n'
                          'Parsing the gps coordinates is accomplished by getting the Google Map '
                          'link with an http request, and then filtering the raw text result. '
                          'Locally, data is cached in an sqlite database, in order to economize '
                          'network requests.\n\n'
                          'This version of the application requires that you set up an elevation '
                          'api server, and provide an openweathermap api key. '
                          'Or you can disable elevation and weather in settings.'
                          '',
                        ),
                        Container(
                          margin: EdgeInsets.only(
                            top: 40,
                            bottom: 10,
                          ),
                          child: Wrap(
                            runSpacing: 30,
                            alignment: WrapAlignment.center,
                            children: <Widget>[
                              Container(
                                margin: EdgeInsets.symmetric(
                                  horizontal: 15,
                                ),
                                child: ButtonTheme(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(6.0)),
                                  ),
                                  height: 75,
                                  child: RaisedButton(
                                    color: peacockBlue,
                                    child: Icon(
                                      Icons.arrow_back,
                                      size: 48.0,
                                      color: Colors.white,
                                    ),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    }
                                  ),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.symmetric(
                                  horizontal: 15,
                                ),
                                child: ButtonTheme(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(6.0)),
                                  ),
                                  height: 75,
                                  child: RaisedButton(
                                    color: peacockBlue,
                                    child: Text(
                                      "License",
                                      style: TextStyle(
                                        height: textHeight,
                                        color: Colors.white,
                                        fontSize: 24,
                                      ),
                                    ),
                                    onPressed: () {
                                      _launchLicense();
                                    }
                                  ),
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
                                      borderRadius: BorderRadius.all(Radius.circular(6.0)),
                                    ),
                                    color: peacockBlue,
                                    child: Text(
                                      "Other Licenses",
                                      style: TextStyle(
                                        height: textHeight,
                                        color: Colors.white,
                                        fontSize: 24,
                                      ),
                                    ),
                                    onPressed: () {
                                      showLicensePage(context: context);
                                    }
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      );
    },
  );
}
