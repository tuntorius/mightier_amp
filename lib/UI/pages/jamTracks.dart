// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

//import 'package:audio_picker/audio_picker.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:mighty_plug_manager/audio/setlistPage.dart';
import 'package:mighty_plug_manager/audio/setlistsPage.dart';
import 'package:mighty_plug_manager/audio/trackdata/trackData.dart';
import 'package:mighty_plug_manager/audio/tracksPage.dart';
import 'package:mighty_plug_manager/platform/presetsStorage.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../audio/models/setlist.dart';
import '../../audio/setlist_player/setlistPlayerState.dart';
import '../../audio/widgets/jamtracksView.dart';
import '../../platform/platformUtils.dart';
import '../widgets/nestedWillPopScope.dart';

class JamTracks extends StatefulWidget {
  const JamTracks({Key? key}) : super(key: key);

  @override
  State createState() => _JamTracksState();
}

class _JamTracksState extends State<JamTracks>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin<JamTracks> {
  late TabController cntrl;
  Setlist? _setlist;
  bool _readOnlySetlist = false;
  final SetlistPlayerState playerState = SetlistPlayerState.instance();
  Permission? _mediaPermission;
  @override
  void initState() {
    super.initState();

    DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
    if (PlatformUtils.isAndroid) {
      deviceInfoPlugin.androidInfo.then((androidInfo) {
        int sdk = androidInfo.version.sdkInt;
        if (sdk < 33) {
          _mediaPermission = Permission.storage;
        } else {
          _mediaPermission = Permission.audio;
        }
        setState(() {});
      });
    } else {
      _mediaPermission = Permission.storage;
    }

    cntrl = TabController(length: 2, vsync: this);

    cntrl.addListener(() {
      if (cntrl.index == 0) setState(() {});
    });

    PresetsStorage().waitLoading().then((value) {
      TrackData().waitLoading().then((value) {
        if (mounted) setState(() {});
      });
    });

    playerState.addListener(onPlayerStateChange);
  }

  @override
  void dispose() {
    super.dispose();
    cntrl.dispose();
    playerState.removeListener(onPlayerStateChange);
  }

  void onPlayerStateChange() {
    setState(() {});
  }

  Widget showSetlists(bool hasTracks) {
    if (hasTracks) {
      return Setlists(
        onAllTracksSelect: () {
          _readOnlySetlist = true;
          _setlist = TrackData().allTracks;
          setState(() {});
        },
        onSetlistSelect: (setlist) {
          _readOnlySetlist = false;
          _setlist = setlist;
          setState(() {});
        },
      );
    }
    return Stack(
      children: [
        Setlists(),
        TextButton(
          child: const Center(child: Text("")),
          onPressed: () {
            cntrl.index = 1;
          },
        ),
      ],
    );
  }

  Widget mainView() {
    if (_setlist == null) {
      bool hasTracks = TrackData().tracks.isNotEmpty;
      return Column(
        children: [
          TabBar(
            tabs: const [Tab(text: "Setlists"), Tab(text: "Tracks")],
            controller: cntrl,
          ),
          Expanded(
            child: TabBarView(
              controller: cntrl,
              children: [
                showSetlists(hasTracks),
                const TracksPage(),
              ],
            ),
          ),
        ],
      );
    } else {
      return SetlistPage(
        setlist: _setlist!,
        readOnly: _readOnlySetlist,
        onBack: _setlist == null
            ? null
            : () {
                _setlist = null;
                setState(() {});
              },
      );
    }
  }

  Widget _permissionInfo() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
                textAlign: TextAlign.center,
                "To access your music files and play along to your favorite songs, the app requires permission to access your device's media library."),
            const SizedBox(
              height: 30,
            ),
            SizedBox(
              height: 60,
              child: ElevatedButton(
                child: const Text("Grant access to Media Library "),
                onPressed: () async {
                  Stopwatch stopwatch = Stopwatch()..start();
                  var status = await _mediaPermission!.request();
                  stopwatch.stop();

                  if (status == PermissionStatus.permanentlyDenied &&
                      stopwatch.elapsedMilliseconds < 500) {
                    await openAppSettings();
                  }
                  setState(() {});
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _jamtracksWidget() {
    return NestedWillPopScope(
        onWillPop: () {
          if (playerState.expanded) {
            playerState.toggleExpanded();
            return Future.value(false);
          }
          if (_setlist != null) {
            _setlist = null;
            setState(() {});
            return Future.value(false);
          }
          return Future.value(true);
        },
        child: JamtracksView(child: mainView()));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FutureBuilder<PermissionStatus>(
        future: _mediaPermission?.status,
        builder:
            (BuildContext context, AsyncSnapshot<PermissionStatus> snapshot) {
          if (snapshot.hasData) {
            switch (snapshot.data) {
              case PermissionStatus.denied:
                return _permissionInfo();
              case PermissionStatus.granted:
                return _jamtracksWidget();
              default:
                return const Text("Permission declined");
            }
          }
          return const Text("Unknown status");
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
