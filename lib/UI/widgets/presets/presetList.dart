import 'package:drag_and_drop_lists/drag_and_drop_lists.dart';
import 'package:flutter/material.dart';
import 'package:qr_utils/qr_utils.dart';

import '../../../audio/trackdata/trackData.dart';
import '../../../bluetooth/NuxDeviceControl.dart';
import '../../../bluetooth/devices/NuxDevice.dart';
import '../../../bluetooth/devices/presets/presetsStorage.dart';
import '../../../platform/fileSaver.dart';
import '../../popups/alertDialogs.dart';
import '../../popups/changeCategory.dart';
import '../../popups/exportQRCode.dart';
import '../../theme.dart';
import 'presetItem.dart';

enum PresetsTopMenuActions { ExportAll, Import }

enum CategoryMenuActions { Delete, Rename, Export }

class PresetList extends StatefulWidget {
  final void Function(dynamic)? onTap;
  final bool simplified;
  final bool noneOption;
  final String? customProductId;

  const PresetList(
      {Key? key,
      this.onTap,
      this.simplified = false,
      this.customProductId,
      this.noneOption = false})
      : super(key: key);

  @override
  State<PresetList> createState() => _PresetListState();
}

class _PresetListState extends State<PresetList>
    with AutomaticKeepAliveClientMixin<PresetList> {
  //main menu
  static final presetsMenu = <PopupMenuEntry>[
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
  static final List<PopupMenuEntry> _popupMenu = <PopupMenuEntry>[
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
            Icons.save_alt,
            color: AppThemeConfig.contextMenuIconColor,
          ),
          const SizedBox(width: 5),
          const Text("Export Category"),
        ],
      ),
    )
  ];

  NuxDevice get device => NuxDeviceControl.instance().device;
  List<dynamic> get _lists => PresetsStorage().presetsData;
  Map<String, NuxDevice> devices = <String, NuxDevice>{};

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

  @override
  Widget build(BuildContext context) {
    super.build(context);

    List<DragAndDropListExpansion> list =
        List.generate(_lists.length, (index) => _buildList(index));

    var presetsList = DragAndDropLists(
        key: const PageStorageKey<String>("presets"),
        children: list,
        contentsWhenEmpty: const SizedBox(
          height: 50,
          child: Center(
            child: Text("Empty"),
          ),
        ),
        onItemReorder: _onItemReorder,
        onListReorder: _onListReorder,
        // listGhost is mandatory when using expansion tiles to prevent multiple widgets using the same globalkey
        listGhost: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Center(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 100.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(7.0),
              ),
              child: const Icon(Icons.add_box),
            ),
          ),
        ));

    if (widget.simplified) return presetsList;
    return SafeArea(
      child: ListView(
        children: [
          ListTile(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            contentPadding: const EdgeInsets.only(left: 16, right: 12),
            title: const Text("Presets"),
            trailing: PopupMenuButton(
              child: const Padding(
                padding:
                    EdgeInsets.only(left: 12.0, right: 4, bottom: 10, top: 10),
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
          presetsList
        ],
      ),
    );
  }

  void _categoryMenu(CategoryMenuActions action, String item) {
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
  }

  _buildList(int outerIndex) {
    Map category = _lists[outerIndex];
    List presets = category["presets"];
    return DragAndDropListExpansion(
      title: Text(category["name"]),
      titleColor: Colors.grey[700],
      titleColorExpanded: Colors.grey[600],
      itemsBackgroundColor: Colors.grey[900]!,
      trailing: widget.simplified
          ? null
          : PopupMenuButton(
              child: const Padding(
                padding:
                    EdgeInsets.only(left: 16.0, right: 0, bottom: 10, top: 10),
                child: Icon(Icons.more_vert, color: Colors.grey),
              ),
              itemBuilder: (context) {
                return _popupMenu;
              },
              onSelected: (pos) {
                _categoryMenu(pos as CategoryMenuActions, category["name"]);
              },
            ),
      children: List.generate(
          presets.length, (index) => _buildPresetItem(presets[index])),
      listKey: ObjectKey(category),
    );
  }

  Widget _presetWidget(Map<String, dynamic> item) {
    return PresetItem(
      device: device,
      item: item,
      ampTextStyle: Theme.of(context).textTheme.bodyText1,
      simplified: widget.simplified,
      customProductId: widget.customProductId,
      onTap: () {
        //remove the new marker if exists
        if (!widget.simplified) {
          PresetsStorage().clearNewFlag(item["category"], item["name"]);
        }

        if (widget.onTap != null) {
          widget.onTap!(item);
        } else {
          var dev = device;
          if (dev.isPresetSupported(item)) {
            device.presetFromJson(item, null);
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
            _exportPreset(item);
            break;
          case PresetItemActions.ChangeCategory:
            _changePresetCategory(item);
            break;
          case PresetItemActions.ExportQR:
            _exportQR(item);
            break;
        }
      },
    );
  }

  _buildPresetItem(Map<String, dynamic> item) {
    return DragAndDropItem(
      feedbackWidget: ListTile(
        tileColor: const Color.fromARGB(127, 127, 127, 127),
        title: Text(item["name"]),
      ),
      child: _presetWidget(item),
    );
  }

  _onItemReorder(
      int oldItemIndex, int oldListIndex, int newItemIndex, int newListIndex) {
    if (PresetsStorage().reorderPresets(
        oldItemIndex, oldListIndex, newItemIndex, newListIndex)) {
      setState(() {});
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          backgroundColor: Colors.deepOrange,
          content: Text(
            "Destination category contains preset with the same name!",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 20),
          )));
    }
  }

  _onListReorder(int oldListIndex, int newListIndex) {
    setState(() {
      PresetsStorage().reorderCategories(oldListIndex, newListIndex);
    });
  }

  @override
  bool get wantKeepAlive => true;

  ///Actions
  ///
  ///
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
        confirmColor: Theme.of(context).hintColor,
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
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          backgroundColor: Colors.deepOrange,
          content: Text(
            "Cannot export empty category!",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 20),
          )));
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

  void _deletePreset(Map preset) {
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
          return !PresetsStorage().presetExists(newName, preset["category"]);
        },
        confirmColor: Theme.of(context).hintColor,
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
          confirmColor: Theme.of(context).hintColor,
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
        confirmColor: Theme.of(context).hintColor,
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
    var dev = NuxDeviceControl.instance().getDeviceFromId(preset["product_id"]);
    var pVersion = preset["version"] ?? 0;
    if (dev != null) {
      int? originalVersion;
      if (dev.productVersion != pVersion) {
        originalVersion = dev.productVersion;
        dev.setFirmwareVersionByIndex(pVersion);
      }
      var qr = dev.jsonToQR(preset);
      if (qr != null) {
        QrUtils.generateQR(qr).then((Image img) {
          var qrExport = QRExportDialog(img, preset["name"], dev);
          showDialog(
            context: context,
            builder: (BuildContext context) => qrExport.buildDialog(context),
          ).then((value) {
            if (originalVersion != null) {
              dev.setFirmwareVersionByIndex(originalVersion);
            }
          });
        });
      }
    }
  }
}
