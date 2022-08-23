library dynamic_treeview;

import 'package:flutter/material.dart';

//The MIT License (MIT)

//Copyright (c) 2019 Thangrobul Infimate

//Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
//documentation files (the "Software"), to deal in the Software without restriction, including without limitation
//the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and
//to permit persons to whom the Software is furnished to do so, subject to the following conditions:

//The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
//WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
//COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
//ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

///Callback when child/parent is tapped . Map data will contain {String 'id',String 'parent_id',String 'title',Map 'extra'}

typedef OnCategoryTap = Function(String title);
typedef OnCategoryLongPress = Function(String title);

typedef ChildBuilder = ChildBuilderInfo Function(dynamic item);

class ChildBuilderInfo {
  late Widget widget;
  late bool hasNewItems;
}

///A tree view that supports indefinite category/subcategory lists with horizontal and vertical scrolling
class DynamicTreeView extends StatefulWidget {
  ///DynamicTreeView will be build based on this.Create a model class and implement [BaseData]
  final List<dynamic> items;
  final List<String> categories;

  ///Called when DynamicTreeView parent or children gets tapped.
  ///Map will contain the following keys :
  ///id , parent_id , title , extra
  final OnCategoryTap onCategoryTap;
  final OnCategoryLongPress onCategoryLongPress;

  final ChildBuilder childBuilder;

  final PopupMenuItemBuilder itemBuilder;
  final Function(int, String) onSelected;
  final bool simplified;

  ///The width of DynamicTreeView
  //final double width;

  ///Configuration object for [DynamicTreeView]
  final Config config;
  const DynamicTreeView({
    Key? key,
    required this.items,
    required this.categories,
    this.config = const Config(),
    required this.onCategoryTap,
    required this.onCategoryLongPress,
    required this.itemBuilder,
    required this.onSelected,
    this.simplified = false,
    required this.childBuilder,
    //this.width = 220.0,
  }) : super(key: key);

  @override
  _DynamicTreeViewOriState createState() => _DynamicTreeViewOriState();
}

class _DynamicTreeViewOriState extends State<DynamicTreeView> {
  List<Widget> treeView = [];
  bool hasNewItems = false;
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  _buildTreeView() {
    var k = widget.categories;

    var widgets = <Widget>[];

    for (var i = 0; i < k.length; i++) {
      widgets.add(buildWidget(k[i]));
    }

    setState(() {
      treeView = widgets;
    });
  }

  ParentWidget buildWidget(String d) {
    var p = ParentWidget(
      onTap: widget.onCategoryTap,
      onLongPress: widget.onCategoryLongPress,
      itemBuilder: widget.itemBuilder,
      onSelected: widget.onSelected,
      config: widget.config,
      simplified: widget.simplified,
      children: _buildChildren(d),
      hasNewItems: hasNewItems,
      title: d,
      key: Key(d),
    );
    return p;
  }

  List<Widget> _buildChildren(String category) {
    var cW = <Widget>[];
    hasNewItems = false;
    for (var item in widget.items) {
      if (item["category"] == category) {
        ChildBuilderInfo cbi = widget.childBuilder(item);
        cW.add(cbi.widget);
        if (cbi.hasNewItems) hasNewItems = true;
      }
    }
    return cW;
  }

  @override
  Widget build(BuildContext context) {
    _buildTreeView();
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: treeView,
      ),
    );
  }
}

class ChildWidget extends StatefulWidget {
  final List<Widget> children;
  final bool shouldExpand;
  final Config config;
  const ChildWidget(
      {Key? key,
      required this.children,
      required this.config,
      this.shouldExpand = false})
      : super(key: key);

  @override
  _ChildWidgetState createState() => _ChildWidgetState();
}

class _ChildWidgetState extends State<ChildWidget>
    with SingleTickerProviderStateMixin {
  late Animation<double> sizeAnimation;
  late AnimationController expandController;

  @override
  void didUpdateWidget(ChildWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.shouldExpand) {
      expandController.forward();
    } else {
      expandController.reverse();
    }
  }

  @override
  void initState() {
    prepareAnimation();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    expandController.dispose();
  }

  void prepareAnimation() {
    expandController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 200));
    Animation<double> curve =
        CurvedAnimation(parent: expandController, curve: Curves.fastOutSlowIn);
    sizeAnimation = Tween(begin: 0.0, end: 1.0).animate(curve);
  }

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      sizeFactor: sizeAnimation,
      axisAlignment: -1.0,
      child: Column(
        children: _buildChildren(),
      ),
    );
  }

  _buildChildren() {
    return widget.children.map((c) {
      // return c;
      return Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: widget.config.childrenPaddingEdgeInsets,
            child: c,
          ));
    }).toList();
  }
}

