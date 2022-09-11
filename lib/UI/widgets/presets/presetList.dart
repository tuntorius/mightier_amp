// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'package:flutter/material.dart';
import 'package:mighty_plug_manager/UI/popups/exportQRCode.dart';
import 'package:mighty_plug_manager/audio/trackdata/trackData.dart';
import 'package:mighty_plug_manager/bluetooth/devices/effects/Processor.dart';
import 'package:qr_utils/qr_utils.dart';
import 'package:tinycolor2/tinycolor2.dart';

import '../../../UI/popups/alertDialogs.dart';
import '../../../UI/popups/changeCategory.dart';
import '../../../bluetooth/NuxDeviceControl.dart';
import '../../../bluetooth/devices/NuxDevice.dart';
import '../../../bluetooth/devices/presets/Preset.dart';
import '../../../bluetooth/devices/presets/presetsStorage.dart';
import '../../../platform/fileSaver.dart';
import '../../mightierIcons.dart';
import '../../theme.dart';
import '../dynamic_treeview.dart';

enum PresetsTopMenuActions { ExportAll, Import }

enum CategoryMenuActions { Delete, Rename, Export }

enum PresetItemActions {
  Delete,
  Rename,
  ChangeChannel,
  Duplicate,
  Export,
  ChangeCategory,
  ExportQR
}

class PresetList extends StatefulWidget {
  final void Function(dynamic)? onTap;
  final bool simplified;
  final bool noneOption;
  final String? customProductId;
  const PresetList(
      {Key? key,
      this.onTap,
      this.simplified = false,
      this.noneOption = false,
      this.customProductId})
      : super(key: key);
  @override
  _PresetListState createState() => _PresetListState();
}

