import 'package:drag_and_drop_lists/drag_and_drop_list_interface.dart';
import 'package:drag_and_drop_lists/drag_and_drop_lists.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
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
  final TabVisibilityEventHandler? visibilityEventHandler;
  const PresetList(
      {Key? key,
      this.onTap,
      this.simplified = false,
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

  // Variables for Expand/Collapse All
  bool _expandAll = false;
  int _expandToggleCount = 0;

  // Variables for Dynamic Selection Scrolling
  final GlobalKey _selectedPresetKey = GlobalKey();
  String _lastPresetUuid = "";
  bool _isVisible = true;

  @override
  void initState() {
    super.initState();

    if (widget.visibilityEventHandler != null) {
      _isVisible = false; 
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

  void _registerListeners() {
    NuxDeviceControl.instance().addListener(refreshPresets);
    PresetsStorage().addListener(refreshPresets);
    NuxDeviceControl.instance().presetNameNotifier.addListener(refreshPresets);
    if (!widget.simplified) {
      SetlistPlayerState.instance().addListener(refreshPresets);
    }
  }

  void _onTabSelected() {
    _isVisible = true;
    _registerListeners();
    if (mounted) {
      setState(() {});
      
      // Always attempt to center the preset when coming back to the tab, 
      // especially after a cold start where the layout wasn't ready yet.
      String currentUuid = NuxDeviceControl.instance().presetUUID;
      _lastPresetUuid = currentUuid;
      _scrollToSelected();
    }
  }

  void _onTabDeselected() {
    _isVisible = false;
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
    if (mounted) {
      setState(() {});

      // Only Auto-Scroll if the Preset List tab is actually visible on screen
      if (_isVisible) {
        String currentUuid = NuxDeviceControl.instance().presetUUID;
        if (currentUuid != _lastPresetUuid) {
          _lastPresetUuid = currentUuid;
          _scrollToSelected();
        }
      }
    }
  }

  void _scrollToSelected() {
    // Add an initial delay to allow tab slide transitions and category 
    // expansion animations to finish before looking for the widget.
    Future.delayed(const Duration(milliseconds: 350), () {
      _tryScroll(15); // Try 15 times, waiting 150ms between each attempt
    });
  }

  void _tryScroll(int attemptsLeft) {
    if (attemptsLeft <= 0 || !mounted) return;
    
    // If the widget has finally rendered in the tree, scroll to it
    if (_selectedPresetKey.currentContext != null) {
      Scrollable.ensureVisible(
        _selectedPresetKey.currentContext!,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        alignment: 0.5, // Center the item vertically
      ).catchError((e) {
        debugPrint("Scroll error caught: $e");
      });
    } else {
      // If it hasn't rendered yet (still animating open), try again shortly
      Future.delayed(const Duration(milliseconds: 150), () {
        _tryScroll(attemptsLeft - 1);
      });
    }
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
        contentPadding: const EdgeInsets.only(left: 16, right: 0),
        title: const Text("Presets"),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
                tooltip: "Expand All",
                onPressed: () {
                  _expandAll = true;
                  _expandToggleCount++;
                  setState(() {});
                },
                icon: const Icon(
                  Icons.expand_more,
                  size: 28,
                )),
            IconButton(
                tooltip: "Collapse All",
                onPressed: () {
                  _expandAll = false;
                  _expandToggleCount++;
                  setState(() {});
                },
                icon: const Icon(
                  Icons.expand_less,
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

  Widget _createDragDropList(
      List<DragAndDropListInterface> list, Widget? header, bool sliverList,
      {bool disableScrolling = false}) {
    return DragAndDropLists(
      scrollController: _scrollController,
      sliverList: sliverList,
      key: const PageStorageKey<String>("presets"),
      children: list,
      disableScrolling: disableScrolling,
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
      listGhost: Container(
        color: Colors.blue,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Center(
            child: Container(
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 100.0),
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
    );
  }

  Widget _createPresetTree(Widget? header, bool hideNonApplicable) {
    List<DragAndDropListInterface> list = List.generate(
        _lists.length, (index) => _buildList(index, hideNonApplicable))
        .where((element) => element != null)
        .cast<DragAndDropListInterface>()
        .toList();

    return SafeArea(
      child: CustomScrollView(
        cacheExtent: 10000, 
        slivers: [
          if (header != null)
            SliverAppBar(
              backgroundColor: Theme.of(context).scaffoldBackgroundColor,
              title: header,
              titleSpacing: 0,
              floating: true,
              snap: true,
            ),
          _createDragDropList(list, header, true)
        ],
      ),
    );
  }

  Widget _createPresetTreeSimple(bool hideNonApplicable) {
    List<DragAndDropListInterface> list = List.generate(
        _lists.length, (index) => _buildList(index, hideNonApplicable))
        .where((element) => element != null)
        .cast<DragAndDropListInterface>()
        .toList();
    return _createDragDropList(list, null, false, disableScrolling: true);
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
        cacheExtent: 10000, 
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

    if (widget.simplified) return _createPresetTreeSimple(hideNonApplicable);
    Widget ui;
    if (_searchText.text.isEmpty) {
      ui = _createPresetTree(header, hideNonApplicable);
    } else {
      ui = _createSearchResultsList(header, hideNonApplicable);
    }

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
    List allPresets = category["presets"];

    // 1. Pre-filter the presets if hideNonApplicable is active
    List presets = [];
    if (hideNonApplicable) {
      for (var p in allPresets) {
        if (device.isPresetSupported(p)) {
          presets.add(p);
        }
      }
    } else {
      presets = List.from(allPresets);
    }

    // 2. If the category is completely empty after filtering, return null to drop it from the tree.
    // The library builder must filter out nulls before rendering.
    if (presets.isEmpty && hideNonApplicable) {
      return null;
    }

    bool containsSelected = false;
    String currentUuid = NuxDeviceControl.instance().presetUUID;
    for (var p in presets) {
      if (p["uuid"] == currentUuid) {
        containsSelected = true;
        break;
      }
    }

    bool shouldExpand = _expandAll || containsSelected;
    Key tileKey = Key(
        "${category["name"]}_${_expandToggleCount}_${containsSelected ? "active" : "inactive"}");

    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return DragAndDropListExpansion(
      initiallyExpanded: shouldExpand,
      canDrag: !widget.simplified,
      title: Container(
        decoration: isDark
            ? null
            : BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey[300]!, width: 1.0),
                ),
              ),
        padding: EdgeInsets.only(top: isDark ? 0 : 8.0),
        child: Text(
          category["name"],
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      titleColor: isDark ? Colors.grey[800] : Colors.transparent,
      titleColorExpanded: isDark ? Colors.grey[700] : Colors.transparent,
      itemsBackgroundColor: isDark ? Colors.grey[900]! : Colors.transparent,
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
      listKey: tileKey,
    );
  }

  Widget _presetWidget(Map<String, dynamic> item, bool hideNonApplicable) {
    bool isSelected = item["uuid"] == NuxDeviceControl.instance().presetUUID;
    return Container(
      key: isSelected ? _selectedPresetKey : null,
      child: PresetWidget(
          simplified: widget.simplified,
          device: device,
          hideNonApplicable: hideNonApplicable,
          onTap: widget.onTap,
          preset: item),
    );
  }

  _buildPresetItem(Map<String, dynamic> item, bool hideNonApplicable) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    
    return DragAndDropItem(
      canDrag: !widget.simplified,
      feedbackWidget: ListTile(
        tileColor: isDark 
            ? const Color.fromARGB(127, 127, 127, 127) 
            : const Color.fromARGB(200, 240, 240, 240),
        title: Text(item["name"], style: TextStyle(color: Theme.of(context).colorScheme.onSurface)),
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