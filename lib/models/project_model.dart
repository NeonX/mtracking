import 'package:mtracking/db/database_helper.dart';
import 'package:sqflite/sqflite.dart';

class ProjectModel {
  static final table = 'projectx';

  static final columnId = '_id';
  static final columnPjCode = 'proj_code';
  static final columnPjName = 'proj_name';
  static final columnJbType = 'job_type';
  static final columnJbTypeId = 'job_type_id';
  static final columnPvId = 'prov_id';
  static final columnApId = 'amph_id';
  static final columnPjId = 'proj_id';
  
  String prjId;
  String prjName;
  String prjCode;
  String jobType;
  String jobTypeId;
  String provId;
  String ampId;

  final dbHelper = DatabaseHelper.instance;

  ProjectModel({this.prjId, this.prjName, this.prjCode, this.jobType,
      this.jobTypeId, this.provId, this.ampId});


  ProjectModel.fromJlist(String pid, List<dynamic> json) {
    prjId = pid;
    prjCode = json[0];
    prjName = json[1];
    jobType = json[2];
    jobTypeId = json[3];
    provId = json[4];
    ampId = json[5];
    
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data[columnId] = this.prjId;
    data[columnPjName] = this.prjName;
    data[columnPjCode] = this.prjCode;
    data[columnJbType] = this.jobType;
    data[columnJbTypeId] = this.jobTypeId;
    data[columnPvId] = this.provId;
    data[columnApId] = this.ampId;
    data[columnPjId] = this.prjId;
    return data;
  }

  ProjectModel.fromMap(Map<String, dynamic> map) {
    prjId = map[columnId].toString();
    prjName = map[columnPjName];
    prjCode = map[columnPjCode];
    jobType = map[columnJbType];
    provId = map[columnPvId].toString();
    ampId = map[columnApId].toString();
    jobTypeId = map[columnJbTypeId];

  }

  Future<int> deleteAll() async {
    Database db = await dbHelper.database;
    return await db.delete(table);
  }

  Future<int> deleteByAmphur(String aid) async {
    Database db = await dbHelper.database;
    return await db.delete(table, where: '$columnPvId is null or $columnApId = ?', whereArgs: [aid]);
  }

  Future<int> deleteByProvince(String pid) async {
    Database db = await dbHelper.database;
    return await db.delete(table, where: '$columnPvId is null or $columnPvId = ?', whereArgs: [pid]);
  }

  Future<void> insertList(List<ProjectModel> listProject) async {

    listProject.forEach((ProjectModel pj) async {
      if(pj.provId != '-1'){
        final id = await dbHelper.insert(table, pj.toJson());
        //print('inserted tracking row id: $id');
      }
    });
  }

  Future<int> delete(int id) async {
    Database db = await dbHelper.database;
    return await db.delete(table, where: '$columnId = ?', whereArgs: [id]);
  }

  Future<List<ProjectModel>> querySql() async {
    Database db = await dbHelper.database;
    final allRows =
        await db.rawQuery('SELECT * FROM $table ORDER BY $columnId ASC');

    List<ProjectModel> list = List();
    allRows.forEach((row) => list.add(ProjectModel.fromMap(row)));

    return list;
  }
}
