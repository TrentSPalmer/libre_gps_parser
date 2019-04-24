import 'package:flutter/material.dart';
import 'global_helper_functions.dart';


class Weather extends StatefulWidget {

  Map<String, dynamic> weather;

  Weather({Key key, this.weather}) : super(key: key);

  @override
  _WeatherState createState() => new _WeatherState();
}

class _WeatherState extends State<Weather> {
  @override
  Widget build(BuildContext context) {
    return Container(
        padding: myBoxPadding,
        decoration: myBoxDecoration(ivory),
        child: Wrap(
          spacing: 10.0,
          children: <Widget>[
            Text(
              'Current Weather Conditions: ${widget.weather['weather'][0]['description']}',
            ),
            Text(
              'Weather location: ${widget.weather['id']}',
            ),
          ],
        )
    );
  }
}
