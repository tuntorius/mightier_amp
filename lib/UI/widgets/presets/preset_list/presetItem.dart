import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mighty_plug_manager/UI/widgets/presets/preset_list/presetEffectPreview.dart';
import 'package:tinycolor2/tinycolor2.dart';
import '/bluetooth/NuxDeviceControl.dart';
import '/bluetooth/devices/NuxDevice.dart';
import '/UI/toneshare/share_preset.dart';
import 'presets_popup_menus.dart';

class PresetItem extends StatelessWidget {
  final Map<String, dynamic> item;
  final NuxDevice device;
  final bool simplified;
  final bool hideNotApplicable;
  final void Function()? onTap;
  final void Function(PresetItemActions, Map<String, dynamic>)? onPopupMenuTap;

  const PresetItem(
      {Key? key,
      required this.item,
      required this.device,
      required this.simplified,
      this.onTap,
      this.onPopupMenuTap,
      required this.hideNotApplicable})
      : super(key: key);

  Widget? _createPresetTrailingWidget(
      Map<String, dynamic> item, BuildContext context) {
    //create trailing widget based on whether the preset is new
    Widget? trailingWidget;
    late Widget pmb;
    if (!simplified) {
      pmb = PopupMenuButton(
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
          child: Icon(Icons.more_vert),
        ),
        itemBuilder: (context) {
          return PresetsPopupMenus.popupMenuPreset;
        },
        onSelected: (pos) {
          onPopupMenuTap?.call(pos as PresetItemActions, item);
        },
      );
    }

    if (simplified) {
      trailingWidget = null;
    } else if (kDebugMode && false) {
      trailingWidget = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => PresetForm()),
                );
              },
              icon: Icon(Icons.adaptive.share)),
          pmb
        ],
      );
    } else {
      trailingWidget = pmb;
    }

    return trailingWidget;
  }

  Widget _iconLabel(String label, Color color) {
    var items = label.split("|");
    List<Widget> widgets = [];
    for (var item in items) {
      if (item != '-') {
        widgets.add(Text(
          item,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: color),
        ));
      } else {
        widgets.add(SizedBox(
          width: 36,
          child: Divider(
            indent: 0,
            endIndent: 0,
            thickness: 2,
            height: 4,
            color: color,
          ),
        ));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: widgets,
    );
  }

  @override
  Widget build(BuildContext context) {
    var pVersion = item["version"] ?? 0;
    var devVersion = device.productVersion;
    bool enabled = true;
    enabled = item["product_id"] == device.presetClass;

    if (!enabled && hideNotApplicable) return const SizedBox.shrink();
    bool selected = item["uuid"] == device.deviceControl.presetUUID;
    bool newItem = item.containsKey("new");

    var dev = NuxDeviceControl.instance()
            .getDeviceFromPresetClass(item["product_id"]) ??
        device;
    Color color = dev.getPreset(0).channelColorsList[item["channel"]];

    if (!enabled) color = TinyColor.fromColor(color).desaturate(90).color;

    int alpha = selected && !simplified ? 105 : 0;

    return ColoredBox(
      color: Color.fromARGB(alpha, 8, 102, 232),
      child: ListTile(
          enabled: enabled,
          minLeadingWidth: 0,
          contentPadding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
          leading: Container(
            margin: const EdgeInsets.only(left: 4),
            decoration: BoxDecoration(
                border: Border.all(color: color, width: 1.5),
                borderRadius: const BorderRadius.all(Radius.circular(5))),
            width: 45,
            height: 45,
            child: Stack(
              alignment: Alignment.center,
              children: [
                FittedBox(
                  fit: BoxFit.fitWidth,
                  child: Padding(
                    padding: const EdgeInsets.all(3.0),
                    child: _iconLabel(dev.productIconLabel, color),
                  ),
                ),
                if (newItem)
                  Transform(
                    transform: Matrix4.translationValues(22, -20, 0),
                    child: const Icon(
                      Icons.circle,
                      color: Colors.blue,
                      size: 16,
                    ),
                  ),
                if (enabled && pVersion != devVersion)
                  Transform(
                    transform: Matrix4.translationValues(18, 15, 0),
                    child: const Icon(
                      Icons.warning,
                      color: Colors.amber,
                      size: 20,
                    ),
                  )
              ],
            ),
          ),
          title: Text(item["name"],
              style:
                  TextStyle(color: enabled ? Colors.white : Colors.grey[600])),
          subtitle:
              PresetEffectPreview(device: dev, preset: item, enabled: enabled),
          trailing: _createPresetTrailingWidget(item, context),
          onTap: onTap),
    );
  }
}
