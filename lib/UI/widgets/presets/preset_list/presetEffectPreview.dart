import 'package:flutter/material.dart';
import '../../../../bluetooth/devices/NuxDevice.dart';
import '../../../../bluetooth/devices/effects/Processor.dart';

class PresetEffectPreview extends StatelessWidget {
  final Map<String, dynamic> preset;
  final NuxDevice device;
  final bool enabled;

  static const TextStyle _ampActive =
      TextStyle(color: Color.fromARGB(255, 158, 158, 158), fontSize: 14);
  static const TextStyle _ampInactive =
      TextStyle(color: Color.fromARGB(255, 90, 90, 90), fontSize: 14);
  const PresetEffectPreview(
      {super.key,
      required this.preset,
      required this.device,
      required this.enabled});

  List<Widget> _buildEffectsPreview(
      Map<String, dynamic> preset, NuxDevice dev) {
    var widgets = <Widget>[];
    //int presetVersion = preset["version"] ?? 0;

    var pVersion = preset["version"] ?? 0;
    for (int i = 0; i < dev.processorList.length; i++) {
      ProcessorInfo pi = dev.processorList[i];

      Color color = pi.color;

      if (!enabled) color = color.withAlpha(128);
      var textStyle = enabled ? _ampActive : _ampInactive;

      if (preset.containsKey(pi.keyName)) {
        //special case for amp
        if (pi.keyName == "amp") {
          var name =
              dev.getAmpNameByNuxIndex(preset[pi.keyName]["fx_type"], pVersion);
          widgets.insert(
              0,
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Text(name, style: textStyle),
              ));
        } else if (pi.keyName == "cabinet") {
          continue;
        } else {
          bool fxEnabled = preset[pi.keyName]["enabled"];
          widgets.add(Icon(
            pi.icon,
            color: fxEnabled ? color : Colors.grey,
            size: 16,
          ));
        }
      }
    }
    return widgets;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: _buildEffectsPreview(preset, device),
    );
  }
}
