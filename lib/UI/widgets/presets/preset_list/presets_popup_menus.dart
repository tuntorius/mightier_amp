import 'package:flutter/material.dart';

import '../../../mightierIcons.dart';
import '../../../theme.dart';

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

class PresetsPopupMenus {
  //mainMenu
  static final presetsMenu = <PopupMenuEntry>[
    const PopupMenuItem(
      value: PresetsTopMenuActions.ExportAll,
      child: Row(
        children: <Widget>[
          Icon(Icons.archive),
          SizedBox(width: 5),
          Text("Backup All"),
        ],
      ),
    ),
    const PopupMenuItem(
      value: PresetsTopMenuActions.Import,
      child: Row(
        children: <Widget>[
          Icon(Icons.unarchive),
          SizedBox(width: 5),
          Text("Restore"),
        ],
      ),
    ),
  ];

  //menu for category
  static final List<PopupMenuEntry> popupMenuCategory = <PopupMenuEntry>[
    const PopupMenuItem(
      value: CategoryMenuActions.Delete,
      child: Row(
        children: <Widget>[
          Icon(Icons.delete),
          SizedBox(width: 5),
          Text("Delete"),
        ],
      ),
    ),
    const PopupMenuItem(
      value: CategoryMenuActions.Rename,
      child: Row(
        children: <Widget>[
          Icon(Icons.drive_file_rename_outline),
          SizedBox(width: 5),
          Text("Rename"),
        ],
      ),
    ),
    const PopupMenuItem(
      value: CategoryMenuActions.Export,
      child: Row(
        children: <Widget>[
          Icon(Icons.archive),
          SizedBox(width: 5),
          Text("Backup Category"),
        ],
      ),
    )
  ];

  static final List<PopupMenuEntry> popupMenuPreset = <PopupMenuEntry>[
    const PopupMenuItem(
      value: PresetItemActions.Delete,
      child: Row(
        children: <Widget>[
          Icon(Icons.delete),
          SizedBox(width: 5),
          Text("Delete"),
        ],
      ),
    ),
    const PopupMenuItem(
      value: PresetItemActions.ChangeChannel,
      child: Row(
        children: <Widget>[
          Icon(Icons.circle),
          SizedBox(width: 5),
          Text("Change Channel"),
        ],
      ),
    ),
    const PopupMenuItem(
      value: PresetItemActions.ChangeCategory,
      child: Row(
        children: <Widget>[
          Icon(MightierIcons.tag),
          SizedBox(width: 5),
          Text("Change Category"),
        ],
      ),
    ),
    const PopupMenuItem(
      value: PresetItemActions.Rename,
      child: Row(
        children: <Widget>[
          Icon(Icons.drive_file_rename_outline),
          SizedBox(width: 5),
          Text("Rename"),
        ],
      ),
    ),
    const PopupMenuItem(
      value: PresetItemActions.Duplicate,
      child: Row(
        children: <Widget>[
          Icon(Icons.copy),
          SizedBox(width: 5),
          Text("Duplicate"),
        ],
      ),
    ),
    const PopupMenuItem(
      value: PresetItemActions.ExportQR,
      child: Row(
        children: <Widget>[
          Icon(Icons.qr_code_2),
          SizedBox(width: 5),
          Text("Share as QR Code"),
        ],
      ),
    ),
    const PopupMenuItem(
      value: PresetItemActions.Export,
      child: Row(
        children: <Widget>[
          Icon(Icons.archive),
          SizedBox(width: 5),
          Text("Backup Preset"),
        ],
      ),
    )
  ];
}