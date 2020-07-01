import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:mtracking/models/dmg_cate_model.dart';
import 'package:mtracking/models/tracking_model.dart';
import 'package:mtracking/screens/my_service.dart';
import 'package:mtracking/utility/my_style.dart';
import 'package:mtracking/utility/normal_dialog.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SurveyRdDmgDrr extends StatefulWidget {
  final String projName;
  final String projId;
  final String jobTypeId;

  @override
  _SurveyRdDmgDrrState createState() => _SurveyRdDmgDrrState();

  SurveyRdDmgDrr(this.projId, this.projName, this.jobTypeId);
}

class _SurveyRdDmgDrrState extends State<SurveyRdDmgDrr> {

  final dataKey = new GlobalKey();
  File file;
  String kmFrom, kmTo, imgCaption;
  String accesskey;
  String dmgLevelSelected = 'ไม่ระบุ';
  double lat, lng;
  var txtCtrlLat = new TextEditingController();
  var txtCtrlLng = new TextEditingController();
  ProgressDialog pr, rf;
  LatLng latLng;

  bool offMode;

  List<DmgCategoryModel> listDmgCateModel = List();
  DmgCategoryModel dmgSelected;

  ScrollController _controller;
  FocusNode _focusKmFrom = FocusNode();
  FocusNode _focusKmTo = FocusNode();
  FocusNode _focusCaption = FocusNode();

  @override
  void initState() {
    super.initState();
    getKey();
    findLatLng();
  }

  Future<void> findLatLng() async {
    LocationData locationData = await findLocationData();
    setState(() {
      lat = locationData.latitude;
      lng = locationData.longitude;
      txtCtrlLat.text = lat.toString();
      txtCtrlLng.text = lng.toString();
    });
  }

  Future<void> getKey() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    accesskey = prefs.getString('accesskey');
    offMode = prefs.containsKey("is_offline");
    prefs.remove("is_offline");

