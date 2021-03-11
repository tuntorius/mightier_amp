// (c) 2020 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mighty_plug_manager/bluetooth/devices/presets/presetsStorage.dart';
import 'package:mighty_plug_manager/platform/simpleSharedPrefs.dart';
import 'UI/popups/alertDialogs.dart';
import 'UI/widgets/NuxAppBar.dart' as NuxAppBar;
import 'UI/widgets/presets/presetList.dart';
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
      context: navigatorKey.currentContext,
      builder: (context) => AlertDialog(
            title: Text(title),
            content: Text(content),
          ));
}

void main() {
  runApp(new App());
}

class App extends StatefulWidget {
  App({Key key}) : super(key: key);

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

class _MainTabsState extends State<MainTabs> {
  int _currentIndex = 0;
  BuildContext dialogContext;

  final List<Widget> _children = [];

  @override
  void initState() {
    super.initState();

    //add 5 pages widgets
    _children.addAll([
      PresetEditor(),
      PresetList(onTap: (preset) {
        NuxDeviceControl().device.presetFromJson(preset);
      }),
      DrumEditor(),
      JamTracks(),
      Settings()
    ]);

    NuxDeviceControl().connectStatus.stream.listen(connectionStateListener);
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

  setTab(int tab) {
    setState(() {
      _currentIndex = tab;
    });
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _willPopCallback,
      child: Scaffold(
        appBar: NuxAppBar.getAppBar(widget.handler),
        body: _children[_currentIndex],
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
        bottomNavigationBar: BottomBar(
          index: _currentIndex,
          onTap: (_index) {
            setState(() {
              _currentIndex = _index;
            });
          },
        ),
      ),
    );
  }
}
