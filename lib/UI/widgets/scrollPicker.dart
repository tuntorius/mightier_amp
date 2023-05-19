// Copyright (c) 2018, codegrue. All rights reserved. Use of this source code
// is governed by the MIT license that can be found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// This helper widget manages the scrollable content inside a picker widget.
class ScrollPicker extends StatefulWidget {
  // Constants
  static const double itemHeight = 50.0;

  const ScrollPicker({
    Key? key,
    required this.items,
    required this.initialValue,
    required this.onChanged,
    required this.onChangedFinal,
    this.enabled = true,
  }) : super(key: key);

  // Events
  final ValueChanged<int> onChanged;
  final Function(int, bool) onChangedFinal;

  // Variables
  final List<String> items;
  final int initialValue;
  final bool enabled;

  @override
  _ScrollPickerState createState() => _ScrollPickerState(initialValue);
}

class _ScrollPickerState extends State<ScrollPicker> {
  _ScrollPickerState(this.selectedValue);

  // Variables
  double widgetHeight = 0;

  int selectedValue;
  bool _isUserGenerated = false;

  late FixedExtentScrollController scrollController;

  @override
  void initState() {
    super.initState();
    scrollController = FixedExtentScrollController(initialItem: selectedValue);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    TextStyle defaultStyle = themeData.textTheme.bodyText2!;
    TextStyle selectedStyle = themeData.textTheme.headline5!
        .copyWith(color: themeData.backgroundColor);

    if (!_isUserGenerated) {
      selectedValue = widget.initialValue;
      scrollController.jumpToItem(
        widget.initialValue,
      );
    }
    //
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        widgetHeight = constraints.maxHeight;

        return IgnorePointer(
          ignoring: !widget.enabled,
          child: Opacity(
            opacity: widget.enabled ? 1 : 0.3,
            child: Stack(
              children: <Widget>[
                GestureDetector(
                  onTapUp: _itemTapped,
                  child: NotificationListener<ScrollNotification>(
                    onNotification: (scrollNotification) {
                      if (scrollNotification is UserScrollNotification) {
                        if (scrollNotification.direction !=
                            ScrollDirection.idle) {
                          _isUserGenerated = true;
                        }
                      } else if (scrollNotification is ScrollEndNotification) {
                        widget.onChangedFinal(selectedValue, _isUserGenerated);
                        _isUserGenerated = false;
                      }
                      return false;
                    },
                    child: ListWheelScrollView.useDelegate(
                      childDelegate: ListWheelChildBuilderDelegate(
                          builder: (BuildContext context, int index) {
                        if (index < 0 || index > widget.items.length - 1) {
                          return null;
                        }

                        var value = widget.items[index];

                        final TextStyle itemStyle = (index == selectedValue)
                            ? selectedStyle
                            : defaultStyle;

                        return Center(
                          child: AnimatedDefaultTextStyle(
                            style: itemStyle,
                            duration: const Duration(milliseconds: 100),
                            child: Text(value),
                          ),
                        );
                      }),
                      controller: scrollController,
                      itemExtent: ScrollPicker.itemHeight,
                      onSelectedItemChanged: _onSelectedItemChanged,
                      physics: const FixedExtentScrollPhysics(),
                    ),
                  ),
                ),
                IgnorePointer(
                  child: Center(
                    child: Container(
                      height: ScrollPicker.itemHeight,
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(
                              color: themeData.backgroundColor, width: 1.0),
                          bottom: BorderSide(
                              color: themeData.backgroundColor, width: 1.0),
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  void _itemTapped(TapUpDetails details) {
    Offset position = details.localPosition;
    double center = widgetHeight / 2;
    double changeBy = position.dy - center;
    double newPosition = scrollController.offset + changeBy;

    // animate to and center on the selected item
    scrollController.animateTo(newPosition,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOutQuad);
  }

  void _onSelectedItemChanged(int index) {
    if (index != selectedValue) {
      selectedValue = index;
      widget.onChanged(selectedValue);
    }
  }
}