    if (offMode) {
        DmgCategoryModel().getDmgDrr().then((dlist) {
          setState(() {
            listDmgCateModel = dlist;
            dmgSelected = listDmgCateModel[0];
          });
        });
    }else{
      loadDmgCate();
    }
  }

  Future<void> loadDmgCate() async {
    if (listDmgCateModel.length > 0) {
      listDmgCateModel.clear();
    }

    String urlDmgList =
        "https://110.77.142.211/MTrackingServerVM10/rd_dmg_cate_drr.jsp?accesskey=${accesskey}";

    Dio dio = new Dio();
      (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate = (client){
        client.badCertificateCallback = (X509Certificate cert, String host, int port){
          return true;
        };
      };
    Response response = await dio.get(urlDmgList);

    if (response != null) {
      String result = response.data;

      var resJs = json.decode(result);
      // print('Result = $resJs');

      Map<String, dynamic> dmgList = resJs['RD_DAMAGE'];

      dmgList.forEach((k, v) {
        // print('$k: $v');

        DmgCategoryModel dmgCateModel = DmgCategoryModel.fromJlist(k, v);

        setState(() {
          listDmgCateModel.add(dmgCateModel);
        });
      });
      dmgSelected = listDmgCateModel[0];
      //print('End');
    }
  }

  Future<LocationData> findLocationData() async {
    var location = Location();
    try {
      return await location.getLocation();
    } catch (e) {}
  }

  Set<Marker> myMarker() {
    return <Marker>[
      Marker(
        position: latLng,
        markerId: MarkerId('myPosition'),
      ),
    ].toSet();
  }

  Widget currentProjSelected() {
    return Container(
      width: 300.0,
      child: Text(
        'โครงการ : ${widget.projName}',
        style: MyStyle().projNameTitle,
      ),
    );
  }

  Widget dmgCategoryList() {
    return Container(
        width: 300.0,
        child: DropdownButton(
            items: listDmgCateModel.map<DropdownMenuItem<DmgCategoryModel>>(
                (DmgCategoryModel dmg) {
              return DropdownMenuItem<DmgCategoryModel>(
                value: dmg,
                child: Text(dmg.dmgCateName),
              );
            }).toList(),
            value: dmgSelected,
            onChanged: (DmgCategoryModel newVal) {
              setState(() {
                dmgSelected = newVal;
              });
            }));
  }

  Widget dmgLevelList() {
    return Container(
        width: 300.0,
        child: DropdownButton(
            items: <String>['ไม่ระบุ', 'เสียหายเบา', 'เสียหายหนัก']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            value: dmgLevelSelected,
            onChanged: (String newVal) {
              setState(() {
                dmgLevelSelected = newVal;
              });
            }));
  }

  Widget fromKmForm() {
    return Container(
      width: 100.0,
      child: TextField(
        focusNode: _focusKmFrom,
        onChanged: (String string) {
          kmFrom = string.trim();
        },
        decoration: InputDecoration(
            hintText: 'กม.ที่', filled: true, fillColor: Colors.grey.shade200),
      ),
    );
  }

  Widget toKmForm() {
    return Container(
      width: 100.0,
      child: TextField(
        focusNode: _focusKmTo,
        onChanged: (String string) {
          kmTo = string.trim();
        },
        decoration: InputDecoration(
            hintText: 'กม.ที่', filled: true, fillColor: Colors.grey.shade200),
      ),
    );
  }

  Widget showPhoto() {
    return Container(
      key: dataKey,
      width: MediaQuery.of(context).size.width * 0.9,
      height: MediaQuery.of(context).size.height * 0.5,
      child:
          file == null ? Image.asset('images/none_img.png') : Image.file(file),
    );
  }

  void clearFocus() {
    _focusKmFrom.unfocus();
    _focusKmTo.unfocus();
    _focusCaption.unfocus();
  }

  Widget cameraButton() {
    return IconButton(
        icon: Icon(
          Icons.add_a_photo,
          size: 50.0,
        ),
        onPressed: () {
          clearFocus();
          getPhoto(ImageSource.camera);
        });
  }

  Widget galleryButton() {
    return IconButton(
      icon: Icon(
        Icons.add_photo_alternate,
        size: 50.0,
      ),
      onPressed: () {
        clearFocus();
        getPhoto(ImageSource.gallery);
      },
    );
  }

  Future<void> getPhoto(ImageSource imageSource) async {
    try {
      var obj = await ImagePicker.pickImage(
        source: imageSource,
        maxWidth: 800.0,
        maxHeight: 800.0,
      );

      setState(() {
        //force build methord work
        file = obj;
        //print(file.path);
      });
    } catch (e) {}
  }

  Widget showButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[cameraButton(), galleryButton()],
    );
  }

  Widget descriptionForm() {
    return Container(
      width: 300.0,
      child: TextField(
        focusNode: _focusCaption,
        onChanged: (String string) {
          imgCaption = string.trim();
        },
        decoration: InputDecoration(hintText: 'คำบรรยายภาพ : '),
      ),
    );
  }

  Widget showDetailMap() {
    latLng = LatLng(lat, lng);
    CameraPosition cameraPosition = CameraPosition(
      target: latLng,
      zoom: 16,
    );

    return GoogleMap(
      markers: myMarker(),
      mapType: MapType.normal,
      initialCameraPosition: cameraPosition,
      myLocationButtonEnabled: true,
      myLocationEnabled: true,
      gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>[
        new Factory<OneSequenceGestureRecognizer>(
          () => new EagerGestureRecognizer(),
        ),
      ].toSet(),
      onMapCreated: (GoogleMapController googleMapController) {},
    );
  }

  Widget showMap() {
    return Container(
      padding: EdgeInsets.only(left: 20.0, right: 20.0, top: 10.0),
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.5,
      child: lat == null
          ? Center(
              child: CircularProgressIndicator(),
            )
          : showDetailMap(),
    );
  }

  Widget latForm() {
    return Container(
      width: 300.0,
      child: TextField(
        onChanged: (String latStr) {
          txtCtrlLat.text = latStr.trim();
          lat = double.parse(latStr.trim());
        },
        decoration: InputDecoration(hintText: 'latitude : '),
        controller: txtCtrlLat,
      ),
    );
  }

  Widget lngForm() {
    return Container(
      width: 300.0,
      child: TextField(
        onChanged: (String lngStr) {
          txtCtrlLng.text = lngStr.trim();
          lng = double.parse(lngStr.trim());
        },
        decoration: InputDecoration(hintText: 'longitude : '),
        controller: txtCtrlLng,
      ),
    );
  }

  Widget getLocationButton() {
    return ButtonTheme(
      height: 20,
      child: RaisedButton(
        color: Colors.blue.shade900,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(10.0))),
        child: Text(
         'Get Current Location',
         style: TextStyle(
           color: Colors.white,
          ),
        ),
        onPressed: () {
          clearFocus();
          rf.show();

          Future.delayed(Duration(seconds: 1)).then((value) {
            findLatLng();
            myMarker();

            if (rf.isShowing()) {
              rf.hide();
            }
          });
        },
      ),
    );
  }

  Widget uploadButton() {
    return RaisedButton(
      color: MyStyle().txtColor,
      child: Text(
        'Upload',
        style: TextStyle(
          color: Colors.white,
        ),
      ),
      onPressed: () {
        if (file == null) {
          normalDialog(context, 'No Image', 'Please add your image');
        } else {
          pr.show();

          Future.delayed(Duration(seconds: 3)).then((value) {
            insertDataToServer();

            if (pr.isShowing()) {
              pr.hide();
            }
          });
        }
      },
    );
  }

  Future<void> insertDataToServer() async {
    String url = 'https://110.77.142.211/MTrackingServerVM10/m_upload/saveimg';

    var now = new DateTime.now();
    var formatter = new DateFormat('yyyy-MM-dd_Hms');
    String snaptime = now.millisecondsSinceEpoch.toString();
    String formatted = formatter.format(now);
    String fileName = 'image_$formatted.jpg';
    print('snaptime = $snaptime');
    print('formatted = $formatted');

    try {
      Map<String, dynamic> map = Map();
      map['uploaded'] = UploadFileInfo(file, fileName);
      map['userkey'] = accesskey;
      map['pid'] = widget.projId;
      map['jobid'] = widget.jobTypeId;
      map['sta'] = kmFrom;
      map['caption'] = imgCaption; //image caption
      map['lat'] = lat.toString();
      map['long'] = lng.toString();
      map['snaptime'] = '$snaptime';

      map['sta_to'] = kmTo;
      map['dmgcatdrrid'] = dmgSelected.dmgCateId;
      map['dmgcatdrr_name'] = dmgSelected.dmgCateName;
      map['dmgcatdrr_level'] = dmgLevelSelected;
      map['dmgcatdrr_othername'] = '';

      // print("userkey : " + map['userkey']);
      // print("pid : " + map['pid']);
      // print("jobid : " + map['jobid']);
      // print("dmgcatdrrid : " + map['dmgcatdrrid']);
      // print("dmgcatdrr_name : " + map['dmgcatdrr_name']);
      // print("dmgcatdrr_level : " + map['dmgcatdrr_level']);
      // print("sta : " + map['sta']);
      // print("sta_to : " + map['sta_to']);
      // print("caption : " + map['caption']);
      // print("lat : " + map['lat']);
      // print("long : " + map['long']);
      // print("snaptime : " + map['snaptime']);

      FormData formData = FormData.from(map);

      Dio dio = new Dio();
      (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate = (client){
        client.badCertificateCallback = (X509Certificate cert, String host, int port){
          return true;
        };
      };
      await dio.post(url, data: formData).then((response) {
        print('response : $response');
        completeDialog('อัพโหลดข้อมูลแล้ว', 'ต้องการเพิ่มรูปถ่ายอีกหรือไม่?');
      });
    } catch (e) {}
  }

  Widget saveButton() {
    return RaisedButton(
      color: MyStyle().txtColor,
      child: Text(
        'Save',
        style: TextStyle(
          color: Colors.white,
        ),
      ),
      onPressed: () {
        insertDataToDB();

        TrackingModel().querySql().then((list) {
          list.forEach((o) => print(
              o.tid + '==>> ' + o.lat + ' + ' + o.lon + ' + ' + o.imgPath));
        });
      },
    );
  }

  Future<void> insertDataToDB() async {
    var now = new DateTime.now();
    String snaptime = now.millisecondsSinceEpoch.toString();

    try {
      Map<String, dynamic> map = Map();

      map[TrackingModel.columnImgPath] = file.path;

      map[TrackingModel.columnPjId] = widget.projId;
      map[TrackingModel.columnPjName] = widget.projName;
      map[TrackingModel.columnJtId] = widget.jobTypeId;
      map[TrackingModel.columnSta] = kmFrom;
      map[TrackingModel.columnStaTo] = kmTo;
      map[TrackingModel.columnCapt] = imgCaption; //image caption
      map[TrackingModel.columnLat] = lat.toString();
      map[TrackingModel.columnLon] = lng.toString();
      map[TrackingModel.columnSnapt] = '$snaptime';
      map[TrackingModel.columnDmgCateDrrId] = dmgSelected.dmgCateId.toString();
      map[TrackingModel.columnDmgCateDrrName] = dmgSelected.dmgCateName;
      map[TrackingModel.columnDmgCateDrrLevel] = dmgLevelSelected;
      map[TrackingModel.columnDmgCateDrrOtherName] = '';

      TrackingModel().insert(map);

      completeDialog('บันทึกข้อมูลแล้ว', 'ต้องการเพิ่มรูปถ่ายอีกหรือไม่?');
    } catch (e) {}
  }

  Future<void> completeDialog(String title, String message) async {
    showDialog(
      context: context,
      barrierDismissible: false, // user must tap button for close dialog!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            FlatButton(
              child: Text('ใช่'),
              onPressed: () {
                setState(() {
                  file = null;
                });

                Scrollable.ensureVisible(dataKey.currentContext);

                Navigator.of(context).pop();
              },
            ),
            FlatButton(
              child: Text('ออก'),
              onPressed: () {
                MaterialPageRoute materialPageRoute = MaterialPageRoute(
                    builder: (BuildContext context) => MyService());
                Navigator.of(context).pushAndRemoveUntil(materialPageRoute,
                    (Route<dynamic> route) {
                  return false;
                });
              },
            )
          ],
        );
      },
    );
  }

  Widget showActionButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: <Widget>[uploadButton(), saveButton()],
    );
  }

  Widget myContent() {
    return SingleChildScrollView(
      controller: _controller,
      child: Column(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          SizedBox(
            height: 30.0,
          ),
          currentProjSelected(),
          SizedBox(
            height: 20.0,
          ),
          Container(
            width: 300,
            child: Text(
              'ประเภทความเสียหาย : ',
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
          ),
          dmgCategoryList(),
          SizedBox(
            height: 20.0,
          ),
          Container(
            width: 300,
            child: Text(
              'ลักษณะความเสียหาย : ',
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
          ),
          dmgLevelList(),
          SizedBox(
            height: 20.0,
          ),
          Container(
            width: 300,
            child: Row(
              children: <Widget>[
                fromKmForm(),
                SizedBox(
                  width: 10.0,
                ),
                Text('ถึง', style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold)),
                SizedBox(
                  width: 10.0,
                ),
                toKmForm()
              ],
            ),
          ),
          showPhoto(),
          showButton(),
          SizedBox(
            height: 20.0,
          ),
          descriptionForm(),
          SizedBox(
            height: 50.0,
          ),
          showMap(),
          getLocationButton(),
          latForm(),
          lngForm(),
          SizedBox(
            height: 50.0,
          ),
          showActionButton(),
          SizedBox(
            height: 50.0,
          ),
        ],
      ),
    );
  }

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

    rf = ProgressDialog(context, type: ProgressDialogType.Normal);
    rf.style(
      message: 'Refreshing data...',
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
          title: Text(
            'ตรวจสอบสภาพถนน ทช.',
            style: TextStyle(fontSize: 16.0),
          ),
        ),
        body: Container(
          child: Center(
            child: myContent(),
          ),
        ));
  }
}
