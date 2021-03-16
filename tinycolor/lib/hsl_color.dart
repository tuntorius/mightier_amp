class HslColor {
  double h;
  double s;
  double l;
  double a;

  HslColor({required this.h, required this.s, required this.l, this.a = 0.0});

  String toString() {
    return "HSL(h: $h, s: $s, l: $l, a: $a)";
  }
}
