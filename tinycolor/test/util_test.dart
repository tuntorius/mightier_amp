import 'package:flutter_test/flutter_test.dart';
//import 'package:test/test.dart';
import 'package:tinycolor/util.dart';

void main() {
  test("bound01 values", () {
    expect(bound01(0.5, 1.0), 0.5);
    expect(bound01(50.0, 100.0), 0.5);
    expect(bound01(20.0, 200.0), 0.1);
    expect(bound01(25.0, 75.0), 0.3333333333333333);
  });

  test("clamp01 values", () {
    expect(clamp01(10.0), 1.0);
    expect(clamp01(0.5), 0.5);
    expect(clamp01(1.5), 1.0);
    expect(clamp01(0.75), 0.75);
    expect(clamp01(1.1), 1.0);
  });
}
