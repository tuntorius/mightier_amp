package com.tuntori.mighty_ble;

import androidx.annotation.NonNull;
import android.content.Context;
import android.app.Activity;
import android.util.Log;

import java.util.HashMap;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;

/** MightyBlePlugin */
public class MightyBlePlugin implements FlutterPlugin, MethodCallHandler, ActivityAware  {

  private static final String TAG = "MBLEPlugin";

  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private MethodChannel channel;
  private Context context;

  @NonNull
  private Activity activity;

  private BLEManager bleManager;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    context = flutterPluginBinding.getApplicationContext();
    channel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "mighty_ble");
    channel.setMethodCallHandler(this);

    bleManager = new BLEManager(context, this);
  }

  @Override
  public void onAttachedToActivity(@NonNull ActivityPluginBinding activityPluginBinding) {
    activity = activityPluginBinding.getActivity();
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {
    // TODO: the Activity your plugin was attached to was
    // destroyed to change configuration.
    // This call will be followed by onReattachedToActivityForConfigChanges().
  }

  @Override
  public void onReattachedToActivityForConfigChanges(ActivityPluginBinding activityPluginBinding) {
    // TODO: your plugin is now attached to a new Activity
    // after a configuration change.
  }

  @Override
  public void onDetachedFromActivity() {
    // TODO: your plugin is no longer associated with an Activity.
    // Clean up references.
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    if (call.method.equals("getPlatformVersion")) {
      result.success("Android " + android.os.Build.VERSION.RELEASE);
    }
    else if(call.method.equals("initBle")) {
      bleManager.init();
      result.success(null);
    }
    else if (call.method.equals("isAvailable"))
      result.success(bleManager.isAvailable());
    else if (call.method.equals("startScan")) {
      bleManager.startScan();
      result.success(null);
    }
    else if (call.method.equals("stopScan")) {
      bleManager.stopScan();
      result.success(null);
    }
    else if (call.method.equals("connect")) {
      String address = call.arguments();
      bleManager.connect(address);
    }
    else if (call.method.equals("disconnect")) {
      String address = call.arguments();
      bleManager.disconnect(address);
    }
    else if (call.method.equals("write")) {
        String address = call.argument("id");
        byte[] data = call.argument("value");
        Log.i(TAG, "writing: address " + address + " data " + data);
        int r = bleManager.write(address, data);
        result.success(r);
    }
    else if (call.method.equals("setNotificationEnabled")) {
      String address = call.argument("id");
      boolean enabled = call.argument("enabled");
      bleManager.setNotificationEnabled(address, enabled);
    }
    else {
      result.notImplemented();
    }
  }

  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }

  public void onScanResult(String name, String address, boolean hasMidiService)
  {
    HashMap<String, Object> resultData = new HashMap<>();

    resultData.put("name", name);
    resultData.put("id", address);
    resultData.put("hasMidiService", hasMidiService);
    channel.invokeMethod("onScanResult", resultData);
  }

  public void onConnected(String address)
  {
    activity.runOnUiThread(() -> {
      channel.invokeMethod("onConnected", address);
    });
    
  }

  public void onDisconnected(String address)
  {
    activity.runOnUiThread(() -> {
      channel.invokeMethod("onDisconnected", address);
    });
  }

  public void onCharacteristicNotify(String address, byte[] data)
  {
    HashMap<String, Object> arguments = new HashMap<>();
    arguments.put("id", address);
    arguments.put("value", data);

    Log.i(TAG, "Characteristic notify " + address + " data " + data);
    activity.runOnUiThread(() -> {
      channel.invokeMethod("onCharacteristicNotify", arguments);
    });
  }
}
