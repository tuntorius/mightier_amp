// (c) 2020 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'package:flutter/material.dart';
import 'package:mighty_plug_manager/bluetooth/devices/presets/presetsStorage.dart';
import 'package:mighty_plug_manager/platform/simpleSharedPrefs.dart';
import 'bluetooth/NuxDeviceControl.dart';
import 'bluetooth/bleMidiHandler.dart';

import 'UI/widgets/bottomBar.dart';
import 'UI/theme.dart';

//pages
import 'UI/pages/styleEditor.dart';
import 'UI/pages/drumEditor.dart';
import 'UI/pages/jamTracks.dart';
import 'UI/pages/settings.dart';
import 'UI/widgets/blinkWidget.dart';

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
  @override
  _MainTabsState createState() => _MainTabsState();
}

class _MainTabsState extends State<MainTabs> {
  int _currentIndex = 0;
  final List<Widget> _children = [
    StyleEditor(),
    DrumEditor(),
    JamTracks(),
    Settings()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[900],
        appBar: AppBar(
          title: Text("Mightier Amp"),
          actions: [
            StreamBuilder<midiSetupStatus>(
              builder: (context, snapshot) {
                IconData icon = Icons.bluetooth_disabled;
                Color color = Colors.grey;
                switch (snapshot.data) {
                  case midiSetupStatus.bluetoothOff:
                    icon = Icons.bluetooth_disabled;
                    break;
                  case midiSetupStatus.deviceIdle:
                  case midiSetupStatus.deviceConnecting:
                    icon = Icons.bluetooth;
                    break;
                  case midiSetupStatus
                      .deviceFound: //note device found is issued
                  //during search only, but here it means nothing
                  //so keep search status
                  case midiSetupStatus.deviceSearching:
                    icon = Icons.bluetooth_searching;
                    return BlinkWidget(
                      children: [
                        Icon(
                          Icons.bluetooth_searching,
                          color: Colors.grey,
                        ),
                        Icon(Icons.bluetooth_searching)
                      ],
                      interval: 500,
                    );

                  case midiSetupStatus.deviceConnected:
                    icon = Icons.bluetooth_connected;
                    color = Colors.white;
                    break;
                  case midiSetupStatus.deviceDisconnected:
                    icon = Icons.bluetooth;
                    break;
                  case midiSetupStatus.unknown:
                    icon = Icons.bluetooth_disabled;
                    break;
                }
                return Icon(icon, color: color);
              },
              stream: widget.handler.status,
            ),
            SizedBox(
              width: 15,
            )
          ],
        ),
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
