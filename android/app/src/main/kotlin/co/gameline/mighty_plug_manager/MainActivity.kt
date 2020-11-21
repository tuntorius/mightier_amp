package co.gameline.mighty_plug_manager

import android.os.Bundle

import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant
import io.flutter.embedding.engine.plugins.shim.ShimPluginRegistry

import io.flutter.view.FlutterMain
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

import java.nio.ShortBuffer

class MainActivity: FlutterActivity() {
    private val CHANNEL = "mighty_plug/decoder"
    var decoder = MediaDecoder();

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine);

        configureDecoderAPI(flutterEngine);
    }

    fun configureDecoderAPI(@NonNull flutterEngine: FlutterEngine)
    {
        MethodChannel(flutterEngine.getDartExecutor(), CHANNEL).setMethodCallHandler { methodCall, result ->
            var arguments = methodCall.arguments<Map<String, String>>();
            if (methodCall.method == "open")
            {
                decoder.open(arguments["path"]);
                result.success(null);
            }
            else if (methodCall.method == "next") {
                if (decoder != null) {
                    var buffer = decoder.readShortData();
                    result.success(buffer);
                }
                else
                    result.success(null);
            }
            else if (methodCall.method == "close") {
                if (decoder != null)
                    decoder.release();
                result.success(null);
            }
            else if (methodCall.method == "duration") {
                if (decoder != null) {
                    var dur = decoder.getDuration();
                    result.success(dur);
                }
                else
                    result.success(-1);
            }
        }
    }
}
