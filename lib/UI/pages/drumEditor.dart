import 'package:flutter/material.dart';
import '../widgets/thickSlider.dart';
import '../widgets/scrollPicker.dart';

class DrumEditor extends StatefulWidget {
  @override
  _DrumEditorState createState() => _DrumEditorState();
}

class _DrumEditorState extends State<DrumEditor> {
  int selectedDrumPattern = 0;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Container(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ScrollPicker(
              initialValue: selectedDrumPattern,
              items: [
                "Metronome",
                "Pop",
                "Metal",
                "Blues",
                "Swing",
                "Rock",
                "Ballad Rock",
                "Funk",
                "R&B",
                "Latin",
                "Dance"
              ],
              onChanged: (value) {
                setState(() {
                  selectedDrumPattern = value;
                });
              },
              onChangedFinal: (value) {
                print("Final value: $value");
              },
            ),
          ),
          Text(
            "Drums",
            textAlign: TextAlign.center,
            style: theme.textTheme.headline4.copyWith(color: Colors.white),
          ),
          ThickSlider(
            min: 0,
            max: 100,
            activeColor: Colors.blue,
            label: "Volume",
            value: 50,
            labelFormatter: (val) => "50",
            onChanged: (val) {},
          ),
          ThickSlider(
            min: 40,
            max: 240,
            activeColor: Colors.blue,
            label: "Tempo",
            value: 100,
            labelFormatter: (val) => "100 BPM",
            onChanged: (val) {},
          )
        ],
      ),
    );
  }
}
