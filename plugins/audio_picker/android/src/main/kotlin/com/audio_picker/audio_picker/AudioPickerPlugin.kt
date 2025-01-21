package com.audio_picker.audio_picker

import android.Manifest.permission.READ_EXTERNAL_STORAGE
import android.app.Activity
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Environment
import android.util.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import android.provider.MediaStore
import android.media.MediaMetadataRetriever
import java.io.File.separator

class AudioPickerPlugin: FlutterPlugin, MethodCallHandler, ActivityAware {
    private lateinit var channel: MethodChannel
    private var activity: Activity? = null
    private var context: Context? = null

    companion object {
        private const val CHANNEL_NAME = "audio_picker"
        private const val REQUEST_CODE = 0x2324
        private const val TAG = "AudioPicker"
        private var pendingResult: Result? = null
    }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, CHANNEL_NAME)
        channel.setMethodCallHandler(this)
        context = binding.applicationContext
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        context = null
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        binding.addActivityResultListener { requestCode, resultCode, data ->
            handleActivityResult(requestCode, resultCode, data)
        }
    }

    override fun onDetachedFromActivity() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        onAttachedToActivity(binding)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        onDetachedFromActivity()
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "pick_audio" -> {
                pendingResult = result
                openAudioPicker(false)
            }
            "pick_audio_multiple" -> {
                pendingResult = result
                openAudioPicker(true)
            }
            "get_metadata" -> {
                pendingResult = result
                val uriString = call.argument<String>("uri")
                val uri = Uri.parse(uriString)
                context?.let { getAudioMetadata(uri, it) }
            }
            else -> result.notImplemented()
        }
    }

    private fun openAudioPicker(multiple: Boolean) {
        val intent = Intent(Intent.ACTION_GET_CONTENT).apply {
            val uri = Uri.parse(Environment.getExternalStorageDirectory().path + separator)
            setDataAndType(uri, "audio/*")
            type = "audio/*"
            addCategory(Intent.CATEGORY_OPENABLE)
            if (multiple) {
                putExtra(Intent.EXTRA_ALLOW_MULTIPLE, true)
            }
        }

        activity?.let {
            if (intent.resolveActivity(it.packageManager) != null) {
                it.startActivityForResult(intent, REQUEST_CODE)
            } else {
                Log.e(TAG, "Can't find a valid activity to handle the request. Make sure you've a file explorer installed.")
                pendingResult?.error(TAG, "Can't handle the provided file type.", null)
            }
        } ?: run {
            pendingResult?.error(TAG, "Activity is not available", null)
        }
    }

    private fun getAudioMetadata(uri: Uri, context: Context) {
        val metadataRetriever = MediaMetadataRetriever()
        val metadataMap = HashMap<String, String?>()

        try {
            metadataRetriever.setDataSource(context, uri)
            metadataMap["title"] = metadataRetriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_TITLE)
            metadataMap["artist"] = metadataRetriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_ARTIST)
        } catch (e: Exception) {
            Log.e(TAG, "Error retrieving audio metadata: ${e.message}")
            e.printStackTrace()
        } finally {
            metadataRetriever.release()
            pendingResult?.success(metadataMap)
        }
    }

    private fun handleActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (requestCode != REQUEST_CODE) return false

        when (resultCode) {
            Activity.RESULT_OK -> {
                Thread {
                    when {
                        data?.data != null -> handleSingleFile(data.data!!)
                        data?.clipData != null -> handleMultipleFiles(data)
                        else -> runOnUiThread("Unknown activity error, please file an issue.", false)
                    }
                }.start()
            }
            Activity.RESULT_CANCELED -> {
                pendingResult?.success(null)
            }
            else -> {
                pendingResult?.error(TAG, "Unknown activity error, please file an issue.", null)
            }
        }
        return true
    }

    private fun handleSingleFile(uri: Uri) {
        val fullPath = context?.let { FileUtils.getPath(it, uri) }
        if (fullPath != null) {
            Log.i(TAG, "Absolute file path: $fullPath")
            runOnUiThread(fullPath, true)
        } else {
            runOnUiThread("Failed to retrieve path.", false)
        }
    }

    private fun handleMultipleFiles(data: Intent) {
        val list = ArrayList<String>()
        for (i in 0 until data.clipData!!.itemCount) {
            val uri = data.clipData!!.getItemAt(i).uri
            context?.let { FileUtils.getPath(it, uri) }?.let { list.add(it) }
        }
        runOnUiThread(list, true)
    }

    private fun runOnUiThread(result: Any, success: Boolean) {
        activity?.runOnUiThread {
            if (success) {
                pendingResult?.success(result)
            } else {
                pendingResult?.error(TAG, result as String, null)
            }
        }
    }
}