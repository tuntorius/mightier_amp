import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'dart:math' as math;

import '../../bluetooth/devices/NuxDevice.dart';
import '../../bluetooth/devices/features/tuner.dart';

class TunerPage extends StatefulWidget {
  final NuxDevice device;
  const TunerPage({super.key, required this.device}) : assert(device is Tuner);

  static const indicatorsAmount = 21;

  //how many cents is half of the scale
  static const scaleSize = 50;

  static const colors = [
    Colors.white,
    Color.fromARGB(255, 119, 202, 29),
    Colors.yellow,
    Colors.red
  ];

  static const colorsInactive = [
    Color(0x32FFFFFF),
    Color.fromARGB(50, 119, 202, 29),
    Color(0x32FFEB3B),
    Color(0x32F44336)
  ];

  static List<String> notes = [
    "A ",
    "A♯",
    "B ",
    "C ",
    "C♯",
    "D ",
    "D♯",
    "E ",
    "F ",
    "F♯",
    "G ",
    "G♯"
  ];

  @override
  State<TunerPage> createState() => _TunerPageState();
}

class _TunerPageState extends State<TunerPage> {
  late Tuner _tuner;
  late TunerData data = TunerData();
  StreamSubscription? _subscription;

  bool _tunerEnabled = false;
  bool _validDetection = false;
  Timer? _timeout;

  final List<DropdownMenuItem<TunerMode>> _modeItems = [];
  final List<DropdownMenuItem<int>> _referenceItems = [];

  @override
  void initState() {
    super.initState();

    _tunerEnabled = false;
    _tuner = widget.device as Tuner;
    _subscription = _tuner.getTunerDataStream().listen(onData);

    //if not requesting 2 times, the device does not answer
    _tuner.tunerRequestSettings();
    _tuner.tunerRequestSettings();

    for (var mode in TunerMode.values) {
      _modeItems.add(DropdownMenuItem(
          value: mode, child: Text(Tuner.modesString[mode.index])));
    }

    for (int i = 0; i < 21; i++) {
      _referenceItems
          .add(DropdownMenuItem(value: i, child: Text("${430 + i} Hz")));
    }
  }

  @override
  void dispose() {
    _timeout?.cancel();
    _subscription?.cancel();
    _tuner.tunerEnable(false);
    super.dispose();
  }

  void onData(TunerData event) {
    if (!_tunerEnabled) {
      _tuner.tunerEnable(true);
      _tunerEnabled = true;
    } else {
      _validDetection = true;
    }

    data = event;
    setState(() {});
    _timeout?.cancel();
    _timeout = Timer(const Duration(seconds: 1), _onTimeout);
  }

  void _onTimeout() {
    if (data.mode == TunerMode.chromatic &&
        data.note == 0 &&
        data.cents == 50) {
      setState(
        () {
          _validDetection = false;
        },
      );
    }
  }

  Widget _indicator() {
    return LayoutBuilder(
      builder: (context, constraints) {
        var width = (constraints.maxWidth / TunerPage.indicatorsAmount) * 0.7;
        var height = constraints.maxHeight;
        int centralIndex = (TunerPage.indicatorsAmount / 2).floor();

        int activeIndex = (math.max(
                        math.min((data.cents - 50), TunerPage.scaleSize),
                        -TunerPage.scaleSize) *
                    centralIndex /
                    TunerPage.scaleSize)
                .round() +
            centralIndex;
        List<Widget> indicators = [];
        for (int i = 0; i < TunerPage.indicatorsAmount; i++) {
          int distance = (centralIndex - i).abs();
          bool central = i == centralIndex;
          int colorIndex = 3;
          if (distance == 0) {
            colorIndex = 0;
          } else if (distance < centralIndex / 10 || distance == 1) {
            colorIndex = 1;
          } else if (distance < centralIndex / 2) {
            colorIndex = 2;
          }

          bool active = _validDetection &&
              (data.note != 0 || data.stringNumber != 0 || data.cents != 0);
          Color color = active && i == activeIndex
              ? TunerPage.colors[colorIndex]
              : TunerPage.colorsInactive[colorIndex];

          indicators.add(Container(
            width: central ? width * 1.5 : width,
            height: central ? height : height * 0.7, // - distance * 2,
            color: color,
          ));
        }
        return Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: indicators,
        );
      },
    );
  }

  Widget _noteDisplay() {
    String wholeNote = TunerPage.notes[data.note].characters.first;
    String sharp = TunerPage.notes[data.note].characters.last;
    String stringNumber = "";

    if (!_validDetection ||
        (data.note == 0 && data.stringNumber == 0 && data.cents == 0)) {
      wholeNote = "-";
      sharp = " ";
    } else if (data.mode == TunerMode.bass && data.stringNumber == 5) {
      stringNumber = "L";
    } else if (data.stringNumber > 0 && data.mode != TunerMode.chromatic) {
      stringNumber = data.stringNumber.toString();
    }

    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Transform.translate(
          offset: const Offset(-47, 42),
          child: Text(
            stringNumber,
            style: const TextStyle(fontSize: 55, fontWeight: FontWeight.bold),
          ),
        ),
        Text(
          wholeNote,
          style: const TextStyle(fontSize: 100),
        ),
        Transform.translate(
          offset: const Offset(44, -14),
          child: Text(
            sharp,
            style: const TextStyle(fontSize: 50),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    bool isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;

    late List<Widget> tunerWidgets;
    if (isPortrait) {
      tunerWidgets = [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: SizedBox(height: 100, child: _indicator()),
        ),
        _noteDisplay(),
      ];
    } else {
      tunerWidgets = [
        Row(
          children: [
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SizedBox(height: 100, child: _indicator()),
              ),
            ),
            Expanded(flex: 1, child: _noteDisplay()),
            IconButton(
                onPressed: () {
                  _tuner.tunerMute(!data.muted);
                },
                iconSize: 56,
                icon: Icon(data.muted ? Icons.volume_off : Icons.volume_up))
          ],
        )
      ];
    }
    return Scaffold(
      appBar: AppBar(title: const Text("Tuner")),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(children: [
          ...tunerWidgets,
          ListTile(
            title: const Text("Mode"),
            trailing: DropdownButton<TunerMode>(
                value: data.mode,
                items: _modeItems,
                onChanged: (index) {
                  setState(() {
                    data.clear();
                    _tuner.tunerSetMode(index!);
                  });
                }),
          ),
          ListTile(
            title: const Text("Reference"),
            trailing: DropdownButton<int>(
                value: data.referencePitch,
                items: _referenceItems,
                onChanged: (index) {
                  setState(() {
                    _tuner.tunerSetReferencePitch(index!);
                  });
                }),
          ),
          if (isPortrait)
            IconButton(
                onPressed: () {
                  _tuner.tunerMute(!data.muted);
                },
                iconSize: 56,
                icon: Icon(data.muted ? Icons.volume_off : Icons.volume_up))
        ]),
      ),
    );
  }
}
