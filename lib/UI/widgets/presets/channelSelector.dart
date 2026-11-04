// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

import 'package:flutter/material.dart';
import 'package:mighty_plug_manager/UI/popups/alertDialogs.dart';
import 'package:mighty_plug_manager/UI/popups/exportQRCode.dart';
import 'package:mighty_plug_manager/bluetooth/NuxDeviceControl.dart';
import 'package:mighty_plug_manager/platform/fileSaver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_utils/qr_utils.dart';

import '../../../bluetooth/devices/presets/Preset.dart';
import '../../../bluetooth/devices/NuxDevice.dart';
import '../../../platform/platformUtils.dart';
import '../../theme.dart';
import '../../utils.dart';
import 'effectSelector.dart';

class ChannelSelector extends StatefulWidget {
  final NuxDevice device;
  const ChannelSelector({Key? key, required this.device}) : super(key: key);

  @override
  State createState() => _ChannelSelectorState();
}

class _ChannelSelectorState extends State<ChannelSelector> {
  late List<Preset> _presets;
  EditorLayoutMode layout = EditorLayoutMode.expand;

  var qrMenu = <PopupMenuEntry>[
    PopupMenuItem(
      value: 1,
      child: Row(
        children: <Widget>[
          Icon(
            Icons.qr_code_scanner,
          ),
          const SizedBox(width: 5),
          const Text("Scan QR"),
        ],
      ),
    ),
    PopupMenuItem(
      value: 2,
      child: Row(
        children: <Widget>[
          Icon(
            Icons.qr_code_2,
          ),
          const SizedBox(width: 5),
          const Text("Import QR Image"),
        ],
      ),
    ),
    PopupMenuItem(
      value: 3,
      child: Row(
        children: <Widget>[
          Icon(
            Icons.qr_code_2,
          ),
          const SizedBox(width: 5),
          const Text("Share QR"),
        ],
      ),
    ),
  ];

  @override
  void initState() {
    super.initState();
  }

  List<Widget> _createButtons(double width) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    var disabledColor = isDark ? Theme.of(context).disabledColor : Colors.grey[400]!;

    List<Widget> buttons = <Widget>[];
    var tooltip = "";
    _presets = widget.device.getPresetsList();

    int row1 = width < 330 && _presets.length > 4
        ? (_presets.length / 2).ceil()
        : _presets.length;

    double itemWidth = (width / row1).floorToDouble();

