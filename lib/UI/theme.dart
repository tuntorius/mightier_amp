// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'package:flutter/material.dart';

final ValueNotifier<ThemeMode> themeModeNotifier =
    ValueNotifier<ThemeMode>(ThemeMode.dark);

class AppThemeConfig {
  static double dragHandlesWidth = 56;
  static bool allowRotation = true;
  static TextStyle ListTileHeaderStyle =
      const TextStyle(color: Colors.lightBlue, fontWeight: FontWeight.bold);

  static double toggleButtonHeight(bool hasLongNames) {
    if (hasLongNames) return 48;
    return 40;
  }
}

ThemeData getTheme() {
  return getDarkTheme();
}

ThemeData getDarkTheme() {
  return ThemeData(
    brightness: Brightness.dark,
    colorScheme: ColorScheme(
      brightness: Brightness.dark,
      primary: Colors.blue,
      onPrimary: Colors.white,
      secondary: Colors.white,
      onSecondary: Colors.grey,
      error: Colors.red,
      onError: Colors.white,
      surface: Colors.grey[900]!,
      onSurface: Colors.white,
    ),
    scaffoldBackgroundColor: Colors.black,
    primaryColor: Colors.black,
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
        CheckboxThemeData(fillColor: WidgetStateColor.resolveWith((states) {
      return Colors.white;
    }), checkColor: WidgetStateColor.resolveWith((states) {
      return Colors.black;
    })),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.black,
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
        ButtonStyle(foregroundColor: WidgetStateColor.resolveWith((states) {
      if (states.contains(WidgetState.disabled)) return Colors.grey[700]!;
      return Colors.grey[300]!;
    }))),
    elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
      backgroundColor: WidgetStateColor.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) return Colors.grey[700]!;
        return Colors.blue;
      }),
      foregroundColor: WidgetStateColor.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) return Colors.grey;
        return Colors.white;
      }),
    )),
    dialogTheme: DialogThemeData(
      contentTextStyle: const TextStyle(color: Colors.white),
      backgroundColor: Colors.grey[900],
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
    popupMenuTheme: PopupMenuThemeData(color: Colors.grey[900]),
    dividerTheme:
        const DividerThemeData(color: Colors.grey, indent: 15, endIndent: 15),
  );
}

ThemeData getLightTheme() {
  return ThemeData(
    brightness: Brightness.light,
    colorScheme: ColorScheme(
      brightness: Brightness.light,
      primary: Colors.blue,
      onPrimary: Colors.white,
      secondary: Colors.blueAccent,
      onSecondary: Colors.white,
      error: Colors.red,
      onError: Colors.white,
      surface: Colors.grey[100]!,
      onSurface: Colors.black87,
    ),
    scaffoldBackgroundColor: Colors.white,
    primaryColor: Colors.blue,
    hintColor: Colors.blue[700],
    disabledColor: Colors.grey[400],
    unselectedWidgetColor: Colors.black54,
    inputDecorationTheme: const InputDecorationTheme(
        labelStyle: TextStyle(color: Colors.black87),
        focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.blue)),
        enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.grey))),
    checkboxTheme:
        CheckboxThemeData(fillColor: WidgetStateColor.resolveWith((states) {
      return Colors.blue;
    }), checkColor: WidgetStateColor.resolveWith((states) {
      return Colors.white;
    })),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.grey[200],
      selectedItemColor: Colors.blue[800],
      unselectedItemColor: Colors.grey[600],
      selectedIconTheme: const IconThemeData(
        size: 40,
      ),
      unselectedIconTheme: const IconThemeData(
        size: 30,
      ),
    ),
    textButtonTheme: TextButtonThemeData(style:
        ButtonStyle(foregroundColor: WidgetStateColor.resolveWith((states) {
      if (states.contains(WidgetState.disabled)) return Colors.grey[400]!;
      return Colors.blue[800]!;
    }))),
    elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
      backgroundColor: WidgetStateColor.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) return Colors.grey[400]!;
        return Colors.blue;
      }),
      foregroundColor: WidgetStateColor.resolveWith((states) {
        if (states.contains(WidgetState.disabled)) return Colors.grey;
        return Colors.white;
      }),
    )),
    dialogTheme: const DialogThemeData(
      contentTextStyle: TextStyle(color: Colors.black87),
      backgroundColor: Colors.white,
    ),
    toggleButtonsTheme: ToggleButtonsThemeData(
      color: Colors.grey[700],
      selectedColor: Colors.blue[800],
      borderColor: Colors.grey[300],
      selectedBorderColor: Colors.blue,
      fillColor: Colors.blue[50],
      borderWidth: 2,
      borderRadius: const BorderRadius.all(Radius.circular(12)),
    ),
    popupMenuTheme: const PopupMenuThemeData(color: Colors.white),
    dividerTheme:
        const DividerThemeData(color: Colors.grey, indent: 15, endIndent: 15),
  );
}