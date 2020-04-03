import 'package:mtracking/db/database_helper.dart';
import 'package:sqflite/sqflite.dart';

class Province {
  // Field
  static final table = 'province';

  static final columnId = '_id';
  static final columnName = 'prov_name_th';
  static final columnNameEn = 'prov_name_en';

  String pId;
  String pName;
  String pEng;

  final dbHelper = DatabaseHelper.instance;

  // Method
  Province({this.pId, this.pName, this.pEng});

  Province.fromJson(Map<String, dynamic> json) {
    pId = json[columnId].toString();
    pName = json[columnName];
    pEng = json[columnNameEn];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data[columnId] = this.pId;
    data[columnName] = this.pName;
    data[columnNameEn] = this.pEng;

    return data;
  }

  Future<List<Province>> query() async {

    Database db = await dbHelper.database;
    final allRows = await db.query(table);

    List<Province> listProv = List();
    allRows.forEach((row) => listProv.add(Province.fromJson(row)));

    //listProv.forEach((o) => print('==>> ' + o.pId + ' x ' + o.pName));

    
    return listProv;
  }

  Future<List<Province>> querySql() async {

    Database db = await dbHelper.database;
    final allRows = await db.rawQuery('SELECT * FROM $table ORDER BY $columnName ASC');

    List<Province> listProv = List();
    allRows.forEach((row) => listProv.add(Province.fromJson(row)));


    return listProv;
  }

  void insert(Map<String, dynamic> row) async {
    
    final id = await dbHelper.insert(table, row);
    print('inserted row id: $id');
  }

  
  
  /*
  Future<int> update(String where, Map<String, dynamic> row) async {
    Database db = await dbHelper.database;
    int id = row[columnId];
    return await db.update(table, row, where: '$columnId = ?', whereArgs: [id]);
  }
  */



}
