import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mighty_plug_manager/UI/pages/drumsPage.dart';
import 'package:mighty_plug_manager/UI/utils.dart';
import 'package:mighty_plug_manager/UI/widgets/NuxAppBar.dart';

import '../bluetooth/NuxDeviceControl.dart';
import '../bluetooth/bleMidiHandler.dart';
import '../bluetooth/ble_controllers/BLEController.dart';
import '../main.dart';
import '../midi/MidiControllerManager.dart';
import '../platform/platformUtils.dart';
import 'pages/jamTracks.dart';
import 'pages/presetEditor.dart';
import 'pages/settings.dart';
import 'popups/alertDialogs.dart';
import 'theme.dart';
import 'widgets/VolumeDrawer.dart';
import 'widgets/app_drawer.dart';
import 'widgets/bottomBar.dart';
import 'widgets/common/nestedWillPopScope.dart';
import 'widgets/presets/preset_list/presetList.dart';

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
      DrumsPage(),
      JamTracks(),
      Settings(),
    ];

    controller =
        TabController(initialIndex: 0, length: _tabs.length, vsync: this);

    controller.addListener(() {
      setState(() {
        _currentIndex = controller.index;
      });
    });

    NuxDeviceControl.instance().connectStatus.listen(connectionStateListener);
    NuxDeviceControl.instance().addListener(onDeviceChanged);

    BLEMidiHandler.instance().initBle(bleErrorHandler);
  }

  void bleErrorHandler(BleError error, dynamic data) {
    {
      switch (error) {
        case BleError.unavailable:
          if (!PlatformUtils.isIOS) {
            AlertDialogs.showInfoDialog(context,
                title: "Warning!",
                description: "Your device does not support bluetooth!",
                confirmButton: "OK");
          }
          break;
        case BleError.permissionDenied:
          AlertDialogs.showLocationPrompt(context, false, null);
          break;
        case BleError.locationServiceOff:
          AlertDialogs.showInfoDialog(context,
              title: "Location service is disabled!",
              description:
                  "Please, enable location service. It is required for Bluetooth connection to work.",
              confirmButton: "OK");
          break;
        case BleError.scanPermissionDenied:
          AlertDialogs.showInfoDialog(context,
              title: "Bluetooth permissions required!",
              description:
                  "Please, grant bluetooth scan and connect permissions. They are required for Mightier Amp to work.",
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
                            const CircularProgressIndicator.adaptive(),
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
        //if the device is connected in this step, then it's
        //just a reset, not connect
        if (NuxDeviceControl.instance().isConnectionComplete()) {
          dialogSetState = null;
          _timeout.cancel();
          Navigator.pop(context);
        }
        debugPrint("presets loaded");
        break;
      case DeviceConnectionState.connectionComplete:
        debugPrint("config loaded");
        dialogSetState = null;
        _timeout.cancel();
        Navigator.pop(context);
        break;
      case DeviceConnectionState.disconnected:
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

    //WARNING: Workaround for a flutter bug - if the app is started with screen off,
    //one of the widgets throws an exception and the app scaffold is empty
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
            resizeToAvoidBottomInset: false,
            appBar: layoutMode != LayoutMode.navBar ? null : const MAAppBar(),
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
                if (layoutMode != LayoutMode.drawer && _currentIndex != 3)
                  BottomDrawer(
                    isBottomDrawerOpen: isBottomDrawerOpen,
                    onExpandChange: (val) => setState(() {
                      isBottomDrawerOpen = val;
                    }),
                    child: VolumeSlider(),
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
