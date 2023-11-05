package com.tuntori.audio_waveform;

import androidx.annotation.NonNull;
import android.content.Context;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import android.os.Handler;
import java.util.List;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/** AudioWaveformPlugin */
public class AudioWaveformPlugin implements FlutterPlugin, MethodCallHandler {
    private MethodChannel channel;

    private Context context;
    private WaveformExtractor decoder = new WaveformExtractor();

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        channel = new MethodChannel(flutterPluginBinding.getFlutterEngine().getDartExecutor(), "com.tuntori.audio_waveform");
        channel.setMethodCallHandler(this);
        context = flutterPluginBinding.getApplicationContext();
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull final Result result) {
        switch (call.method) {
        case "open":
                String audioInPath = call.argument("path");
                boolean legacy = call.argument("legacy");
                decoder.open(audioInPath, context, legacy);
                result.success(null);
            break;
        case "next":
            if (decoder != null) {
                byte[] buffer = decoder.readShortData();
                result.success(buffer);
            }
            else
                result.error("decoder_unavailable", "you must open a file first", null);
            break;
        case "close":
            if (decoder != null)
                decoder.release();
            result.success(null);
            break;
        case "duration":
            if (decoder != null) {
                long dur = decoder.getDuration();
                result.success(dur);
            }
            else
                result.error("decoder_unavailable", "you must open a file first", null);
            break;
        case "sampleRate":
            if (decoder != null) {
                int sr = decoder.getSampleRate();
                result.success(sr);
            }
            else
                result.error("decoder_unavailable", "you must open a file first", null);
            break;
        default:
            result.notImplemented();
            break;
        }
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        channel.setMethodCallHandler(null);
    }
}
