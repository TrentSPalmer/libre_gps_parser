import 'package:permission_handler/permission_handler.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'global_helper_functions.dart';
import 'database_helper.dart';
import 'dart:io';

class EditNotes extends StatefulWidget {
  final String mapLocation;

  EditNotes({
    Key key,
    this.mapLocation,
  }) : super(key: key);

  @override
  _EditNotesState createState() => _EditNotesState();
}

class _EditNotesState extends State<EditNotes> {
  final double textHeight = 1.5;
  final _textEditingController = TextEditingController();
  final dbHelper = DatabaseHelper.instance;
  String _inputText = '';
  String _oldNotes = '';

  @override
  void initState() {
    super.initState();
    loadNotes();
  }

  @override
  Widget build(BuildContext context) {
    Future<bool> _requestPop() {
      if (_inputText != _oldNotes) {
        showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return AlertDialog(
                backgroundColor: ivory,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(6.0)),
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      'Discard your changes?',
                      textAlign: TextAlign.center,
                    ),
                    Container(
                      margin: EdgeInsets.only(
                        top: 40,
                        bottom: 10,
                      ),
                      child: Wrap(
                        runSpacing: 30,
                        children: <Widget>[
                          Container(
                            margin: EdgeInsets.symmetric(
                              horizontal: 15,
                            ),
                            child: ButtonTheme(
                              height: 75,
                              child: RaisedButton(
                                  color: peacockBlue,
                                  child: Text(
                                    "No",
                                    style: TextStyle(
                                      height: textHeight,
                                      color: Colors.white,
                                      fontSize: 24,
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  }),
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.symmetric(
                              horizontal: 15,
                            ),
                            child: ButtonTheme(
                              height: 75,
                              child: RaisedButton(
                                  color: peacockBlue,
                                  child: Text(
                                    "Discard",
                                    style: TextStyle(
                                      height: textHeight,
                                      color: Colors.white,
                                      fontSize: 24,
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    Navigator.of(context).pop();
                                  }),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            });
        return Future.value(false);
      } else {
        return Future.value(true);
      }
    }

    return WillPopScope(
      onWillPop: _requestPop,
      child: Scaffold(
        backgroundColor: ivory,
        appBar: AppBar(
          title: const Text('Notes, MarkDown Supported'),
          actions: <Widget>[
            IconButton(
                icon: Icon(Icons.save),
                onPressed: () async {
                  Navigator.of(context).pop(this._inputText);
                  Map<String, dynamic> row = {
                    DatabaseHelper.columnMapLocation: widget.mapLocation,
                    DatabaseHelper.columnNotes: this._inputText,
                  };
                  await dbHelper.update(row);
                }),
          ],
        ),
        body: Column(
          children: <Widget>[
            Expanded(
              child: TextField(
                controller: _textEditingController,
                keyboardType: TextInputType.multiline,
                maxLines: null,
                onChanged: (text) {
                  _inputText = text;
                },
              ),
            ),
            Row(
              children: <Widget>[
                Expanded(
                  child: Container(),
                ),
                Container(
                  margin: EdgeInsets.all(20.0),
                  child: ButtonTheme(
                    height: 55,
                    padding: EdgeInsets.only(
                        top: 5, right: 12, bottom: 12, left: 10),
                    child: RaisedButton(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(6.0)),
                        ),
                        color: peacockBlue,
                        child: Text(
                          'Import',
                          style: TextStyle(
                            height: textHeight,
                            color: Colors.white,
                            fontSize: 24,
                          ),
                        ),
                        onPressed: () async {
                          Map<PermissionGroup, PermissionStatus>
                              _storagePermissions;
                          PermissionStatus _storagePermission =
                              await PermissionHandler().checkPermissionStatus(
                                  PermissionGroup.storage);
                          if (_storagePermission == PermissionStatus.denied) {
                            _storagePermissions = await PermissionHandler()
                                .requestPermissions([PermissionGroup.storage]);
                          }
                          if ((_storagePermission ==
                                  PermissionStatus.granted) ||
                              (_storagePermissions.toString() ==
                                  PermissionStatus.granted.toString())) {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    backgroundColor: ivory,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(6.0)),
                                    ),
                                    title: Text(
                                      'You can import a markdown (or plain text) file.',
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
                                                left: 10),
                                            child: RaisedButton(
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(6.0)),
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
                                                onPressed: () async {
                                                  String _filePath;
                                                  _filePath = await FilePicker
                                                      .getFilePath(
                                                          type: FileType.ANY);
                                                  Navigator.of(context).pop();
                                                  try {
                                                    String _contents =
                                                        await File(_filePath)
                                                            .readAsString();
                                                    setState(() {
                                                      this
                                                          ._textEditingController
                                                          .text = _contents;
                                                      this._inputText =
                                                          _contents;
                                                    });
                                                  } catch (e) {
                                                    print(e);
                                                    showDialog(
                                                        context: context,
                                                        builder: (BuildContext
                                                            context) {
                                                          return AlertDialog(
                                                            backgroundColor:
                                                                ivory,
                                                            shape:
                                                                RoundedRectangleBorder(
                                                              borderRadius: BorderRadius
                                                                  .all(Radius
                                                                      .circular(
                                                                          6.0)),
                                                            ),
                                                            title: Text(
                                                              'Oops, something went wrong',
                                                              textAlign:
                                                                  TextAlign
                                                                      .center,
                                                              style: TextStyle(
                                                                color:
                                                                    candyApple,
                                                              ),
                                                            ),
                                                            content: Column(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              children: <
                                                                  Widget>[
                                                                Container(
                                                                  margin:
                                                                      EdgeInsets
                                                                          .only(
                                                                    top: 40,
                                                                    bottom: 10,
                                                                  ),
                                                                  child:
                                                                      ButtonTheme(
                                                                    height: 55,
                                                                    padding: EdgeInsets.only(
                                                                        top: 5,
                                                                        right:
                                                                            12,
                                                                        bottom:
                                                                            12,
                                                                        left:
                                                                            10),
                                                                    child: RaisedButton(
                                                                        shape: RoundedRectangleBorder(
                                                                          borderRadius:
                                                                              BorderRadius.all(Radius.circular(6.0)),
                                                                        ),
                                                                        color: peacockBlue,
                                                                        child: Text(
                                                                          'OK',
                                                                          style:
                                                                              TextStyle(
                                                                            height:
                                                                                textHeight,
                                                                            color:
                                                                                Colors.white,
                                                                            fontSize:
                                                                                24,
                                                                          ),
                                                                        ),
                                                                        onPressed: () async {
                                                                          Navigator.of(context)
                                                                              .pop();
                                                                        }),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          );
                                                        });
                                                  }
                                                }),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                });
                          }
                        }),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> loadNotes() async {
    String _notes = await dbHelper.queryNotes(widget.mapLocation);
    setState(() {
      _oldNotes = _notes;
      _textEditingController.text = _notes;
      _inputText = _notes;
    });
  }
}
