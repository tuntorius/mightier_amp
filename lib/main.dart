// (c) 2020 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'package:flutter/material.dart';
import 'package:mighty_plug_manager/bluetooth/devices/presets/presetsStorage.dart';
import 'package:mighty_plug_manager/platform/simpleSharedPrefs.dart';
import 'UI/widgets/NuxAppBar.dart' as NuxAppBar;
import 'bluetooth/NuxDeviceControl.dart';
import 'bluetooth/bleMidiHandler.dart';

import 'UI/widgets/bottomBar.dart';
import 'UI/theme.dart';

//pages
import 'UI/pages/styleEditor.dart';
import 'UI/pages/drumEditor.dart';
import 'UI/pages/jamTracks.dart';
import 'UI/pages/settings.dart';
import 'bluetooth/devices/NuxDevice.dart';

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
      home: MainTabs(device.device),
      navigatorKey: navigatorKey,
    );
  }
}

class MainTabs extends StatefulWidget {
  final NuxDevice device;
  final BLEMidiHandler handler = BLEMidiHandler();

  MainTabs(this.device);
  @override
  _MainTabsState createState() => _MainTabsState();
}

class _MainTabsState extends State<MainTabs> {
  int _currentIndex = 0;
  BuildContext dialogContext;

  final List<Widget> _children = [
    StyleEditor(),
    DrumEditor(),
    JamTracks(),
    Settings()
  ];

  @override
  void initState() {
    super.initState();
    widget.device.connectStatus.stream.listen(connectionStateListener);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: NuxAppBar.getAppBar(widget.device, widget.handler),
        body: _children[_currentIndex],
        bottomNavigationBar: BottomBar(
          index: _currentIndex,
          onTap: (_index) {
            setState(() {
              _currentIndex = _index;
            });
          },
        ));
  }
}
