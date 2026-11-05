// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:mighty_plug_manager/UI/pages/DebugConsolePage.dart';
import 'package:mighty_plug_manager/platform/presetsStorage.dart';
import 'package:mighty_plug_manager/platform/simpleSharedPrefs.dart';

//pages
import 'UI/mainTabs.dart';
import 'UI/theme.dart';
import 'audio/trackdata/trackData.dart';
import 'bluetooth/NuxDeviceControl.dart';

import 'modules/cloud/cloudManager.dart';

final navigatorKey = GlobalKey<NavigatorState>();
final bucketGlobal = PageStorageBucket();

void main() {
  runZoned(() {
    WidgetsFlutterBinding.ensureInitialized();
    SharedPrefs prefs = SharedPrefs();

    prefs.waitLoading().then((value) {
      bool isDark = prefs.getValue(SettingsKeys.darkMode, true);
      themeModeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;

      PresetsStorage storage = PresetsStorage();
      storage.init().then((value) => mainRunApp());
    });
  }, zoneSpecification: ZoneSpecification(
      print: (Zone self, ZoneDelegate parent, Zone zone, String line) {
    parent.print(zone, line);
    DebugConsole.print(line);
  }));
}

mainRunApp() {
  if (kDebugMode) CloudManager.instance.initialize();

  runApp(const App());
}

class App extends StatefulWidget {
  const App({Key? key}) : super(key: key);

  @override
  State createState() => _AppState();
}

class _AppState extends State<App> {
  NuxDeviceControl device = NuxDeviceControl.instance();
  SharedPrefs prefs = SharedPrefs();
  TrackData trackData = TrackData();

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeModeNotifier,
      builder: (context, ThemeMode mode, child) {
        return MaterialApp(
          title: 'Mightier Amp',
          theme: getLightTheme(),
          darkTheme: getDarkTheme(),
          themeMode: mode,
          home: MainTabs(),
          scrollBehavior: const MaterialScrollBehavior().copyWith(
            dragDevices: {
              PointerDeviceKind.mouse,
              PointerDeviceKind.touch,
              PointerDeviceKind.stylus,
              PointerDeviceKind.unknown
            },
          ),
          navigatorKey: navigatorKey,
        );
      },
    );
  }
}