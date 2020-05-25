import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mtracking/utility/my_style.dart';
import 'package:mtracking/utility/normal_dialog.dart';


class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  // Field
  File file;
  String name, email, user, password, confPwd;

  //Method
  Widget passwordForm() {
    Color color = Colors.green.shade700;

    return Container(
      margin: EdgeInsets.only(left: 30.0, right: 30.0),
      child: TextField(
        onChanged: (String string) {
          password = string.trim();
        },
        obscureText: true,
        style: TextStyle(color: color),
        decoration: InputDecoration(
          enabledBorder:
              UnderlineInputBorder(borderSide: BorderSide(color: color)),
          helperStyle: TextStyle(color: color),
          helperText: 'Type your password in blank',
          labelText: 'Password :',
          labelStyle: TextStyle(color: color),
          icon: Icon(
            Icons.lock,
            size: 36.0,
            color: color,
          ),
        ),
      ),
    );
  }

  Widget confPasswordForm() {
    Color color = Colors.purple.shade300;

    return Container(
      margin: EdgeInsets.only(left: 30.0, right: 30.0),
      child: TextField(
        onChanged: (String string) {
          confPwd = string.trim();
        },
        obscureText: true,
        style: TextStyle(color: color),
        decoration: InputDecoration(
          enabledBorder:
              UnderlineInputBorder(borderSide: BorderSide(color: color)),
          helperStyle: TextStyle(color: color),
          helperText: 'Type your password again',
          labelText: 'Confirm Password :',
          labelStyle: TextStyle(color: color),
          icon: Icon(
            Icons.lock,
            size: 36.0,
            color: color,
          ),
        ),
      ),
    );
  }

  Widget userForm() {
    Color color = Colors.blue.shade700;

    return Container(
      margin: EdgeInsets.only(left: 30.0, right: 30.0),
      child: TextField(
        onChanged: (String string) {
          user = string.trim();
        },
        style: TextStyle(color: color),
        decoration: InputDecoration(
          enabledBorder:
              UnderlineInputBorder(borderSide: BorderSide(color: color)),
          helperStyle: TextStyle(color: color),
          helperText: 'Type your user in blank',
          labelText: 'User :',
          labelStyle: TextStyle(color: color),
          icon: Icon(
            Icons.account_box,
            size: 36.0,
            color: color,
          ),
        ),
      ),
    );
  }

  Widget nameForm() {
    Color color = Colors.yellow.shade700;

    return Container(
      margin: EdgeInsets.only(left: 30.0, right: 30.0),
      child: TextField(
        onChanged: (String string) {
          name = string.trim();
        },
        style: TextStyle(color: color),
        decoration: InputDecoration(
          enabledBorder:
              UnderlineInputBorder(borderSide: BorderSide(color: color)),
          helperStyle: TextStyle(color: color),
          helperText: 'Type your name in blank',
          labelText: 'Display Name :',
          labelStyle: TextStyle(color: color),
          icon: Icon(
            Icons.face,
            size: 36.0,
            color: color,
          ),
        ),
      ),
    );
  }

  Widget mailForm() {
    Color color = Colors.orange.shade700;

    return Container(
      margin: EdgeInsets.only(left: 30.0, right: 30.0),
      child: TextField(
        onChanged: (String string) {
          email = string.trim();
        },
        style: TextStyle(color: color),
        decoration: InputDecoration(
          enabledBorder:
              UnderlineInputBorder(borderSide: BorderSide(color: color)),
          helperStyle: TextStyle(color: color),
          helperText: 'Type your e-mail in blank',
          labelText: 'E-mail :',
          labelStyle: TextStyle(color: color),
          icon: Icon(
            Icons.face,
            size: 36.0,
            color: color,
          ),
        ),
      ),
    );
  }

  Widget galleryButton() {
    return IconButton(
      icon: Icon(Icons.add_a_photo),
      onPressed: () {
        getPhoto(ImageSource.gallery);
      },
    );
  }

  Future<void> getPhoto(ImageSource imageSource) async {
    try {
      var object = await ImagePicker.pickImage(
        source: imageSource,
        maxWidth: 800.0,
        maxHeight: 800.0,
      );

      setState(() {
        file = object;
      });
    } catch (e) {}
  }

  Widget cameraButton() {
    return IconButton(
      icon: Icon(Icons.add_a_photo),
      onPressed: () {
        getPhoto(ImageSource.camera);
      },
    );
  }

  Widget showButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[signUpButton(),],
    );
  }

  Widget signUpButton() {
    return RaisedButton(
      color: MyStyle().txtColor,
      child: Text(
        'Submit',
        style: TextStyle(
          color: Colors.white,
        ),
      ),
      onPressed: () {
        if (name == null ||
            name.isEmpty ||
            user == null ||
            user.isEmpty ||
            password == null ||
            password.isEmpty) {
          normalDialog(context, 'No Info', 'Please fill your information');
        }else if(password != confPwd){
          setState(() {
            password = null;
            confPwd = null;
          });
          normalDialog(context, 'Confirm password', 'Please check your password');
        } else {
          processInserDatabase();
        }
      },
    );
  }

  Widget showAvatar() {
    return Container(
      padding: EdgeInsets.all(20.0),
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.5,
      child: file == null ? Image.asset('images/none_img.png') : Image.file(file),
    );
  }

  Widget registerButton() {
    return IconButton(
      icon: Icon(Icons.cloud_upload),
      onPressed: () {

        if (name == null ||
            name.isEmpty ||
            user == null ||
            user.isEmpty ||
            password == null ||
            password.isEmpty) {
          normalDialog(context, 'No Info', 'Please fill your information');
        }else if(password != confPwd){
          setState(() {
            password = null;
            confPwd = null;
          });
          normalDialog(context, 'Confirm password', 'Please check your password');
        } else {
          processInserDatabase();
        }
      },
    );
  }

  Future<void> processInserDatabase() async {

    String url = 'https://110.77.142.211/MTrackingServerVM10/register.jsp?name=$name&email=$email&user=$user&password=$password';

    Dio dio = new Dio();
      (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate = (client){
        client.badCertificateCallback = (X509Certificate cert, String host, int port){
          return true;
        };
      };

    await dio.get(url).then((response) {
      if (response.toString() == 'null') {
          normalDialog(context, 'Register', '๊Unable to register at this time. Please try again later');
      } else {

        Map<String, dynamic> map = json.decode(response.toString());
        bool success = map['SUCCESS'];
        String msg = map['MESSAGE'];

        
        if (success) { 

          toStepPopDialog(context, 'Register', msg);
          //return to login page
        }else{
          normalDialog(context, 'Register', msg);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Register'),
        //actions: <Widget>[registerButton()],
        backgroundColor: MyStyle().barColor,
      ),
      body: ListView(
        children: <Widget>[
          //showAvatar(),
          //showButton(),
          nameForm(),
          mailForm(),
          userForm(),
          passwordForm(),
          confPasswordForm(),
          SizedBox(
            height: 50,
          ),
          showButton(),
        ],
      ),
    );
  }
}
