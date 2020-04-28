import 'package:flutter/material.dart';
import 'package:progress_dialog/progress_dialog.dart';

class SurveyRdDmgDoh extends StatefulWidget {
  final String projName;
  final String projId;
  final String jobTypeId;

  @override
  _SurveyRdDmgDohState createState() => _SurveyRdDmgDohState();

  SurveyRdDmgDoh(this.projId, this.projName, this.jobTypeId);
}

class _SurveyRdDmgDohState extends State<SurveyRdDmgDoh> {
  ProgressDialog pr;

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

    return Scaffold(
        appBar: AppBar(
          title: Text('ตรวจสอบสภาพถนน ทล.', style: TextStyle(fontSize: 16.0),),
        ),
        body: Container(
          child: Center(
            child: Text('Under Construction for Survey Road Damage DOH Form'),
          ),
        ));
  }
}
