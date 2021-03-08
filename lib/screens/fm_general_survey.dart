
import 'dart:io';

import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_save/image_save.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:mtracking/models/tracking_model.dart';
import 'package:mtracking/utility/my_style.dart';
import 'package:mtracking/utility/normal_dialog.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'my_service.dart';

class GeneralSurvey extends StatefulWidget {

  final String projName;
  final String projId;
  final String jobTypeId;

  @override
  _GeneralSurveyState createState() => _GeneralSurveyState();

  GeneralSurvey(this.projId, this.projName, this.jobTypeId);
}

class _GeneralSurveyState extends State<GeneralSurvey> {
 
  bool offMode = false;
  final dataKey = new GlobalKey();
  String accesskey;
  String topic, info1, info2, imgCaption;
  ScrollController _controller;
  FocusNode _focusTopic = FocusNode();
  FocusNode _focusInfo1 = FocusNode();
  FocusNode _focusInfo2 = FocusNode();
  FocusNode _focusCaption = FocusNode();
  double lat, lng;
  LatLng latLng;
  ProgressDialog pr, rf;
  File file;

  var txtCtrlLat = new TextEditingController();
  var txtCtrlLng = new TextEditingController();

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

  Future<LocationData> findLocationData() async {
    var location = Location();
    try {
      return await location.getLocation();
    } catch (e) {}
  }

  Future<void> getKey() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    accesskey = prefs.getString('accesskey');
    offMode = prefs.containsKey("is_offline");
    prefs.remove("is_offline");

    if (offMode) {
      
    } else {

    }
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

  Widget topicForm() {
    return Container(
      width: 300.0,
      child: TextField(
        focusNode: _focusTopic,
        onChanged: (String string) {
          topic = string.trim();
        },
        decoration: InputDecoration(hintText: 'ชื่อ/หัวข้อ/โครงการย่อย : '),
      ),
    );
  }

  Widget info1Form() {
    return Container(
      width: 300.0,
      child: TextField(
        focusNode: _focusInfo1,
        onChanged: (String string) {
          info1 = string.trim();
        },
        decoration: InputDecoration(hintText: 'Info 1 : '),
      ),
    );
  }

  Widget info2Form() {
    return Container(
      width: 300.0,
      child: TextField(
        focusNode: _focusInfo2,
        onChanged: (String string) {
          info2 = string.trim();
        },
        decoration: InputDecoration(hintText: 'Info 2 : '),
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

  Set<Marker> myMarker() {
    return <Marker>[
      Marker(
        position: latLng,
        markerId: MarkerId('myPosition'),
      ),
    ].toSet();
  }

  Widget getLocationButton() {
    return ButtonTheme(
      height: 20,
      child: RaisedButton(
        color: Colors.blue.shade900,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0))),
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

  Widget showActionButton() {
    return offMode
        ? Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[saveButton()],
          )
        : Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[uploadButton(), saveButton()],
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
      map['uploaded'] = await MultipartFile.fromFile(file.path, filename:fileName);
      map['userkey'] = accesskey;
      map['pid'] = widget.projId;
      map['jobid'] = widget.jobTypeId;
      map['topic'] = topic;
      map['info1'] = info1;
      map['info2'] = info2;
      map['caption'] = imgCaption; //image caption
      map['lat'] = lat.toString();
      map['long'] = lng.toString();
      map['snaptime'] = '$snaptime';

      FormData formData = FormData.fromMap(map);

      Dio dio = new Dio();
      (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
          (client) {
        client.badCertificateCallback =
            (X509Certificate cert, String host, int port) {
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

  Future<void> insertDataToDB() async {
    var now = new DateTime.now();
    String snaptime = now.millisecondsSinceEpoch.toString();

    try {
      await ImageSave.saveImage(file.readAsBytesSync(), "jpg", albumName: "mtracking");
      Map<String, dynamic> map = Map();

      map[TrackingModel.columnImgPath] = file.path;

      map[TrackingModel.columnPjId] = widget.projId;
      map[TrackingModel.columnPjName] = widget.projName;
      map[TrackingModel.columnJtId] = widget.jobTypeId;
      map[TrackingModel.columnCapt] = imgCaption; //image caption
      map[TrackingModel.columnLat] = lat.toString();
      map[TrackingModel.columnLon] = lng.toString();
      map[TrackingModel.columnSnapt] = '$snaptime';
      map[TrackingModel.columnTopic] = topic;
      map[TrackingModel.columnInfo1] = info1;
      map[TrackingModel.columnInfo2] = info2;

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

  void clearFocus() {
    _focusTopic.unfocus();
    _focusInfo1.unfocus();
    _focusInfo2.unfocus();
    _focusCaption.unfocus();
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
          topicForm(),
          SizedBox(
            height: 20.0,
          ),
          info1Form(),
          SizedBox(
            height: 20.0,
          ),
          info2Form(),
          SizedBox(
            height: 20.0,
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
            'งานสำรวจทั่วไป',
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