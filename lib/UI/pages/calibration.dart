// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mighty_plug_manager/platform/simpleSharedPrefs.dart';
import '../../bluetooth/NuxDeviceControl.dart';
import '../../bluetooth/devices/presets/Preset.dart';

class Calibration extends StatefulWidget {
  @override
  _CalibrationState createState() => _CalibrationState();
}

class _CalibrationState extends State<Calibration> {
  int delay = 0;
  AudioPlayer player;
  int nuxMode = 0;
  bool toggled = false;
  Color presetColor = Preset.channelColors[0];
  NuxDeviceControl devControl = NuxDeviceControl();

  @override
  void initState() {
    super.initState();
    player = AudioPlayer();
    player.setAsset("assets/audio/calibration.wav");
    player.setLoopMode(LoopMode.one);
    player.play();
    player
        .createPositionStream(
            steps: 99999999,
            minPeriod: Duration(milliseconds: 1),
            maxPeriod: Duration(milliseconds: 100))
        .listen(onPositionUpdate);
    delay = SharedPrefs().getInt(SettingsKeys.latency, 0);
  }

  void onPositionUpdate(Duration pos) {
    int posMs = pos.inMilliseconds;
    if (posMs >= 500 + delay) {
      if (!toggled) {
        nuxMode++;
        if (nuxMode > 3) nuxMode = 0;
        devControl.changeDevicePreset(nuxMode);

        setState(() {
          presetColor = Preset.channelColors[nuxMode];
        });

        toggled = true;
      }
    } else {
      toggled = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await player.stop();
        await player.dispose();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text("Latency Calibration"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Make sure the NUX device is connected in both Audio and App mode!",
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 20,
              ),
              Text(
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
