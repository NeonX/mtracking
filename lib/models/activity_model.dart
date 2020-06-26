import 'dart:convert';

import 'package:mtracking/db/database_helper.dart';
import 'package:sqflite/sqflite.dart';

class ActivityModel {

  static final table = 'activity';

  static final columnId = '_id';
  static final columnActName = 'act_name';
  static final columnUnit = 'unit';
  static final columnPrjId = 'proj_id';
  static final columnActBaseId = 'activity_base_id';
  static final columnOrder = 'order_no';

  String aid;
  String actId;
  int orderNo;
  String actName;
  String projId;
  String unit;

  final dbHelper = DatabaseHelper.instance;
  
  ActivityModel({this.aid, this.actId, this.orderNo, this.actName, this.unit, this.projId});

  ActivityModel.fromJson(Map<String, dynamic> json) {
    aid = json[columnId].toString();
    actId = json[columnActBaseId].toString();
    orderNo = json[columnOrder];
    actName = json[columnActName];
    projId = json[columnPrjId].toString();
    unit = json[columnUnit];
  }

  ActivityModel.fromJlist(String aid, List<dynamic> json) {
    actId = aid;
    actName = json[0];
    unit = json[1];
    orderNo = json[2];

  }

  ActivityModel.fromList(List<dynamic> json) {

    projId = json[0];
    actId = json[1];
    actName = json[2];
    unit = json[3];
    orderNo = json[4];
  }
  

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data[columnId] = this.aid;
    data[columnActBaseId] = this.actId;
    data[columnOrder] = this.orderNo;
    data[columnActName] = this.actName;
    data[columnUnit] = this.unit;
    data[columnPrjId] = this.projId;
    return data;
  }

  Map<String, dynamic> ltoJson(List<dynamic> json) {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data[columnPrjId] = json[0];
    data[columnActBaseId] = json[1];
    data[columnActName] = json[2];
    data[columnUnit] = json[3];
    data[columnOrder] = json[4];
    
    return data;
  }

  Future<List<ActivityModel>> getAcyByProjId(String pid) async {
    Database db = await dbHelper.database;
    final allRows =
        await db.rawQuery('SELECT * FROM $table WHERE $columnPrjId = $pid ORDER BY $columnOrder ASC');

    List<ActivityModel> list = List();
    allRows.forEach((row) => list.add(ActivityModel.fromJson(row)));

    return list;
  }

  Future<int> deleteByProjIds(String pid) async {
    Database db = await dbHelper.database;
    //return await db.delete(table, where: '$columnPrjId in (?)', whereArgs: [pid]);

    return await db.rawDelete('delete from $table where $columnPrjId in ($pid) ');
  }

  Future<void> insertMap(Map<String, dynamic> mapActivity) async {

 
    await dbHelper.insert(table, mapActivity );
    //print('inserted tracking row id: $id');

  }
}
