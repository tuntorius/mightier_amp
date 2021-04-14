// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mighty_plug_manager/UI/pages/DebugConsolePage.dart';
import 'package:mighty_plug_manager/bluetooth/devices/presets/presetsStorage.dart';
import 'package:mighty_plug_manager/platform/simpleSharedPrefs.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'UI/popups/alertDialogs.dart';
import 'UI/widgets/NuxAppBar.dart' as NuxAppBar;
import 'UI/widgets/nestedWillPopScope.dart';
import 'UI/widgets/presets/presetList.dart';
import 'UI/widgets/thickSlider.dart';
import 'bluetooth/NuxDeviceControl.dart';
import 'bluetooth/bleMidiHandler.dart';

import 'UI/widgets/bottomBar.dart';
import 'UI/theme.dart';

//pages
import 'UI/pages/presetEditor.dart';
import 'UI/pages/drumEditor.dart';
import 'UI/pages/jamTracks.dart';
import 'UI/pages/settings.dart';

//recreate this file with your own api keys
import 'configKeys.dart';

//able to create snackbars/messages everywhere
final navigatorKey = GlobalKey<NavigatorState>();

void showMessageDialog(String title, String content) {
  showDialog(
      context: navigatorKey.currentContext!,
      builder: (context) => AlertDialog(
            title: Text(title),
            content: Text(content),
          ));
}

void main() {
  //configuration data is needed before start of the app
  WidgetsFlutterBinding.ensureInitialized();
  SharedPrefs prefs = SharedPrefs();

  //capture flutter errors
  if (!kDebugMode)
    FlutterError.onError = (FlutterErrorDetails details) {
      print("");
      DebugConsole.print("Flutter error: ${details.toString()}");
      // Send report
      Sentry.captureException(
        details,
        stackTrace: details.stack,
      );
    };

  if (!kDebugMode) {
    runZonedGuarded(() {
      prefs.waitLoading().then((value) async {
        if (!kDebugMode) {
          await SentryFlutter.init((options) {
            options.dsn = sentryDsn;
          });
        }
        runApp(App());
      });
    }, (Object error, StackTrace stackTrace) async {
      // Whenever an error occurs, call the `_reportError` function. This sends
      // Dart errors to the dev console or Sentry depending on the environment.
      //_reportError(error, stackTrace);

      DebugConsole.print("Dart error: ${error.toString()}");
      DebugConsole.print(stackTrace);

      await Sentry.captureException(
        error,
        stackTrace: stackTrace,
      );
    });
  } else {
    prefs.waitLoading().then((value) {
      runApp(App());
    });
  }
}

class App extends StatefulWidget {
  App({Key? key}) : super(key: key);

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  NuxDeviceControl device = NuxDeviceControl();
  SharedPrefs prefs = SharedPrefs();
  PresetsStorage storage = PresetsStorage();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mightier Amp',
      theme: getTheme(),
      //theme: ThemeData.dark(),
      home: MainTabs(),
      navigatorKey: navigatorKey,
    );
  }
}

class MainTabs extends StatefulWidget {
  final BLEMidiHandler handler = BLEMidiHandler();

  MainTabs();
  @override
  _MainTabsState createState() => _MainTabsState();
}

