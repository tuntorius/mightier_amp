// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'dart:math';

import 'package:flutter/material.dart';

class AppThemeConfig {
  static double dragHandlesWidth = 56;
  static Color contextMenuIconColor = Colors.grey[400]!;
  static bool allowRotation = false;

  static TextStyle ListTileHeaderStyle =
      const TextStyle(color: Colors.lightBlue, fontWeight: FontWeight.bold);
  static double toggleButtonHeight(bool isPortrait, double viewportHeight) {
    if (!isPortrait) return 48;

    var ratio = (viewportHeight - 592) / 140;
    return 35 + max(0, min(ratio, 1)) * 15;
  }
}

ThemeData getTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    backgroundColor: Colors.white,
    //canvasColor: Colors.white,
    scaffoldBackgroundColor: Colors.grey[900],

    //primary color is AppBar bg color
    primaryColor: Colors.grey[800],
    accentColor: Colors.white,
    hintColor: Colors.blue,
    disabledColor: Colors.grey[700],
    unselectedWidgetColor: Colors.white,
    toggleableActiveColor: Colors.white,
    inputDecorationTheme: InputDecorationTheme(
        focusedBorder:
            UnderlineInputBorder(borderSide: BorderSide(color: Colors.white)),
        enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey[600]!))),
    checkboxTheme:
        CheckboxThemeData(fillColor: MaterialStateColor.resolveWith((states) {
      return Colors.white;
    }), checkColor: MaterialStateColor.resolveWith((states) {
      return Colors.black;
    })),
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
    textButtonTheme: TextButtonThemeData(style:
        ButtonStyle(foregroundColor: MaterialStateColor.resolveWith((states) {
      if (states.contains(MaterialState.disabled)) return Colors.grey[700]!;
      return Colors.grey[400]!;
    }))),
    // elevatedButtonTheme: ElevatedButtonThemeData(
    //     style: ButtonStyle(
    //   backgroundColor: MaterialStateColor.resolveWith((states) {
    //     if (states.contains(MaterialState.disabled)) return Colors.grey[700]!;
    //     return Colors.blue;
    //   }),
    //   foregroundColor: MaterialStateColor.resolveWith((states) {
    //     if (states.contains(MaterialState.disabled)) return Colors.grey;
    //     return Colors.white;
    //   }),
    // )),
    textTheme: TextTheme(
      caption: TextStyle(color: Colors.grey[400]),
      button: TextStyle(color: Colors.pink),

      // headline1: TextStyle(color: Colors.orange),
      // headline2: TextStyle(color: Colors.red),
      // overline: TextStyle(color: Colors.pink),
      // headline3: TextStyle(color: Colors.pink),
      // headline4: TextStyle(color: Colors.red),
      // headline5: TextStyle(color: Colors.green),

      //popup titles
      headline6: TextStyle(color: Colors.white),

      bodyText1: TextStyle(color: Colors.grey),
      subtitle1: TextStyle(color: Colors.white),
      subtitle2: TextStyle(color: Colors.pink),
      bodyText2: TextStyle(color: Colors.white), //default text
    ),
    dialogTheme: DialogTheme(
      contentTextStyle: TextStyle(color: Colors.white),
      backgroundColor: Colors.grey[800],
      //shape: RoundedRectangleBorder(
      //    borderRadius: BorderRadius.all(Radius.circular(10))),
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
    ),
    dividerTheme:
        DividerThemeData(color: Colors.grey, indent: 15, endIndent: 15),
  );
}
