import 'package:flutter/material.dart';

import 'scrollPicker.dart';

//direct_select: ^2.0.0

class DrumStyleBottomSheet extends StatefulWidget {
  final Map<String, Map> styleMap;
  final int selected;
  final Function(int) onChange;
  const DrumStyleBottomSheet(
      {Key? key,
      required this.styleMap,
      required this.selected,
      required this.onChange})
      : super(key: key);

  @override
  State<DrumStyleBottomSheet> createState() => _DrumStyleBottomSheetState();
}

class _DrumStyleBottomSheetState extends State<DrumStyleBottomSheet> {
  late List<String> categoriesList;
  List<String> stylesList = [];
  int categoriesIndex = 0;
  int selectedStyle = 0;

  @override
  void initState() {
    super.initState();
    categoriesList = widget.styleMap.keys.toList();

    selectedStyle = widget.selected;

    for (var key in widget.styleMap.keys) {
      stylesList.addAll(widget.styleMap[key]!.keys as Iterable<String>);
      for (var style in widget.styleMap[key]!.keys)
        if (widget.styleMap[key]![style] == widget.selected) {
          categoriesIndex = categoriesList.indexOf(key);
        }
    }
  }

  void _onCategoryChanged(int value, bool userGenerated) {
    categoriesIndex = value;

    //print("remote $remote, remoteChangeStyle $remoteChangeCategory");

    if (userGenerated) {
      var key = categoriesList[categoriesIndex];
      var firstKey = widget.styleMap[key]!.keys.first as String;

      selectedStyle = widget.styleMap[key]![firstKey];
      setState(() {});
    }
  }

  void _onStyleChanged(int value, bool userGenerated, bool finalChange) {
    selectedStyle = value;

    //print("remote $remote, remoteChangeStyle $remoteChangeStyle");

    if (userGenerated) {
      //find category
      for (var cat in widget.styleMap.keys)
        for (var style in widget.styleMap[cat]!.keys) {
          if (widget.styleMap[cat]![style] == value) {
            categoriesIndex = categoriesList.indexOf(cat);
            setState(() {});
            break;
          }
        }
    }

    if (finalChange) widget.onChange(selectedStyle);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 400,
      child: Column(
        children: [
          SizedBox(
            height: 40,
            child: Center(
              child: Text(
                "Select Style",
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const Divider(
            thickness: 1,
          ),
          Expanded(
            child: Row(
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
