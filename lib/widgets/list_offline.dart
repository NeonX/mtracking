import 'package:flutter/material.dart';
import 'package:mtracking/models/project_model.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mtracking/screens/fm_survey_rd_dmg_doh.dart';
import 'package:mtracking/screens/fm_survey_rd_dmg_drr.dart';
import 'package:mtracking/screens/upload_form.dart';
import 'package:mtracking/utility/app_util.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:circular_menu/circular_menu.dart';
import 'package:flutter_slidable_list_view/flutter_slidable_list_view.dart';

class ListOffline extends StatefulWidget {
  @override
  _ListOfflineState createState() => _ListOfflineState();
}

class _ListOfflineState extends State<ListOffline> {
  String accesskey;
  List<ProjectModel> listProjectModel = List();
  double percent = 0.0;
  ProgressDialog pr;

  String _colorName = 'No';
  Color _color = Colors.black;

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

  Widget showSlideListView() {
    return listProjectModel.isEmpty
        ? Center(child: Text('No data'))
        : Padding(
            padding: const EdgeInsets.only(top: 0.0),
            child: SlideListView(
              itemBuilder: (bc, index) {
                return GestureDetector(
                  child: Container(
                    padding: EdgeInsets.all(10),
                    child: Row(
                      children: <Widget>[
                        showImage(index),
                        showText(index),
                      ],
                    ),
                  ),
                  onTap: () {
                    setPref("is_offline", "true");

                    ProjectModel projectModel = listProjectModel[index];
                    // Scaffold.of(context).showSnackBar(SnackBar(content: Text(projectModel.prjName)));
                    MaterialPageRoute materialPageRoute =
                        MaterialPageRoute(builder: (BuildContext buildContext) {
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
                  },
                  behavior: HitTestBehavior.translucent,
                );
              },
              actionWidgetDelegate:
                  ActionWidgetDelegate(2, (actionIndex, listIndex) {
                if (actionIndex == 0) {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[Icon(Icons.delete), Text('delete')],
                  );
                } else {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      listIndex > 5 ? Icon(Icons.close) : Icon(Icons.adjust),
                      Text('close')
                    ],
                  );
                }
              }, (int indexInList, int index, BaseSlideItem item) {
                if (index == 0) {
             
                  String pid = listProjectModel[indexInList].prjId;
                  ProjectModel().delete(int.parse(pid));

                  item.remove(); 
                } else {
                  item.close();
                }
              }, [Colors.redAccent, Colors.blueAccent]),
              dataList: listProjectModel,
              refreshCallback: () async {
                await Future.delayed(Duration(seconds: 2));
                return;
              },
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

  Widget showCircularMenu() {
    return CircularMenu(
      alignment: Alignment.bottomRight,
      toggleButtonColor: Colors.red,
      toggleButtonSize: 33,
      toggleButtonMargin: 15,
      toggleButtonBoxShadow: [
        BoxShadow(
          color: Colors.red,
          blurRadius: 2,
        ),
      ],
      items: [
        CircularMenuItem(
            icon: Icons.delete_forever,
            color: Colors.red.shade900,
            onTap: () {
              deleteAllDialog();
            }),
        CircularMenuItem(
            icon: Icons.search,
            color: Colors.blue,
            onTap: () {
              setState(() {
                _color = Colors.blue;
                _colorName = 'Blue';
              });
            }),
        CircularMenuItem(
            icon: Icons.settings,
            color: Colors.orange,
            onTap: () {
              setState(() {
                _color = Colors.orange;
                _colorName = 'Orange';
              });
            }),
      ],
    );
  }

  Future<void> deleteAllDialog() async {
    showDialog(
      context: context,
      barrierDismissible: false, // user must tap button for close dialog!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('ลบโครงการ'),
          content: Text('คุณต้องการลบรายชื่อโครงการทั้งหมด ใช่หรือไม่?'),
          actions: <Widget>[
            FlatButton(
              child: Text('ใช่'),
              onPressed: () {
                ProjectModel().deleteAll().then((int x) {
                  readData();
                  Navigator.of(context).pop();
                });
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
  }

  Widget deleteAllButton() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(right: 15.0, bottom: 15.0),
              child: FloatingActionButton(
                child: Icon(Icons.delete_forever),
                onPressed: () {
                  deleteAllDialog();
                },
              ),
            ),
          ],
        ),
      ],
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
        showSlideListView(),
        //buildSpeedDial(),
        //showCircularMenu() ,
        deleteAllButton(),
      ],
    );
  }
}
