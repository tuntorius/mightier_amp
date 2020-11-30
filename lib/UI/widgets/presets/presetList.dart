// (c) 2020 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'package:mighty_plug_manager/UI/popups/alertDialogs.dart';

import '../../../bluetooth/devices/presets/Preset.dart';
import '../dynamic_treeview.dart';
import 'package:flutter/material.dart';
import '../../../bluetooth/devices/presets/presetsStorage.dart';

class PresetList extends StatefulWidget {
  final void Function(dynamic) onTap;
  PresetList({this.onTap});
  @override
  _PresetListState createState() => _PresetListState();
}

class _PresetListState extends State<PresetList> {
  var popupMenu = <PopupMenuEntry>[
    PopupMenuItem(
      value: 0,
      child: Row(
        children: <Widget>[
          Icon(Icons.delete),
          Text("Delete"),
        ],
      ),
    ),
    PopupMenuItem(
      value: 1,
      child: Row(
        children: <Widget>[
          Icon(Icons.drive_file_rename_outline),
          Text("Rename"),
        ],
      ),
    )
  ];

  void menuActions(action, item) {
    {
      if (item is String) {
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
                    .then((value) => setState(() {}));
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
                confirmColor: Colors.blue, onConfirm: (renamed, newName) {
              print("Renamed: $renamed, new name $newName");
              if (renamed) {
                if (!PresetsStorage().getCategories().contains(newName))
                  PresetsStorage()
                      .renameCategory(item, newName)
                      .then((value) => setState(() {}));
                else
                  AlertDialogs.showInfoDialog(context,
                      confirmButton: "OK",
                      title: "Warning",
                      description: "Category already exists!");
              }
            });
            break;
        }
      } else {
        switch (action) {
          case 0:
            AlertDialogs.showConfirmDialog(context,
                title: "Confirm",
                description: "Are you sure you want to delete ${item["name"]}?",
                cancelButton: "Cancel",
                confirmButton: "Delete",
                confirmColor: Colors.red, onConfirm: (delete) {
              if (delete) {
                if (item is Map) {
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
                confirmColor: Colors.blue, onConfirm: (renamed, newName) {
              print("Renamed: $renamed, new name $newName");
              if (renamed) {
                if (PresetsStorage().findPreset(newName, item["category"]) ==
                    null)
                  PresetsStorage()
                      .renamePreset(item["category"], item["name"], newName)
                      .then((value) => setState(() {}));
                else
                  AlertDialogs.showInfoDialog(context,
                      confirmButton: "OK",
                      title: "Warning",
                      description: "Preset already exists!");
              }
            });
            break;
        }
      }
    }
  }

  void showContextMenu(_position, dynamic item) {
    final RenderBox overlay = Overlay.of(context).context.findRenderObject();
    //open menu
    var rect = RelativeRect.fromRect(
        _position & const Size(40, 40), // smaller rect, the touch area
        Offset.zero & overlay.size);
    showMenu(
      position: rect,
      items: popupMenu,
      context: context,
    ).then((value) {
      menuActions(value, item);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (PresetsStorage().getCategories().length == 0)
      return Center(child: Text("No presets"));
    Offset _position;
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTapDown: (details) {
        _position = details.globalPosition;
      },
      child: DynamicTreeView(
        onCategoryTap: (val) {
          print(val);
        },
        onCategoryLongPress: (val) {
          showContextMenu(_position, val);
        },
        categories: PresetsStorage().getCategories(),
        items: PresetsStorage().presetsData,
        childBuilder: (item) {
          return ListTile(
            onTap: () {
              widget.onTap(item);
            },
            onLongPress: () {
              print("Long");
              showContextMenu(_position, item);
            },
            title: Text(
              item["name"],
              style: TextStyle(color: Colors.white),
            ),
            subtitle: Text(
              Channel.values[
                      Preset.nuxChannel(item["instrument"], item["channel"])]
                  .toString()
                  .split('.')[1],
              style: TextStyle(
                  color: Preset.channelColors[
                      Preset.nuxChannel(item["instrument"], item["channel"])]),
            ),
            trailing: PopupMenuButton(
              child: Icon(Icons.more_vert, color: Colors.grey),
              itemBuilder: (context) {
                return popupMenu;
              },
              onSelected: (pos) {
                menuActions(pos, item);
              },
            ),
          );
        },
        config: Config(
            parentTextStyle: TextStyle(color: Colors.white),
            parentPaddingEdgeInsets: EdgeInsets.only(left: 20),
            arrowIcon: Icon(Icons.keyboard_arrow_down, color: Colors.white)),
      ),
    );
  }
}
