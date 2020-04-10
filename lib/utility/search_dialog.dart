import 'package:flutter/material.dart';
import 'package:mtracking/models/amphur.dart';
import 'package:mtracking/models/province.dart';


class SearchDialog extends StatefulWidget {

  final Function(Province, Amphur) notifyParent;
  SearchDialog({Key key, @required this.notifyParent}) : super(key: key);

  @override
  _SearchDialogState createState() => _SearchDialogState();


}

class _SearchDialogState extends State<SearchDialog> {
  Province provSelected;
  Amphur ampSelected;
  List<DropdownMenuItem<Province>> ddProvince = List();
  List<DropdownMenuItem<Amphur>> ddAmphur = List();

  @override
  void initState() {
    super.initState();
    getListProvince();
  }

  Future<void> getListProvince() async {
    Province().querySql().then((listProv) {
      //listProv.forEach((o) => print('==>> ' + o.pId + ' x ' + o.pName));

      listProv.forEach((prov) {
        setState(() {
          ddProvince.add(DropdownMenuItem<Province>(
            value: prov,
            child: Text(prov.pName),
          ));
        });
      });
    });
  }

  Future<void> getListAmphur() async {

    Amphur().queryByPid(provSelected.pId).then((listAmp){
      ddAmphur.clear();
      listAmp.forEach((amp) {
        setState(() { 
          ddAmphur.add(DropdownMenuItem<Amphur>(
            value: amp,
            child: Text(amp.aName),
          ));
        });
      });
    });
  }

  Widget drownDownProvince() {
    return DropdownButton(
      value: provSelected,
      items: ddProvince,
      hint: Text('เลือกจังหวัด'),
      onChanged: ((Province province) {
        setState(() {
          provSelected = province;
          ampSelected = null;
          getListAmphur();
        });
      }),
    );
  }

  Widget drownDownAmphur() {
    return DropdownButton(
      value: ampSelected,
      items: ddAmphur,
      hint: Text('เลือกอำเภอ'),
      onChanged: ((Amphur amph) {
        setState(() {
          ampSelected = amph;
          //print(provSelected.pName);
        });
      }),
    );
  }

  @override
  Widget build(BuildContext context) {

    return SimpleDialog(
      title: Text('Search...'),
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left:5.0),
          child: drownDownProvince(),
        ),
        Padding(
          padding: const EdgeInsets.only(left:5.0),
          child: drownDownAmphur(),
        ),
        SimpleDialogOption(
          onPressed: () {
            List<dynamic> list = List();
            list.add(provSelected);
            list.add(ampSelected);

            if(provSelected != null || ampSelected != null){
              widget.notifyParent(provSelected, ampSelected);
            }


            Navigator.pop(context, list);
          },
          child: const Text('Search'),
        ),
      ],
    );
  }
}
