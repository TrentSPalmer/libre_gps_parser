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

For each location that you save in your history you can also write some notes,
including support for [markdown](https://pub.dev/packages/flutter_markdown),
and including import/export from [markdown](https://pub.dev/packages/flutter_markdown) or
plain text file.

Data is cached locally in sqlite using [sqflite](https://pub.dev/packages/sqflite),
in order to economize network request tasks.

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

## road map
*
* add more things to be implemented
* add input from Bing Maps, OSM? 
* add other elevation api server options
* include shared-prefs import/export in history import/export

## archive
* [Previous Versions of Libre Gps Parser](https://trentsonlinedocs.xyz/android_app_archive/libre_gps_parser/)

* [archive sha256sums](https://raw.githubusercontent.com/TrentSPalmer/libre_gps_parser/master/archive_sha256sums.md)
