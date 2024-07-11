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
    colorScheme: ColorScheme(
      brightness: Brightness.dark,
      primary: Colors.blue, //buttons
      onPrimary: Colors.white, //text on buttons
      secondary: Colors.white,
      onSecondary: Colors.grey,
      error: Colors.red,
      onError: Colors.white,
      background: Colors.grey,
      onBackground: Colors.grey,
      surface: Colors.grey[700]!, //appbar
      onSurface: Colors.white, //titlebar text
    ),
    //canvasColor: Colors.white,
    scaffoldBackgroundColor: Colors.grey[900],

    //primary color is AppBar bg color
    primaryColor: Colors.grey[800],
    //accentColor: Colors.white,

    //unselected labels
    hintColor: Colors.blue[300],

    disabledColor: Colors.grey[700],
    unselectedWidgetColor: Colors.white,
    inputDecorationTheme: InputDecorationTheme(
        labelStyle: const TextStyle(color: Colors.white),
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

    elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
      backgroundColor: MaterialStateColor.resolveWith((states) {
        if (states.contains(MaterialState.disabled)) return Colors.grey[700]!;
        return Colors.blue;
      }),
      foregroundColor: MaterialStateColor.resolveWith((states) {
        if (states.contains(MaterialState.disabled)) return Colors.grey;
        return Colors.white;
      }),
    )),

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
      borderRadius: const BorderRadius.all(Radius.circular(12)),
    ),
    popupMenuTheme: PopupMenuThemeData(color: Colors.grey[700]),
    dividerTheme:
        const DividerThemeData(color: Colors.grey, indent: 15, endIndent: 15),
  );
}
