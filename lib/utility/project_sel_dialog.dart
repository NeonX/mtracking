import 'dart:convert';
import 'dart:io';

import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mtracking/models/project_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProjectSelDialog extends StatefulWidget {

  final Function(String) selProject;
  ProjectSelDialog({Key key, @required this.selProject}) : super(key: key);

  @override
  _ProjectSelDialogState createState() => _ProjectSelDialogState();
}

class _ProjectSelDialogState extends State<ProjectSelDialog> {
  // Field
  List<ProjectModel> listProjectModel = List();
  String accesskey, provname, amphname;

  // Method

  @override
  void initState() {
    super.initState();
    getKey();
  }

  Future<void> getKey() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      accesskey = prefs.getString('accesskey');
      //print('Key = $accesskey');

      readData();
    });
  }

  Future<void> readData() async {
    if (listProjectModel.length > 0) {
      listProjectModel.clear();
    }

    String urlProjList =
        "https://110.77.142.211/MTrackingServerVM10/projlist.jsp?onlyprg=t&provname=$provname&amphname=$amphname&accesskey=$accesskey";

    Dio dio = new Dio();
      (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate = (client){
        client.badCertificateCallback = (X509Certificate cert, String host, int port){
          return true;
        };
      };
    Response response = await dio.get(urlProjList);

    if (response != null) {
      String result = response.data;

      // result = result.substring(0, result.indexOf('<!'));

      var resJs = json.decode(result);
      //print('Result = $resJs');

      //Map<String, dynamic> proj_ls = resJs['PROJ'];

      resJs['PROJ'].forEach((k, v) {
        //print('$k: $v');

        ProjectModel projectModel = ProjectModel.fromJlist(k, v);

        //print(projectModel.prjId + ' ==>> ' + projectModel.prjName);
        setState(() {
          listProjectModel.add(projectModel);
        });
      });

      //print('End');
    }
  }

  Widget showListView() {
    return Container(
      height: MediaQuery.of(context).size.width * 0.8,
      width: MediaQuery.of(context).size.width * 0.7,
      child: ListView.builder(
        itemBuilder: (BuildContext buildContext, int index) {
          return GestureDetector(
              child: Row(
                children: <Widget>[
                  showImage(index),
                  showText(index),
                ],
              ),
              onTap: () {
                String prjid = listProjectModel[index].prjId;
                widget.selProject(prjid);
                Navigator.pop(context);
              });
        },
        itemCount: listProjectModel.length,
      ),
    );
  }

  Widget showImage(int index) {
    return Container(
        width: MediaQuery.of(context).size.width * 0.2,
        height: MediaQuery.of(context).size.width * 0.2,
        child: Icon(Icons.bookmark));
  }

  Widget showText(int index) {
    return Flexible(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            listProjectModel[index].prjCode,
            style: GoogleFonts.exo2(
                textStyle: TextStyle(
              fontSize: 16,
              color: Colors.red.shade900,
              fontWeight: FontWeight.bold,
            )),
          ),
          Text(listProjectModel[index].prjName),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Text('Select project'),
      children: <Widget>[
        showListView(),
      ],
    );
  }
}
