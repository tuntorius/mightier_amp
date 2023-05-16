import 'package:flutter/material.dart';
import 'package:mighty_plug_manager/UI/pages/drum_editor/drumEditor.dart';

class DrumsPage extends StatelessWidget {
  const DrumsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const SafeArea(
      child: DrumEditor(),
    );
  }
}
