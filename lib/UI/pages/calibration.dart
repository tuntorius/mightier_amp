// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mighty_plug_manager/UI/widgets/common/nestedWillPopScope.dart';
import 'package:mighty_plug_manager/platform/simpleSharedPrefs.dart';
import '../../bluetooth/NuxDeviceControl.dart';
import '../../bluetooth/devices/presets/preset_constants.dart';

class Calibration extends StatefulWidget {
  const Calibration({Key? key}) : super(key: key);

  @override
  State createState() => _CalibrationState();
}

class _CalibrationState extends State<Calibration> {
  int delay = 0;
  late AudioPlayer player;
  int nuxMode = 0;
  bool toggled = false;
  Color presetColor = PresetConstants.channelColorsPlug[0];
  NuxDeviceControl devControl = NuxDeviceControl.instance();
  StreamSubscription? _playerSub;
  @override
  void initState() {
    super.initState();
    player = AudioPlayer();
    player.setAsset("assets/audio/calibration.wav");
    player.setLoopMode(LoopMode.one);
    player.play();
    _playerSub = player
        .createPositionStream(
            steps: 99999999,
            minPeriod: const Duration(milliseconds: 1),
            maxPeriod: const Duration(milliseconds: 100))
        .listen(onPositionUpdate);
    delay = SharedPrefs().getInt(SettingsKeys.latency, 0);
  }

  void onPositionUpdate(Duration pos) {
    int posMs = pos.inMilliseconds;
    if (posMs >= 500 + delay) {
      if (!toggled) {
        nuxMode++;
        if (nuxMode > 2) nuxMode = 0;
        devControl.changeDeviceChannel(nuxMode);

        setState(() {
          presetColor = PresetConstants.channelColorsPlug[nuxMode];
        });

        toggled = true;
      }
    } else {
      toggled = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return NestedWillPopScope(
      onWillPop: () async {
        await player.stop();
        _playerSub?.cancel();
        await player.dispose();

        //reset to prevent device losing sync
        NuxDeviceControl.instance().resetToChannelDefaults();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Latency Calibration"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Text(
                "Make sure the NUX device is connected in both Audio and App mode!",
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 20,
              ),
              const Text(
                "Adjust the slider so that the NUX light change and the audio clicks happen at the same time.",
                textAlign: TextAlign.center,
              ),
              // Text(
              //   "The app uses this value to apply extra latency to the commands sent to the device",
              //   textAlign: TextAlign.center,
              // ),
              Slider(
                value: delay.toDouble(),
                min: 0,
                max: 400,
                label: "$delay",
                divisions: 400,
                onChanged: (val) {
                  setState(() {
                    delay = val.round();
                  });
                },
                onChangeEnd: (val) {
                  SharedPrefs().setInt(SettingsKeys.latency, val.round());
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}
