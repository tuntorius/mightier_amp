import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:mighty_plug_manager/bluetooth/devices/communication/plugProCommunication.dart';

import '../../UI/pages/device_specific_settings/PlugProSettings.dart';
import 'NuxMightyPlugPro.dart';
import 'effects/plug_pro/EQ.dart';
import 'features/looper.dart';
import 'features/tuner.dart';

class NuxMightySpaceConfiguration extends NuxPlugProConfiguration {
  EQTenBandSpeaker speakerEQ = EQTenBandSpeaker();
  int speakerEQGroup = 0;
}

class NuxMightySpace extends NuxMightyPlugPro implements Tuner, Looper {
  NuxMightySpace(super.devControl);

  final NuxMightySpaceConfiguration _config = NuxMightySpaceConfiguration();

  @override
  NuxMightySpaceConfiguration get config => _config;

  PlugProCommunication get _communication =>
      communication as PlugProCommunication;

  @override
  String get productName => "NUX Mighty Space";
  @override
  String get productNameShort => "Mighty Space";
  @override
  String get productStringId => "mighty_space";
  @override
  int get productVersion => version.index;
  @override
  String get productIconLabel => "MP-3|-|SPACE";
  @override
  List<String> get productBLENames => ["MIGHTY SPACE"];

  @override
  int get loopState => config.looperData.loopState;
  @override
  int get loopUndoState => config.looperData.loopUndoState;
  @override
  int get loopRecordMode => config.looperData.loopRecordMode;
  @override
  double get loopLevel => config.looperData.loopLevel;

  bool get speakerAvailable => versionDate.compareTo("20230101") > 0;

  final looperController = StreamController<LooperData>.broadcast();

  @override
  Widget getSettingsWidget() {
    return PlugProSettings(device: this, mightySpace: true);
  }

  @override
  Stream<LooperData> getLooperDataStream() {
    return looperController.stream;
  }

  void notifyLooperListeners() {
    looperController.add(config.looperData);
  }

  @override
  void looperClear() {
    _communication.looperClear();
  }

  @override
  void looperRecordPlay() {
    _communication.looperRecord();
  }

  @override
  void looperStop() {
    _communication.looperStop();
  }

  @override
  void looperUndoRedo() {
    _communication.looperUndoRedo();
  }

  @override
  void looperLevel(int vol) {
    config.looperData.loopLevel = vol.toDouble();
    _communication.looperVolume(vol);
  }

  @override
  void looperNrAr(bool auto) {
    config.looperData.loopRecordMode = auto ? 1 : 0;
    _communication.looperNrAr(auto);
  }

  @override
  void requestLooperSettings() {
    _communication.requestLooperSettings();
  }
}
