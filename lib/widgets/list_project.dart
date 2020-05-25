import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mtracking/models/amphur.dart';
import 'package:mtracking/models/project_model.dart';
import 'package:mtracking/models/province.dart';
import 'package:mtracking/screens/fm_survey_rd_dmg_doh.dart';
import 'package:mtracking/screens/fm_survey_rd_dmg_drr.dart';
import 'package:mtracking/screens/upload_form.dart';
import 'package:mtracking/utility/my_style.dart';
import 'package:mtracking/utility/search_dialog.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ListProject extends StatefulWidget {
  @override
  _ListProjectState createState() => _ListProjectState();
}

class _ListProjectState extends State<ListProject> {
  // Field
  List<ProjectModel> listProjectModel = List();
  String accesskey, provname, amphname, provdisp, amphdisp;
  ProgressDialog pr;

  // Method

  @override
  void initState() {
    super.initState();
    getKey();

    provdisp = 'ทั้งหมด';
    amphdisp = 'ทั้งหมด';
  }

  Future<void> getKey() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      accesskey = prefs.getString('accesskey');
      //print('Key = $accesskey');

      readData();
    });
  }

  Future<void> refreshProjectList() async {
    pr.show();

    Future.delayed(Duration(seconds: 3)).then((value) async {
      await readData();
   
      if (pr.isShowing()) {
        pr.hide();
      }
    });
  }

  Future<void> readData() async {
    if (listProjectModel.length > 0) {
      setState(() {
        listProjectModel.clear();
      });
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

      result = result.substring(0, result.indexOf('<!'));

      var resJs = json.decode(result);
      // print('Result = $resJs');

      Map<String, dynamic> proj_ls = resJs['PROJ'];

      if (proj_ls.isNotEmpty) {
        proj_ls.forEach((k, v) {
          //print('$k: $v');

          ProjectModel projectModel = ProjectModel.fromJlist(k, v);

          //print(projectModel.prjId + ' ==>> ' + projectModel.prjName);
          setState(() {
            listProjectModel.add(projectModel);
          });
        });
      } else {
        setState(() {
          listProjectModel.clear();
        });
      }
    } else {
      setState(() {
        listProjectModel.clear();
      });
    }
  }

  Future<void> refresh(Province province, Amphur amphur) async {
    provname = province != null && province.pId != '0' ? province.pName : null;
    amphname = amphur != null && amphur.aId != '0' ? amphur.aName : null;

    setState(() {
      provdisp = province != null ? province.pName : 'ทั้งหมด';
      amphdisp = amphur != null ? amphur.aName : 'ทั้งหมด';
    });

    readData();
  }

  Widget showListView() {
    return listProjectModel.isEmpty
        ? Center(child: Text('No data'))
        : Padding(
            padding: const EdgeInsets.only(top: 25.0),
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
                      ProjectModel projectModel = listProjectModel[index];
                      // Scaffold.of(context).showSnackBar(SnackBar(content: Text(projectModel.prjName)));
                      MaterialPageRoute materialPageRoute = MaterialPageRoute(
                          builder: (BuildContext buildContext) {
                        if (projectModel.jobTypeId.compareTo('1') == 0) {
                          return UploadForm(projectModel.prjId,
                              projectModel.prjName, projectModel.jobTypeId);
                        } else if (projectModel.jobTypeId.compareTo('2') == 0) {
                          return SurveyRdDmgDoh(projectModel.prjId,
                              projectModel.prjName, projectModel.jobTypeId);
                        } else if (projectModel.jobTypeId.compareTo('8') == 0) {
                          return SurveyRdDmgDrr(projectModel.prjId,
                              projectModel.prjName, projectModel.jobTypeId);
                        }
                      });
                      Navigator.of(context).push(materialPageRoute);
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

  Widget refreshButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(right: 15.0, bottom: 18.0),
          child: FloatingActionButton(
            heroTag: "refreshBtn",
            backgroundColor: Colors.white,
            foregroundColor: Colors.red,
            child: Icon(Icons.refresh),
            onPressed: () {
              refreshProjectList();
            },
          ),
        ),
      ],
    );
  }

  Widget searchButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(right: 15.0, bottom: 15.0),
          child: FloatingActionButton(
            heroTag: "searchBtn",
            child: Icon(Icons.search),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return SearchDialog(notifyParent: refresh);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget showButton() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        refreshButton(),
        searchButton(),
      ],
    );
  }

  Widget showSearchData() {
    return Padding(
      padding: const EdgeInsets.only(left: 10.0, top: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Text('ค้นหา >> ',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: MyStyle().txtColor,
              )),
          Text('จังหวัด : $provdisp',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade500,
              )),
          Text(' >> ',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: MyStyle().txtColor,
              )),
          Text('อำเภอ : $amphdisp',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green.shade500,
              )),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    pr = ProgressDialog(context, type: ProgressDialogType.Normal);

    pr.style(
      message: 'Refresh data...',
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
        showListView(),
        showSearchData(),
        showButton(),
      ],
    );
  }
}
