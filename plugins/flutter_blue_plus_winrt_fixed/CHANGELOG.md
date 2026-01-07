## 0.0.9
* Fix: "vector erase iterator outside range" crash by safely handling device closure to avoid synchronous vector modifications.

## 0.0.8
* Fix: ensure `connect` method waits for actual physical connection completion before returning a result.

## 0.0.7
* Fix: ensure `connect` returns `false` on failure instead of throwing an exception.
* Improvement: refined connection state waiting logic for better reliability.

## 0.0.6
* Fix: ensure `connect` method waits for actual physical connection completion before returning a result.
* Fix: enhanced thread safety during rapid connection and disconnection to prevent `vector erase` crashes.
* Improvement: more robust resource cleanup when connection attempts fail.

## 0.0.5
* Fix: compilation errors (C2220) and typos in method signatures.

## 0.0.4
* Fix: crash during connection/disconnection caused by invalid vector iterators.
* Feature: add `setOptions` implementation.

## 0.0.3
* Fix: ensure physical disconnection by explicitly closing all GATT services.
* Fix: potential race condition where a device might stay connected if disconnected during the connection process.
* Fix: properly clear characteristic and descriptor caches upon disconnection.

## 0.0.2
* Fix: a version issue with `flutter_blue_plus_platform_interface` #1

## 0.0.1
* Initial release.
