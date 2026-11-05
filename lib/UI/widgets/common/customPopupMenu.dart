// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

// Examples can assume:
// enum Commands { heroAndScholar, hurricaneCame }
// dynamic _heroAndScholar;
// dynamic _selection;
// BuildContext context;
// void setState(VoidCallback fn) { }

const Duration _kMenuDuration = Duration(milliseconds: 300);
const double _kBaselineOffsetFromBottom = 20.0;
const double _kMenuCloseIntervalEnd = 2.0 / 3.0;
const double _kMenuHorizontalPadding = 0.0; //16.0;
const double _kMenuItemHeight = 48.0;
const double _kMenuDividerHeight = 16.0;
const double _kMenuMaxWidth = 5.0 * _kMenuWidthStep;
const double _kMenuMinWidth = 2.0 * _kMenuWidthStep;
const double _kMenuVerticalPadding = 0.0; //8.0;
const double _kMenuWidthStep = 56.0;
const double _kMenuScreenPadding = 8.0;

/// A base class for entries in a material design popup menu.
///
/// The popup menu widget uses this interface to interact with the menu items.
/// To show a popup menu, use the [showMenu] function. To create a button that
/// shows a popup menu, consider using [PopupMenuButton].
///
/// The type `T` is the type of the value(s) the entry represents. All the
/// entries in a given menu must represent values with consistent types.
///
/// A [PopupMenuEntry] may represent multiple values, for example a row with
/// several icons, or a single entry, for example a menu item with an icon (see
/// [PopupMenuItem]), or no value at all (for example, [PopupMenuDivider]).
///
/// See also:
///
///  * [PopupMenuItem], a popup menu entry for a single value.
///  * [PopupMenuDivider], a popup menu entry that is just a horizontal line.
///  * [CheckedPopupMenuItem], a popup menu item with a checkmark.
///  * [showMenu], a method to dynamically show a popup menu at a given location.
///  * [PopupMenuButton], an [IconButton] that automatically shows a menu when
///    it is tapped.
abstract class PopupMenuEntry<T> extends StatefulWidget {
  /// Abstract const constructor. This constructor enables subclasses to provide
  /// const constructors so that they can be used in const expressions.
  const PopupMenuEntry({Key? key}) : super(key: key);

  /// The amount of vertical space occupied by this entry.
  ///
  /// This value is used at the time the [showMenu] method is called, if the
  /// `initialValue` argument is provided, to determine the position of this
  /// entry when aligning the selected entry over the given `position`. It is
  /// otherwise ignored.
  double get height;

  /// Whether this entry represents a particular value.
  ///
  /// This method is used by [showMenu], when it is called, to align the entry
  /// representing the `initialValue`, if any, to the given `position`, and then
  /// later is called on each entry to determine if it should be highlighted (if
  /// the method returns true, the entry will have its background set to the
  /// selected color).
  bool represents(T? value);
}

class LabeledDivider extends StatelessWidget {
  final String label;
  final Color? color;
  const LabeledDivider({Key? key, required this.label, this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    var c = color ?? Theme.of(context).textTheme.bodySmall?.color;
    return Row(
      children: [
        const SizedBox(
          width: 8,
        ),
        Text(
          label,
          style: TextStyle(color: c),
        ),
        const SizedBox(
          width: 8,
        ),
        Expanded(
          child: Container(
            color: c,
            height: 1,
          ),
        ),
        const SizedBox(
          width: 8,
        ),
      ],
    );
  }
}

/// A horizontal divider in a material design popup menu.
///
/// This goes between the logical sections of the popup menu.
///
/// See also:
///
///  * [PopupMenuItem], a popup menu entry for a single value.
///  * [showMenu], a method to dynamically show a popup menu at a given location.
///  * [PopupMenuButton], an [IconButton] that automatically shows a menu when
///    it is tapped.
class PopupMenuDivider extends PopupMenuEntry<Null> {
  /// Creates a horizontal divider for a popup menu.
  ///
  /// By default, the divider has a height of 16 logical pixels.
  const PopupMenuDivider({Key? key, this.height = _kMenuDividerHeight, this.text, this.color})
      : super(key: key);

  /// The height of the divider dimension.
  ///
  /// Defaults to 16 pixels.
  @override
  final double height;
  final String? text;
  final Color? color;

  @override
  bool represents(Null value) => false;

