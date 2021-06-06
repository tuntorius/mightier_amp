package com.example.pitchdetector;

import androidx.annotation.NonNull;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry;
import io.flutter.plugin.common.PluginRegistry.RequestPermissionsResultListener;
import io.flutter.plugin.common.PluginRegistry.Registrar;

import android.os.Build;
import android.os.Bundle;
import  java.util.Map;
import java.util.HashMap;

import android.content.pm.PackageManager;
import android.Manifest;

import android.media.AudioFormat;
import android.media.AudioRecord;
import android.media.MediaRecorder.AudioSource;
import android.os.Handler;
import android.os.Looper;


import java.util.List;
import java.util.ArrayList;


import org.xml.sax.HandlerBase;

/** PitchdetectorPlugin */
public class PitchdetectorPlugin implements FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private MethodChannel channel;
  private static Registrar reg; 
  boolean recording = false;
  private boolean replySubmitted = false;

  private int SAMPLE_RATE = 22050;
  private int SAMPLE_SIZE = 2048;
  
  AudioRecord  audioRecorder = null;
  private short[] audioData = new short[SAMPLE_SIZE];
  private Handler mainHandler =  new Handler();
  private Handler subHandler = new Handler();
  private Runnable runnable; 
  private float pitch = 0;
  private PitchHandler pitchHandler;
  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    channel = new MethodChannel(flutterPluginBinding.getFlutterEngine().getDartExecutor(), "pitchdetector");
    channel.setMethodCallHandler(this);
  }

  // This static function is optional and equivalent to onAttachedToEngine. It supports the old
  // pre-Flutter-1.12 Android projects. You are encouraged to continue supporting
  // plugin registration via this function while apps migrate to use the new Android APIs
  // post-flutter-1.12 via https://flutter.dev/go/android-project-migration.
  //
  // It is encouraged to share logic between onAttachedToEngine and registerWith to keep
  // them functionally equivalent. Only one of onAttachedToEngine or registerWith will be called
  // depending on the user's project. onAttachedToEngine or registerWith must both be defined
  // in the same class.
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "pitchdetector");
    channel.setMethodCallHandler(new PitchdetectorPlugin());
    reg = registrar;
  }

  @Override
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result) {
    switch(call.method){
      
      case "initializeValues":
        this.SAMPLE_RATE = call.argument("sampleRate");
        this.SAMPLE_SIZE = call.argument("sampleSize");
        audioData = new short[this.SAMPLE_SIZE];
        pitchHandler = new PitchHandler(SAMPLE_RATE , SAMPLE_SIZE);
        break;
      case "startRecording":
        startRecord(result);
        break;
      case "stopRecording" : 
        System.out.println("call stop recording");
        stopRecording();
        break;
      default : 
        result.notImplemented();
        break;
    }
  
  }
  private void initRecorder(){
    if(audioRecorder == null) {
      System.out.println("sample rate is" + SAMPLE_RATE);
      System.out.println("sample size is" + SAMPLE_SIZE);
      
      audioRecorder = new AudioRecord( 
        1, //mic
        SAMPLE_RATE, 
        1, 
        AudioFormat.ENCODING_PCM_16BIT, 
        SAMPLE_SIZE);
    }
   
  }
  private void startRecord(final Result result){
    recording = true;
    initRecorder();
    audioRecorder.startRecording();
    findPitch(audioRecorder , recording);
    result.success("ok");
  }

  private void findPitch(final AudioRecord audioRecorder ,  final boolean recordingState){
    if(recording){
      mainHandler = new Handler();
      mainHandler.postDelayed(new Runnable() {
        public void run() {
          if (audioRecorder.getState() == AudioRecord.STATE_INITIALIZED) {
              //RUN FOR DELAY OF 500ms
              audioRecorder.read(audioData, 0, SAMPLE_SIZE);
              //System.out.println(audioData.toString());
              float[] samples = pitchHandler.shortToPcmArray(audioData);
              float pitchResult =  pitchHandler.getPitch(samples);
              try {
                //if(pitchResult != -1.0){
                  channel.invokeMethod("getPitch", pitchResult);
                //}
                findPitch(audioRecorder , recording);
                  // SENDS ARRAY "returnData" BACK TO FLUTTER
              } catch (Exception err) {
                  System.out.println(err.getMessage());
              }
          }
      }
    }, 50);
    //mainHandler.post(runnable);
    }
    
  }
  private void stopRecording(){
    recording = false;
    System.out.println("this is the recording state" + recording);
    audioRecorder.stop();
    mainHandler.removeCallbacksAndMessages(runnable);
    subHandler.removeCallbacksAndMessages(null);
    audioData = new short[SAMPLE_SIZE];
  }
  @Override
  public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
    channel.setMethodCallHandler(null);
  }

}
