import 'dart:math';

import 'package:flutter/material.dart';

import 'nestedWillPopScope.dart';

class Bubble {
  const Bubble(
      {required this.title,
      required this.titleStyle,
      required this.iconColor,
      required this.bubbleColor,
      required this.icon,
      required this.onPress});

  final IconData icon;
  final Color iconColor;
  final Color bubbleColor;
  final Function() onPress;
  final String title;
  final TextStyle titleStyle;
}

class BubbleMenu extends StatelessWidget {
  const BubbleMenu(this.item, {Key? key}) : super(key: key);

  final Bubble item;

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      shape: const StadiumBorder(),
      padding: const EdgeInsets.only(top: 11, bottom: 13, left: 32, right: 32),
      color: item.bubbleColor,
      splashColor: Colors.grey.withOpacity(0.1),
      highlightColor: Colors.grey.withOpacity(0.1),
      elevation: 2,
      highlightElevation: 2,
      disabledColor: item.bubbleColor,
      onPressed: item.onPress,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(
            item.icon,
            color: item.iconColor,
          ),
          const SizedBox(
            width: 10.0,
          ),
          Text(
            item.title,
            style: item.titleStyle,
          ),
        ],
      ),
    );
  }
}

class _DefaultHeroTag {
  const _DefaultHeroTag();
  @override
  String toString() => '<default FloatingActionBubble tag>';
}

class FloatingActionBubble extends AnimatedWidget {
  const FloatingActionBubble({
    Key? key,
    required this.items,
    required this.onPress,
    required this.iconColor,
    required this.backGroundColor,
    required Animation animation,
    this.herotag,
    this.iconData,
    this.animatedIconData,
  })  : assert((iconData == null && animatedIconData != null) ||
            (iconData != null && animatedIconData == null)),
        super(key: key, listenable: animation);

  final List<Bubble> items;
  final Function() onPress;
  final AnimatedIconData? animatedIconData;
  final Object? herotag;
  final IconData? iconData;
  final Color iconColor;
  final Color backGroundColor;

  get _animation => listenable;

  Widget buildItem(BuildContext context, int index) {
    final transform = Matrix4.translationValues(
      0,
      -(_animation.value - 1) * 40 * (items.length - index),
      0.0,
    );

    return Transform(
      transform: transform,
      child: Opacity(
        opacity: _animation.value,
        child: BubbleMenu(items[index]),
      ),
    );
  }

  List<Widget> buildItems(BuildContext context) {
    var widgets = <Widget>[];
    var sb = const SizedBox(height: 12.0);
    for (int i = 0; i < items.length; i++) {
      widgets.add(buildItem(context, i));
      if (i < items.length - 1) widgets.add(sb);
    }

    return widgets;
  }

  Future<bool> _preventPopIfOpen() async {
    if (_animation.value > 0.8) {
      onPress();
      return false;
    }
    return true;
  }

  buildBackgroundWidget() {
    double val = _animation.value;
    return IgnorePointer(
      ignoring: val == 0,
      child: InkWell(
        onTap: onPress,
        child: Opacity(
          opacity: val,
          child: const ColoredBox(
            color: Colors.black54,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return NestedWillPopScope(
      onWillPop: _preventPopIfOpen,
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          buildBackgroundWidget(),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Flexible(
                  child: IgnorePointer(
                    ignoring: _animation.value == 0,
                    child: SingleChildScrollView(
                        // physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: buildItems(context),
                        )),
                  ),
                ),
                Transform.rotate(
                  angle: _animation.value * pi * 3 / 4,
                  child: FloatingActionButton(
                    heroTag: herotag ?? const _DefaultHeroTag(),
                    backgroundColor: backGroundColor,
                    onPressed: onPress,
                    // iconData is mutually exclusive with animatedIconData
                    // only 1 can be null at the time
                    child: iconData == null
                        ? AnimatedIcon(
                            icon: animatedIconData!,
                            progress: _animation,
                            color: iconColor,
                          )
                        : Icon(
                            iconData,
                            color: iconColor,
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