  @override
  _PopupMenuDividerState createState() => _PopupMenuDividerState();
}

class _PopupMenuDividerState extends State<PopupMenuDivider> {
  @override
  Widget build(BuildContext context) {
    if (widget.text == null) return Divider(height: widget.height);
    return LabeledDivider(
      label: widget.text!,
      color: widget.color,
    );
  }
}

/// An item in a material design popup menu.
///
/// To show a popup menu, use the [showMenu] function. To create a button that
/// shows a popup menu, consider using [PopupMenuButton].
///
/// To show a checkmark next to a popup menu item, consider using
/// [CheckedPopupMenuItem].
///
/// Typically the [child] of a [PopupMenuItem] is a [Text] widget. More
/// elaborate menus with icons can use a [ListTile]. By default, a
/// [PopupMenuItem] is 48 pixels high. If you use a widget with a different
/// height, the [height] property should be set to the same value.
///
/// {@tool sample}
///
/// Here, a [ContextMenu] class uses a generic [PopupMenuItem] to display
/// two options to the user:
///
/// ```dart
/// class ContextMenu extends StatelessWidget {
///   enum ContextMenuOptions { showDetails, delete }
///
///   @override
///   Widget build(BuildContext context) {
///     return PopupMenuButton<ContextMenuOptions>(
///       onSelected: (ContextMenuOptions result) {
///         switch (result) {
///           case ContextMenuOptions.showDetails:
///             break;
///           case ContextMenuOptions.delete:
///             break;
///         }
///       },
///       itemBuilder: (BuildContext context) => <PopupMenuEntry<ContextMenuOptions>>[
///         const PopupMenuItem<ContextMenuOptions>(
///           value: ContextMenuOptions.showDetails,
///           child: Text('Details'),
///         ),
///         const PopupMenuItem<ContextMenuOptions>(
///           value: ContextMenuOptions.delete,
///           child: Text('Delete'),
///         ),
///       ],
///     );
///   }
/// }
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [PopupMenuDivider], which can be used to divide logical sections of the menu.
///  * [showMenu], a method to dynamically show a popup menu at a given location.
///  * [PopupMenuButton], an [IconButton] that automatically shows a menu when
///    it is tapped.
class PopupMenuItem<T> extends PopupMenuEntry<T> {
  /// Creates an item for a popup menu.
  ///
  /// By default, the item is [enabled].
  ///
  /// The [height] and [enabled] arguments must not be null.
  const PopupMenuItem({
    Key? key,
    this.value,
    this.enabled = true,
    this.height = _kMenuItemHeight,
    this.textStyle,
    required this.child,
    this.backgroundColor,
  }) : super(key: key);

  /// The value that will be returned by [showMenu] if this entry is selected.
  final T? value;

  /// Whether a user can select this menu item.
  ///
  /// Defaults to true. If false, the item will not react to touches.
  final bool enabled;

  /// The minimum height of the menu item.
  ///
  /// Defaults to 48.0 pixels.
  @override
  final double height;

  /// The text style applied to the child.
  final TextStyle? textStyle;

  /// The widget below this widget in the tree.
  ///
  /// Typically a single-line [ListTile] (for menus with icons) or a [Text] widget.
  final Widget? child;

  final Color? backgroundColor;

  @override
  bool represents(T? value) => value == this.value;

  @override
  PopupMenuItemState<T, PopupMenuItem<T>> createState() =>
      PopupMenuItemState<T, PopupMenuItem<T>>();
}

/// The [State] for [PopupMenuItem] subclasses.
///
/// By default this implements the basic styling and interaction for a list
/// item in a popup menu.
///
/// The status of [enabled] will determine whether the menu item responds to
/// tap events.
class PopupMenuItemState<T, W extends PopupMenuItem<T>> extends State<W> {
  /// The menu item's child widget.
  ///
  /// Set by the default [build] implementation to [PopupMenuItem.child].
  @protected
  Widget? buildChild() => widget.child;

