import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
              Scaffold.of(context)
                  .showSnackBar(SnackBar(content: Text(trackingModel.tid)));
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
                Scaffold.of(context)
                    .showSnackBar(SnackBar(content: Text(trackingModel.tid)));
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
      map['uploaded'] = UploadFileInfo(file, fileName);
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

      FormData formData = FormData.from(map);

      Dio dio = new Dio();
      (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate = (client){
        client.badCertificateCallback = (X509Certificate cert, String host, int port){
          return true;
        };
      };
      await dio.post(url, data: formData).then((response) {
        // print('response : $response');

        Map<String, dynamic> res = json.decode(response.toString());

        if (res['SUCCESS'] == 1) {
          int id = int.parse(track.tid);
          TrackingModel().delete(id);

          return true;
        }
      });
    } catch (e) {
      
    }
     return false;
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
        uploadButton(),
      ],
    );
  }
}
