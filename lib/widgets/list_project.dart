import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mtracking/models/activity_model.dart';
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
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

class ListProject extends StatefulWidget {
  @override
  _ListProjectState createState() => _ListProjectState();
}

class _ListProjectState extends State<ListProject> {
  // Field
  List<ProjectModel> listProjectModel = List();
  String accesskey, provname, amphname, provdisp, amphdisp;
  String provId, amphId;
  ProgressDialog pr;
  bool dialVisible = true;
  String prj4Act;

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

    pr.style(message: "Refreshing data...");
    pr.show();

    Future.delayed(Duration(seconds: 3)).then((value) async {
      await readData();

      if (pr.isShowing()) {
        pr.hide();
      }
    });
  }

  Future<void> saveProjectList() async {
    Navigator.of(context).pop();
    pr.style(message: "Saving Project List");
    pr.show();

    //print("Search pid = $provId and aid = $amphId .... ^ ^" );

    Future.delayed(Duration(seconds: 3)).then((value) async {

      if(amphId != null){
        await ProjectModel().deleteByAmphur(amphId);
      }else if(provId != null){
        await ProjectModel().deleteByProvince(provId);
      }else{
        await ProjectModel().deleteAll();
      }

      await ProjectModel().insertList(listProjectModel);

      await ProjectModel().querySql().then((list) async{
        prj4Act = "";
        list.forEach((proj) {
          if(proj.jobType == "PROGRESSION"){
            prj4Act += proj.prjId+",";
          }
          //print('>>${proj.prjName} :: ${proj.provId}');
        }); 

        if(prj4Act.length > 0){
          prj4Act = prj4Act.substring(0, prj4Act.length-1);

          await readActivity();
        }

        //print('Save project = ${list.length} rec.');
      }); 

      if (pr.isShowing()) {
        pr.hide();
      }
      
    });
  }

  Future<void> readActivity() async {
    String urlActList = "https://110.77.142.211/MTrackingServerVM10/act_multi_list.jsp?accesskey=$accesskey&pid=$prj4Act";

    Dio dio = new Dio();
    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
        (client) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) {
        return true;
      };
    };
    Response response = await dio.get(urlActList);

    if (response != null) {
      String result = response.data;
      var resJs = json.decode(result);

      List<dynamic> act_ls = resJs['ACTIVITY'];

      if (act_ls.isNotEmpty) {

        await ActivityModel().deleteByProjIds(prj4Act);

        act_ls.forEach((json) async{
          Map<String, dynamic> data = ActivityModel().ltoJson(json);
          await ActivityModel().insertMap(data);
        });
        
      }

    }
  }

  Future<void> confirmSaveDialog() async {
    showDialog(
      context: context,
      barrierDismissible: false, // user must tap button for close dialog!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("บันทึกโครงการ"),
          content: Text("ต้องการบันทึกโครงการใช่หรือไม่?"),
          actions: <Widget>[
            FlatButton(
              child: Text('ใช่'),
              onPressed: () {
                saveProjectList();
        
              },
            ),
            FlatButton(
              child: Text('ยกเลิก'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
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
    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
        (client) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) {
        return true;
      };
    };
    Response response = await dio.get(urlProjList);

    if (response != null) {
      String result = response.data;

      // result = result.substring(0, result.indexOf('<!'));

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

    provId = province != null && province.pId != '0' ? province.pId : null;
    amphId = amphur != null && amphur.aId != '0' ? amphur.aId : null;

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
              child: Icon(Icons.save, color: Colors.white),
              backgroundColor: Colors.deepOrange,
              onTap: () {
                confirmSaveDialog();
              },
              label: 'บันทึกโครงการ',
              labelStyle:
                  TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
              labelBackgroundColor: Colors.deepOrangeAccent,
            ),
            SpeedDialChild(
              child: Icon(Icons.refresh, color: Colors.white),
              backgroundColor: Colors.green,
              onTap: () {

                refreshProjectList();
              },
              label: 'รีเฟรซ',
              labelStyle:
                  TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
              labelBackgroundColor: Colors.green,
            ),
            SpeedDialChild(
              child: Icon(Icons.search, color: Colors.white),
              backgroundColor: Colors.blue,
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return SearchDialog(notifyParent: refresh);
                  },
                );
              },
              label: 'ค้นหาโครงการ',
              labelStyle:
                  TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
              labelBackgroundColor: Colors.blue,
            ),
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    pr = ProgressDialog(context, type: ProgressDialogType.Normal);

    pr.style(
      message: "...",
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
        showSearchData(),
        showListView(),
        buildSpeedDial(),
      ],
    );
  }
}
