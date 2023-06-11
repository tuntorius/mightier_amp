import 'package:flutter/material.dart';
import '../../../../bluetooth/devices/NuxDevice.dart';
import '../../../../bluetooth/devices/effects/Processor.dart';

class PresetEffectPreview extends StatelessWidget {
  final TextStyle? ampTextStyle;
  final Map<String, dynamic> preset;
  final NuxDevice device;

  const PresetEffectPreview(
      {super.key,
      this.ampTextStyle,
      required this.preset,
      required this.device});

  List<Widget> _buildEffectsPreview(
      Map<String, dynamic> preset, NuxDevice dev) {
    var widgets = <Widget>[];
    //int presetVersion = preset["version"] ?? 0;

    var pVersion = preset["version"] ?? 0;
    for (int i = 0; i < dev.processorList.length; i++) {
      ProcessorInfo pi = dev.processorList[i];
      if (preset.containsKey(pi.keyName)) {
        //special case for amp
        if (pi.keyName == "amp") {
          var name =
              dev.getAmpNameByNuxIndex(preset[pi.keyName]["fx_type"], pVersion);
          widgets.insert(
              0,
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Text(name, style: ampTextStyle),
              ));
        } else if (pi.keyName == "cabinet") {
          continue;
        } else {
          bool enabled = preset[pi.keyName]["enabled"];
          widgets.add(Icon(
            pi.icon,
            color: enabled ? pi.color : Colors.grey,
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