    // SAFEGUARD: Ensure we don't iterate past the available presets bounds
    for (int i = 0; i < _presets.length; i++) {
      // SAFEGUARD: Check bounds against the device's selectedChannel explicitly 
      // when firmware hot-swaps happen.
      bool isSelected = false;
      if (widget.device.selectedChannel >= 0 && widget.device.selectedChannel < _presets.length) {
         isSelected = (i == widget.device.selectedChannel);
      }
      
      var col = isSelected
          ? _presets[widget.device.selectedChannel].channelColor
          : disabledColor;

      Widget buttonBody;
      if (widget.device.longChannelNames) {
        tooltip = _presets[i].channelName;
        buttonBody = Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              widget.device.getChannelActive(i)
                  ? Icons.circle
                  : Icons.circle_outlined,
              color: col,
              size: 32,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6.0),
              child: FittedBox(
                  fit: BoxFit.fill,
                  child: Text(
                    _presets[i].channelName,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  )),
            ),
          ],
        );
      } else {
        tooltip = "Channel ${i + 1}";
        buttonBody = Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              widget.device.getChannelActive(i)
                  ? Icons.circle
                  : Icons.circle_outlined,
              color: col,
              size: 32,
            ),
            Text(
              _presets[i].channelName,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected 
                    ? (col.computeLuminance() > 0.5 ? Colors.black : Colors.white) 
                    : Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        );
      }

      var button = GestureDetector(
        onTap: () {
          if (widget.device.selectedChannel == i) return;
          widget.device.setSelectedChannel(i,
              notifyBT: true, sendFullPreset: false, notifyUI: true);
          widget.device
              .getPreset(widget.device.selectedChannel)
              .setupPresetFromNuxData();
        },
        onLongPress: () {
          widget.device.toggleChannelActive(i);
        },
        child: Container(
          color: Colors.transparent,
          width: itemWidth,
          height:
              AppThemeConfig.toggleButtonHeight(widget.device.longChannelNames),
          child: Semantics(
            selected: widget.device.selectedChannel == i,
            label: tooltip,
            child: ExcludeSemantics(child: buttonBody),
          ),
        ),
      );
      buttons.add(button);
    }

    return buttons;
  }

  qrPopupSelection(pos) async {
    switch (pos) {
      case 1:
        var result = await Permission.camera.request();
        if (result.isPermanentlyDenied) {
          // Explained in settings
        }
        final content = await QrUtils.scanQR;
        if (content?.isNotEmpty ?? false) {
          setupFromQRData(content!);
          setState(() {});
        }
        break;
      case 2:
        if (PlatformUtils.isAndroid) {
          openFile("image/*").then((value) async {
            final content = await QrUtils.scanImageFromData(value);
            if (content != null) {
              setupFromQRData(content);
              setState(() {});
            } else {
              showQRError();
            }
          });
        } else if (PlatformUtils.isIOS) {
          final content = await QrUtils.scanImage();
          if (content != null) {
            setupFromQRData(content);
            setState(() {});
          } else {
            showQRError();
          }
        }
        break;
      case 3:
        var qr = widget.device.channelToQR(widget.device.selectedChannel);
        var name = widget.device.deviceControl.presetName;
        Image img = await QrUtils.generateQR(qr);
        if (name.isEmpty) {
          AlertDialogs.showInputDialog(context,
              title: "Enter preset name",
              description: "It will be displayed below the QR code.",
              value: "",
              onConfirm: (value) => {showQRExport(img, value)});
        } else {
          showQRExport(img, name);
        }
    }
  }

  void showQRExport(Image img, String name) {
    var qrExport =
        QRExportDialog(img, name, NuxDeviceControl.instance().device);
    showDialog(
      context: context,
      builder: (BuildContext context) => qrExport.buildDialog(context),
    );
  }

  void showQRError() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        backgroundColor: Colors.red,
        content: Text(
          "Error decoding QR code!",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.white, fontSize: 20),
        )));
  }

  void setupFromQRData(String qrData) {
    var result = widget.device.setupFromQRData(qrData);
    bool success = result == PresetQRError.Ok;
    NuxDeviceControl.instance().changes.clearHistory();
    setState(() {});
    var message = QrUtils.QRMessages[result.index];
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: success ? Colors.green : Colors.red,
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white, fontSize: 20),
        )));
  }

  @override
  Widget build(BuildContext context) {
    layout = getEditorLayoutMode(MediaQuery.of(context));
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    _presets = widget.device.getPresetsList();
    
    // SAFEGUARD: Gracefully fall back if device selection is completely out of sync
    if (widget.device.selectedChannel < 0 || widget.device.selectedChannel >= _presets.length) {
       return const SizedBox.shrink();
    }

    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Container(
            decoration: BoxDecoration(
                color: isDark ? Colors.grey[800] : Theme.of(context).cardColor,
                border: Border.all(
                    color: isDark ? Theme.of(context).disabledColor : Colors.grey[300]!),
                borderRadius: BorderRadius.circular(6)),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                PopupMenuButton(
                    itemBuilder: (context) {
                      return qrMenu;
                    },
                    onSelected: qrPopupSelection,
                    child: SizedBox(
                      width: 60,
                      child: Column(
                        children: [
                          Icon(
                            Icons.qr_code_2,
                            size: 32,
                            color: Theme.of(context).iconTheme.color,
                          ),
                          Text(
                            "QR Code",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          )
                        ],
                      ),
                    )),
                Expanded(
                  child: Container(
                    constraints: const BoxConstraints(minHeight: 60),
                    color: isDark ? Colors.grey[900] : Colors.grey[100],
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return Wrap(
                          alignment: WrapAlignment.center,
                          runAlignment: WrapAlignment.center,
                          children: _createButtons(constraints.maxWidth),
                        );
                      },
                    ),
                  ),
                ),
                Semantics(
                  checked: widget.device
                      .getChannelActive(widget.device.selectedChannel),
                  child: InkWell(
                    onTap: () {
                      widget.device
                          .toggleChannelActive(widget.device.selectedChannel);
                    },
                    child: SizedBox(
                      width: 60,
                      child: Column(
                        children: [
                          Icon(
                            widget.device.getChannelActive(
                                    widget.device.selectedChannel)
                                ? Icons.check_circle
                                : Icons.circle_outlined,
                            size: 30,
                            color: widget.device.getChannelActive(
                                    widget.device.selectedChannel)
                                ? Colors.green
                                : Theme.of(context).iconTheme.color,
                          ),
                          Text(
                            "Active",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurface,
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
        if (layout == EditorLayoutMode.expand)
          Expanded(
            child: EffectSelector(
                device: widget.device,
                preset: _presets[widget.device.selectedChannel]),
          )
        else
          EffectSelector(
              device: widget.device,
              preset: _presets[widget.device.selectedChannel])
      ],
    );
  }
}