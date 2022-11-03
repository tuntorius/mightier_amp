import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class PresetListTest extends StatefulWidget {
  const PresetListTest({Key? key}) : super(key: key);

  @override
  State<PresetListTest> createState() => _PresetListTestState();
}

class _PresetListTestState extends State<PresetListTest>
    with AutomaticKeepAliveClientMixin<PresetListTest> {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        ExpansionTile(
          title: Text("Expand me"),
          children: [
            SizedBox(
              height: 200,
              child: ReorderableListView.builder(
                itemCount: 3,
                dragStartBehavior: DragStartBehavior.down,
                proxyDecorator: (child, index, anim) {
                  return AnimatedBuilder(
                    animation: anim,
                    builder: (BuildContext context, Widget? child) {
                      final double animValue =
                          Curves.easeInOut.transform(anim.value);
                      final double elevation = lerpDouble(0, 10, animValue)!;
                      return Transform.translate(
                        offset: Offset(0, -elevation),
                        child: Material(
                          elevation: elevation,
                          color: Colors.blue,
                          child: Text("Ni moji"),
                        ),
                      );
                    },
                    child: child,
                  );
                },
                itemBuilder: (context, index) {
                  return ListTile(
                    key: Key(index.toString()),
                    title: Text("Row $index"),
                  );
                },
                onReorder: (a, b) {},
              ),
            )
          ],
        ),
        ExpansionTile(
          title: Text("Expand me"),
          children: [
            SizedBox(
              height: 200,
              child: ReorderableListView.builder(
                itemCount: 3,
                itemBuilder: (context, index) {
                  return ListTile(
                    key: Key(index.toString()),
                    title: Text("Row $index"),
                  );
                },
                onReorder: (a, b) {},
              ),
            )
          ],
        )
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
