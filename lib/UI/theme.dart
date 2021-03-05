// (c) 2020 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'package:flutter/material.dart';

ThemeData getTheme() {
  return new ThemeData(
    backgroundColor: Colors.white,
    canvasColor: Colors.white,
    scaffoldBackgroundColor: Colors.grey[900],
    primaryColor: Colors.grey[800],
    accentColor: Colors.grey[300],
    hintColor: Colors.blue,
    disabledColor: Colors.grey[700],
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.grey[800],
      selectedItemColor: Colors.white,
      unselectedItemColor: Colors.grey[500],
      selectedIconTheme: IconThemeData(
        size: 40,
      ),
      unselectedIconTheme: IconThemeData(
        size: 30,
      ),
    ),
    textTheme: TextTheme(
      caption: TextStyle(color: Colors.grey[400]),
      button: TextStyle(color: Colors.pink),
      //overline: TextStyle(color: Colors.pink),
      bodyText1: TextStyle(color: Colors.pink),
      subtitle1: TextStyle(color: Colors.white),
      subtitle2: TextStyle(color: Colors.pink),
      bodyText2: TextStyle(color: Colors.grey[500]),
    ),
    dialogTheme: DialogTheme(contentTextStyle: TextStyle(color: Colors.black)),
    toggleButtonsTheme: ToggleButtonsThemeData(
      color: Colors.grey[600],
      selectedColor: Colors.white,
      borderColor: Colors.grey[800],
      selectedBorderColor: Colors.grey[800],
      fillColor: Colors.transparent,
      borderWidth: 2,
      borderRadius: BorderRadius.all(Radius.circular(5)),
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: Colors.grey[700],
      textStyle: TextStyle(color: Colors.white),
    ),
    dividerTheme:
        DividerThemeData(color: Colors.grey, indent: 15, endIndent: 15),
  );
}
