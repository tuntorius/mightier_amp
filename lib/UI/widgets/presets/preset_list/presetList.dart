import 'package:drag_and_drop_lists/drag_and_drop_list_interface.dart';
import 'package:drag_and_drop_lists/drag_and_drop_lists.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mighty_plug_manager/UI/toneshare/toneshare_main.dart';
import 'package:mighty_plug_manager/UI/widgets/presets/preset_list/preset_widget.dart';
import 'package:mighty_plug_manager/platform/simpleSharedPrefs.dart';
import '../../../mainTabs.dart';
import '/utilities/string_extensions.dart';

import '../../search_field.dart';
import '/audio/setlist_player/setlistPlayerState.dart';
import '/audio/trackdata/trackData.dart';
import '/bluetooth/NuxDeviceControl.dart';
import '/bluetooth/devices/NuxDevice.dart';
import '/platform/presetsStorage.dart';
import '/platform/fileSaver.dart';
import '/platform/platformUtils.dart';
import '/UI/popups/alertDialogs.dart';
import '../trackEventsBlockInfo.dart';
import 'presetListMethods.dart';
import 'presets_popup_menus.dart';

class PresetList extends StatefulWidget {
  final void Function(dynamic)? onTap;
  final bool simplified;
  final bool noneOption;
  final TabVisibilityEventHandler? visibilityEventHandler;
  const PresetList(
      {Key? key,
      this.onTap,
      this.simplified = false,
      this.noneOption = false,
      this.visibilityEventHandler})
      : super(key: key);

  @override
  State<PresetList> createState() => _PresetListState();
}

class _PresetListState extends State<PresetList>
    with AutomaticKeepAliveClientMixin<PresetList> {
  NuxDevice get device => NuxDeviceControl.instance().device;
  List<dynamic> get _lists => PresetsStorage().presetsData;
  Map<String, NuxDevice> devices = <String, NuxDevice>{};
  bool _showSearch = false;
  final TextEditingController _searchText = TextEditingController(text: "");
  late ScrollController _scrollController;
  @override
  void initState() {
    super.initState();

    if (widget.visibilityEventHandler != null) {
      widget.visibilityEventHandler!.onTabSelected = _onTabSelected;
      widget.visibilityEventHandler!.onTabDeselected = _onTabDeselected;
    }
    _registerListeners();
    _searchText.addListener(refreshPresets);

    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    super.dispose();
    _onTabDeselected();
    _searchText.removeListener(refreshPresets);
  }

  void _onTabSelected() {
    _registerListeners();
    setState(() {});
  }

  void _registerListeners() {
    NuxDeviceControl.instance().addListener(refreshPresets);
    PresetsStorage().addListener(refreshPresets);
    NuxDeviceControl.instance().presetNameNotifier.addListener(refreshPresets);
    if (!widget.simplified) {
      SetlistPlayerState.instance().addListener(refreshPresets);
    }
  }

  void _onTabDeselected() {
    print("on deselected");
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
        return PresetsPopupMenus.presetsMenu;
      },
      onSelected: (pos) {
        mainMenuActions(pos);
      },
    );
  }

  Widget? _createHeader() {
    if (_showSearch) {
      return SearchField(
        textEditingController: _searchText,
        onCloseSearch: () {
          _searchText.clear();
          _showSearch = false;
          setState(() {});
        },
      );
    } else if (!widget.simplified) {
      return ListTile(
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
            IconButton(
                onPressed: () {
                  _showSearch = true;
                  setState(() {});
                },
                icon: const Icon(
                  Icons.search,
                  size: 28,
                )),
            _mainPopupMenu()
          ],
        ),
      );
    }
    return null;
  }

  Widget _createPresetTree(Widget? header, bool hideNonApplicable) {
    List<DragAndDropListInterface> list = List.generate(
        _lists.length, (index) => _buildList(index, hideNonApplicable));

    return SafeArea(
      child: CustomScrollView(
        slivers: [
          if (header != null)
            SliverAppBar(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              title: header,
              titleSpacing: 0,
              floating: true,
              snap: true,
            ),
          DragAndDropLists(
            scrollController: _scrollController,
            sliverList: true,
            key: const PageStorageKey<String>("presets"),
            children: list,
            headerWidget: header,
            lastListTargetSize: 60,
            contentsWhenEmpty: const SliverFillRemaining(
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
        ],
      ),
    );
  }

  Widget _createSearchResultsList(Widget? header, bool hideNonApplicable) {
    List presetList = [];
    var searchText = _searchText.text.trim();
    for (var l in _lists) {
      var presets = l["presets"];
      for (var p in presets) {
        if (p["name"].toString().containsIgnoreCase(searchText)) {
          presetList.add(p);
        }
      }
    }
    presetList.sort((a, b) => a["name"].compareTo(b["name"]));
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            title: header,
            titleSpacing: 0,
            floating: true,
            snap: true,
          ),
          if (presetList.isEmpty)
            const SliverFillRemaining(
              child: Center(child: Text("No Results")),
            ),
          if (presetList.isNotEmpty)
            SliverList.builder(
              itemBuilder: (context, index) {
                return _presetWidget(presetList[index], hideNonApplicable);
              },
              itemCount: presetList.length,
              // prototypeItem: const ListTile(
              //   subtitle: SizedBox.shrink(),
              // ),
            )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    bool hideNonApplicable =
        SharedPrefs().getInt(SettingsKeys.hideNotApplicablePresets, 0) == 1;

    Widget? header = _createHeader();

    Widget ui;
    if (_searchText.text.isEmpty) {
      ui = _createPresetTree(header, hideNonApplicable);
    } else {
      ui = _createSearchResultsList(header, hideNonApplicable);
    }
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
                return PresetsPopupMenus.popupMenuCategory;
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
    return PresetWidget(
        simplified: widget.simplified,
        device: device,
        hideNonApplicable: hideNonApplicable,
        onTap: widget.onTap,
        preset: item);
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

  void _onFileRead(String value) {
    PresetsStorage().presetsFromJson(value).then((value) {
      setState(() {});
      String label =
          value == 1 ? "Imported 1 preset" : "Imported $value presets";
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.green,
          content: Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 20),
          )));
    }).catchError((error) {
      AlertDialogs.showInfoDialog(context,
          title: "Error",
          description: "The selected file is not a valid preset file!",
          confirmButton: "OK");
    });
  }
}
