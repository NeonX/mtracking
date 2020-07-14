import 'dart:async';
import 'dart:convert';
import 'package:dio/adapter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:mtracking/models/activity_model.dart';
import 'package:mtracking/models/tracking_model.dart';
import 'package:mtracking/screens/my_service.dart';
import 'package:mtracking/utility/app_util.dart';
import 'package:mtracking/utility/my_style.dart';
import 'package:mtracking/utility/normal_dialog.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class UploadForm extends StatefulWidget {
  final String projName;
  final String projId;
  final String jobTypeId;

  @override
  _UploadFormState createState() => _UploadFormState();

  // UploadForm({Key key, this.projName}) : super (key : key);
  UploadForm(this.projId, this.projName, this.jobTypeId);
}

class _UploadFormState extends State<UploadForm> {
  // Field
  final dataKey = new GlobalKey();

  ActivityModel activityModel;
  ActivityModel actSelected;
  String accesskey;
  File file;
  String km, jobDetail, imgCaption;
  LatLng latLng;
  double lat, lng;
  var txtCtrlLat = new TextEditingController();
  var txtCtrlLng = new TextEditingController();

  bool offMode = false;

  ScrollController _controller;
  FocusNode _focusKm = FocusNode();
  FocusNode _focusJobDetail = FocusNode();
  FocusNode _focusCaption = FocusNode();
  FocusNode _focusLat = FocusNode();
  FocusNode _focusLon = FocusNode();

  List<ActivityModel> listActModel = List();
  List<String> actItems = List();
  ProgressDialog pr;
  ProgressDialog rf;

  // Method
  @override
  void initState() {
    _controller = ScrollController();
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

    // Duration duration = Duration(seconds: 10);
    // await Timer(duration, () {
    //   setState(() {
    //     lat = 13.685514;
    //     lng = 100.567656;
    //   });
    // });
  }

  Future<void> getKey() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    offMode = prefs.containsKey("is_offline");
    prefs.remove("is_offline");

    if (offMode) {
      ActivityModel().getAcyByProjId(widget.projId).then((list) {
        setState(() {
          listActModel = list;
          actSelected = listActModel[0];
        });

        print('${list.length} ---- ${listActModel.length}');
      });
    } else {
      accesskey = prefs.getString('accesskey');
      readActivity();
    }
  }

  Future<void> readActivity() async {
    if (listActModel.length > 0) {
      listActModel.clear();
    }

    String urlActList =
        "https://110.77.142.211/MTrackingServerVM10/actlist.jsp?pid=${widget.projId}&accesskey=${accesskey}";

    Dio dio = new Dio();
    (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate =
        (client) {
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) {
        return true;
      };
    };
    Response response = await dio.get(urlActList);

    if (response != null) {
      String result = response.data;

      var resJs = json.decode(result);
      // print('Result = $resJs');

      Map<String, dynamic> act_ls = resJs['ACTIVITY'];

      act_ls.forEach((k, v) {
        // print('$k: $v');

        ActivityModel activityModel = ActivityModel.fromJlist(k, v);

        // print(activityModel.actId + ' ==>> ' + activityModel.actName);
        setState(() {
          listActModel.add(activityModel);
        });
      });
      actSelected = listActModel[0];
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

  Widget activityList() {
    return Container(
        width: 300.0,
        child: DropdownButton(
            items: listActModel
                .map<DropdownMenuItem<ActivityModel>>((ActivityModel act) {
              return DropdownMenuItem<ActivityModel>(
                value: act,
                child: Text(act.actName),
              );
            }).toList(),
            value: actSelected,
            onChanged: (ActivityModel newVal) {
              setState(() {
                actSelected = newVal;
              });
            }));
  }

  Widget kmInputForm() {
    return Container(
      width: 300.0,
      child: TextField(
        focusNode: _focusKm,
        onChanged: (String string) {
          km = string.trim();
        },
        decoration: InputDecoration(hintText: 'ตำแหน่ง กม. : '),
      ),
    );
  }

  Widget jobDetailForm() {
    return Container(
      width: 300.0,
      child: TextField(
        focusNode: _focusJobDetail,
        onChanged: (String string) {
          jobDetail = string.trim();
        },
        decoration: InputDecoration(hintText: 'รายละเอียดงาน : '),
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
    _focusKm.unfocus();
    _focusJobDetail.unfocus();
    _focusCaption.unfocus();
    _focusLat.unfocus();
    _focusLon.unfocus();
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
        focusNode: _focusLat,
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
        focusNode: _focusLon,
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

  Widget uploadButton() {
    return RaisedButton(
      color: MyStyle().txtColor,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0))),
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
      
      map['uploaded'] = await MultipartFile.fromFile(file.path, filename:fileName);
      map['userkey'] = accesskey;
      map['pid'] = widget.projId;
      map['actid'] = actSelected.actId;
      map['jobid'] = widget.jobTypeId;
      map['sta'] = km;
      map['detail'] = jobDetail; //job detail
      map['caption'] = imgCaption; //image caption
      map['lat'] = lat.toString();
      map['long'] = lng.toString();
      map['snaptime'] = '$snaptime';

      /*
      print("userkey : " + map['userkey']);
      print("pid : " + map['pid']);
      print("actid : " + map['actid']);
      print("jobid : " + map['jobid']);
      print("sta : " + map['sta']);
      print("detail : " + map['detail']);
      print("caption : " + map['caption']);
      print("lat : " + map['lat']);
      print("long : " + map['long']);
      print("snaptime : " + map['snaptime']);
      */

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
        // print('response : $response');
        completeDialog('อัพโหลดข้อมูลแล้ว', 'ต้องการเพิ่มรูปถ่ายอีกหรือไม่?');
      });
    } catch (e) {}
  }

  Widget saveButton() {
    return RaisedButton(
      color: MyStyle().txtColor,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10.0))),
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
      map[TrackingModel.columnAcId] = actSelected.actId;
      map[TrackingModel.columnJtId] = widget.jobTypeId;
      map[TrackingModel.columnSta] = km;
      map[TrackingModel.columnJdet] = jobDetail; //job detail
      map[TrackingModel.columnCapt] = imgCaption; //image caption
      map[TrackingModel.columnLat] = lat.toString();
      map[TrackingModel.columnLon] = lng.toString();
      map[TrackingModel.columnSnapt] = '$snaptime';

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
                if(offMode){
                  setPref("is_offline", "true");
                }
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
          activityList(),
          kmInputForm(),
          jobDetailForm(),
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
            height: 30.0,
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
            'รายงานความก้าวหน้าโครงการก่อสร้าง',
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
