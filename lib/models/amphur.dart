import 'package:mtracking/db/database_helper.dart';
import 'package:sqflite/sqflite.dart';

class Amphur {
  // Field
  static final table = 'amphur';

  static final columnId = '_id';
  static final columnName = 'amph_name_th';
  static final columnNameEn = 'amph_name_en';
  static final columnRefId = 'prov_id';

  String aId,aName,aEng,pId;


  final dbHelper = DatabaseHelper.instance;

  // Method
  Amphur({this.aId, this.aName, this.aEng, this.pId});

  Amphur.fromJson(Map<String, dynamic> json) {
    aId = json[columnId].toString();
    aName = json[columnName];
    aEng = json[columnNameEn];
    pId = json[columnRefId].toString();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data[columnId] = this.aId;
    data[columnName] = this.aName;
    data[columnNameEn] = this.aEng;
    data[columnRefId] = this.pId;

    return data;
  }

  Future<List<Amphur>> query() async {

    Database db = await dbHelper.database;
    final allRows = await db.query(table);

    List<Amphur> listAmp = List();
    allRows.forEach((row) => listAmp.add(Amphur.fromJson(row)));

    return listAmp;
  }

  Future<List<Amphur>> queryByPid(String pid) async {

    String sql = 'SELECT * FROM amphur ';
    if(pid != null){
      sql += ' WHERE prov_id = $pid';
    }

    sql += ' ORDER BY $columnName ASC';
    Database db = await dbHelper.database;
    final allRows = await db.rawQuery(sql);

    List<Amphur> listAmp = List();
    allRows.forEach((row) => listAmp.add(Amphur.fromJson(row)));

    return listAmp;
  }



}
