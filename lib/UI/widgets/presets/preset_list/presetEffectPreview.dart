// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'package:flutter/material.dart';
import '../../../../bluetooth/devices/NuxDevice.dart';
import '../../../../bluetooth/devices/effects/Processor.dart';

class PresetEffectPreview extends StatelessWidget {
  final Map<String, dynamic> preset;
  final NuxDevice device;
  final bool enabled;

  const PresetEffectPreview(
      {super.key,
      required this.preset,
      required this.device,
      required this.enabled});

  List<Widget> _buildEffectsPreview(
      BuildContext context, Map<String, dynamic> preset, NuxDevice dev) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    var widgets = <Widget>[];

    var pVersion = preset["version"] ?? 0;

    TextStyle ampStyle;
    if (enabled) {
      ampStyle = TextStyle(
          color: isDark
              ? const Color.fromARGB(255, 180, 180, 180)
              : const Color.fromARGB(255, 100, 100, 100),
          fontSize: 14);
    } else {
      ampStyle = TextStyle(
          color: isDark
              ? const Color.fromARGB(255, 100, 100, 100)
              : const Color.fromARGB(255, 160, 160, 160),
          fontSize: 14);
    }

    bool isNamPro = dev.presetClass == "mighty_nam_pro";

    // CRITICAL FIX: Extract the exact chain order from the saved JSON keys
    // instead of iterating over the static factory processorList.
    List<ProcessorInfo> dynamicChainOrder = [];
    for (String key in preset.keys) {
      var pi = dev.getProcessorInfoByKey(key);
      if (pi != null) {
        dynamicChainOrder.add(pi);
      }
    }

    for (ProcessorInfo pi in dynamicChainOrder) {
      Color color = pi.color;

      if (!enabled) color = color.withAlpha(128);

      if (preset.containsKey(pi.keyName)) {
        if (!isNamPro && pi.keyName == "amp") {
          var name =
              dev.getAmpNameByNuxIndex(preset[pi.keyName]["fx_type"], pVersion);
          widgets.insert(
              0,
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Text(name, style: ampStyle),
              ));
        } else if (!isNamPro && pi.keyName == "cabinet") {
          continue;
        } else {
          bool fxEnabled = preset[pi.keyName]["enabled"] ?? false;
          widgets.add(Icon(
            pi.icon,
            color: fxEnabled
                ? color
                : (isDark ? Colors.grey[700] : Colors.grey[400]),
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
      children: _buildEffectsPreview(context, preset, device),
    );
  }
}