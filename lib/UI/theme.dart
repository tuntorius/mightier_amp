// (c) 2020 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'package:flutter/material.dart';

ThemeData getTheme() {
  return new ThemeData(
    backgroundColor: Colors.white,
    canvasColor: Colors.white,
    scaffoldBackgroundColor: Colors.black,
    primaryColor: Colors.grey[800],
    accentColor: Colors.grey[300],
    hintColor: Colors.blue,
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
      bodyText2: TextStyle(color: Colors.grey[500]),
    ),
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
  );
}
