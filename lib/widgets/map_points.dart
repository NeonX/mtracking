import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:mtracking/models/pin_info_model.dart';
import 'package:mtracking/utility/marker_detail_dialog.dart';
import 'package:mtracking/utility/project_sel_dialog.dart';

class MapPoints extends StatefulWidget {
  @override
  _MapPointsState createState() => _MapPointsState();
}

class _MapPointsState extends State<MapPoints> {
  // Field
  double lat, lon;
  LatLng latLng;
  List<LatLng> list = List();
  List<PinInfo> listPin = List();
  String projId;

  GoogleMapController mapController;

  // Method
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        builder: (context) {
          return ProjectSelDialog(selProject: refresh);
        },
      );
    }); //*/

    findLocationData();
    //readData();
  }

  Future<void> refresh(String prjid) async {
    projId = prjid;
    readData();
  }

  Future<void> readData() async {
    if (listPin.length > 0) {
      listPin.clear();
    }

    String urlPinList =
        'https://110.77.142.211/MTrackingServerVM10/proj_img_list.jsp?pid=$projId'; //"http://winti.pte.co.th/sample_map.json";

    Dio dio = new Dio();
      (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate = (client){
        client.badCertificateCallback = (X509Certificate cert, String host, int port){
          return true;
        };
      };
    Response response = await dio.get(urlPinList);

    if (response != null) {
      var resJs = json.decode(response.data);

      //print('Result = $resJs');

      if (resJs['SUCCESS'] == true) {
        int cnt = 0;
        for (var map in resJs['marker']) {
          PinInfo pin = PinInfo.fromJson(map);
          setState(() {
            listPin.add(pin);
            list.add(pin.getLatLon());

            if (lat == null) {
              lat = double.parse(pin.lat);
              lon = double.parse(pin.lon);
            }

            updateBound();
          });
          cnt++;
        }

        if(cnt == 0){
          setState(() {
            listPin.clear();
            list.clear();
            
          });

          findLocationData();
        }

      }else{
        setState(() {
            listPin.clear();
            list.clear();

          });

          findLocationData();
      }

      //print('End ${listPin.length}' );
    }
  }

  Future<LocationData> findLocationData() async {
    var location = Location();

    try {
      LocationData locationData = await location.getLocation();

      setState(() {
        lat = locationData.latitude;
        lon = locationData.longitude;
      });

      boundsFromLatLngList();
      return locationData;
    } catch (e) {}

    return null;
  }

  Set<Marker> myMarker() {
    Set<Marker> sm = Set();
    int i = 0;
    listPin.forEach((pin) {
      sm.add(Marker(
        position: pin.getLatLon(),
        markerId: MarkerId('$i'),
        onTap: () {
          showDialog(
            context: context,
            builder: (context) {
              return MarkerDetail(data: pin);
            },
          );
        },
      ));
      i++;
    });

    return sm;
/*
    return <Marker>[
      Marker(position: latLng, markerId: MarkerId('home')),
      Marker(position: LatLng(13.759208, 100.568766), markerId: MarkerId('test')),

    ].toSet();
    */
  }

  Widget mapPanel() {
    latLng = LatLng(lat, lon);
    CameraPosition cameraPosition = CameraPosition(
      target: latLng,
      zoom: 16,
    );

    return GoogleMap(
      markers: myMarker(),
      mapType: MapType.normal,
      initialCameraPosition: cameraPosition,
      onMapCreated: (GoogleMapController controller) {
        mapController = controller;
        updateBound();
      },
      onTap: (LatLng point) {},
    );
  }

  Future<void> updateBound() async {
    Future.delayed(
        Duration(milliseconds: 200),
        () => mapController.animateCamera(
            CameraUpdate.newLatLngBounds(boundsFromLatLngList(), 1)));
  }

  LatLngBounds boundsFromLatLngList() {
    double x0, x1, y0, y1;
    for (LatLng latLng in list) {
      if (x0 == null) {
        x0 = x1 = latLng.latitude;
        y0 = y1 = latLng.longitude;
      } else {
        if (latLng.latitude > x1) x1 = latLng.latitude;
        if (latLng.latitude < x0) x0 = latLng.latitude;
        if (latLng.longitude > y1) y1 = latLng.longitude;
        if (latLng.longitude < y0) y0 = latLng.longitude;
      }
    }

    double r = 6378137;
    double dLat = (1000) / r;
    double dLon = (-10000) / (r * cos(3.1415 * y1 / 180));

    x1 = x1 + dLat * 180 / 3.1415;
    y1 = y1 + dLon * 180 / 3.1415;

    return LatLngBounds(northeast: LatLng(x1, y1), southwest: LatLng(x0, y0));
  }

  Widget showMap() {
    return Container(
      padding: EdgeInsets.only(left: 2.0, right: 2.0, top: 1.0),
      //padding: EdgeInsets.only(left: 20.0, right: 20.0, top: 20.0),
      //height: MediaQuery.of(context).size.height * 0.3,
      //width: MediaQuery.of(context).size.width,
      child:
          lat == null ? Center(child: CircularProgressIndicator()) : mapPanel(),
    );
  }

  Widget searchButton() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Container(
              margin: EdgeInsets.only(right: 15.0, bottom: 60.0),
              child: FloatingActionButton(
                child: Icon(Icons.search),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return ProjectSelDialog(selProject: refresh);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        showMap(),
        searchButton(),
      ],
    );
  }
}
