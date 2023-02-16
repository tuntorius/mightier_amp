// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

//import 'package:audio_picker/audio_picker.dart';
import 'package:flutter/material.dart';
import 'package:mighty_plug_manager/audio/setlistPage.dart';
import 'package:mighty_plug_manager/audio/setlistsPage.dart';
import 'package:mighty_plug_manager/audio/trackdata/trackData.dart';
import 'package:mighty_plug_manager/audio/tracksPage.dart';
import 'package:mighty_plug_manager/bluetooth/devices/presets/presetsStorage.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../audio/models/setlist.dart';
import '../../audio/setlist_player/setlistPlayerState.dart';
import '../../audio/widgets/jamtracksView.dart';
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

  @override
  void initState() {
    super.initState();
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
      child: ElevatedButton(
        child: const Text("Grant storage permission"),
        onPressed: () async {
          await Permission.storage.request();
          setState(() {});
        },
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
        future: Permission.storage.status,
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
