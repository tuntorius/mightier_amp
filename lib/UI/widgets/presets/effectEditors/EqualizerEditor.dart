import 'package:flutter/material.dart';
import 'package:mighty_plug_manager/UI/widgets/verticalThickSlider.dart';
import 'package:tinycolor2/tinycolor2.dart';
import '../../../../bluetooth/devices/effects/Processor.dart';
import '../../../utils.dart';

class EqualizerEditor extends StatefulWidget {
  final Processor eqEffect;
  final bool enabled;
  final Function(Parameter, double value, bool skip)? onChanged;
  final Function(Parameter, double, double)? onChangedFinal;
  const EqualizerEditor(
      {required this.eqEffect,
      required this.enabled,
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
      var screenWidth = constraints.maxWidth;
      var layout = getEditorLayoutMode(MediaQuery.of(context));

      List<Parameter> params = widget.eqEffect.parameters;
      List<Widget> sliders = [];
      for (int i = 0; i < params.length; i++) {
        var param = params[i];
        Color color =
            (i == 0 && params.length > 6) ? Colors.amber : Colors.blue;
        if (!widget.enabled) {
          color = TinyColor.fromColor(color).desaturate(80).color;
        }
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
          onChanged: (val, bool skip) {
            widget.onChanged?.call(param, val, skip);
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
      if (_sliderWidth * params.length < screenWidth) {
        slidersContainer = Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: sliders,
        );
      } else {
        slidersContainer = Scrollbar(
          child: ListView(
            primary: true,
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            children: sliders,
          ),
        );
      }

      if (layout == EditorLayoutMode.expand) {
        return Column(
          children: [
            Expanded(child: slidersContainer),
            const SizedBox(
              height: 30,
            )
          ],
        );
      } else {
        return SizedBox(
          height: 200,
          child: slidersContainer,
        );
      }
    });
  }
}
