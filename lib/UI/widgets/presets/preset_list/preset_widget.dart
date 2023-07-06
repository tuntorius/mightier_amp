import 'package:flutter/material.dart';
import 'package:mighty_plug_manager/bluetooth/devices/NuxDevice.dart';

import '../../../../audio/trackdata/trackData.dart';
import '../../../../bluetooth/NuxDeviceControl.dart';
import '../../../../platform/presetsStorage.dart';
import '../../../popups/alertDialogs.dart';
import '../../../popups/changeCategory.dart';
import 'presetItem.dart';
import 'presetListMethods.dart';
import 'presets_popup_menus.dart';

class PresetWidget extends StatefulWidget {
  final bool simplified;
  final NuxDevice device;
  final bool hideNonApplicable;
  final Map<String, dynamic> preset;
  final void Function(dynamic)? onTap;

  const PresetWidget(
      {super.key,
      required this.simplified,
      required this.device,
      required this.hideNonApplicable,
      required this.preset,
      this.onTap});

  @override
  State<PresetWidget> createState() => _PresetWidgetState();
}

class _PresetWidgetState extends State<PresetWidget> {
  Widget _presetWidget(Map<String, dynamic> item, bool hideNonApplicable) {
    return PresetItem(
      device: widget.device,
      item: item,
      hideNotApplicable: hideNonApplicable,
      simplified: widget.simplified,
      onTap: () {
        //remove the new marker if exists
        if (!widget.simplified) {
          PresetsStorage().clearNewFlag(item);
        }

        if (widget.onTap != null) {
          widget.onTap!(item);
        } else {
          var dev = widget.device;
          if (dev.isPresetSupported(item)) {
            widget.device.presetFromJson(item, null);
          }
        }
        setState(() {});
      },
      onPopupMenuTap: (action, item) {
        switch (action) {
          case PresetItemActions.Delete:
            _deletePreset(item);
            break;
          case PresetItemActions.Rename:
            _renamePreset(item);
            break;
          case PresetItemActions.ChangeChannel:
            _changePresetChannel(item);
            break;
          case PresetItemActions.Duplicate:
            _duplicatePreset(item);
            break;
          case PresetItemActions.Export:
            PresetListMethods.exportPreset(item, context);
            break;
          case PresetItemActions.ChangeCategory:
            _changePresetCategory(item);
            break;
          case PresetItemActions.ExportQR:
            PresetListMethods.exportQR(item, context);
            break;
        }
      },
    );
  }

  void _deletePreset(Map<String, dynamic> preset) {
    bool inUse = TrackData().isPresetInUse(preset["uuid"]!);
    String description = "Are you sure you want to delete ${preset["name"]}?";
    if (inUse) {
      description += "\n\nThe preset is used in one or more Jamtracks!";
    }

    AlertDialogs.showConfirmDialog(context,
        title: "Confirm",
        description: description,
        cancelButton: "Cancel",
        confirmButton: "Delete",
        confirmColor: Colors.red, onConfirm: (delete) {
      if (delete) {
        String uuid = preset["uuid"] ?? "";
        TrackData().removePresetInstances(uuid);
        PresetsStorage().deletePreset(preset).then((value) => setState(() {}));
      }
    });
  }

  void _renamePreset(Map<String, dynamic> preset) {
    var category = PresetsStorage().findCategoryOfPreset(preset);
    if (category != null) {
      AlertDialogs.showInputDialog(context,
          title: "Rename",
          description: "Enter preset name:",
          cancelButton: "Cancel",
          confirmButton: "Rename",
          value: preset["name"],
          validationErrorMessage: "Name already taken!",
          validation: (newName) {
            return !PresetsStorage().presetExists(newName, category["name"]);
          },
          confirmColor: Theme.of(context).hintColor,
          onConfirm: (newName) {
            PresetsStorage()
                .renamePreset(preset, newName)
                .then((value) => setState(() {}));
          });
    }
  }

  void _changePresetChannel(Map<String, dynamic> preset) {
    List<String> channelList = [];
    int nuxChannel = preset["channel"];
    var d = NuxDeviceControl.instance().getDeviceFromId(preset["product_id"]);

    if (d != null) {
      for (int i = 0; i < d.channelsCount; i++) {
        channelList.add(d.channelName(i));
      }
      var dialog = AlertDialogs.showOptionDialog(context,
          confirmButton: "Change",
          cancelButton: "Cancel",
          title: "Select Channel",
          confirmColor: Theme.of(context).hintColor,
          options: channelList,
          value: nuxChannel, onConfirm: (changed, newValue) {
        if (changed) {
          setState(() {
            PresetsStorage().changeChannel(preset, newValue);
          });
        }
      });
      showDialog(
        context: context,
        builder: (BuildContext context) => dialog,
      );
    }
  }

  void _duplicatePreset(Map<String, dynamic> preset) {
    var category = PresetsStorage().findCategoryOfPreset(preset);
    if (category != null) {
      PresetsStorage()
          .duplicatePreset(category["name"], preset["name"])
          .then((value) {
        setState(() {});
      });
    }
  }

  void _changePresetCategory(Map<String, dynamic> preset) {
    var category = PresetsStorage().findCategoryOfPreset(preset);
    if (category != null) {
      var categoryDialog = ChangeCategoryDialog(
          category: category["name"],
          name: preset["name"],
          confirmColor: Theme.of(context).hintColor,
          onCategoryChange: (newCategory) {
            setState(() {
              PresetsStorage().changePresetCategory(
                  category["name"], preset["name"], newCategory);
            });
          });
      showDialog(
        context: context,
        builder: (BuildContext context) => categoryDialog.buildDialog(context),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return _presetWidget(widget.preset, widget.hideNonApplicable);
  }
}
