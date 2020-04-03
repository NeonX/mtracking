
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mtracking/models/image_model.dart';

class PinInfo {
  String projId, projName, desc;
  String lat, lon;
  List<ImageModel> listUrlImg;

  static final columnId = 'proj_id';
  static final columnName = 'proj_name';
  static final columnLat = 'lat';
  static final columnLon = 'lon';
  static final columnImgs = 'imgs';

  PinInfo({this.projId, this.projName, this.desc, this.lat, this.lon, this.listUrlImg});

  PinInfo.fromJson(Map<String, dynamic> json) {

    projId = json[columnId].toString();
    projName = json[columnName];
    lat = json[columnLat];
    lon = json[columnLon];

    Iterable l = json[columnImgs];
    listUrlImg = l.map((o)=> ImageModel.fromJson(o)).toList();

  }

  LatLng getLatLon(){
    double dlat = double.parse(lat);
    double dlon = double.parse(lon);

    return LatLng(dlat, dlon);

  }

}