package io.flutter.plugins;

import io.flutter.plugin.common.PluginRegistry;
import com.pauldemarco.flutter_blue.FlutterBluePlugin;
import dev.flutter.plugins.e2e.E2EPlugin;

/**
 * Generated file. Do not edit.
 */
public final class GeneratedPluginRegistrant {
  public static void registerWith(PluginRegistry registry) {
    if (alreadyRegisteredWith(registry)) {
      return;
    }
    FlutterBluePlugin.registerWith(registry.registrarFor("com.pauldemarco.flutter_blue.FlutterBluePlugin"));
    E2EPlugin.registerWith(registry.registrarFor("dev.flutter.plugins.e2e.E2EPlugin"));
  }

  private static boolean alreadyRegisteredWith(PluginRegistry registry) {
    final String key = GeneratedPluginRegistrant.class.getCanonicalName();
    if (registry.hasPlugin(key)) {
      return true;
    }
    registry.registrarFor(key);
    return false;
  }
}
