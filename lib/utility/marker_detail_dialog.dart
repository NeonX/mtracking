import 'package:flutter/material.dart';
import 'package:mtracking/models/image_model.dart';
import 'package:mtracking/models/pin_info_model.dart';
import 'package:mtracking/utility/my_style.dart';

class MarkerDetail extends StatefulWidget {
  final PinInfo data;
  MarkerDetail({this.data});

  @override
  _MarkerDetailState createState() => _MarkerDetailState();
}

class _MarkerDetailState extends State<MarkerDetail> {
  PinInfo pinfo;

  @override
  void initState() {
    super.initState();

    pinfo = widget.data;

    print('ProjId : ${pinfo.projId}');
    print('Lat : ${pinfo.lat}');
    print('Lon : ${pinfo.lon}');
    print('Imgs : ${pinfo.listUrlImg.length}');
  }

  Widget showImage(int index) {
    String imgPath = pinfo.listUrlImg[index].imgUrl;
    return Container(
        padding:
            EdgeInsets.only(top: 10.0, right: 5.0, bottom: 10.0, left: 5.0),
        width: MediaQuery.of(context).size.width * 0.7,
        height: MediaQuery.of(context).size.width * 0.7,
        child: Image.network(
          imgPath,
          fit: BoxFit.cover,
        ));
  }

  Widget showImgDesc(ImageModel imgx) {
    return Container(
      padding: EdgeInsets.only(left: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          showImageX(imgx),
          Text('Description : ${imgx.desc}'),
          Text('Date : ${imgx.idate}'),
        ],
      ),
    );
  }

  Widget showImageX(ImageModel imgx) {
    return Container(
        padding:
            EdgeInsets.only(top: 10.0, right: 10.0, bottom: 10.0),
        width: MediaQuery.of(context).size.width * 0.7,
        height: MediaQuery.of(context).size.width * 0.7,
        child: Image.network(
          imgx.imgUrl,
          fit: BoxFit.cover,
        ));
  }

  Widget showListView() {
    return Container(
      height: MediaQuery.of(context).size.width * 0.7,
      width: MediaQuery.of(context).size.width * 0.8,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemBuilder: (BuildContext buildContext, int index) {
          return GestureDetector(
              child: Row(
                children: <Widget>[
                  showImage(index),
                ],
              ),
              onTap: () {
                print('URL : ${pinfo.listUrlImg[index]}');
              });
        },
        itemCount: pinfo.listUrlImg.length,
      ),
    );
  }

  List<Widget> genImgContList() {
    List<Widget> listV = List();

    List<ImageModel> limg = pinfo.listUrlImg;

    limg.forEach((img) {
      listV.add(showImgDesc(img));
    });

    return listV;
  }

  Widget showTabView() {
    return Container(
      height: MediaQuery.of(context).size.width * 0.9,
      width: MediaQuery.of(context).size.width * 0.8,
      child: DefaultTabController(
        length: pinfo.listUrlImg.length,
        child: Builder(
            builder: (BuildContext context) => Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: <Widget>[
                      TabPageSelector(),
                      Expanded(
                        child: IconTheme(
                          data: IconThemeData(
                            size: 128.0,
                            color: Theme.of(context).accentColor,
                          ),
                          child: TabBarView(children: genImgContList()),
                        ),
                      ),
                    ],
                  ),
                )),
      ),
    );
  }

  

  Widget showLatLon() {
    return Container(
      padding: EdgeInsets.only(left: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text('Latitude : ${pinfo.lat}'),
          Text('Longitude : ${pinfo.lon}'),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SimpleDialog(
      title: Text(pinfo.projName,
          style: TextStyle(
            color: MyStyle().txtColor,
          )),
      children: <Widget>[
        showLatLon(),
        showTabView(),
        //showListView(),
      ],
    );
  }
}
