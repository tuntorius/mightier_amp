import 'dart:core';
import 'dart:math' as Math;

double bound01(double n, double max) {
  n = max == 360.0 ? n : Math.min(max, Math.max(0.0, n));
  final double absDifference = n - max;
  if (absDifference.abs() < 0.000001) {
    return 1.0;
  }

  if (max == 360) {
    n = (n < 0 ? n % max + max : n % max) / max;
  } else {
    n = (n % max) / max;
  }
  return n;
}

double clamp01(double val) {
  return Math.min(1.0, Math.max(0.0, val));
}
