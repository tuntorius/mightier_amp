import 'package:flutter/material.dart';
import 'package:tinycolor2/tinycolor2.dart';

import '../../../bluetooth/NuxDeviceControl.dart';
import '../../../bluetooth/devices/NuxDevice.dart';
import '../../../bluetooth/devices/effects/Processor.dart';
import '../../../bluetooth/devices/presets/Preset.dart';
import '../../mightierIcons.dart';
import '../../theme.dart';

enum PresetItemActions {
  Delete,
  Rename,
  ChangeChannel,
  Duplicate,
  Export,
  ChangeCategory,
  ExportQR
}

class PresetItem extends StatelessWidget {
  final Map<String, dynamic> item;
  final String? customProductId;
  final NuxDevice device;
  final bool simplified;
  final TextStyle? ampTextStyle;
  final void Function()? onTap;
  final void Function(PresetItemActions, Map<String, dynamic>)? onPopupMenuTap;

  static final List<PopupMenuEntry> _popupSubmenu = <PopupMenuEntry>[
    PopupMenuItem(
      value: PresetItemActions.Delete,
      child: Row(
        children: <Widget>[
          Icon(
            Icons.delete,
            color: AppThemeConfig.contextMenuIconColor,
          ),
          const SizedBox(width: 5),
          const Text("Delete"),
        ],
      ),
    ),
    PopupMenuItem(
      value: PresetItemActions.ChangeChannel,
      child: Row(
        children: <Widget>[
          Icon(
            Icons.circle,
            color: AppThemeConfig.contextMenuIconColor,
          ),
          const SizedBox(width: 5),
          const Text("Change Channel"),
        ],
      ),
    ),
    PopupMenuItem(
      value: PresetItemActions.ChangeCategory,
      child: Row(
        children: <Widget>[
          Icon(
            MightierIcons.tag,
            color: AppThemeConfig.contextMenuIconColor,
          ),
          const SizedBox(width: 5),
          const Text("Change Category"),
        ],
      ),
    ),
    PopupMenuItem(
      value: PresetItemActions.Rename,
      child: Row(
        children: <Widget>[
          Icon(
            Icons.drive_file_rename_outline,
            color: AppThemeConfig.contextMenuIconColor,
          ),
          const SizedBox(width: 5),
          const Text("Rename"),
        ],
      ),
    ),
    PopupMenuItem(
      value: PresetItemActions.Duplicate,
      child: Row(
        children: <Widget>[
          Icon(
            Icons.copy,
            color: AppThemeConfig.contextMenuIconColor,
          ),
          const SizedBox(width: 5),
          const Text("Duplicate"),
        ],
      ),
    ),
    PopupMenuItem(
      value: PresetItemActions.ExportQR,
      child: Row(
        children: <Widget>[
          Icon(
            Icons.qr_code_2,
            color: AppThemeConfig.contextMenuIconColor,
          ),
          const SizedBox(width: 5),
          const Text("Export QR Code"),
        ],
      ),
    ),
    PopupMenuItem(
      value: PresetItemActions.Export,
      child: Row(
        children: <Widget>[
          Icon(
            Icons.save_alt,
            color: AppThemeConfig.contextMenuIconColor,
          ),
          const SizedBox(width: 5),
          const Text("Export Preset"),
        ],
      ),
    )
  ];

  const PresetItem(
      {Key? key,
      required this.item,
      this.customProductId,
      required this.device,
      required this.simplified,
      this.onTap,
      this.ampTextStyle,
      this.onPopupMenuTap})
      : super(key: key);

  List<Widget> _buildEffectsPreview(Map<String, dynamic> preset) {
    var widgets = <Widget>[];
    NuxDevice? dev =
        NuxDeviceControl.instance().getDeviceFromId(item["product_id"]);
    //int presetVersion = preset["version"] ?? 0;

    if (dev != null) {
      var pVersion = item["version"] ?? 0;
      for (int i = 0; i < dev.processorList.length; i++) {
        ProcessorInfo pi = dev.processorList[i];
        if (preset.containsKey(pi.keyName)) {
          //special case for amp
          if (pi.keyName == "amp") {
            var name =
                dev.getAmpNameByIndex(preset[pi.keyName]["fx_type"], pVersion);
            widgets.insert(
                0,
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Text(
                    name,
                    style: ampTextStyle,
                  ),
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
    }
    return widgets;
  }

  Widget? _createPresetTrailingWidget(Map<String, dynamic> item) {
    //create trailing widget based on whether the preset is new
    Widget? trailingWidget;
    if (simplified) {
      trailingWidget = null;
    } else {
      var button = PopupMenuButton(
        child: const Padding(
          padding: EdgeInsets.only(left: 16.0, right: 0, bottom: 10, top: 10),
          child: Icon(Icons.more_vert, color: Colors.grey),
        ),
        itemBuilder: (context) {
          return _popupSubmenu;
        },
        onSelected: (pos) {
          onPopupMenuTap?.call(pos as PresetItemActions, item);
        },
      );
      if (item.containsKey("new")) {
        trailingWidget = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.circle,
              color: Colors.blue,
              size: 16,
            ),
            const SizedBox(
              width: 12,
            ),
            button
          ],
        );
      } else {
        trailingWidget = button;
      }
    }

    return trailingWidget;
  }

  @override
  Widget build(BuildContext context) {
    var pVersion = item["version"] ?? 0;
    var devVersion = device.productVersion;
    bool enabled = true;
    if (customProductId == null) {
      enabled = item["product_id"] == device.productStringId;
    } else {
      enabled = item["product_id"] == customProductId;
    }

    bool selected = item["uuid"] == device.presetUUID;

    Color color = Preset.channelColors[item["channel"]];
    if (!enabled) color = TinyColor.fromColor(color).desaturate(90).color;

    int alpha = selected && !simplified ? 105 : 0;

    return ColoredBox(
      color: Color.fromARGB(alpha, 8, 102, 232),
      child: ListTile(
          enabled: enabled,
          minLeadingWidth: 0,
          contentPadding: const EdgeInsets.fromLTRB(0, 0, 16, 0),
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
                Text(
                  NuxDeviceControl.instance()
                      .getDeviceFromId(item["product_id"])!
                      .productIconLabel,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: color),
                ),
                if (enabled && pVersion != devVersion)
                  Transform(
                    transform: Matrix4.translationValues(10, 10, 0),
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
          subtitle: Opacity(
            opacity: enabled ? 1 : 0.5,
            child: Row(
              children: _buildEffectsPreview(item),
            ),
          ),
          trailing: _createPresetTrailingWidget(item),
          onTap: onTap),
    );
  }
}
