import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MyStyle {
  Color txtColor = Colors.red.shade900;
  Color mainColor = Color.fromARGB(0xff, 0x74, 0x74, 0x74);
  Color barColor = Colors.red.shade900;

  TextStyle h1Main = GoogleFonts.exo2(
      textStyle: TextStyle(
          fontSize: 20,
          color: Colors.red.shade900,
          fontWeight: FontWeight.bold,
          fontStyle: FontStyle.italic));

  TextStyle txtnormal = GoogleFonts.exo2(
      textStyle: TextStyle(
          fontSize: 20,
          color: Colors.red.shade900,
          fontWeight: FontWeight.bold,
          fontStyle: FontStyle.italic));

  TextStyle projNameTitle = GoogleFonts.exo2(
      textStyle: TextStyle(
          fontSize: 20,
          color: Colors.indigo.shade800,
          fontWeight: FontWeight.bold,
          fontStyle: FontStyle.normal));

  MyStyle();
}
