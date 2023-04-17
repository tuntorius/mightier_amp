// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)
import 'package:flutter/material.dart';

class AppThemeConfig {
  static double dragHandlesWidth = 56;
  static Color contextMenuIconColor = Colors.white;
  static bool allowRotation = true;

  static TextStyle ListTileHeaderStyle =
      const TextStyle(color: Colors.lightBlue, fontWeight: FontWeight.bold);
  static double toggleButtonHeight(bool hasLongNames) {
    if (hasLongNames) return 48;
    return 40;
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

    //unselected labels
    hintColor: Colors.blue[300],

    disabledColor: Colors.grey[700],
    unselectedWidgetColor: Colors.white,
    toggleableActiveColor: Colors.white,
    inputDecorationTheme: InputDecorationTheme(
        focusedBorder: const UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.white)),
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
      selectedIconTheme: const IconThemeData(
        size: 40,
      ),
      unselectedIconTheme: const IconThemeData(
        size: 30,
      ),
    ),
    textButtonTheme: TextButtonThemeData(style:
        ButtonStyle(foregroundColor: MaterialStateColor.resolveWith((states) {
      if (states.contains(MaterialState.disabled)) return Colors.grey[700]!;
      return Colors.grey[300]!;
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
      button: const TextStyle(color: Colors.pink),

      // headline1: TextStyle(color: Colors.orange),
      // headline2: TextStyle(color: Colors.red),
      // overline: TextStyle(color: Colors.pink),
      // headline3: TextStyle(color: Colors.pink),
      // headline4: TextStyle(color: Colors.red),
      // headline5: TextStyle(color: Colors.green),

      //popup titles
      headline6: const TextStyle(color: Colors.white),

      bodyText1: const TextStyle(color: Colors.grey),
      subtitle1: const TextStyle(color: Colors.white),
      subtitle2: const TextStyle(color: Colors.pink),
      bodyText2: const TextStyle(color: Colors.white), //default text
    ),
    dialogTheme: DialogTheme(
      contentTextStyle: const TextStyle(color: Colors.white),
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
      borderRadius: const BorderRadius.all(Radius.circular(5)),
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: Colors.grey[700],
    ),
    dividerTheme:
        const DividerThemeData(color: Colors.grey, indent: 15, endIndent: 15),
  );
}
