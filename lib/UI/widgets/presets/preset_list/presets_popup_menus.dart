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
    PopupMenuItem(
      value: PresetsTopMenuActions.ExportAll,
      child: Row(
        children: <Widget>[
          Icon(
            Icons.archive,
            color: AppThemeConfig.contextMenuIconColor,
          ),
          const SizedBox(width: 5),
          const Text("Backup All"),
        ],
      ),
    ),
    PopupMenuItem(
      value: PresetsTopMenuActions.Import,
      child: Row(
        children: <Widget>[
          Icon(
            Icons.unarchive,
            color: AppThemeConfig.contextMenuIconColor,
          ),
          const SizedBox(width: 5),
          const Text("Restore"),
        ],
      ),
    ),
  ];

  //menu for category
  static final List<PopupMenuEntry> popupMenuCategory = <PopupMenuEntry>[
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
      value: CategoryMenuActions.Export,
      child: Row(
        children: <Widget>[
          Icon(
            Icons.archive,
            color: AppThemeConfig.contextMenuIconColor,
          ),
          const SizedBox(width: 5),
          const Text("Backup Category"),
        ],
      ),
    )
  ];

  static final List<PopupMenuEntry> popupMenuPreset = <PopupMenuEntry>[
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
          const Text("Share as QR Code"),
        ],
      ),
    ),
    PopupMenuItem(
      value: PresetItemActions.Export,
      child: Row(
        children: <Widget>[
          Icon(
            Icons.archive,
            color: AppThemeConfig.contextMenuIconColor,
          ),
          const SizedBox(width: 5),
          const Text("Backup Preset"),
        ],
      ),
    )
  ];
}
