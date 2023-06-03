import 'package:flutter/material.dart';
import '../../widgets/scrollPicker.dart';

enum DrumStyleMode { flat, categorized }

class DrumStyleBottomSheet extends StatefulWidget {
  final dynamic styleMap;
  final DrumStyleMode mode;
  final int selected;
  final Function(int) onChange;
  const DrumStyleBottomSheet(
      {Key? key,
      required this.styleMap,
      required this.selected,
      required this.onChange,
      required this.mode})
      : super(key: key);

  @override
  State<DrumStyleBottomSheet> createState() => _DrumStyleBottomSheetState();
}

class _DrumStyleBottomSheetState extends State<DrumStyleBottomSheet> {
  List<String> categoriesList = [];
  List<String> stylesList = [];
  int categoriesIndex = 0;
  int selectedStyle = 0;

  @override
  void initState() {
    super.initState();
    selectedStyle = widget.selected;
    if (widget.mode == DrumStyleMode.categorized) {
      categoriesList = widget.styleMap.keys.toList();

      for (var key in widget.styleMap.keys) {
        stylesList.addAll(widget.styleMap[key]!.keys as Iterable<String>);
        for (var style in widget.styleMap[key]!.keys) {
          if (widget.styleMap[key]![style] == widget.selected) {
            categoriesIndex = categoriesList.indexOf(key);
          }
        }
      }
    } else {
      stylesList = widget.styleMap;
    }
  }

  void _onCategoryChanged(int value, bool userGenerated) {
    categoriesIndex = value;

    if (userGenerated) {
      var key = categoriesList[categoriesIndex];
      var firstKey = widget.styleMap[key]!.keys.first as String;

      selectedStyle = widget.styleMap[key]![firstKey];
      setState(() {});
    }
  }

  void _onStyleChanged(int value, bool userGenerated, bool finalChange) {
    selectedStyle = value;
    if (userGenerated) {
      //find category
      for (var cat in widget.styleMap.keys) {
        for (var style in widget.styleMap[cat]!.keys) {
          if (widget.styleMap[cat]![style] == value) {
            categoriesIndex = categoriesList.indexOf(cat);
            setState(() {});
            break;
          }
        }
      }
    }

    if (finalChange) widget.onChange(selectedStyle);
  }

  void _onFlatStyleChanged(int value, bool finalChange) {
    selectedStyle = value;
    widget.onChange(selectedStyle);
    if (!finalChange) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 400,
      child: Column(
        children: [
          const SizedBox(
            height: 40,
            // ignore: unnecessary_const
            child: Center(
              child: Text(
                "Select Style",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20),
              ),
            ),
          ),
          const Divider(
            thickness: 1,
          ),
          Expanded(
            child: widget.mode == DrumStyleMode.flat
                ? ScrollPicker(
                    initialValue: selectedStyle,
                    items: stylesList,
                    onChanged: (value) {
                      _onFlatStyleChanged(value, false);
                    },
                    onChangedFinal: (value, user) =>
                        _onFlatStyleChanged(value, true),
                  )
                : Row(
                    children: [
                      Expanded(
                        child: ScrollPicker(
                          initialValue: categoriesIndex,
                          items: categoriesList,
                          onChanged: (value) {
                            _onCategoryChanged(value, true);
                          },
                          onChangedFinal: _onCategoryChanged,
                        ),
                      ),
                      Expanded(
                        child: ScrollPicker(
                          initialValue: selectedStyle,
                          items: stylesList,
                          onChanged: (value) {
                            _onStyleChanged(value, true, false);
                          },
                          onChangedFinal: (value, user) =>
                              _onStyleChanged(value, user, true),
                        ),
                      )
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
