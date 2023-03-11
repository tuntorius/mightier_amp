import 'package:flutter/widgets.dart';

enum LayoutMode { navBar, drawer }

enum EditorLayoutMode { scroll, expand }

LayoutMode getLayoutMode(MediaQueryData mediaQuery) {
  final screenWidth = mediaQuery.size.width;
  final screenHeight = mediaQuery.size.height;
  if (screenHeight > 650) return LayoutMode.navBar;
  if (screenWidth >= 500) return LayoutMode.drawer;
  return LayoutMode.navBar;
}

EditorLayoutMode getEditorLayoutMode(MediaQueryData mediaQuery) {
  final screenHeight = mediaQuery.size.height;
  if (screenHeight <= 580) return EditorLayoutMode.scroll;
  return EditorLayoutMode.expand;
}
