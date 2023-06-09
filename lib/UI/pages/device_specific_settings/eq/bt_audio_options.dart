import 'package:flutter/material.dart';

import '../../../mightierIcons.dart';

class BTAudioOptions extends StatelessWidget {
  final bool btInvertChannel;
  final bool btEQMute;
  final void Function(bool) onInvert;
  final void Function(bool) onMute;
  const BTAudioOptions(
      {super.key,
      required this.btInvertChannel,
      required this.btEQMute,
      required this.onInvert,
      required this.onMute});

  @override
  Widget build(BuildContext context) {
    return ToggleButtons(
      fillColor: Colors.blue,
      selectedBorderColor: Colors.blue,
      color: Colors.grey,
      isSelected: [btInvertChannel, btEQMute],
      onPressed: (index) {
        switch (index) {
          case 0:
            onInvert(!btInvertChannel);
            break;
          case 1:
            onMute(!btEQMute);
            break;
        }
      },
      children: [
        const Tooltip(
          message: "Invert the phase of Bluetooth Audio.",
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 15.0),
            child: Icon(MightierIcons.sinewave, size: 40),
          ),
        ),
        Tooltip(
          message: "Mute Bluetooth audio.",
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25.0),
            child: Icon(btEQMute ? Icons.volume_off : Icons.volume_up),
          ),
        ),
      ],
    );
  }
}