  /// The handler for when the user selects the menu item.
  ///
  /// Used by the [InkWell] in the default [build] implementation.
  @protected
  void handleTap() {
    Navigator.pop<T>(context, widget.value);
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final PopupMenuThemeData popupMenuTheme = PopupMenuTheme.of(context);
    TextStyle style = widget.textStyle ??
        popupMenuTheme.textStyle ??
        theme.textTheme.titleMedium!;

    if (!widget.enabled) style = style.copyWith(color: theme.disabledColor);

    Widget item = AnimatedDefaultTextStyle(
      style: style,
      duration: kThemeChangeDuration,
      child: Container(
        alignment: AlignmentDirectional.centerStart,
        constraints: BoxConstraints(minHeight: widget.height),
        padding:
            const EdgeInsets.symmetric(horizontal: _kMenuHorizontalPadding),
        child: buildChild(),
      ),
    );

    if (widget.backgroundColor != null) {
      item = Material(
        color: widget.backgroundColor,
        child: item,
      );
    }

    return InkWell(
      onTap: widget.enabled ? handleTap : null,
      canRequestFocus: widget.enabled,
      child: item,
    );
  }
}

/// An item with a checkmark in a material design popup menu.
///
/// To show a popup menu, use the [showMenu] function. To create a button that
/// shows a popup menu, consider using [PopupMenuButton].
///
/// A [CheckedPopupMenuItem] is 48 pixels high, which matches the default height
/// of a [PopupMenuItem]. The horizontal layout uses [ListTileStyle.drawer], but
/// can be overridden with [ListTileTheme].
///
/// {@tool sample}
///
/// Suppose a `Commands` enum with `heroAndScholar` and `hurricaneCame`
/// values, and a `_selection` field with the currently-selected value:
///
/// ```dart
/// CheckedPopupMenuItem<Commands>(
///   value: Commands.heroAndScholar,
///   checked: _selection == Commands.heroAndScholar,
///   child: const Text('Hero and scholar'),
/// )
/// ```
/// {@end-tool}
///
/// See also:
///
///  * [PopupMenuItem], a popup menu entry for a single value.
///  * [PopupMenuDivider], a popup menu entry that is just a horizontal line.
///  * [showMenu], a method to dynamically show a popup menu at a given location.
///  * [PopupMenuButton], an [IconButton] that automatically shows a menu when
///    it is tapped.
class CheckedPopupMenuItem<T> extends PopupMenuItem<T> {
  /// Creates a popup menu item with a checkmark.
  ///
  /// By default, the item is [enabled] but unticked ([checked] is false).
  ///
  /// To visually mark the item as checked, set [checked] to true.
  ///
  /// The [checked] and [enabled] arguments must not be null.
  const CheckedPopupMenuItem({
    Key? key,
    T? value,
    this.checked = false,
    bool enabled = true,
    Widget? child,
  }) : super(
          key: key,
          value: value,
          enabled: enabled,
          child: child,
        );

  /// Whether to display a checkmark next to the label.
  ///
  /// Defaults to false.
  final bool checked;

  @override
  Widget? get child => super.child;

  @override
  _CheckedPopupMenuItemState<T> createState() =>
      _CheckedPopupMenuItemState<T>();
}

class _CheckedPopupMenuItemState<T>
    extends PopupMenuItemState<T, CheckedPopupMenuItem<T>>
    with SingleTickerProviderStateMixin {
  static const Duration _kFadeOutDuration = Duration(milliseconds: 150);

  AnimationController? _controller;
  Animation<double> get _opacity => _controller!.view;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: _kFadeOutDuration, vsync: this)
      ..value = widget.checked ? 1.0 : 0.0
      ..addListener(() => setState(() {/* animation changed */}));
  }

  @override
  void handleTap() {
    // This fades the checkmark in or out when tapped.
    if (widget.checked) {
      _controller!.reverse();
    } else {
      _controller!.forward();
    }
    super.handleTap();
  }

  @override
  Widget buildChild() {
    return ListTile(
      enabled: widget.enabled,
      leading: FadeTransition(
        opacity: _opacity,
        child: Icon(_controller!.isDismissed ? null : Icons.done),
      ),
      title: widget.child,
      hoverColor: Colors.transparent,
    );
  }
}

class _PopupMenu<T> extends StatelessWidget {
  const _PopupMenu({
    Key? key,
    required this.route,
    required this.semanticLabel,
    this.controller,
  }) : super(key: key);

  final _PopupMenuRoute<T> route;
  final String semanticLabel;
  final ScrollController? controller;

  @override
  Widget build(BuildContext context) {
    final double unit = 1.0 / (route.items.length + 1.5);
    final List<Widget> children = <Widget>[];

    for (int i = 0; i < route.items.length; i += 1) {
      final double start = (i + 1) * unit;
      final double end = (start + 1.5 * unit).clamp(0.0, 1.0);
      final CurvedAnimation opacity = CurvedAnimation(
        parent: route.animation!,
        curve: Interval(start, end),
      );
      Widget item = route.items[i];
      if (route.initialValue != null &&
          route.items[i].represents(route.initialValue)) {
        item = Container(
          color: Theme.of(context).highlightColor,
          child: item,
        );
      }
      children.add(FadeTransition(
        opacity: opacity,
        child: item,
      ));
    }

    final CurveTween opacity =
        CurveTween(curve: const Interval(0.0, 1.0 / 3.0));
    final CurveTween width = CurveTween(curve: Interval(0.0, unit));
    final CurveTween height =
        CurveTween(curve: Interval(0.0, unit * route.items.length));

    final Widget child = ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: _kMenuMinWidth,
        maxWidth: _kMenuMaxWidth,
      ),
      child: SingleChildScrollView(
        controller: controller,
        padding: const EdgeInsets.symmetric(
          vertical: _kMenuVerticalPadding,
        ),
        child: ListBody(children: children),
      ),
    );

    return AnimatedBuilder(
      animation: route.animation!,
      builder: (BuildContext context, Widget? child) {
        return Opacity(
          opacity: opacity.evaluate(route.animation!),
          child: Material(
            type: MaterialType.card,
            elevation: route.elevation,
            child: Align(
              alignment: AlignmentDirectional.topEnd,
              widthFactor: width.evaluate(route.animation!),
              heightFactor: height.evaluate(route.animation!),
              child: child,
            ),
          ),
        );
      },
      child: child,
    );
  }
}

