// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mighty_plug_manager/bluetooth/devices/presets/presetsStorage.dart';
import 'package:mighty_plug_manager/platform/simpleSharedPrefs.dart';
import 'UI/popups/alertDialogs.dart';
import 'UI/widgets/NuxAppBar.dart' as NuxAppBar;
import 'UI/widgets/presets/presetList.dart';
import 'UI/widgets/thickSlider.dart';
import 'audio/trackdata/trackData.dart';
import 'bluetooth/NuxDeviceControl.dart';
import 'bluetooth/bleMidiHandler.dart';

import 'UI/widgets/bottomBar.dart';
import 'UI/theme.dart';

//pages
import 'UI/pages/presetEditor.dart';
import 'UI/pages/drumEditor.dart';
import 'UI/pages/jamTracks.dart';
import 'UI/pages/settings.dart';

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
  runApp(new App());
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
            return WillPopScope(
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
                      SizedBox(
                        width: 8,
                      ),
                      Text(
                        "Connecting",
                        style: TextStyle(color: Colors.white),
                      ),
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
    return WillPopScope(
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
                          onChanged: (value) {
                            setState(() {
                              NuxDeviceControl().masterVolume = value;
                            });
                          }),
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
