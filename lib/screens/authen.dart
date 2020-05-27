import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:mtracking/screens/my_service.dart';
import 'package:mtracking/screens/register.dart';
import 'package:mtracking/utility/my_style.dart';
import 'package:mtracking/utility/normal_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Authen extends StatefulWidget {
  @override
  _AuthenState createState() => _AuthenState();
}

class _AuthenState extends State<Authen> {
  // Field
  String user, password;
  bool chkVal = false;

  // Method

  @override
  void initState() {
    checkRemember();

    super.initState();
  }

  Future<void> checkRemember() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('remember')) {
      bool rem = prefs.getBool('remember');
      if (rem) {
        MaterialPageRoute materialPageRoute =
            MaterialPageRoute(builder: (BuildContext context) => MyService());
        Navigator.of(context).pushAndRemoveUntil(materialPageRoute,
            (Route<dynamic> route) {
          return false;
        });
      } else {
        await prefs.remove('remember');
        await prefs.remove('uname');
        await prefs.remove('accesskey');
      }
    }
  }

  Widget signInButton() {
    return RaisedButton(
      color: MyStyle().txtColor,
      child: Text(
        'Login',
        style: TextStyle(
          color: Colors.white,
        ),
      ),
      onPressed: () {
        if (user == null ||
            user.isEmpty ||
            password == null ||
            password.isEmpty) {
          normalDialog(context, 'Have space', 'Please fill User and Password');
        } else {
          checkAuthen();
        }
      },
    );
  }

  Future<void> checkAuthen() async {
    try {
      String urlAut =
          'https://110.77.142.211/MTrackingServerVM10/m_access/verifykey?uname=$user&password=$password';

      Dio dio = new Dio();
      (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate = (client){
        client.badCertificateCallback = (X509Certificate cert, String host, int port){
          return true;
        };
      };
      await dio.post(urlAut).then((response) {
        // print('Response = $response');

        if (response.toString() == 'null') {
          normalDialog(context, 'Password False', 'Please try again');
        } else {
          Map<String, dynamic> map = json.decode(response.toString());

          bool success = map['SUCCESS'];
          String akey = map['ACCESSKEY'];

          if (success) {
            if (chkVal) {
              remmemberMe('remember', true);
            }

            setPref('uname', user);
            setPref('accesskey', akey);

            MaterialPageRoute materialPageRoute = MaterialPageRoute(
                builder: (BuildContext context) => MyService());

            Navigator.push(context, materialPageRoute);
            /*
            Navigator.of(context).pushAndRemoveUntil(materialPageRoute,
                (Route<dynamic> route) {
              return false;
            });
            */
          } else {
            normalDialog(context, 'Login fail', 'Please try again');
          }
        }
      });
    } catch (e) {}
  }

  Future<void> setPref(String key, String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  Future<void> remmemberMe(String key, bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  Widget signUpButton() {
    return OutlineButton(
      borderSide: BorderSide(color: MyStyle().txtColor),
      child: Text(
        'Sign Up',
        style: TextStyle(color: MyStyle().txtColor),
      ),
      onPressed: () {
        print('You Click Sign Up');
        MaterialPageRoute materialPageRoute =
            MaterialPageRoute(builder: (BuildContext buildContext) {
          return Register();
        });
        Navigator.of(context).push(materialPageRoute);
      },
    );
  }

  Widget showButton() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        signInButton(),
        SizedBox(width: 5.0),
        signUpButton(),
      ],
    );
  }

  Widget userPassword() {
    return Container(
      child: TextField(
        controller: TextEditingController()..text = '',
        onChanged: (String string) {
          password = string.trim();
        },
        obscureText: true,
        decoration: InputDecoration(
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.yellow.shade600)),
            enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: MyStyle().txtColor)),
            prefixIcon: Icon(
              Icons.lock,
              color: MyStyle().txtColor,
            ),
            hintText: 'Password :',
            hintStyle: TextStyle(
              color: MyStyle().txtColor,
            )),
      ),
      width: 250.0,
    );
  }

  Widget userForm() {
    return Container(
      child: TextField(
        controller: TextEditingController()..text = '',
        onChanged: (String string) {
          user = string.trim();
        },
        decoration: InputDecoration(
            focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.yellow.shade600)),
            enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(color: MyStyle().txtColor)),
            prefixIcon: Icon(
              Icons.account_box,
              color: MyStyle().txtColor,
            ),
            hintText: 'Username :',
            hintStyle: TextStyle(
              color: MyStyle().txtColor,
            )),
      ),
      width: 250.0,
    );
  }

  Widget rememberCheck() {
    return Container(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Checkbox(
            value: chkVal,
            onChanged: (bool value) {
              setState(() {
                chkVal = value;
                print('now is : $chkVal');
              });
            },
            activeColor: MyStyle().txtColor,
            focusColor: MyStyle().txtColor,
            hoverColor: MyStyle().txtColor,
          ),
          Text(
            "Remember login",
            style: TextStyle(
              color: MyStyle().txtColor,
            ),
          ),
          // SizedBox(width: 5.0),
          // signUpButton(),
        ],
      ),
      width: 250.0,
    );
  }

  Widget showLogo() {
    return Container(
      child: Image.asset('images/pte_logo.png'),
      width: 125.0,
    );
  }

  Widget showAppName() {
    return Text(
      'Flutter Workshop',
      style: MyStyle().h1Main,
    );
  }

  Widget showAFooterName() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Text(
          'PTE Engineering Consultants Ltd.',
          style: TextStyle(
            color: MyStyle().txtColor,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
            gradient: RadialGradient(
                colors: <Color>[Colors.white, MyStyle().mainColor],
                radius: 1.2)),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                showLogo(),
                //showAppName(),
                SizedBox(height: 30.0),
                userForm(),
                userPassword(),
                rememberCheck(),
                SizedBox(height: 30.0),
                showButton(),
                //showAFooterName(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