class ParentWidget extends StatefulWidget {
  final List<Widget> children;
  final Config config;
  final OnCategoryTap? onTap;
  final OnCategoryLongPress? onLongPress;
  final PopupMenuItemBuilder itemBuilder;
  final Function(int, String) onSelected;
  final bool simplified;
  final String title;
  final bool hasNewItems;
  const ParentWidget({
    this.onTap,
    this.onLongPress,
    required this.children,
    required this.config,
    required this.title,
    required this.onSelected,
    required this.itemBuilder,
    required this.simplified,
    required this.hasNewItems,
    Key? key,
  }) : super(key: key);

  @override
  _ParentWidgetState createState() => _ParentWidgetState();
}

class _ParentWidgetState extends State<ParentWidget>
    with SingleTickerProviderStateMixin {
  bool shouldExpand = false;
  late Animation<double> arrowAnimation;
  late AnimationController expandController;

  @override
  void dispose() {
    super.dispose();
    expandController.dispose();
  }

  @override
  void initState() {
    prepareAnimation();
    super.initState();
  }

  void prepareAnimation() {
    expandController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 300));
    Animation<double> curve =
        CurvedAnimation(parent: expandController, curve: Curves.fastOutSlowIn);
    arrowAnimation = Tween(begin: 0.0, end: 0.5).animate(curve);
  }

  @override
  Widget build(BuildContext context) {
    //create trailing widget based on whether the preset is new
    Widget? trailingWidget;
    if (widget.simplified)
      trailingWidget = null;
    else {
      var button = PopupMenuButton(
        icon: Padding(
          padding: const EdgeInsets.only(left: 16.0, right: 16),
          child: Icon(Icons.more_vert, color: Colors.grey),
        ),
        itemBuilder: widget.itemBuilder,
        onSelected: (pos) {
          if (pos is int) widget.onSelected(pos, widget.title);
        },
      );
      if (widget.hasNewItems)
        trailingWidget = Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.circle,
              color: Colors.blue,
              size: 16,
            ),
            button
          ],
        );
      else
        trailingWidget = button;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ListTile(
            tileColor: Colors.grey[800],
            onTap: () {
              widget.onTap?.call(widget.title);

              setState(() {
                shouldExpand = !shouldExpand;
              });
              if (shouldExpand) {
                expandController.forward();
              } else {
                expandController.reverse();
              }
            },
            onLongPress: () {
              if (!widget.simplified) widget.onLongPress?.call(widget.title);
            },
            title: Transform.translate(
                offset: Offset(-16, 0), //workaround until horizontalTitleGap
                //is available in release channel
                child:
                    Text(widget.title, style: widget.config.parentTextStyle)),
            contentPadding: widget.config.parentPaddingEdgeInsets,
            leading: RotationTransition(
              turns: arrowAnimation,
              child: widget.config.arrowIcon,
            ),
            trailing: trailingWidget),
        ChildWidget(
          children: widget.children,
          config: widget.config,
          shouldExpand: shouldExpand,
        )
      ],
    );
  }
}

///A singleton Child tap listener
class ChildTapListener extends ValueNotifier<Map<String, dynamic>> {
  /* static final ChildTapListener _instance = ChildTapListener.internal();

  factory ChildTapListener() => _instance;

  ChildTapListener.internal() : super(null); */
  Map<String, dynamic> mapValue = {};

  ChildTapListener(Map<String, dynamic> value) : super(value);

  // ChildTapListener() : super(null);

  void addMapValue(Map<String, dynamic> map) {
    this.mapValue = map;
    notifyListeners();
  }

  Map getMapValue() {
    return this.mapValue;
  }
}

class Config {
  final TextStyle parentTextStyle;
  final EdgeInsets childrenPaddingEdgeInsets;
  final EdgeInsets parentPaddingEdgeInsets;

  ///Animated icon when tile collapse/expand
  final Widget arrowIcon;

  const Config({
    this.parentTextStyle =
        const TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
    this.parentPaddingEdgeInsets = const EdgeInsets.all(6.0),
    this.childrenPaddingEdgeInsets =
        const EdgeInsets.only(left: 15.0, top: 0, bottom: 0),
    this.arrowIcon = const Icon(Icons.keyboard_arrow_down),
  });
}