// Positioning of the menu on the screen.
class _PopupMenuRouteLayout extends SingleChildLayoutDelegate {
  _PopupMenuRouteLayout(
      this.position, this.selectedItemOffset, this.textDirection);

  // Rectangle of underlying button, relative to the overlay's dimensions.
  final RelativeRect position;

  // The distance from the top of the menu to the middle of selected item.
  final double selectedItemOffset;

  // Whether to prefer going to the left or to the right.
  final TextDirection textDirection;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    return BoxConstraints.loose(constraints.biggest -
            const Offset(_kMenuScreenPadding * 2.0, _kMenuScreenPadding * 2.0)
        as Size);
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    // 1. Consistent vertical positioning:
    // Anchor directly beneath the button, flipping above only if it exceeds the screen bottom.
    final double buttonBottom = size.height - position.bottom;
    final double buttonTop = position.top;
    double y;

    if (buttonBottom + childSize.height <= size.height - _kMenuScreenPadding) {
      y = buttonBottom;
    } else if (buttonTop - childSize.height >= _kMenuScreenPadding) {
      y = buttonTop - childSize.height;
    } else {
      y = buttonBottom.clamp(
        _kMenuScreenPadding,
        size.height - childSize.height - _kMenuScreenPadding,
      );
    }

    // Find the ideal horizontal position.
    double x;
    if (position.left > position.right) {
      // Menu button is closer to the right edge, so grow to the left, aligned to the right edge.
      x = size.width - position.right - childSize.width;
    } else if (position.left < position.right) {
      // Menu button is closer to the left edge, so grow to the right, aligned to the left edge.
      x = position.left;
    } else {
      // Menu button is equidistant from both edges, so grow in reading direction.
      switch (textDirection) {
        case TextDirection.rtl:
          x = size.width - position.right - childSize.width;
          break;
        case TextDirection.ltr:
          x = position.left;
          break;
      }
    }

    // Avoid going outside an area defined as the rectangle 8.0 pixels from the
    // edge of the screen in every direction.
    if (x < _kMenuScreenPadding) {
      x = _kMenuScreenPadding;
    } else if (x + childSize.width > size.width - _kMenuScreenPadding) {
      x = size.width - childSize.width - _kMenuScreenPadding;
    }
    if (y < _kMenuScreenPadding) {
      y = _kMenuScreenPadding;
    } else if (y + childSize.height > size.height - _kMenuScreenPadding) {
      y = size.height - childSize.height - _kMenuScreenPadding;
    }
    return Offset(x, y);
  }

  @override
  bool shouldRelayout(_PopupMenuRouteLayout oldDelegate) {
    return position != oldDelegate.position;
  }
}

class _PopupMenuRoute<T> extends PopupRoute<T> {
  _PopupMenuRoute({
    required this.position,
    required this.items,
    this.initialValue,
    this.elevation = 8,
    required this.theme,
    required this.barrierLabel,
    required this.semanticLabel,
  });

  final RelativeRect position;
  final List<PopupMenuEntry<T>> items;
  final dynamic initialValue;
  final double elevation;
  final ThemeData theme;
  final String semanticLabel;

  @override
  Animation<double> createAnimation() {
    return CurvedAnimation(
      parent: super.createAnimation(),
      curve: Curves.linear,
      reverseCurve: const Interval(0.0, _kMenuCloseIntervalEnd),
    );
  }

  @override
  Duration get transitionDuration => _kMenuDuration;

  @override
  bool get barrierDismissible => true;

  @override
  Color? get barrierColor => null;

  @override
  final String barrierLabel;

