// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'package:mighty_plug_manager/audio/trackdata/trackData.dart';
import 'package:mighty_plug_manager/bluetooth/devices/effects/Processor.dart';

import '../../../UI/popups/alertDialogs.dart';
import '../../../UI/popups/changeCategory.dart';
import '../../../bluetooth/NuxDeviceControl.dart';
import '../../../bluetooth/devices/NuxDevice.dart';
import 'package:tinycolor/tinycolor.dart';
import '../../../platform/fileSaver.dart';

import '../../../bluetooth/devices/presets/Preset.dart';
import '../../mightierIcons.dart';
import '../../theme.dart';
import '../dynamic_treeview.dart';
import 'package:flutter/material.dart';
import '../../../bluetooth/devices/presets/presetsStorage.dart';

class PresetList extends StatefulWidget {
  final void Function(dynamic) onTap;
  final bool simplified;
  final bool noneOption;
  final String? customProductId;
  PresetList(
      {required this.onTap,
      this.simplified = false,
      this.noneOption = false,
      this.customProductId});
  @override
  _PresetListState createState() => _PresetListState();
}

class _PresetListState extends State<PresetList>
    with AutomaticKeepAliveClientMixin<PresetList> {
  Map<String, NuxDevice> devices = <String, NuxDevice>{};
  var presetsMenu = <PopupMenuEntry>[
    PopupMenuItem(
      value: 1,
      child: Row(
        children: <Widget>[
          Icon(
            Icons.save_alt,
            color: AppThemeConfig.contextMenuIconColor,
          ),
          const SizedBox(width: 5),
          Text("Export"),
        ],
      ),
    ),
    PopupMenuItem(
      value: 2,
      child: Row(
        children: <Widget>[
          Icon(
            Icons.open_in_browser,
            color: AppThemeConfig.contextMenuIconColor,
          ),
          const SizedBox(width: 5),
          Text("Import"),
        ],
      ),
    )
  ];
  //menu for category
  var popupMenu = <PopupMenuEntry>[
    PopupMenuItem(
      value: 0,
      child: Row(
        children: <Widget>[
          Icon(
            Icons.delete,
            color: AppThemeConfig.contextMenuIconColor,
          ),
          const SizedBox(width: 5),
          Text("Delete"),
        ],
      ),
    ),
    PopupMenuItem(
      value: 1,
      child: Row(
        children: <Widget>[
          Icon(
            Icons.drive_file_rename_outline,
            color: AppThemeConfig.contextMenuIconColor,
          ),
          const SizedBox(width: 5),
          Text("Rename"),
        ],
      ),
    ),
    PopupMenuItem(
      value: 2,
      child: Row(
        children: <Widget>[
          Icon(
            Icons.save_alt,
            color: AppThemeConfig.contextMenuIconColor,
          ),
          const SizedBox(width: 5),
          Text("Export Category"),
        ],
      ),
    )
  ];

  //menu for preset
  var popupSubmenu = <PopupMenuEntry>[
    PopupMenuItem(
      value: 0,
      child: Row(
        children: <Widget>[
          Icon(
            Icons.delete,
            color: AppThemeConfig.contextMenuIconColor,
          ),
          const SizedBox(width: 5),
          Text("Delete"),
        ],
      ),
    ),
    PopupMenuItem(
      value: 2,
      child: Row(
        children: <Widget>[
          Icon(
            Icons.circle,
            color: AppThemeConfig.contextMenuIconColor,
          ),
          const SizedBox(width: 5),
          Text("Change Channel"),
        ],
      ),
    ),
    PopupMenuItem(
      value: 5,
      child: Row(
        children: <Widget>[
          Icon(
            MightierIcons.tag,
            color: AppThemeConfig.contextMenuIconColor,
          ),
          const SizedBox(width: 5),
          Text("Change Category"),
        ],
      ),
    ),
    PopupMenuItem(
      value: 1,
      child: Row(
        children: <Widget>[
          Icon(
            Icons.drive_file_rename_outline,
            color: AppThemeConfig.contextMenuIconColor,
          ),
          const SizedBox(width: 5),
          Text("Rename"),
        ],
      ),
    ),
    PopupMenuItem(
      value: 3,
      child: Row(
        children: <Widget>[
          Icon(
            Icons.copy,
            color: AppThemeConfig.contextMenuIconColor,
          ),
          const SizedBox(width: 5),
          Text("Duplicate"),
        ],
      ),
    ),
    PopupMenuItem(
      value: 4,
      child: Row(
        children: <Widget>[
          Icon(
            Icons.save_alt,
            color: AppThemeConfig.contextMenuIconColor,
          ),
          const SizedBox(width: 5),
          Text("Export Preset"),
        ],
      ),
    ),
  ];

  @override
  bool get wantKeepAlive => true;

  void mainMenuActions(action) async {
    switch (action) {
      case 1: //export category
        String? data = PresetsStorage().presetsToJson();

        if (data != null)
          saveFile("application/octet-stream", "presets.nuxpreset", data);
        break;
      case 2: //import
        openFile("application/octet-stream").then((value) {
          PresetsStorage().presetsFromJson(value).then((value) {
            setState(() {});
          }).catchError((error) {
            AlertDialogs.showInfoDialog(context,
                title: "Error",
                description: "The selected file is not a valid preset file!",
                confirmButton: "OK");
          });
        });
    }
  }

  void menuActions(action, item) async {
    {
      if (item is String) {
        //category
        switch (action) {
          case 0:
            AlertDialogs.showConfirmDialog(context,
                title: "Confirm",
                description: "Are you sure you want to delete category $item?",
                cancelButton: "Cancel",
                confirmButton: "Delete",
                confirmColor: Colors.red, onConfirm: (delete) {
              if (delete) {
                PresetsStorage()
                    .deleteCategory(item)
                    .then((List<String> uuids) {
                  TrackData().removeMultiplePresetsInstances(uuids);
                  setState(() {});
                });
              }
            });
            break;
          case 1:
            AlertDialogs.showInputDialog(context,
                title: "Rename",
                description: "Enter category name:",
                cancelButton: "Cancel",
                confirmButton: "Rename",
                value: item,
                validation: (String newName) {
                  return !PresetsStorage().getCategories().contains(newName);
                },
                validationErrorMessage: "Name already taken!",
                confirmColor: Colors.blue,
                onConfirm: (newName) {
                  PresetsStorage()
                      .renameCategory(item, newName)
                      .then((value) => setState(() {}));
                });
            break;
          case 2: //export category
            String? data = PresetsStorage().presetsToJson(item);

            if (data != null)
              saveFile("application/octet-stream", "$item.nuxpreset", data);
        }
      } else {
        //preset
        switch (action) {
          case 0:
            bool inUse = TrackData().isPresetInUse(item["uuid"]);
            String description =
                "Are you sure you want to delete ${item["name"]}?";
            if (inUse)
              description += "\n\nThe preset is used in one or more Jamtracks!";

            AlertDialogs.showConfirmDialog(context,
                title: "Confirm",
                description: description,
                cancelButton: "Cancel",
                confirmButton: "Delete",
                confirmColor: Colors.red, onConfirm: (delete) {
              if (delete) {
                if (item is Map) {
                  String uuid = item["uuid"];
                  TrackData().removePresetInstances(uuid);
                  PresetsStorage()
                      .deletePreset(item["category"], item["name"])
                      .then((value) => setState(() {}));
                }
              }
            });
            break;
          case 1:
            AlertDialogs.showInputDialog(context,
                title: "Rename",
                description: "Enter preset name:",
                cancelButton: "Cancel",
                confirmButton: "Rename",
                value: item["name"],
                validationErrorMessage: "Name already taken!",
                validation: (newName) {
                  return PresetsStorage()
                          .findPreset(newName, item["category"]) ==
                      null;
                },
                confirmColor: Colors.blue,
                onConfirm: (newName) {
                  PresetsStorage()
                      .renamePreset(item["category"], item["name"], newName)
                      .then((value) => setState(() {}));
                });
            break;
          case 2:
            var channelList = <String>[];
            int nuxChannel = item["channel"];
            var d = NuxDeviceControl().getDeviceFromId(item["product_id"]);

            if (d != null) {
              for (int i = 0; i < d.channelsCount; i++)
                channelList.add(d.channelName(i));
              var dialog = AlertDialogs.showOptionDialog(context,
                  confirmButton: "Change",
                  cancelButton: "Cancel",
                  title: "Select Channel",
                  confirmColor: Colors.blue,
                  options: channelList,
                  value: nuxChannel, onConfirm: (changed, newValue) {
                if (changed) {
                  setState(() {
                    PresetsStorage().changeChannel(
                        item["category"], item["name"], newValue);
                  });
                }
              });
              showDialog(
                context: context,
                builder: (BuildContext context) => dialog,
              );
            }
            break;
          case 3: //duplicate
            PresetsStorage()
                .duplicatePreset(item["category"], item["name"])
                .then((value) {
              setState(() {});
            });
            break;
          case 4: //export
            String? data =
                PresetsStorage().presetToJson(item["category"], item["name"]);

            if (data != null)
              saveFile("application/octet-stream", "${item["name"]}.nuxpreset",
                  data);
            break;
          case 5: //change category
            //TODO:
            var categoryDialog = ChangeCategoryDialog(
                category: item["category"],
                name: item["name"],
                confirmColor: Colors.blue,
                onCategoryChange: (newCategory) {
                  setState(() {
                    PresetsStorage().changePresetCategory(
                        item["category"], item["name"], newCategory);
                  });
                });
            showDialog(
              context: context,
              builder: (BuildContext context) =>
                  categoryDialog.buildDialog(context),
            );
            break;
        }
      }
    }
  }

  void showContextMenu(
      Offset _position, dynamic item, List<PopupMenuEntry> _menu) {
    final RenderBox? overlay =
        Overlay.of(context)!.context.findRenderObject() as RenderBox;
    //open menu
    if (overlay != null) {
      var rect = RelativeRect.fromRect(
          _position & const Size(40, 40), // smaller rect, the touch area
          Offset.zero & overlay.size);
      showMenu(
        position: rect,
        items: _menu,
        context: context,
      ).then((value) {
        menuActions(value, item);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    NuxDeviceControl().addListener(refreshPresets);
    PresetsStorage().addListener(refreshPresets);

    //cache devices
    NuxDeviceControl().deviceList.forEach((element) {
      devices[element.productStringId] = element;
    });
  }

  @override
  void dispose() {
    super.dispose();
    NuxDeviceControl().removeListener(refreshPresets);
    PresetsStorage().removeListener(refreshPresets);
  }

  void refreshPresets() {
    setState(() {});
  }

  List<Widget> buildEffectsPreview(Map<String, dynamic> preset) {
    var widgets = <Widget>[];
    NuxDevice? dev = devices[preset["product_id"]];
    int presetVersion = preset["version"] ?? 0;

    if (dev != null) {
      for (int i = 0; i < dev.processorList.length; i++) {
        ProcessorInfo pi = dev.processorList[i];
        if (preset.containsKey(pi.keyName)) {
          //special case for amp
          if (pi.keyName == "amp") {
            var name = dev.getAmpNameByIndex(preset[pi.keyName]["fx_type"]);
            widgets.insert(
                0,
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: Text(
                    name,
                    style: Theme.of(context).textTheme.bodyText1,
                  ),
                ));
          } else if (pi.keyName == "cabinet")
            continue;
          else {
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

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Column(
      children: [
        if (!widget.simplified)
          ListTile(
            contentPadding: EdgeInsets.only(left: 16, right: 12),
            title: Text("Presets"),
            trailing: PopupMenuButton(
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 12.0, right: 4, bottom: 10, top: 10),
                child: Icon(Icons.more_vert, color: Colors.grey),
              ),
              itemBuilder: (context) {
                return presetsMenu;
              },
              onSelected: (pos) {
                mainMenuActions(pos);
              },
            ),
          ),
        Expanded(
          child: _buildList(context),
        )
      ],
    );
  }

  Widget _buildList(BuildContext context) {
    if (PresetsStorage().getCategories().length == 0)
      return Center(
          child: Text("Empty", style: Theme.of(context).textTheme.bodyText1));
    late Offset _position;

    Widget out = GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTapDown: (details) {
        _position = details.globalPosition;
      },
      child: DynamicTreeView(
        simplified: widget.simplified,
        onCategoryTap: (val) {
          //print(val);
        },
        onCategoryLongPress: (val) {
          showContextMenu(_position, val, popupMenu);
        },
        itemBuilder: (context) {
          return popupMenu;
        },
        onSelected: (pos, item) {
          menuActions(pos, item);
        },
        categories: PresetsStorage().getCategories(),
        items: PresetsStorage().presetsData,
        childBuilder: (item) {
          var device = NuxDeviceControl().device;
          var pVersion = item["version"] ?? 0;
          var devVersion = device.productVersion;
          bool newItem = false;
          //check if enabled and desaturate color if needed

          bool enabled = true;
          if (widget.customProductId == null)
            enabled = item["product_id"] == device.productStringId;
          else
            enabled = item["product_id"] == widget.customProductId;

          Color color = Preset.channelColors[item["channel"]];
          if (!enabled) color = TinyColor(color).desaturate(90).color;
          bool selected = item["category"] == device.presetCategory &&
              item["name"] == device.presetName;

          //create trailing widget based on whether the preset is new
          Widget? trailingWidget;
          if (widget.simplified)
            trailingWidget = null;
          else {
            var button = PopupMenuButton(
              child: Padding(
                padding: const EdgeInsets.only(
                    left: 16.0, right: 0, bottom: 10, top: 10),
                child: Icon(Icons.more_vert, color: Colors.grey),
              ),
              itemBuilder: (context) {
                return popupSubmenu;
              },
              onSelected: (pos) {
                menuActions(pos, item);
              },
            );
            if (item.containsKey("new")) {
              newItem = true;
              trailingWidget = Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
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
            } else
              trailingWidget = button;
          }
          var out = ChildBuilderInfo();
          out.hasNewItems = newItem;
          out.widget = ListTile(
              enabled: enabled,
              selectedTileColor: Color.fromARGB(
                  255, 9, 51, 116), //Color.fromARGB(255, 45, 60, 68),
              selected: selected && !widget.simplified,
              onTap: () {
                //remove the new marker if exists
                if (!widget.simplified)
                  PresetsStorage().clearNewFlag(item["category"], item["name"]);
                widget.onTap(item);
                setState(() {});
              },
              onLongPress: () {
                if (!widget.simplified)
                  showContextMenu(_position, item, popupSubmenu);
              },
              minLeadingWidth: 0,
              leading: Container(
                height:
                    double.infinity, //strange hack to center icon vertically
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      NuxDeviceControl()
                          .getDeviceFromId(item["product_id"])!
                          .productIcon,
                      size: 30,
                      color: color,
                    ),
                    if (pVersion != devVersion)
                      Transform(
                        transform: Matrix4.translationValues(10, 10, 0),
                        child: Icon(
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
                      TextStyle(color: enabled ? Colors.white : Colors.grey)),
              subtitle: Row(
                children: buildEffectsPreview(item),
              ),
              trailing: trailingWidget);
          return out;
        },
        config: Config(
            parentTextStyle: TextStyle(color: Colors.white),
            parentPaddingEdgeInsets: EdgeInsets.only(left: 16, right: 16),
            childrenPaddingEdgeInsets: EdgeInsets.only(left: 0, right: 0),
            arrowIcon: Icon(Icons.keyboard_arrow_down, color: Colors.white)),
      ),
    );

    if (widget.noneOption) {
      out = Column(
        children: [
          ListTile(
            contentPadding: EdgeInsets.only(left: 16, right: 4),
            leading: Icon(
              Icons.close,
              color: Colors.white,
            ),
            title: Transform.translate(
                offset: Offset(-16, 0), child: Text("None")),
            onTap: () {
              widget.onTap(false);
            },
          ),
          out
        ],
      );
    }
    return out;
  }
}
