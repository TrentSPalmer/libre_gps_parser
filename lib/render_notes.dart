import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'global_helper_functions.dart';
import 'dart:io';

class RenderNotes extends StatefulWidget {
  final String notes;

  RenderNotes({
    Key key,
    this.notes,
  }) : super(key: key);

  @override
  _RenderNotesState createState() => _RenderNotesState();
}

class _RenderNotesState extends State<RenderNotes> {
  final double textHeight = 1.5;
  final _textEditingController = TextEditingController();
  String _exportFileNameString = '';
  String fileName = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ivory,
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            floating: true,
            snap: false,
            pinned: false,
            expandedHeight: 50,
            title: const Text('Notes, MarkDown Supported'),
          ),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget> [
                Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: 10.0,
                  ),
                  child: MarkdownBody(
                    data: widget.notes,
                  ),
                ),
                Row(
                  children: <Widget> [
                    Expanded(
                      child: Container(),
                    ),
                    Container(
                      margin: EdgeInsets.all(20.0),
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
                                      'File Name To Save As?',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        color: candyApple,
                                      ),
                                    ),
                                    content: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        TextField(
                                          controller: _textEditingController,
                                          keyboardType: TextInputType.multiline,
                                          maxLines: null,
                                          decoration: InputDecoration(
                                            hintText: 'i.e.  timbuktu.md',
                                          ),
                                          onChanged: (text) {
                                            _exportFileNameString = text;
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
                                                if (this._exportFileNameString.length > 0) {
                                                  String _fileName = '${sdcard.path}/${this._exportFileNameString}';
                                                  File _file = File(_fileName);
                                                  File _result = await _file.writeAsString(widget.notes);
                                                  Navigator.of(context).pop();
                                                  if (_result == null) {
                                                    setState(() {
                                                      this.fileName = _fileName;
                                                    });
                                                    showDialog(
                                                      context: context,
                                                      builder: (BuildContext context) {
                                                        return AlertDialog(
                                                          backgroundColor: ivory,
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.all(Radius.circular(6.0)),
                                                          ),
                                                          title: Text(
                                                            'Writing To\n\'$fileName\'\n(sdcard) Failed!',
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
                                                    setState(() {
                                                      this.fileName = _fileName;
                                                    });
                                                    showDialog(
                                                      context: context,
                                                      builder: (BuildContext context) {
                                                        return AlertDialog(
                                                          backgroundColor: ivory,
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.all(Radius.circular(6.0)),
                                                          ),
                                                          title: Text(
                                                            'Writing To\n\'$fileName\'\n(sdcard) Succeeded!',
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}
