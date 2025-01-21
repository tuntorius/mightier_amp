import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef TextMapper = String Function(String numberText);

class NumberPicker extends StatefulWidget {
  /// Min value user can pick
  final int minValue;

  /// Max value user can pick
  final int maxValue;

  /// Currently selected value
  final int value;

  /// Called when selected value changes
  final ValueChanged<int>? onChanged;

  /// Specifies how many items should be shown - defaults to 3
  final int itemCount;

  /// Step between elements. Only for integer datePicker
  /// Examples:
  /// if step is 100 the following elements may be 100, 200, 300...
  /// if min=0, max=6, step=3, then items will be 0, 3 and 6
  /// if min=0, max=5, step=3, then items will be 0 and 3.
  final int step;

  /// height of single item in pixels
  final double itemHeight;

  /// width of single item in pixels
  final double itemWidth;

  /// Direction of scrolling
  final Axis axis;

  /// Style of non-selected numbers. If null, it uses Theme's bodyText2
  final TextStyle? textStyle;

  /// Style of non-selected numbers. If null, it uses Theme's headline5 with accentColor
  final TextStyle? selectedTextStyle;

  /// Whether to trigger haptic pulses or not
  final bool haptics;

  /// Build the text of each item on the picker
  final TextMapper? textMapper;

  /// Pads displayed integer values up to the length of maxValue
  final bool zeroPad;

  /// display the number in hex format
  final bool hex;

  /// Symbol to display instead of zero
  final String? zeroSymbol;

  /// Decoration to apply to central box where the selected value is placed
  final Decoration? decoration;

  const NumberPicker({
    Key? key,
    required this.minValue,
    required this.maxValue,
    required this.value,
    required this.onChanged,
    this.itemCount = 3,
    this.step = 1,
    this.itemHeight = 50,
    this.itemWidth = 100,
    this.axis = Axis.vertical,
    this.textStyle,
    this.selectedTextStyle,
    this.haptics = false,
    this.decoration,
    this.hex = false,
    this.zeroSymbol,
    this.zeroPad = false,
    this.textMapper,
  })  : assert(minValue <= value),
        assert(value <= maxValue),
        super(key: key);

  @override
  State createState() => _NumberPickerState();
}

class _NumberPickerState extends State<NumberPicker> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    final initialOffset =
        (widget.value - widget.minValue) ~/ widget.step * itemExtent;
    _scrollController = ScrollController(initialScrollOffset: initialOffset)
      ..addListener(_scrollListener);
  }

  void _scrollListener() {
    final indexOfMiddleElement =
        (_scrollController.offset / itemExtent).round().clamp(0, itemCount - 1);
    final intValueInTheMiddle = _intValueFromIndex(indexOfMiddleElement + 1);

    if (widget.value != intValueInTheMiddle) {
      widget.onChanged?.call(intValueInTheMiddle);
      if (widget.haptics) {
        HapticFeedback.selectionClick();
      }
    }
    Future.delayed(
      const Duration(milliseconds: 100),
      () => _maybeCenterValue(),
    );
  }

  @override
  void didUpdateWidget(NumberPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _maybeCenterValue();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  bool get isScrolling => _scrollController.position.isScrollingNotifier.value;

  double get itemExtent =>
      widget.axis == Axis.vertical ? widget.itemHeight : widget.itemWidth;

  int get itemCount => (widget.maxValue - widget.minValue) ~/ widget.step + 1;

  int get listItemsCount => itemCount + 2;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.axis == Axis.vertical
          ? widget.itemWidth
          : widget.itemCount * widget.itemWidth,
      height: widget.axis == Axis.vertical
          ? widget.itemCount * widget.itemHeight
          : widget.itemHeight,
      child: NotificationListener<ScrollEndNotification>(
        onNotification: (not) {
          if (not.dragDetails?.primaryVelocity == 0) {
            Future.microtask(() => _maybeCenterValue());
          }
          return true;
        },
        child: Stack(
          children: [
            ListView.builder(
              itemCount: listItemsCount,
              scrollDirection: widget.axis,
              controller: _scrollController,
              itemExtent: itemExtent,
              itemBuilder: _itemBuilder,
            ),
            _NumberPickerSelectedItemDecoration(
              axis: widget.axis,
              itemExtent: itemExtent,
              decoration: widget.decoration,
            ),
          ],
        ),
      ),
    );
  }

  Widget _itemBuilder(BuildContext context, int index) {
    final themeData = Theme.of(context);
    final defaultStyle = widget.textStyle ?? themeData.textTheme.bodyMedium;
    final selectedStyle = widget.selectedTextStyle ??
        themeData.textTheme.headlineSmall
            ?.copyWith(color: themeData.colorScheme.surface);

    final value = _intValueFromIndex(index);
    final isExtra = index == 0 || index == listItemsCount - 1;
    final itemStyle = value == widget.value ? selectedStyle : defaultStyle;

    final child = isExtra
        ? const SizedBox.shrink()
        : Text(
            _getDisplayedValue(value),
            style: itemStyle,
          );

    return Container(
      width: widget.itemWidth,
      height: widget.itemHeight,
      alignment: Alignment.center,
      child: child,
    );
  }

  String _getDisplayedValue(int value) {
    String text = "";
    if (value == 0 && widget.zeroSymbol != null) return widget.zeroSymbol!;
    if (widget.hex) {
      text = value.toRadixString(16).padLeft(2, '0');
      return text;
    } else {
      String strValue = value.toString();
      text = widget.zeroPad
          ? strValue.padLeft(widget.maxValue.toString().length, '0')
          : strValue.toString();
    }
    if (widget.textMapper != null) {
      return widget.textMapper!(text);
    } else {
      return text;
    }
  }

  int _intValueFromIndex(int index) {
    index--;
    index %= itemCount;
    return widget.minValue + index * widget.step;
  }

  void _maybeCenterValue() {
    if (_scrollController.hasClients && !isScrolling) {
      int diff = widget.value - widget.minValue;
      int index = diff ~/ widget.step;
      _scrollController.animateTo(
        index * itemExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
    }
  }
}

class _NumberPickerSelectedItemDecoration extends StatelessWidget {
  final Axis axis;
  final double itemExtent;
  final Decoration? decoration;

  const _NumberPickerSelectedItemDecoration({
    Key? key,
    required this.axis,
    required this.itemExtent,
    required this.decoration,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: IgnorePointer(
        child: Container(
          width: isVertical ? double.infinity : itemExtent,
          height: isVertical ? itemExtent : double.infinity,
          decoration: decoration,
        ),
      ),
    );
  }

  bool get isVertical => axis == Axis.vertical;
}
