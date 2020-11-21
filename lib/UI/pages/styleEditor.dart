import 'package:flutter/material.dart';
import '../widgets/presets/presetList.dart';
import '../widgets/presets/instrumentSelector.dart';
import '../../bluetooth/NuxDeviceControl.dart';

class StyleEditor extends StatefulWidget {
  @override
  _StyleEditorState createState() => _StyleEditorState();
}

class _StyleEditorState extends State<StyleEditor>
    with TickerProviderStateMixin {
  final NuxDeviceControl deviceCtrl = NuxDeviceControl();

  TabController cntrl;
  @override
  void initState() {
    super.initState();
    cntrl = TabController(length: 2, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
      children: [
        TabBar(
          tabs: [Tab(text: "Editor"), Tab(text: "Presets")],
          controller: cntrl,
        ),
        Expanded(
          child: TabBarView(controller: cntrl, children: [
            InstrumentSelector(deviceCtrl.device),
            PresetList(onTap: (preset) {
              deviceCtrl.device.presetFromJson(preset);
            })
          ]),
        ),
      ],
    ));
  }
}
