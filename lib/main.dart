// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mighty_plug_manager/UI/pages/DebugConsolePage.dart';
import 'package:mighty_plug_manager/bluetooth/devices/presets/presetsStorage.dart';
import 'package:mighty_plug_manager/midi/MidiControllerManager.dart';
import 'package:mighty_plug_manager/platform/simpleSharedPrefs.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'UI/popups/alertDialogs.dart';
import 'UI/widgets/NuxAppBar.dart' as NuxAppBar;
import 'UI/widgets/VolumeDrawer.dart';
import 'UI/widgets/nestedWillPopScope.dart';
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

//recreate this file with your own api keys
import 'configKeys.dart';

//able to create snackbars/messages everywhere
final navigatorKey = GlobalKey<NavigatorState>();

void main() {
  //configuration data is needed before start of the app
  WidgetsFlutterBinding.ensureInitialized();
  SharedPrefs prefs = SharedPrefs();

  //capture flutter errors
  if (!kDebugMode)
    FlutterError.onError = (FlutterErrorDetails details) {
      DebugConsole.print("Flutter error: ${details.toString()}");

      //update diagnostics with json preset
      NuxDeviceControl().updateDiagnosticsData(includeJsonPreset: true);

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
        mainRunApp();
      });
    }, (Object error, StackTrace stackTrace) async {
      // Whenever an error occurs, call the `_reportError` function. This sends
      // Dart errors to the dev console or Sentry depending on the environment.
      //_reportError(error, stackTrace);

      DebugConsole.print("Dart error: ${error.toString()}");
      DebugConsole.print(stackTrace);

      //update diagnostics with json preset
      NuxDeviceControl().updateDiagnosticsData(includeJsonPreset: true);

      await Sentry.captureException(
        error,
        stackTrace: stackTrace,
      );
    });
  } else {
    prefs.waitLoading().then((value) {
      mainRunApp();
    });
  }
}

mainRunApp() {
  runApp(App());
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
  final MidiControllerManager midiMan = MidiControllerManager();

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

  bool connectionFailed = false;
  late Timer _timeout;
  StateSetter? dialogSetState;

  @override
  void initState() {
    if (!AppThemeConfig.allowRotation)
      SystemChrome.setPreferredOrientations(
          [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    else
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight
      ]);

    super.initState();

    //add 5 pages widgets
    _children.addAll(
        [PresetEditor(), PresetList(), DrumEditor(), JamTracks(), Settings()]);

    controller = TabController(initialIndex: 0, length: 5, vsync: this);

    controller.addListener(() {
      _currentIndex = controller.index;
      setState(() {});
    });

    NuxDeviceControl().connectStatus.stream.listen(connectionStateListener);
    NuxDeviceControl().addListener(onDeviceChanged);

    BLEMidiHandler().initBle(bleErrorHandler);
  }

  void bleErrorHandler(BluetoothError error, dynamic data) {
    {
      switch (error) {
        case BluetoothError.unavailable:
          AlertDialogs.showInfoDialog(context,
              title: "Warning!",
              description: "Your device does not support bluetooth!",
              confirmButton: "OK");
          break;
        case BluetoothError.permissionDenied:
          AlertDialogs.showLocationPrompt(context, false, null);
          break;
        case BluetoothError.locationServiceOff:
          AlertDialogs.showInfoDialog(context,
              title: "Location service is disabled!",
              description:
                  "Please, enable location service. It is required for Bluetooth connection to work.",
              confirmButton: "OK");
          break;
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    NuxDeviceControl().removeListener(onDeviceChanged);
  }

  void onConnectionTimeout() async {
    connectionFailed = true;
    if (dialogSetState != null) {
      dialogSetState?.call(() {});
      await Future.delayed(Duration(seconds: 3));
      Navigator.pop(context);
      dialogSetState = null;
      BLEMidiHandler().disconnectDevice();
    }
  }

  void connectionStateListener(DeviceConnectionState event) {
    switch (event) {
      case DeviceConnectionState.connectedStart:
        if (dialogSetState != null) break;
        print("just connected");
        connectionFailed = false;
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            dialogContext = context;
            return StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
              dialogSetState = setState;
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
                        if (!connectionFailed) CircularProgressIndicator(),
                        if (connectionFailed)
                          Icon(
                            Icons.error,
                            color: Colors.red,
                          ),
                        const SizedBox(
                          width: 8,
                        ),
                        Text(connectionFailed
                            ? "Connection Failed!"
                            : "Connecting"),
                      ],
                    ),
                  ),
                ),
              );
            });
          },
        );

        //setup a timer incase something fails
        _timeout = Timer(const Duration(seconds: 10), onConnectionTimeout);

        break;
      case DeviceConnectionState.presetsLoaded:
        print("presets loaded");
        break;
      case DeviceConnectionState.configReceived:
        print("config loaded");
        dialogSetState = null;
        _timeout.cancel();
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
    var isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    //WARNING: Workaround for a flutter bug - if the app is started with screen off,
    //one of the widgets throwns an exception and the app scaffold is empty
    if (MediaQuery.of(context).size.width < 10) return Container();
    return FocusScope(
      autofocus: true,
      onKey: (node, event) {
        if (event.runtimeType.toString() == 'RawKeyDownEvent' &&
            event.logicalKey.keyId != 0x100001005) {
          MidiControllerManager().onHIDData(event);
        }
        return KeyEventResult.skipRemainingHandlers;
      },
      child: NestedWillPopScope(
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
              VolumeDrawer(
                  expanded: openDrawer,
                  onChanged: () => setState(() {}),
                  onExpandChange: (val) => openDrawer = val)
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
          drawer: isPortrait
              ? null
              : SafeArea(
                  child: Drawer(
                      child: ListView(
                    padding: EdgeInsets.zero,
                    children: [const DrawerHeader(child: Text("Mightier Amp"))],
                  )),
                ),
          bottomNavigationBar: !isPortrait
              ? null
              : GestureDetector(
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
      ),
    );
  }
}
