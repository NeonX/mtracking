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
  static final columnStaTo = 'sta_to';
  static final columnLat = 'latitude';
  static final columnLon = 'longitude';
  static final columnImgPath = 'img_path';
  static final columnJdet = 'prg_detail';
  static final columnCapt = 'description';
  static final columnSnapt = 'snap_time';

  static final columnRdCode = 'road_code';
  static final columnDmgDetId = 'dmg_det_id';

  static final columnTopic = 'topic';
  static final columnInfo1 = 'info1';
  static final columnInfo2 = 'info2';

  static final columnDmgCateDrrId = 'dmg_cate_drr_id';
  static final columnDmgCateDrrName = 'dmg_cate_drr_name';
  static final columnDmgCateDrrLevel = 'dmg_cate_drr_level';
  static final columnDmgCateDrrOtherName = 'dmg_cate_drr_other_name';

  String tid,
      projId,
      projName,
      actId,
      jobTypeId,
      sta,
      staTo,
      lat,
      lon,
      imgPath,
      jobDetail,
      caption,
      snaptime,
      dmgCateDrrId,
      dmgCateDrrName,
      dmgCateDrrLevel,
      dmgCateDrrOtherName,
      rdCode,
      dmgDetId,
      topic,
      info1,
      info2;
  bool checked = false;

  final dbHelper = DatabaseHelper.instance;

  TrackingModel(
      {this.tid,
      this.projId,
      this.projName,
      this.actId,
      this.jobTypeId,
      this.sta,
      this.staTo,
      this.lat,
      this.lon,
      this.imgPath,
      this.jobDetail,
      this.caption,
      this.snaptime,
      this.dmgCateDrrId,
      this.dmgCateDrrName,
      this.dmgCateDrrLevel,
      this.dmgCateDrrOtherName,
      this.rdCode,
      this.dmgDetId,
      this.topic,
      this.info1,
      this.info2});

  TrackingModel.fromMap(Map<String, dynamic> map) {
    tid = map[columnId].toString();
    projId = map[columnPjId].toString();
    projName = map[columnPjName];
    actId = map[columnAcId].toString();
    jobTypeId = map[columnJtId].toString();
    sta = map[columnSta];
    staTo = map[columnStaTo];
    lat = map[columnLat];
    lon = map[columnLon];
    imgPath = map[columnImgPath];
    jobDetail = map[columnJdet];
    caption = map[columnCapt];
    snaptime = map[columnSnapt].toString();
    dmgCateDrrId = map[columnDmgCateDrrId].toString();
    dmgCateDrrName = map[columnDmgCateDrrName];
    dmgCateDrrLevel = map[columnDmgCateDrrLevel];
    dmgCateDrrOtherName = map[columnDmgCateDrrOtherName];
    rdCode = map[columnRdCode];
    dmgDetId = map[columnDmgDetId].toString();
    topic = map[columnTopic].toString();
    info1 = map[columnInfo1].toString();
    info2 = map[columnInfo2].toString();
    // more
  }

  void insert(Map<String, dynamic> row) async {
    final id = await dbHelper.insert(table, row);
    print('inserted tracking row id: $id');
  }

  Future<List<TrackingModel>> querySql() async {
    Database db = await dbHelper.database;
    final allRows =
        await db.rawQuery('SELECT * FROM $table ORDER BY $columnId ASC');

    List<TrackingModel> list = List();
    allRows.forEach((row) => list.add(TrackingModel.fromMap(row)));

    return list;
  }

  Future<int> delete(String id) async {
    Database db = await dbHelper.database;
    return await db.delete(table, where: '$columnId = ?', whereArgs: [id]);
  }
}