  ScrollController? scrollController;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    double selectedItemOffset = 0;
    double scrollItemOffset = 0;
    if (initialValue != null) {
      double y = _kMenuVerticalPadding;
      for (PopupMenuEntry<T> entry in items) {
        if (entry.represents(initialValue)) {
          selectedItemOffset = y + entry.height / 2.0;
          scrollItemOffset = y - entry.height / 2.0;
          break;
        }
        y += entry.height;
      }
    }

    scrollController = ScrollController(initialScrollOffset: scrollItemOffset);
    Widget menu = _PopupMenu<T>(
        route: this,
        semanticLabel: semanticLabel,
        controller: scrollController);
    menu = Theme(data: theme, child: menu);

    return SafeArea(
      child: Builder(
        builder: (BuildContext context) {
          return CustomSingleChildLayout(
            delegate: _PopupMenuRouteLayout(
              position,
              selectedItemOffset,
              Directionality.of(context),
            ),
            child: menu,
          );
        },
      ),
    );
  }
}

/// Show a popup menu that contains the `items` at `position`.
Future<T?> showMenu<T>({
  required BuildContext context,
  required RelativeRect position,
  required List<PopupMenuEntry<T>> items,
  T? initialValue,
  double elevation = 8.0,
  String semanticLabel = "",
}) {
  assert(items.isNotEmpty);
  assert(debugCheckHasMaterialLocalizations(context));
  String label = semanticLabel;
  switch (defaultTargetPlatform) {
    case TargetPlatform.iOS:
      label = semanticLabel;
      break;
    case TargetPlatform.android:
    case TargetPlatform.fuchsia:
      label = semanticLabel.isNotEmpty
          ? semanticLabel
          : MaterialLocalizations.of(context).popupMenuLabel;
      break;
    default:
      label = semanticLabel;
  }

  return Navigator.push(
      context,
      _PopupMenuRoute<T>(
        position: position,
        items: items,
        initialValue: initialValue,
        elevation: elevation,
        semanticLabel: label,
        theme: Theme.of(context),
        barrierLabel:
            MaterialLocalizations.of(context).modalBarrierDismissLabel,
      ));
}

/// Signature for the callback invoked when a menu item is selected.
typedef PopupMenuItemSelected<T> = void Function(T value);

/// Signature for the callback invoked when a [PopupMenuButton] is dismissed without selecting an item.
typedef PopupMenuCanceled = void Function();

/// Signature used by [PopupMenuButton] to lazily construct the items shown when the button is pressed.
typedef PopupMenuItemBuilder<T> = List<PopupMenuEntry<T>> Function(
    BuildContext context);

/// Displays a menu when pressed and calls [onSelected] when the menu is dismissed.
class PopupMenuButton<T> extends StatelessWidget {
  const PopupMenuButton({
    Key? key,
    required this.itemBuilder,
    this.initialValue,
    this.onSelected,
    this.onCanceled,
    this.tooltip,
    this.elevation = 8.0,
    this.padding = const EdgeInsets.all(8.0),
    this.child,
    this.icon,
    this.offset = Offset.zero,
    this.enabled = true,
  })  : assert(!(child != null && icon != null)),
        super(key: key);

  final PopupMenuItemBuilder<T> itemBuilder;
  final T? initialValue;
  final PopupMenuItemSelected<T>? onSelected;
  final PopupMenuCanceled? onCanceled;
  final String? tooltip;
  final double elevation;
  final EdgeInsetsGeometry padding;
  final Widget? child;
  final Icon? icon;
  final Offset offset;
  final bool enabled;

  void showButtonMenu(BuildContext context) {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Overlay.of(context).context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(offset, ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero) + offset,
            ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );
    final List<PopupMenuEntry<T>> items = itemBuilder(context);
    if (items.isNotEmpty) {
      showMenu<T>(
        context: context,
        elevation: elevation,
        items: items,
        initialValue: initialValue,
        position: position,
      ).then<void>((T? newValue) {
        if (newValue == null) {
          onCanceled?.call();
          return null;
        }
        onSelected?.call(newValue);
      });
    }
  }

  Icon _getIcon(TargetPlatform platform) {
    switch (platform) {
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
        return const Icon(Icons.more_vert);
      case TargetPlatform.iOS:
        return const Icon(Icons.more_horiz);
      default:
        return const Icon(Icons.more_vert);
    }
  }

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasMaterialLocalizations(context));
    return child != null
        ? InkWell(
            onTap: enabled ? () => showButtonMenu(context) : null,
            child: child,
          )
        : IconButton(
            icon: icon ?? _getIcon(Theme.of(context).platform),
            padding: padding,
            tooltip:
                tooltip ?? MaterialLocalizations.of(context).showMenuTooltip,
            onPressed: enabled ? () => showButtonMenu(context) : null,
          );
  }
}