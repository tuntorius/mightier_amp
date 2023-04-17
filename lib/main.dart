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

//recreate this file with your own api keys
//import 'configKeys.dart';
import 'modules/cloud/cloudManager.dart';

//able to create snackbars/messages everywhere
final navigatorKey = GlobalKey<NavigatorState>();
final bucketGlobal = PageStorageBucket();

void main() {
  //configuration data is needed before start of the app
  WidgetsFlutterBinding.ensureInitialized();
  SharedPrefs prefs = SharedPrefs();

  //capture flutter errors
  /*
  if (!kDebugMode) {
    FlutterError.onError = (FlutterErrorDetails details) {
      DebugConsole.printString("Flutter error: ${details.toString()}");

      //update diagnostics with json preset
      NuxDeviceControl.instance()
          .updateDiagnosticsData(includeJsonPreset: true);

      // Send report
      Sentry.captureException(
        details,
        stackTrace: details.stack,
      );
    };
  }*/

/*
  if (!kDebugMode) {
    runZonedGuarded(() {
      prefs.waitLoading().then((value) async {
        if (!kDebugMode) {
          await SentryFlutter.init((options) {
            options.dsn = sentryDsn;
            options.sampleRate = 0.33;
          });
        }
        mainRunApp();
      });
    }, (Object error, StackTrace stackTrace) async {
      // Whenever an error occurs, call the `_reportError` function. This sends
      // Dart errors to the dev console or Sentry depending on the environment.
      //_reportError(error, stackTrace);

      DebugConsole.printString("Dart error: ${error.toString()}");
      DebugConsole.printString(stackTrace);

      //update diagnostics with json preset
      NuxDeviceControl.instance()
          .updateDiagnosticsData(includeJsonPreset: true);

      await Sentry.captureException(
        error,
        stackTrace: stackTrace,
      );
    });
  } else {*/
  prefs.waitLoading().then((value) {
    mainRunApp();
  });
  //}
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
  PresetsStorage storage = PresetsStorage();
  TrackData trackData = TrackData();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mightier Amp',
      theme: getTheme(),
      home: MainTabs(),
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.mouse,
          PointerDeviceKind.touch,
          PointerDeviceKind.stylus,
          PointerDeviceKind.unknown
        },
      ),
      //showSemanticsDebugger: true,
      navigatorKey: navigatorKey,
    );
  }
}