class _PresetListState extends State<PresetList>
    with AutomaticKeepAliveClientMixin<PresetList> {
  Map<String, NuxDevice> devices = <String, NuxDevice>{};

  var presetsMenu = <PopupMenuEntry>[
    PopupMenuItem(
      value: PresetsTopMenuActions.ExportAll,
      child: Row(
        children: <Widget>[
          Icon(
            Icons.save_alt,
            color: AppThemeConfig.contextMenuIconColor,
          ),
          const SizedBox(width: 5),
          const Text("Export All"),
        ],
      ),
    ),
    PopupMenuItem(
      value: PresetsTopMenuActions.Import,
      child: Row(
        children: <Widget>[
          Icon(
            Icons.open_in_browser,
            color: AppThemeConfig.contextMenuIconColor,
          ),
          const SizedBox(width: 5),
          const Text("Import"),
        ],
      ),
    ),
  ];

  //menu for category
  var popupMenu = <PopupMenuEntry>[
    PopupMenuItem(
      value: CategoryMenuActions.Delete,
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
      value: CategoryMenuActions.Rename,
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
      value: CategoryMenuActions.Rename,
      child: Row(
        children: <Widget>[
          Icon(
            Icons.save_alt,
            color: AppThemeConfig.contextMenuIconColor,
          ),
          const SizedBox(width: 5),
          const Text("Export Category"),
        ],
      ),
    )
  ];

  //menu for preset
  var popupSubmenu = <PopupMenuEntry>[
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

  @override
  bool get wantKeepAlive => true;

  void _deleteCategory(String category) {
    AlertDialogs.showConfirmDialog(context,
        title: "Confirm",
        description: "Are you sure you want to delete category $category?",
        cancelButton: "Cancel",
        confirmButton: "Delete",
        confirmColor: Colors.red, onConfirm: (delete) {
      if (delete) {
        PresetsStorage().deleteCategory(category).then((List<String> uuids) {
          TrackData().removeMultiplePresetsInstances(uuids);
          setState(() {});
        });
      }
    });
  }

  void _renameCategory(String category) {
    AlertDialogs.showInputDialog(context,
        title: "Rename",
        description: "Enter category name:",
        cancelButton: "Cancel",
        confirmButton: "Rename",
        value: category,
        validation: (String newName) {
          return !PresetsStorage().getCategories().contains(newName);
        },
        validationErrorMessage: "Name already taken!",
        confirmColor: Colors.blue,
        onConfirm: (newName) {
          PresetsStorage()
              .renameCategory(category, newName)
              .then((value) => setState(() {}));
        });
  }

  //if category is empty string it exports all categories
  void _exportCategory(String category) {
    String? data = PresetsStorage().presetsToJson(category);

    if (data != null) {
      saveFileString("application/octet-stream", "$category.nuxpreset", data);
    }
  }

  void _importPresets() {
    openFileString("application/octet-stream").then((value) {
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

  void _deletePreset(Map<String, String> preset) {
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
        PresetsStorage()
            .deletePreset(preset["category"]!, preset["name"]!)
            .then((value) => setState(() {}));
      }
    });
  }

  void _renamePreset(Map preset) {
    AlertDialogs.showInputDialog(context,
        title: "Rename",
        description: "Enter preset name:",
        cancelButton: "Cancel",
        confirmButton: "Rename",
        value: preset["name"],
        validationErrorMessage: "Name already taken!",
        validation: (newName) {
          return PresetsStorage().findPreset(newName, preset["category"]) ==
              null;
        },
        confirmColor: Colors.blue,
        onConfirm: (newName) {
          PresetsStorage()
              .renamePreset(preset["category"], preset["name"], newName)
              .then((value) => setState(() {}));
        });
  }

  void _changePresetChannel(Map preset) {
    var channelList = <String>[];
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
          confirmColor: Colors.blue,
          options: channelList,
          value: nuxChannel, onConfirm: (changed, newValue) {
        if (changed) {
          setState(() {
            PresetsStorage()
                .changeChannel(preset["category"], preset["name"], newValue);
          });
        }
      });
      showDialog(
        context: context,
        builder: (BuildContext context) => dialog,
      );
    }
  }

  void _duplicatePreset(Map preset) {
    PresetsStorage()
        .duplicatePreset(preset["category"], preset["name"])
        .then((value) {
      setState(() {});
    });
  }

  void _exportPreset(Map preset) {
    String? data =
        PresetsStorage().presetToJson(preset["category"], preset["name"]);

    if (data != null) {
      saveFileString(
          "application/octet-stream", "${preset["name"]}.nuxpreset", data);
    }
  }

  void _changePresetCategory(Map preset) {
    var categoryDialog = ChangeCategoryDialog(
        category: preset["category"],
        name: preset["name"],
        confirmColor: Colors.blue,
        onCategoryChange: (newCategory) {
          setState(() {
            PresetsStorage().changePresetCategory(
                preset["category"], preset["name"], newCategory);
          });
        });
    showDialog(
      context: context,
      builder: (BuildContext context) => categoryDialog.buildDialog(context),
    );
  }

  void _exportQR(Map preset) {
    var qr = NuxDeviceControl.instance().device.jsonToQR(preset);
    if (qr != null) {
      QrUtils.generateQR(qr).then((Image img) {
        var qrExport = QRExportDialog(img, preset["name"]);
        showDialog(
          context: context,
          builder: (BuildContext context) => qrExport.buildDialog(context),
        );
      });
    }
  }

  void mainMenuActions(action) {
    switch (action) {
      case PresetsTopMenuActions.ExportAll:
        _exportCategory("");
        break;
      case PresetsTopMenuActions.Import:
        _importPresets();
        break;
    }
  }

  void menuActions(action, item) async {
    {
      if (item is String) {
        //category
        switch (action) {
          case CategoryMenuActions.Delete:
            _deleteCategory(item);
            break;
          case CategoryMenuActions.Rename:
            _renameCategory(item);
            break;
          case CategoryMenuActions.Export:
            _exportCategory(item);
            break;
        }
      } else {
        //preset
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
            _exportPreset(item);
            break;
          case PresetItemActions.ChangeCategory:
            _changePresetCategory(item);
            break;
          case PresetItemActions.ExportQR:
            _exportQR(item);
            break;
        }
      }
    }
  }

  void showContextMenu(
      Offset _position, dynamic item, List<PopupMenuEntry> _menu) {
    final RenderBox? overlay =
        Overlay.of(context)?.context.findRenderObject() as RenderBox?;
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
    NuxDeviceControl.instance().addListener(refreshPresets);
    PresetsStorage().addListener(refreshPresets);

    //cache devices
    for (var element in NuxDeviceControl.instance().deviceList) {
      devices[element.productStringId] = element;
    }
  }

  @override
  void dispose() {
    super.dispose();
    NuxDeviceControl.instance().removeListener(refreshPresets);
    PresetsStorage().removeListener(refreshPresets);
  }

  void refreshPresets() {
    setState(() {});
  }

  List<Widget> buildEffectsPreview(Map<String, dynamic> preset) {
    var widgets = <Widget>[];
    NuxDevice? dev = devices[preset["product_id"]];
    //int presetVersion = preset["version"] ?? 0;

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

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return SafeArea(
      child: ListView(
        children: [
          if (!widget.simplified)
            ListTile(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              contentPadding: const EdgeInsets.only(left: 16, right: 12),
              title: const Text("Presets"),
              trailing: PopupMenuButton(
                child: const Padding(
                  padding: EdgeInsets.only(
                      left: 12.0, right: 4, bottom: 10, top: 10),
                  child: const Icon(Icons.more_vert, color: Colors.grey),
                ),
                itemBuilder: (context) {
                  return presetsMenu;
                },
                onSelected: (pos) {
                  mainMenuActions(pos);
                },
              ),
            ),
          _buildList(context)
        ],
      ),
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
          //this creates the presets
          var device = NuxDeviceControl.instance().device;
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
          int alpha = selected && !widget.simplified ? 105 : 0;
          out.widget = ColoredBox(
            color: Color.fromARGB(alpha, 8, 102, 232),
            child: ListTile(
                enabled: enabled,
                //this is buggy
                //selectedTileColor: Color.fromARGB(
                //    255, 9, 51, 116), //Color.fromARGB(255, 45, 60, 68),
                //selected: selected && !widget.simplified ? 255 : 0;,
                onTap: () {
                  //remove the new marker if exists
                  if (!widget.simplified)
                    PresetsStorage()
                        .clearNewFlag(item["category"], item["name"]);

                  if (widget.onTap != null)
                    widget.onTap!(item);
                  else {
                    var dev = NuxDeviceControl.instance().device;
                    if (dev.isPresetSupported(item)) {
                      NuxDeviceControl.instance()
                          .device
                          .presetFromJson(item, null);
                    }
                  }
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
                        NuxDeviceControl.instance()
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
                    style: TextStyle(
                        color: enabled ? Colors.white : Colors.grey[600])),
                subtitle: Opacity(
                  opacity: enabled ? 1 : 0.5,
                  child: Row(
                    children: buildEffectsPreview(item),
                  ),
                ),
                trailing: trailingWidget),
          );
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
              widget.onTap?.call(false);
            },
          ),
          out
        ],
      );
    }
    return out;
  }
}
