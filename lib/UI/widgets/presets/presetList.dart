// (c) 2020 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

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
  void showContextMenu(_position, dynamic item) {
    final RenderBox overlay = Overlay.of(context).context.findRenderObject();
    //open menu
    var rect = RelativeRect.fromRect(
        _position & const Size(40, 40), // smaller rect, the touch area
        Offset.zero & overlay.size);
    showMenu(
      position: rect,
      items: <PopupMenuEntry>[
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
      ],
      context: context,
    ).then((value) {
      switch (value) {
        case 0:
          if (item is Map) {
            PresetsStorage()
                .deletePreset(item["category"], item["name"])
                .then((value) => setState(() {
                      //print("Deletion complete be masurqk takuv");
                    }));
          }
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (PresetsStorage().getCategories().length == 0)
      return Center(child: Text("No presets"));
    Offset _position;
    return GestureDetector(
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
