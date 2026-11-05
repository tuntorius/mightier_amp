import 'communication/communication.dart';
import 'communication/namProCommunication.dart';
import 'device_data/processors_list.dart';
import 'effects/Processor.dart';
import 'NuxMightyPlugPro.dart';
import '../NuxDeviceControl.dart';
import 'presets/NamProPreset.dart';

/// Device profile for the Mighty NAM custom firmware.
class NuxMightyNamPro extends NuxMightyPlugPro {
  late final NamProCommunication _communication =
      NamProCommunication(this, config);

  @override
  DeviceCommunication get communication => _communication;

  NuxMightyNamPro(NuxDeviceControl devControl) : super(devControl) {
    presets.clear();
    channelNames.clear();
    for (int i = 0; i < channelsCount; i++) {
      presets.add(NamProPreset(
          device: this, channel: i, channelName: (i + 1).toString()));
    }
    for (var preset in presets) {
      (preset as NamProPreset).setFirmwareVersion(version.index);
      channelNames.add("Channel ${preset.channelName}");
    }
  }

  @override
  String get productName => "NUX Mighty NAM";

  @override
  String get productNameShort => "Mighty NAM";

  @override
  String get productStringId => "mighty_nam_pro";

  @override
  int get effectsChainLength => 11;

  @override
  String get presetClass => "mighty_nam_pro";

  // CRITICAL FIX: The custom firmware has a rigid 11-block DSP topology.
  // We lock this so presetFromJson skips sending kSYX_MODULELINK, protecting the A2DP audio stream.
  @override
  bool get reorderableFXChain => false;

  @override
  List<String> get productBLENames => ["MIGHTY PLUG PRO", "MIGHTY NAM"];

  @override
  List<ProcessorInfo> get processorList => ProcessorsList.mightyNamProList;

  @override
  NamProPreset getCustomPreset(int channel) {
    var preset = NamProPreset(device: this, channel: channel, channelName: "");
    preset.setFirmwareVersion(productVersion);
    return preset;
  }
}