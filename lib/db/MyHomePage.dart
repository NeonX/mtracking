import 'package:flutter/material.dart';
import 'package:mtracking/db/database_helper.dart';
import 'package:mtracking/models/province.dart';


class MyHomePage extends StatelessWidget {

  // reference to our single class that manages the database
  final dbHelper = DatabaseHelper.instance;

  Province province = new Province();

  // homepage layout
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('sqflite'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            RaisedButton(
              child: Text('insert', style: TextStyle(fontSize: 20),),
              onPressed: () {_insert();},
            ),
            RaisedButton(
              child: Text('query', style: TextStyle(fontSize: 20),),
              onPressed: () {Province().query();},
            ),
            RaisedButton(
              child: Text('update', style: TextStyle(fontSize: 20),),
              onPressed: () {_update();},
            ),
            RaisedButton(
              child: Text('delete', style: TextStyle(fontSize: 20),),
              onPressed: () {_delete();},
            ),
          ],
        ),
      ),
    );
  }
  
  // Button onPressed methods
  
  void _insert() async {
    // row to insert
    Map<String, dynamic> row = {Province.columnName: 'Bob', Province.columnNameEn: null};

    Province().insert(row);
  }
/*
  void _query() async {
    final allRows = await dbHelper.queryAllRows();
    print('query all rows:');
    allRows.forEach((row) => print(row));
  } */

  void _update() async {
    /*
    // row to update
    Map<String, dynamic> row = {
      DatabaseHelper.columnId   : 97,
      DatabaseHelper.columnNameEn  : 'TEST'
    };
    final rowsAffected = await dbHelper.update(row);
    print('updated $rowsAffected row(s)');
    */
  }

  void _delete() async {
    /*
    // Assuming that the number of rows is the id for the last row.
    final id = await dbHelper.queryRowCount();
    final rowsDeleted = await dbHelper.delete(97);
    print('deleted $rowsDeleted row(s): row $id');
    */
  }
  
}