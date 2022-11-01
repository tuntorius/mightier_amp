import 'package:flutter/material.dart';
import 'package:mighty_plug_manager/UI/widgets/verticalThickSlider.dart';
import '../../../../bluetooth/devices/effects/Processor.dart';
import 'dart:math';

class EqualizerEditor extends StatefulWidget {
  final Processor eqEffect;
  final Function(Parameter, double)? onChanged;
  final Function(Parameter, double, double)? onChangedFinal;
  const EqualizerEditor(
      {required Processor this.eqEffect,
      required this.onChanged,
      required this.onChangedFinal,
      Key? key})
      : super(key: key);

  @override
  State<EqualizerEditor> createState() => _EqualizerEditorState();
}

class _EqualizerEditorState extends State<EqualizerEditor> {
  double _oldValue = 0;
  final _sliderWidth = 47;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
      var isPortrait =
          MediaQuery.of(context).orientation == Orientation.portrait;
      var screenWidth = constraints.maxWidth;

      List<Parameter> params = widget.eqEffect.parameters;
      List<Widget> sliders = [];
      for (int i = 0; i < params.length; i++) {
        var param = params[i];
        var color = (i == 0 && params.length > 6) ? Colors.blue : Colors.grey;
        var slider = VerticalThickSlider(
          min: param.formatter.min.toDouble(),
          max: param.formatter.max.toDouble(),
          width: _sliderWidth.toDouble(),
          activeColor: color,
          label: param.name,
          handleHorizontalDrag: false,
          labelFormatter: (double val) {
            return val.toStringAsFixed(1);
          },
          value: param.value,
          onChanged: (val) {
            widget.onChanged?.call(param, val);
          },
          onDragStart: (val) {
            _oldValue = val;
          },
          onDragEnd: (val) {
            widget.onChangedFinal?.call(param, val, _oldValue);
          },
        );
        sliders.add(slider);
      }

      Widget slidersContainer;
      if (_sliderWidth * params.length < screenWidth)
        slidersContainer = Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: sliders,
        );
      else
        slidersContainer = Scrollbar(
          child: ListView(
            primary: true,
            scrollDirection: Axis.horizontal,
            children: sliders,
            shrinkWrap: true,
          ),
        );

      if (isPortrait)
        return Column(
          children: [
            Expanded(child: slidersContainer),
            const SizedBox(
              height: 30,
            )
          ],
        );
      else
        return Container(
          child: slidersContainer,
          height: 200,
        );
    });
  }
}
