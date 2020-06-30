import 'package:mtracking/db/database_helper.dart';
import 'package:sqflite/sqflite.dart';

class DmgDetailModel {

  static final table = 'damage_detail';

  static final columnId = '_id';
  static final columnDetName = 'damage_detail_name';
  static final columnCatId = 'damage_category_id';

  String dmgDetailId;
  String dmgDetailName;
  String dmgCateId;

  final dbHelper = DatabaseHelper.instance;
  
  DmgDetailModel({this.dmgDetailId, this.dmgDetailName, this.dmgCateId});

  DmgDetailModel.fromMap(Map<String, dynamic> map) {
    dmgDetailId = map[columnId].toString();
    dmgDetailName = map[columnDetName];
    dmgCateId = map[columnCatId].toString();
  }

  DmgDetailModel.fromJlist(String did, List<dynamic> json) {
    dmgDetailId = did;
    dmgDetailName = json[0];
    dmgCateId = json[1].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data[columnId] = this.dmgDetailId.toString();
    data[columnDetName] = this.dmgDetailName;
    data[columnCatId] = this.dmgCateId.toString();
    return data;
  }

  Future<List<DmgDetailModel>> querySql(String catId) async {
    Database db = await dbHelper.database;
    final allRows = await db.rawQuery('SELECT * FROM $table WHERE $columnCatId = $catId  ORDER BY $columnDetName ASC');

    List<DmgDetailModel> list = List();
    allRows.forEach((row) => list.add(DmgDetailModel.fromMap(row)));

    return list;
  }

  Future<int> deleteAll() async {
    Database db = await dbHelper.database;
    return await db.delete(table);
  }

  Future<void> insertList(List<DmgDetailModel> listDet) async {

    listDet.forEach((DmgDetailModel det) async {
      await dbHelper.insert(table, det.toJson());
    });
  }

}
