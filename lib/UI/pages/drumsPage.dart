import 'package:flutter/material.dart';
import 'package:mighty_plug_manager/UI/pages/drum_editor/drumEditor.dart';
import 'package:mighty_plug_manager/UI/pages/looperPage.dart';

import '../../bluetooth/NuxDeviceControl.dart';
import '../../bluetooth/devices/features/looper.dart';

class DrumsPage extends StatelessWidget {
  const DrumsPage({super.key});

  @override
  Widget build(BuildContext context) {
    if (NuxDeviceControl.instance().device is Looper) {
      return const SafeArea(child: LooperControl());
    }
    return const SafeArea(child: DrumEditor());
  }
}
