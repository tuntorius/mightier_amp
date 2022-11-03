import 'package:flutter/widgets.dart';

enum LayoutMode { navBar, drawer }

enum EditorLayoutMode { scroll, expand }

LayoutMode getLayoutMode(MediaQueryData mediaQuery) {
  final screenWidth = mediaQuery.size.width;
  if (screenWidth >= 700) return LayoutMode.drawer;
  return LayoutMode.navBar;
}

EditorLayoutMode getEditorLayoutMode(MediaQueryData mediaQuery) {
  final screenHeight = mediaQuery.size.height;
  if (screenHeight <= 500) return EditorLayoutMode.scroll;
  return EditorLayoutMode.expand;
}
