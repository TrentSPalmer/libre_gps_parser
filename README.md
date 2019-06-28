# Libre Gps Parser
The essence of Libre Gps Parser is parsing gps coordinates from a map location that you share from
a map application. The location is requested using the [dart http](https://pub.dev/packages/http)
package, and then the raw text result is filtered with regex to pick out the gps coordinates.

You can take a look at the request and regex in
[`global_helper_functions.dart`](https://github.com/TrentSPalmer/libre_gps_parser/blob/master/lib/global_helper_functions.dart)
`parseMapUrl` function.

Using the gps coordinates you can get weather and/or elevation for each location you have saved.
For weather you need a weather api key. For elevation you need to set up an
[elvation api server](https://github.com/Jorl17/open-elevation). The elevation api server
requires some disk space; a $5 Lightsail server with 40G disk works.

_____
### main screen
![main screen](https://raw.githubusercontent.com/TrentSPalmer/libre_gps_parser/master/screenshots/Screenshot_20190626-230011_Libre_Gps_Parser.png)
_____
### settings 
weather and elevation can be enabled or disabled
_____
![main screen](https://raw.githubusercontent.com/TrentSPalmer/libre_gps_parser/master/screenshots/Screenshot_20190626-230227_Libre_Gps_Parser.png)
_____
### history
_____
![main screen](https://raw.githubusercontent.com/TrentSPalmer/libre_gps_parser/master/screenshots/Screenshot_20190626-230633_Libre_Gps_Parser.png)
_____

## to be implemented
*
* add more things to be implemented