class _MainTabsState extends State<MainTabs> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late BuildContext dialogContext;
  late TabController controller;
  final List<Widget> _children = [];

  bool openDrawer = false;

  @override
  void initState() {
    super.initState();

    //add 5 pages widgets
    _children.addAll([
      PresetEditor(),
      PresetList(onTap: (preset) {
        var dev = NuxDeviceControl().device;
        if (dev.isPresetSupported(preset))
          NuxDeviceControl().device.presetFromJson(preset, null);
        else
          print("Preset is for different device!");
      }),
      DrumEditor(),
      JamTracks(),
      Settings()
    ]);

    controller = TabController(initialIndex: 0, length: 5, vsync: this);

    controller.addListener(() {
      _currentIndex = controller.index;
      setState(() {});
    });
    NuxDeviceControl().connectStatus.stream.listen(connectionStateListener);
    NuxDeviceControl().addListener(onDeviceChanged);
  }

  @override
  void dispose() {
    super.dispose();
    NuxDeviceControl().removeListener(onDeviceChanged);
  }

  void connectionStateListener(DeviceConnectionState event) {
    switch (event) {
      case DeviceConnectionState.connectedStart:
        print("just connected");
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            dialogContext = context;
            return NestedWillPopScope(
              onWillPop: () => Future.value(false),
              child: Dialog(
                backgroundColor: Colors.grey[700],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: new Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      const SizedBox(
                        width: 8,
                      ),
                      Text("Connecting"),
                    ],
                  ),
                ),
              ),
            );
          },
        );
        break;
      case DeviceConnectionState.presetsLoaded:
        print("presets loaded");
        break;
      case DeviceConnectionState.configReceived:
        print("config loaded");
        Navigator.pop(context);
        break;
    }
  }

  Future<bool> _willPopCallback() async {
    Completer<bool> confirmation = Completer<bool>();
    AlertDialogs.showConfirmDialog(context,
        title: "Exit Mightier Amp?",
        cancelButton: "No",
        confirmButton: "Yes",
        confirmColor: Colors.red,
        description: "Are you sure?", onConfirm: (val) {
      if (val) {
        //disconnect device if connected
        BLEMidiHandler().disconnectDevice();
      }
      confirmation.complete(val);
    });
    return confirmation.future;
  }

  // setTab(int tab) {
  //   _currentIndex = tab;
  //   setState(() {});
  //   Navigator.of(context).pop();
  // }

  void onDeviceChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return NestedWillPopScope(
      onWillPop: _willPopCallback,
      child: Scaffold(
        appBar: NuxAppBar.getAppBar(widget.handler),
        body: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            TabBarView(
              children: _children,
              physics: NeverScrollableScrollPhysics(),
              controller: controller,
            ),
            //this is the volume bar, which is not ready yet
            if (kDebugMode)
              GestureDetector(
                onTap: () {
                  openDrawer = !openDrawer;
                  setState(() {});
                },
                onVerticalDragUpdate: (details) {
                  if (details.delta.dy < 0) {
                    //open
                    openDrawer = true;
                  } else {
                    //close
                    openDrawer = false;
                  }
                  setState(() {});
                },
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 50,
                      decoration: BoxDecoration(
                          color: Theme.of(context)
                              .bottomNavigationBarTheme
                              .backgroundColor,
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(15))),
                      child: Icon(
                        openDrawer
                            ? Icons.keyboard_arrow_down
                            : Icons.keyboard_arrow_up,
                        size: 20,
                        color: Colors.grey,
                      ),
                    ),
                    AnimatedContainer(
                      padding: EdgeInsets.all(8),
                      color: Theme.of(context)
                          .bottomNavigationBarTheme
                          .backgroundColor,
                      duration: Duration(milliseconds: 100),
                      height: openDrawer ? 60 : 0,
                      child: ThickSlider(
                        activeColor: Colors.blue,
                        value: NuxDeviceControl().masterVolume,
                        skipEmitting: 3,
                        label: "Volume",
                        labelFormatter: (value) {
                          return value.round().toString();
                        },
                        min: 0,
                        max: 100,
                        handleVerticalDrag: false,
                        onChanged: (value) {
                          setState(() {
                            NuxDeviceControl().masterVolume = value;
                          });
                        },
                        onDragEnd: (value) {
                          //TODO: save it to config
                        },
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        /*drawer: Drawer(
          child: ListView(
            children: [
              Text("Mightier Amp"),
              Divider(),
              ListTile(
                title: Text("Style editor"),
                onTap: () {
                  setTab(0);
                },
              ),
              ListTile(
                title: Text("Presets"),
                onTap: () {
                  setTab(1);
                },
              ),
              ListTile(
                title: Text("Drums"),
                onTap: () {
                  setTab(2);
                },
              ),
              ListTile(
                title: Text("Jam Tracks"),
                onTap: () {
                  setTab(3);
                },
              ),
              ListTile(
                title: Text("Settings"),
                onTap: () {
                  setTab(4);
                },
              ),
            ],
          ),
        ),*/
        bottomNavigationBar: GestureDetector(
          onVerticalDragUpdate: (details) {
            if (details.delta.dy < 0) {
              //open
              openDrawer = true;
            } else {
              //close
              openDrawer = false;
            }
            setState(() {});
          },
          child: BottomBar(
            index: _currentIndex,
            onTap: (_index) {
              setState(() {
                _currentIndex = _index;
                controller.animateTo(_currentIndex);
              });
            },
          ),
        ),
      ),
    );
  }
}
