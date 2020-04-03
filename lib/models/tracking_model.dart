import 'package:mtracking/db/database_helper.dart';
import 'package:sqflite/sqflite.dart';

class TrackingModel {
  static final table = 'trackingdata';

  static final columnId = '_id';
  static final columnPjId = 'proj_id';
  static final columnPjName = 'proj_name';
  static final columnAcId = 'act_id';
  static final columnJtId = 'job_type_id';
  static final columnSta = 'sta';
  static final columnLat = 'latitude';
  static final columnLon = 'longitude';
  static final columnImgPath = 'img_path';
  static final columnJdet = 'prg_detail';
  static final columnCapt = 'description';
  static final columnSnapt = 'snap_time';

  String tid, projId, projName, actId, jobTypeId, sta, lat, lon, imgPath, jobDetail, caption, snaptime;
  bool checked = false;


  final dbHelper = DatabaseHelper.instance;

  TrackingModel(
      {this.tid,
      this.projId,
      this.projName,
      this.actId,
      this.jobTypeId,
      this.sta,
      this.lat,
      this.lon,
      this.imgPath,
      this.jobDetail,
      this.caption,
      this.snaptime});

  TrackingModel.fromMap(Map<String, dynamic> map) {
    tid = map[columnId].toString();
    projId = map[columnPjId].toString();
    projName = map[columnPjName];
    actId = map[columnAcId].toString();
    jobTypeId = map[columnJtId].toString();
    sta = map[columnSta];
    lat = map[columnLat];
    lon = map[columnLon];
    imgPath = map[columnImgPath];
    jobDetail = map[columnJdet];
    caption = map[columnCapt];
    snaptime = map[columnSnapt].toString();
    // more
  }

  void insert(Map<String, dynamic> row) async {
    
    final id = await dbHelper.insert(table, row);
    print('inserted tracking row id: $id');
  }

  Future<List<TrackingModel>> querySql() async {

    Database db = await dbHelper.database;
    final allRows = await db.rawQuery('SELECT * FROM $table ORDER BY $columnId ASC');

    List<TrackingModel> list = List();
    allRows.forEach((row) => list.add(TrackingModel.fromMap(row)));


    return list;
  }

    Future<int> delete(int id) async {
    Database db = await dbHelper.database;
    return await db.delete(table, where: '$columnId = ?', whereArgs: [id]);
  }

}
