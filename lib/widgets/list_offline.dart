import 'package:flutter/material.dart';
import 'package:mtracking/models/project_model.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mtracking/screens/fm_survey_rd_dmg_doh.dart';
import 'package:mtracking/screens/fm_survey_rd_dmg_drr.dart';
import 'package:mtracking/screens/upload_form.dart';
import 'package:mtracking/utility/app_util.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ListOffline extends StatefulWidget {
  @override
  _ListOfflineState createState() => _ListOfflineState();
}

class _ListOfflineState extends State<ListOffline> {
  String accesskey;
  List<ProjectModel> listProjectModel = List();
  double percent = 0.0;
  ProgressDialog pr;

  @override
  void initState() {
    super.initState();
    getKey();
    readData();
  }

  Future<void> readData() async {
    if (listProjectModel.length > 0) {
      setState(() {
        listProjectModel.clear();
      });
    }

    await ProjectModel().querySql().then((list) async {
      list.forEach((proj) {
        setState(() {
          listProjectModel.add(proj);
        });
        //print('>>${proj.prjName} :: ${proj.provId}');
      });
    });
  }

  Future<void> getKey() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      accesskey = prefs.getString('accesskey');
    });
  }

  Widget showListView() {
    return listProjectModel.isEmpty
        ? Center(child: Text('No data'))
        : Padding(
            padding: const EdgeInsets.only(top: 0.0),
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

                      setPref("is_offline", "true");
                      
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
        //showSearchData(),
        showListView(),
        //buildSpeedDial(),
      ],
    );
  }
}
