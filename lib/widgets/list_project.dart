import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mtracking/models/amphur.dart';
import 'package:mtracking/models/project_model.dart';
import 'package:mtracking/models/province.dart';
import 'package:mtracking/screens/upload_form.dart';
import 'package:mtracking/utility/search_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ListProject extends StatefulWidget {

  @override
  _ListProjectState createState() => _ListProjectState();


}

class _ListProjectState extends State<ListProject> {
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
        "http://110.77.142.211/MTrackingServer/projlist.jsp?onlyprg=t&provname=$provname&amphname=$amphname&accesskey=$accesskey";

    Response response = await Dio().get(urlProjList);

    if (response != null) {
      String result = response.data;

      result = result.substring(0, result.indexOf('<!'));

      var resJs = json.decode(result);
      print('Result = $resJs');

      Map<String, dynamic> proj_ls = resJs['PROJ'];

      proj_ls.forEach((k, v) {
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

  Future<void> refresh(Province province, Amphur amphur) async {
    provname = province!= null ? province.pName : null;
    amphname = amphur  != null ? amphur.aName   : null;
    readData();
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
              ProjectModel projectModel = listProjectModel[index];
              // Scaffold.of(context).showSnackBar(SnackBar(content: Text(projectModel.prjName)));
              MaterialPageRoute materialPageRoute =
                  MaterialPageRoute(builder: (BuildContext buildContext) {
                return UploadForm(projectModel.prjId, projectModel.prjName, projectModel.jobTypeId);
              });
              Navigator.of(context).push(materialPageRoute);
            });
      },
      itemCount: listProjectModel.length,
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

  Widget searchButton() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(right: 15.0, bottom: 15.0),
              child: FloatingActionButton(
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
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        showListView(),
        searchButton(),
      ],
    );
  }
}
