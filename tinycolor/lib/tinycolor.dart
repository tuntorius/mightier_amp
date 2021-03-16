import 'dart:math' as Math;
import 'dart:ui';

import 'package:flutter/painting.dart';

import 'color_from_string.dart';
import 'conversion.dart';
import 'hsl_color.dart';
import 'util.dart';

export 'hsl_color.dart';
export 'color_extension.dart';

class TinyColor {
  final Color originalColor;
  late Color _color;

  TinyColor(Color color) : this.originalColor = color {
    this._color =
        Color.fromARGB(color.alpha, color.red, color.green, color.blue);
  }

  factory TinyColor.fromRGB(
      {required int r, required int g, required int b, int a = 100}) {
    return TinyColor(Color.fromARGB(a, r, g, b));
  }

  factory TinyColor.fromHSL(HslColor hsl) {
    return TinyColor(hslToColor(hsl));
  }

  factory TinyColor.fromHSV(HSVColor hsv) {
    return TinyColor(hsv.toColor());
  }

  factory TinyColor.fromString(String string) {
    return TinyColor(colorFromString(string));
  }

  bool isDark() {
    return this.getBrightness() < 128.0;
  }

  bool isLight() {
    return !this.isDark();
  }

  double getBrightness() {
    return (_color.red * 299 + _color.green * 587 + _color.blue * 114) / 1000;
  }

  double getLuminance() {
    return _color.computeLuminance();
  }

  TinyColor setAlpha(int alpha) {
    _color.withAlpha(alpha);
    return this;
  }

  TinyColor setOpacity(double opacity) {
    _color.withOpacity(opacity);
    return this;
  }

  HSVColor toHsv() {
    return colorToHsv(_color);
  }

  HslColor toHsl() {
    final hsl = rgbToHsl(
      r: _color.red.toDouble(),
      g: _color.green.toDouble(),
      b: _color.blue.toDouble(),
    );
    return HslColor(
        h: hsl.h * 360, s: hsl.s, l: hsl.l, a: _color.alpha.toDouble());
  }

  TinyColor clone() {
    return TinyColor(_color);
  }

  TinyColor lighten([int amount = 10]) {
    final hsl = this.toHsl();
    hsl.l += amount / 100;
    hsl.l = clamp01(hsl.l);
    return TinyColor.fromHSL(hsl);
  }

  TinyColor brighten([int amount = 10]) {
    final color = Color.fromARGB(
      _color.alpha,
      Math.max(0, Math.min(255, _color.red - (255 * -(amount / 100)).round())),
      Math.max(
          0, Math.min(255, _color.green - (255 * -(amount / 100)).round())),
      Math.max(0, Math.min(255, _color.blue - (255 * -(amount / 100)).round())),
    );
    return TinyColor(color);
  }

  TinyColor darken([int amount = 10]) {
    final hsl = this.toHsl();
    hsl.l -= amount / 100;
    hsl.l = clamp01(hsl.l);
    return TinyColor.fromHSL(hsl);
  }

  TinyColor tint([int amount = 10]) {
    return this.mix(input: Color.fromRGBO(255, 255, 255, 1.0));
  }

  TinyColor shade([int amount = 10]) {
    return this.mix(input: Color.fromRGBO(0, 0, 0, 1.0));
  }

  TinyColor desaturate([int amount = 10]) {
    final hsl = this.toHsl();
    hsl.s -= amount / 100;
    hsl.s = clamp01(hsl.s);
    return TinyColor.fromHSL(hsl);
  }

  TinyColor saturate([int amount = 10]) {
    final hsl = this.toHsl();
    hsl.s += amount / 100;
    hsl.s = clamp01(hsl.s);
    return TinyColor.fromHSL(hsl);
  }

  TinyColor greyscale() {
    return desaturate(100);
  }

  TinyColor spin(double amount) {
    final hsl = this.toHsl();
    final hue = (hsl.h + amount) % 360;
    hsl.h = hue < 0 ? 360 + hue : hue;
    return TinyColor.fromHSL(hsl);
  }

  TinyColor mix({required Color input, int amount = 50}) {
    final int p = (amount / 100).round();
    final color = Color.fromARGB(
        (input.alpha - _color.alpha) * p + _color.alpha,
        (input.red - _color.red) * p + _color.red,
        (input.green - _color.green) * p + _color.green,
        (input.blue - _color.blue) * p + _color.blue);
    return TinyColor(color);
  }

  TinyColor complement() {
    final hsl = this.toHsl();
    hsl.h = (hsl.h + 180) % 360;
    return TinyColor.fromHSL(hsl);
  }

  Color get color {
    return _color;
  }
}
