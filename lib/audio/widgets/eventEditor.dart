import 'package:flutter/material.dart';
import 'package:mighty_plug_manager/UI/popups/selectPreset.dart';
import 'package:mighty_plug_manager/UI/widgets/thickSlider.dart';
import 'package:mighty_plug_manager/bluetooth/NuxDeviceControl.dart';
import 'package:mighty_plug_manager/bluetooth/devices/presets/Preset.dart';
import 'package:mighty_plug_manager/bluetooth/devices/presets/presetsStorage.dart';
import '../models/trackAutomation.dart';

class EventEditor {
  final AutomationEvent event;
  EventEditor({required this.event});

  List<Widget> createPresetTiles(
      context, dynamic preset, StateSetter setState) {
    var tiles = <Widget>[];
    Color color =
        preset != null ? Preset.channelColors[preset["channel"]] : Colors.white;
    var name =
        preset != null ? "${preset['category']}/${preset['name']}" : "None";
    var tile = ListTile(
      title: Text(
        name,
        style: TextStyle(color: color),
      ),
      trailing: Icon(Icons.keyboard_arrow_right),
      onTap: () {
        showDialog(
          context: context,
          builder: (BuildContext context) =>
              SelectPresetDialog().buildDialog(context, noneOption: false),
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
            var device = NuxDeviceControl().device;
            bool cab = device.cabinetSupport;
            var preset =
                PresetsStorage().findPresetByUuid(event.getPresetUuid());

            return SafeArea(
              child: AlertDialog(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    IconButton(
                        icon: Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                        ),
                        onPressed: () => Navigator.of(context).pop()),
                    Text("Edit Event", style: TextStyle(color: Colors.white)),
                  ],
                ),
                backgroundColor: Colors.grey[900],
                contentPadding:
                    EdgeInsets.only(left: 10, right: 10, bottom: 20, top: 30),
                content: ListTileTheme(
                  iconColor: Colors.white,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text("Preset",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold)),
                      ...createPresetTiles(context, preset, setState),
                      if (cab) Divider(),
                      if (cab)
                        CheckboxListTile(
                          title: Text("Cabinet level override"),
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
                          title: ThickSlider(
                            enabled: event.cabinetLevelOverrideEnable,
                            activeColor: Colors.blue,
                            min: -6,
                            max: 6,
                            value: event.cabinetLevelOverride,
                            onChanged: (value) {
                              event.cabinetLevelOverride = value;
                              setState(() {});
                            },
                            label: "Level",
                            labelFormatter: (value) {
                              return "${value.toStringAsFixed(1)} db";
                            },
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.replay_sharp),
                            onPressed: !event.cabinetLevelOverrideEnable
                                ? null
                                : () {
                                    if (preset != null)
                                      event.cabinetLevelOverride =
                                          preset["cabinet"]["level"];
                                    setState(() {});
                                  },
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
