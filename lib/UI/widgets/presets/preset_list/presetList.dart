import 'package:drag_and_drop_lists/drag_and_drop_list_interface.dart';
import 'package:drag_and_drop_lists/drag_and_drop_lists.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mighty_plug_manager/UI/toneshare/toneshare_main.dart';
import 'package:mighty_plug_manager/platform/simpleSharedPrefs.dart';

import '/audio/setlist_player/setlistPlayerState.dart';
import '/audio/trackdata/trackData.dart';
import '/bluetooth/NuxDeviceControl.dart';
import '/bluetooth/devices/NuxDevice.dart';
import '/platform/presetsStorage.dart';
import '/platform/fileSaver.dart';
import '/platform/platformUtils.dart';
import '/UI/popups/alertDialogs.dart';
import '/UI/popups/changeCategory.dart';
import '/UI/theme.dart';
import 'presetItem.dart';
import '../trackEventsBlockInfo.dart';
import 'presetListMethods.dart';

enum PresetsTopMenuActions { ExportAll, Import }

enum CategoryMenuActions { Delete, Rename, Export }

class PresetList extends StatefulWidget {
  final void Function(dynamic)? onTap;
  final bool simplified;
  final bool noneOption;

  const PresetList(
      {Key? key, this.onTap, this.simplified = false, this.noneOption = false})
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
            Icons.archive,
            color: AppThemeConfig.contextMenuIconColor,
          ),
          const SizedBox(width: 5),
          const Text("Backup Category"),
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
    NuxDeviceControl.instance().presetNameNotifier.addListener(refreshPresets);
    if (!widget.simplified) {
      SetlistPlayerState.instance().addListener(refreshPresets);
    }
  }

  @override
  void dispose() {
    super.dispose();
    NuxDeviceControl.instance().removeListener(refreshPresets);
    PresetsStorage().removeListener(refreshPresets);
    NuxDeviceControl.instance()
        .presetNameNotifier
        .removeListener(refreshPresets);
    if (!widget.simplified) {
      SetlistPlayerState.instance().removeListener(refreshPresets);
    }
  }

  void refreshPresets() {
    setState(() {});
  }

  void _openToneShare() {
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (context) => const ToneShare()));
  }

  Widget _mainPopupMenu() {
    return PopupMenuButton(
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
        child: Icon(Icons.more_vert),
      ),
      itemBuilder: (context) {
        return presetsMenu;
      },
      onSelected: (pos) {
        mainMenuActions(pos);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    bool hideNonApplicable =
        SharedPrefs().getInt(SettingsKeys.hideNotApplicablePresets, 0) == 1;
    List<DragAndDropListInterface> list = List.generate(
        _lists.length, (index) => _buildList(index, hideNonApplicable));

    var header = widget.simplified
        ? null
        : ListTile(
            // shape: RoundedRectangleBorder(
            //     borderRadius: BorderRadius.circular(20),
            //     side: BorderSide(color: Colors.grey)),
            contentPadding: const EdgeInsets.only(left: 16, right: 0),
            title: const Text("Presets"),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (kDebugMode)
                  IconButton(
                      onPressed: _openToneShare,
                      icon: const Icon(
                        Icons.cloud_download,
                        size: 28,
                      )),
                _mainPopupMenu()
              ],
            ),
          );

    var ui = SafeArea(
      child: DragAndDropLists(
        key: const PageStorageKey<String>("presets"),
        children: list,
        headerWidget: header,
        lastListTargetSize: 60,
        contentsWhenEmpty: const SizedBox(
          height: 50,
          child: Center(
            child: Text("Empty"),
          ),
        ),
        onItemReorder: _onItemReorder,
        onListReorder: _onListReorder,
        itemGhost: (item) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.keyboard_arrow_right,
                size: 30,
                color: Colors.grey,
              ),
              Expanded(child: Opacity(opacity: 0.4, child: item))
            ],
          );
        },
        itemGhostOpacity: 1,
        itemDragOffset: const Offset(30, 0),
        // listGhost is mandatory when using expansion tiles to prevent multiple widgets using the same globalkey
        listGhost: Container(
          color: Colors.blue,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                    vertical: 8.0, horizontal: 100.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white),
                  borderRadius: BorderRadius.circular(7.0),
                ),
                child: const Icon(
                  Icons.add_box,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    if (widget.simplified) return ui;
    var sps = SetlistPlayerState.instance();
    if (sps.state != PlayerState.play ||
        (sps.automation?.presetChangeEventsAvailable == false)) {
      return ui;
    } else {
      return TrackEventsBlockInfo(
        child: ui,
        onBypass: () {
          setState(() {});
        },
      );
    }
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

  _buildList(int outerIndex, bool hideNonApplicable) {
    Map category = _lists[outerIndex];
    List presets = category["presets"];
    return DragAndDropListExpansion(
      canDrag: !widget.simplified,
      title: Text(category["name"]),
      titleColor: Colors.grey[700],
      titleColorExpanded: Colors.grey[600],
      itemsBackgroundColor: Colors.grey[900]!,
      trailing: widget.simplified
          ? null
          : PopupMenuButton(
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Icon(Icons.more_vert),
              ),
              itemBuilder: (context) {
                return _popupMenu;
              },
              onSelected: (pos) {
                _categoryMenu(pos as CategoryMenuActions, category["name"]);
              },
            ),
      children: List.generate(presets.length,
          (index) => _buildPresetItem(presets[index], hideNonApplicable)),
      listKey: ObjectKey(category),
    );
  }

  Widget _presetWidget(Map<String, dynamic> item, bool hideNonApplicable) {
    return PresetItem(
      device: device,
      item: item,
      hideNotApplicable: hideNonApplicable,
      ampTextStyle: Theme.of(context).textTheme.bodyLarge,
      simplified: widget.simplified,
      onTap: () {
        //remove the new marker if exists
        if (!widget.simplified) {
          PresetsStorage().clearNewFlag(item);
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
            PresetListMethods.exportQR(item, context);
            break;
        }
      },
    );
  }

  _buildPresetItem(Map<String, dynamic> item, bool hideNonApplicable) {
    return DragAndDropItem(
      canDrag: !widget.simplified,
      feedbackWidget: ListTile(
        tileColor: const Color.fromARGB(127, 127, 127, 127),
        title: Text(item["name"]),
      ),
      child: _presetWidget(item, hideNonApplicable),
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

  ///
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

  ///
  /// Preset actions
  ///
  ///
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

    if (category.isEmpty) {
      category = "Backup";
    }
    if (data != null) {
      if (!PlatformUtils.isIOS) {
        saveFileString("application/octet-stream", "$category.nuxpreset", data);
      } else {
        PresetListMethods.saveFileIos(category, data, context);
      }
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
    if (PlatformUtils.isAndroid) {
      openFileString("application/octet-stream").then(_onFileRead);
    } else {
      FilePicker().readFile().then((value) {
        if (value != null) _onFileRead(value);
      });
    }
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

  void _exportPreset(Map<String, dynamic> preset) {
    var category = PresetsStorage().findCategoryOfPreset(preset);
    if (category != null) {
      String? data =
          PresetsStorage().presetToJson(category["name"], preset["name"]);

      if (data != null) {
        if (!PlatformUtils.isIOS) {
          saveFileString(
              "application/octet-stream", "${preset["name"]}.nuxpreset", data);
        } else {
          PresetListMethods.saveFileIos(preset["name"], data, context);
        }
      }
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

  void _onFileRead(String value) {
    PresetsStorage().presetsFromJson(value).then((value) {
      setState(() {});
    }).catchError((error) {
      AlertDialogs.showInfoDialog(context,
          title: "Error",
          description: "The selected file is not a valid preset file!",
          confirmButton: "OK");
    });
  }
}
