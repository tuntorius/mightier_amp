// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mighty_plug_manager/UI/pages/DebugConsolePage.dart';
import 'package:mighty_plug_manager/UI/utils.dart';
import 'package:mighty_plug_manager/UI/widgets/app_drawer.dart';
import 'package:mighty_plug_manager/bluetooth/devices/presets/presetsStorage.dart';
import 'package:mighty_plug_manager/midi/MidiControllerManager.dart';
import 'package:mighty_plug_manager/platform/simpleSharedPrefs.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'UI/pages/drumEditor.dart';
import 'UI/pages/jamTracks.dart';
//pages
import 'UI/pages/presetEditor.dart';
import 'UI/pages/settings.dart';
import 'UI/popups/alertDialogs.dart';
import 'UI/theme.dart';
import 'UI/widgets/bottomBar.dart';
import 'UI/widgets/nestedWillPopScope.dart';
import 'UI/widgets/NuxAppBar.dart';
import 'UI/widgets/presets/presetList.dart';
import 'UI/widgets/VolumeDrawer.dart';
import 'bluetooth/NuxDeviceControl.dart';
import 'bluetooth/bleMidiHandler.dart';
//recreate this file with your own api keys
import 'configKeys.dart';

//able to create snackbars/messages everywhere
final navigatorKey = GlobalKey<NavigatorState>();
final bucketGlobal = PageStorageBucket();

void main() {
  //configuration data is needed before start of the app
  WidgetsFlutterBinding.ensureInitialized();
  SharedPrefs prefs = SharedPrefs();

  //capture flutter errors
  if (!kDebugMode) {
    FlutterError.onError = (FlutterErrorDetails details) {
      DebugConsole.print("Flutter error: ${details.toString()}");

      //update diagnostics with json preset
      NuxDeviceControl.instance()
          .updateDiagnosticsData(includeJsonPreset: true);

      // Send report
      Sentry.captureException(
        details,
        stackTrace: details.stack,
      );
    };
  }

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
      NuxDeviceControl.instance()
          .updateDiagnosticsData(includeJsonPreset: true);

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
  final MidiControllerManager midiMan = MidiControllerManager();

  MainTabs({Key? key}) : super(key: key);

  @override
  State<MainTabs> createState() => _MainTabsState();
}

class _MainTabsState extends State<MainTabs> with TickerProviderStateMixin {
  int _currentIndex = 0;
  late BuildContext dialogContext;
  late TabController controller;
  late final List<Widget> _tabs;

  bool isBottomDrawerOpen = false;

  bool connectionFailed = false;
  late Timer _timeout;
  StateSetter? dialogSetState;

  @override
  void initState() {
    if (!AppThemeConfig.allowRotation) {
      SystemChrome.setPreferredOrientations(
          [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight
      ]);
    }

    super.initState();

    //add 5 pages widgets
    _tabs = const [
      PresetEditor(),
      PresetList(),
      DrumEditor(),
      JamTracks(),
      Settings(),
    ];

    controller = TabController(initialIndex: 0, length: 5, vsync: this);

    controller.addListener(() {
      setState(() {
        _currentIndex = controller.index;
      });
    });

    NuxDeviceControl.instance()
        .connectStatus
        .stream
        .listen(connectionStateListener);
    NuxDeviceControl.instance().addListener(onDeviceChanged);

    BLEMidiHandler.instance().initBle(bleErrorHandler);
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
    NuxDeviceControl.instance().removeListener(onDeviceChanged);
  }

  void onConnectionTimeout() async {
    connectionFailed = true;
    if (dialogSetState != null) {
      dialogSetState?.call(() {});
      await Future.delayed(const Duration(seconds: 3));
      Navigator.pop(context);
      dialogSetState = null;
      BLEMidiHandler.instance().disconnectDevice();
    }
  }

  void connectionStateListener(DeviceConnectionState event) {
    switch (event) {
      case DeviceConnectionState.connectionBegin:
        if (dialogSetState != null) break;
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
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (!connectionFailed)
                            const CircularProgressIndicator(),
                          if (connectionFailed)
                            const Icon(
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
              },
            );
          },
        );

        //setup a timer in case something fails
        _timeout = Timer(const Duration(seconds: 10), onConnectionTimeout);

        break;
      case DeviceConnectionState.presetsLoaded:
        debugPrint("presets loaded");
        break;
      case DeviceConnectionState.connectionComplete:
        debugPrint("config loaded");
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
        BLEMidiHandler.instance().disconnectDevice();
      }
      confirmation.complete(val);
    });
    return confirmation.future;
  }

  void onDeviceChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final layoutMode = getLayoutMode(mediaQuery);
    final currentVolume = NuxDeviceControl.instance().masterVolume;

    //WARNING: Workaround for a flutter bug - if the app is started with screen off,
    //one of the widgets throwns an exception and the app scaffold is empty
    if (screenWidth < 10) return const SizedBox();
    return PageStorage(
      bucket: bucketGlobal,
      child: FocusScope(
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
            appBar: layoutMode != LayoutMode.navBar ? null : const NuxAppBar(),
            body: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Row(
                  children: [
                    if (layoutMode == LayoutMode.drawer)
                      AppDrawer(
                        onSwitchPageIndex: _onSwitchPageIndex,
                        currentIndex: _currentIndex,
                        totalTabs: _tabs.length,
                        currentVolume: currentVolume,
                        onVolumeChanged: _onVolumeChanged,
                        onVolumeDragEnd: _onVolumeDragEnd,
                      ),
                    Expanded(
                      child: layoutMode == LayoutMode.navBar
                          ? TabBarView(
                              physics: const NeverScrollableScrollPhysics(),
                              controller: controller,
                              children: _tabs,
                            )
                          : _tabs.elementAt(_currentIndex),
                    ),
                  ],
                ),
                if (layoutMode != LayoutMode.drawer)
                  BottomDrawer(
                    isBottomDrawerOpen: isBottomDrawerOpen,
                    onExpandChange: (val) => setState(() {
                      isBottomDrawerOpen = val;
                    }),
                    child: VolumeSlider(
                      currentVolume: currentVolume,
                      onVolumeChanged: _onVolumeChanged,
                      onVolumeDragEnd: _onVolumeDragEnd,
                    ),
                  ),
              ],
            ),
            bottomNavigationBar: layoutMode == LayoutMode.navBar
                ? GestureDetector(
                    onVerticalDragUpdate: _onBottomBarSwipe,
                    child: BottomBar(
                      index: _currentIndex,
                      onTap: _onSwitchPageIndex,
                    ),
                  )
                : null,
          ),
        ),
      ),
    );
  }

  void _onVolumeDragEnd(_) {
    SharedPrefs().setValue(
      SettingsKeys.masterVolume,
      NuxDeviceControl.instance().masterVolume,
    );
  }

  void _onVolumeChanged(value, bool skip) {
    setState(() {
      NuxDeviceControl.instance().masterVolume = value;
    });
  }

  void _onBottomBarSwipe(DragUpdateDetails details) {
    if (details.delta.dy < 0) {
      //open
      setState(() {
        isBottomDrawerOpen = true;
      });
    } else {
      //close
      setState(() {
        isBottomDrawerOpen = false;
      });
    }
  }

  void _onSwitchPageIndex(int index) {
    setState(() {
      _currentIndex = index;
      controller.animateTo(_currentIndex);
    });
  }
}
