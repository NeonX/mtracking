import 'dart:convert';
import 'dart:io';

import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:intl/intl.dart';
import 'package:mtracking/models/activity_model.dart';
import 'package:mtracking/models/tracking_model.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mtracking/utility/normal_dialog.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ListPending extends StatefulWidget {
  @override
  _ListPendingState createState() => _ListPendingState();
}

class _ListPendingState extends State<ListPending> {
  String accesskey;
  List<TrackingModel> listPending = List();
  List<TrackingModel> _selecteItems = List();
  double percent = 0.0;
  ProgressDialog pr;

  @override
  void initState() {
    super.initState();
    getKey();
    readData();
  }

  Future<void> readData() async {
    if (listPending.length > 0) {
      setState(() {
        listPending.clear();
        _selecteItems.clear();
      });
    }

    TrackingModel().querySql().then((list) {
      list.forEach((tracking) {
        setState(() {
          listPending.add(tracking);
        });
      });
    });

    print('list size = ${listPending.length}');
  }

  Future<void> getKey() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      accesskey = prefs.getString('accesskey');
    });
  }

  Widget showListView() {
    return ListView.builder(
      itemBuilder: (BuildContext buildContext, int index) {
        return GestureDetector(
            child: Row(
              children: <Widget>[
                showImage(index),
                showText(index),
              ],
            ),
            onTap: () {
              TrackingModel trackingModel = listPending[index];
              //Scaffold.of(context).showSnackBar(SnackBar(content: Text(trackingModel.tid)));
            });
      },
      itemCount: listPending.length,
    );
  }

  void _onItemSelected(bool selected, TrackingModel trackingModel) {
    if (selected == true) {
      setState(() {
        _selecteItems.add(trackingModel);
      });
    } else {
      setState(() {
        _selecteItems.remove(trackingModel);
      });
    }
  }

  Widget showListChk() {
    return ListView.builder(
      itemBuilder: (BuildContext buildContext, int index) {
        return CheckboxListTile(
          controlAffinity: ListTileControlAffinity.leading,
          value: _selecteItems.contains(listPending[index]),
          onChanged: (bool selected) {
            _onItemSelected(selected, listPending[index]);
          },
          title: GestureDetector(
              child: Row(
                children: <Widget>[
                  showImage(index),
                  showText(index),
                ],
              ),
              onTap: () {
                TrackingModel trackingModel = listPending[index];
                //Scaffold.of(context).showSnackBar(SnackBar(content: Text(trackingModel.tid)));
              }),
        );
      },
      itemCount: listPending.length,
    );
  }

  Widget showImage(int index) {
    return Container(
        padding: EdgeInsets.only(top: 10.0, right: 10.0, bottom: 10.0),
        width: MediaQuery.of(context).size.width * 0.4,
        height: MediaQuery.of(context).size.width * 0.3,
        child: Image.file(
          new File(listPending[index].imgPath),
          fit: BoxFit.cover,
        ));
  }

  Widget showText(int index) {
    var tstamp = int.parse(listPending[index].snaptime);
    var date = new DateTime.fromMillisecondsSinceEpoch(tstamp);
    var formatter = new DateFormat('dd-MM-yyyy HH:mm:ss');

    String formatted = formatter.format(date);

    return Flexible(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            listPending[index].projName,
            style: GoogleFonts.exo2(
                textStyle: TextStyle(
              fontSize: 16,
              color: Colors.red.shade900,
              fontWeight: FontWeight.bold,
            )),
          ),
          Text(formatted),
        ],
      ),
    );
  }

  Widget uploadButton() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(right: 15.0, bottom: 15.0),
              child: FloatingActionButton(
                child: Icon(Icons.cloud_upload),
                onPressed: () {
                  uploadDataToServer();
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> uploadDataToServer() async {
    if (_selecteItems.length > 0) {
      pr.style(message: "Uploading data...");
      pr.show();

      await Future.forEach(_selecteItems, (track) async {
        await insertDataToServer(track);
        print('Upload tracking_id = ${track.tid}');
      });
      print('Upload finish!!');

      if (pr.isShowing()) {
        readData();
        pr.hide();
      }
    } else {
      normalDialog(context, 'Upload', 'No data was selected');
    }
  }

  Future<bool> insertDataToServer(TrackingModel track) async {
    String url = 'https://110.77.142.211/MTrackingServerVM10/m_upload/saveimg';

    var tstamp = int.parse(track.snaptime);
    var tsdate = new DateTime.fromMillisecondsSinceEpoch(tstamp);

    var formatter = new DateFormat('yyyy-MM-dd_Hms');
    String formatted = formatter.format(tsdate);
    String fileName = 'image_$formatted.jpg';
    print(fileName);

    try {
      File file = new File(track.imgPath);

      Map<String, dynamic> map = Map();
      map['uploaded'] =
          await MultipartFile.fromFile(file.path, filename: fileName);
      map['userkey'] = accesskey;
      map['pid'] = track.projId;
      map['actid'] = track.actId;
      map['jobid'] = track.jobTypeId;
      map['sta'] = track.sta;
      map['detail'] = track.jobDetail; //job detail
      map['caption'] = track.caption; //image caption
      map['lat'] = track.lat;
      map['long'] = track.lon;
      map['snaptime'] = track.snaptime;

      //--survey road damage drr
      map['sta_to'] = track.staTo;
      map['dmgcatdrrid'] = track.dmgCateDrrId;
      map['dmgcatdrr_name'] = track.dmgCateDrrName;
      map['dmgcatdrr_level'] = track.dmgCateDrrLevel;

      //--survey road damage doh
      map['rdcode'] = track.rdCode;
      map['dmgdetid'] = track.dmgDetId;

      FormData formData = FormData.fromMap(map);

      Dio dio = new Dio();
      (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
          (client) {
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) {
          return true;
        };
      };
      await dio.post(url, data: formData).then((response) {
        // print('response : $response');

        Map<String, dynamic> res = json.decode(response.toString());

        if (res['SUCCESS'] == 1) {
          //int id = int.parse(track.tid);
          TrackingModel().delete(track.tid);

          return true;
        }
      });
    } catch (e) {}
    return false;
  }

  Widget buildSpeedDial() {
    return Container(
        margin: EdgeInsets.only(right: 15.0, bottom: 15.0),
        child: SpeedDial(
          animatedIcon: AnimatedIcons.menu_close,
          animatedIconTheme: IconThemeData(size: 22.0),
          // child: Icon(Icons.add),
          onOpen: () => print('OPENING DIAL'),
          onClose: () => print('DIAL CLOSED'),
          visible: true,
          curve: Curves.bounceIn,
          children: [
            SpeedDialChild(
              child: Icon(Icons.delete_forever, color: Colors.white),
              backgroundColor: Colors.red,
              onTap: () {
                deleteDialog();
              },
              label: 'ลบข้อมูล',
              labelStyle:
                  TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
              labelBackgroundColor: Colors.red,
            ),
            SpeedDialChild(
              child: Icon(Icons.cloud_upload, color: Colors.white),
              backgroundColor: Colors.blue,
              onTap: () {
                uploadDataToServer();
              },
              label: 'อัพโหลดข้อมูล',
              labelStyle:
                  TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
              labelBackgroundColor: Colors.blue,
            ),
          ],
        ));
  }

  Future<void> deleteDialog() async {
    if (_selecteItems.length > 0) {
      showDialog(
        context: context,
        barrierDismissible: false, // user must tap button for close dialog!
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('ลบข้อมูลสำรวจ'),
            content: Text('คุณต้องการลบข้อมูลสำรวจ ใช่หรือไม่?'),
            actions: <Widget>[
              FlatButton(
                child: Text('ใช่'),
                onPressed: () {
                  deleteData();
                  
                },
              ),
              FlatButton(
                child: Text('ไม่'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        },
      );
    } else {
      normalDialog(context, 'Delete', 'No data was selected');
    }
  }

  Future<void> deleteData() async {
      Navigator.of(context).pop();
      pr.style(message: "Deleting data...");
      pr.show();

      await Future.forEach(_selecteItems, (track) async {
        await TrackingModel().delete(track.tid);
        setState(() {
          listPending.removeWhere((item) => item.tid == track.tid);
        });
      });

      Future.delayed(Duration(seconds: 1)).then((value) async {
        if (pr.isShowing()) {
          //readData();
          pr.hide();
          
        }
      });
  }

  @override
  Widget build(BuildContext context) {
    pr = ProgressDialog(context, type: ProgressDialogType.Normal);

    pr.style(
      message: 'Uploading data...',
      borderRadius: 10.0,
      backgroundColor: Colors.white,
      elevation: 10.0,
      insetAnimCurve: Curves.easeInOut,
      progress: 0.0,
      maxProgress: 100.0,
      progressTextStyle: TextStyle(
          color: Colors.black, fontSize: 13.0, fontWeight: FontWeight.w400),
      messageTextStyle: TextStyle(
          color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.w600),
    );

    return Stack(
      children: <Widget>[
        //showListView(),
        showListChk(),
        buildSpeedDial(),
        //uploadButton(),
      ],
    );
  }
}
