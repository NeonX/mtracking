import 'package:mtracking/db/database_helper.dart';
import 'package:sqflite/sqflite.dart';

class DmgCategoryModel {

  static final table = 'damage_category';

  static final columnId = '_id';
  static final columnDmgName = 'damage_cate_name';
  static final columnOrder = 'order_no';

  String dmgCateId;
  String dmgCateName;
  int orderNo;

  final dbHelper = DatabaseHelper.instance;
  
  DmgCategoryModel({this.dmgCateId, this.dmgCateName, this.orderNo});

  DmgCategoryModel.fromJson(Map<String, dynamic> json) {
    dmgCateId = json[columnId].toString();
    dmgCateName = json[columnDmgName];
    orderNo = json[columnOrder];

  }

  DmgCategoryModel.fromJlist(String did, List<dynamic> json) {
    dmgCateId = did;
    dmgCateName = json[0];
    orderNo = json[1];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data[columnId] = this.dmgCateId;
    data[columnDmgName] = this.dmgCateName;
    data[columnOrder] = this.orderNo;
    return data;
  }

  Future<List<DmgCategoryModel>> querySql() async {
    Database db = await dbHelper.database;
    final allRows = await db.rawQuery('SELECT * FROM $table ORDER BY $columnOrder ASC');

    List<DmgCategoryModel> list = List();
    allRows.forEach((row) => list.add(DmgCategoryModel.fromJson(row)));

    return list;
  }

  Future<int> deleteAll() async {
    Database db = await dbHelper.database;
    return await db.delete(table);
  }

  Future<void> insertList(List<DmgCategoryModel> listDmg) async {

    listDmg.forEach((DmgCategoryModel dmg) async {
      await dbHelper.insert(table, dmg.toJson());
    });
  }
}
