import 'package:flutter/material.dart';
import 'package:mighty_plug_manager/UI/popups/selectPreset.dart';
import 'package:mighty_plug_manager/UI/widgets/thickSlider.dart';
import 'package:mighty_plug_manager/bluetooth/NuxDeviceControl.dart';
import 'package:mighty_plug_manager/bluetooth/devices/presets/preset_constants.dart';
import 'package:mighty_plug_manager/platform/presetsStorage.dart';
import '../models/trackAutomation.dart';

class EventEditor {
  final AutomationEvent event;
  final bool noneOption;
  EventEditor({required this.event, required this.noneOption});

  List<Widget> createPresetTiles(
      context, dynamic preset, StateSetter setState) {
    var tiles = <Widget>[];

    Color color = preset != null
        ? PresetConstants.channelColorsPlug[preset["channel"]]
        : Colors.white;
    String category = preset != null
        ? PresetsStorage().findCategoryOfPreset(preset)!["name"]
        : "";
    String name = preset != null ? "$category/${preset['name']}" : "None";
    var tile = ListTile(
      title: Text(
        name,
        style: TextStyle(color: color),
      ),
      trailing: const Icon(Icons.keyboard_arrow_right),
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) =>
              SelectPresetDialog().buildDialog(context, noneOption: noneOption),
        ).then((value) {
          if (value == false) {
            event.setPresetUuid("");
          } else if (value != null) {
            event.setPresetUuid(value['uuid']);
          }
          setState(() {});
        });
      },
    );
    tiles.add(tile);
    return tiles;
  }

  Future buildDialog(BuildContext context) {
    return showGeneralDialog(
      context: context,
      barrierDismissible:
          true, // should dialog be dismissed when tapped outside
      barrierLabel: "Dialog", // label for barrier
      pageBuilder: (_, __, ___) {
        // your widget implementation
        return StatefulBuilder(
          builder: (context, setState) {
            var device = NuxDeviceControl.instance().device;
            bool cab = device.cabinetSupport;
            var preset =
                PresetsStorage().findPresetByUuid(event.getPresetUuid());

            return AlertDialog(
              title: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  IconButton(
                      icon: Icon(
                        Icons.adaptive.arrow_back,
                        color: Colors.white,
                      ),
                      onPressed: () => Navigator.of(context).pop()),
                  const Text("Edit Event",
                      style: TextStyle(color: Colors.white)),
                ],
              ),
              contentPadding: const EdgeInsets.only(
                  left: 10, right: 10, bottom: 20, top: 30),
              content: ListTileTheme(
                iconColor: Colors.white,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("Preset",
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold)),
                    ...createPresetTiles(context, preset, setState),
                    if (cab) const Divider(),
                    if (cab)
                      CheckboxListTile(
                        title: const Text("Cabinet level override"),
                        value: event.cabinetLevelOverrideEnable,
                        onChanged: (val) {
                          if (val == null) return;
                          event.cabinetLevelOverrideEnable = val;
                          setState(() {});
                        },
                      ),
                    if (cab)
                      ListTile(
                        enabled: event.cabinetLevelOverrideEnable,
                        title: SizedBox(
                          height: 50,
                          width: 1,
                          child: ThickSlider(
                            enabled: event.cabinetLevelOverrideEnable,
                            activeColor: Colors.blue,
                            min: device.decibelFormatter?.min.toDouble() ?? -6,
                            max: device.decibelFormatter?.max.toDouble() ?? 6,
                            value: event.cabinetLevelOverride,
                            onChanged: (value, skip) {
                              event.cabinetLevelOverride = value;
                              setState(() {});
                            },
                            label: "Level",
                            labelFormatter: (value) {
                              return "${value.toStringAsFixed(1)} db";
                            },
                          ),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.replay_sharp),
                          onPressed: !event.cabinetLevelOverrideEnable
                              ? null
                              : () {
                                  if (preset != null) {
                                    event.cabinetLevelOverride =
                                        preset["cabinet"]["level"];
                                  } else {
                                    event.cabinetLevelOverride = 0;
                                  }
                                  setState(() {});
                                },
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
