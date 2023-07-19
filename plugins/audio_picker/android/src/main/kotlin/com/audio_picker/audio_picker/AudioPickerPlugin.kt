package com.audio_picker.audio_picker

import android.Manifest.permission.READ_EXTERNAL_STORAGE
import android.app.Activity
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Environment
import android.util.Log
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry
import io.flutter.plugin.common.PluginRegistry.Registrar
import java.io.File.separator
import android.os.Build
import android.provider.MediaStore
import android.provider.DocumentsContract
import android.content.ContentUris
import android.text.TextUtils
import android.annotation.TargetApi
import android.database.Cursor
import android.media.MediaMetadataRetriever



class AudioPickerPlugin : MethodCallHandler {

    private val PERM_CODE = AudioPickerPlugin::class.java.hashCode() + 50 and 0x0000ffff
    private val permission = READ_EXTERNAL_STORAGE

    companion object {
        private var instance: Registrar? = null
        private val REQUEST_CODE = AudioPickerPlugin::class.java.hashCode() + 43 and 0x0000ffff
        private var result: Result? = null
        private const val TAG = "AudioPicker"

        @JvmStatic
        fun registerWith(registrar: Registrar) {
            val channel = MethodChannel(registrar.messenger(), "audio_picker")
            channel.setMethodCallHandler(AudioPickerPlugin())
            instance = registrar

            instance?.addActivityResultListener(object : PluginRegistry.ActivityResultListener {
                override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {

                    if (requestCode == REQUEST_CODE && resultCode == Activity.RESULT_OK) {

                        Thread(Runnable {
                            if (data != null) {
                                if (data.data != null) {
                                    val uri = data.data
                                    Log.i(TAG, "[SingleFilePick] File URI:" + uri!!.toString())

                                    var fullPath = instance?.context()?.let { FileUtils.getPath(it, uri) }

                                    if (fullPath != null) {
                                        Log.i(TAG, "Absolute file path:$fullPath")
                                        runOnUiThread(fullPath, true, false)
                                    } else {
                                        runOnUiThread("Failed to retrieve path.", false, false)
                                    }
                                } else if (data.getClipData() != null) {
                                    val count = data.getClipData()!!.getItemCount()
                                    var currentItem = 0
                                    val list = arrayListOf<String>()
                                    while (currentItem < count) {
                                        val uri = data.getClipData()!!.getItemAt(currentItem).getUri()
                                        var fullPath = instance?.context()?.let { FileUtils.getPath(it, uri) }

                                        if (fullPath!=null) {
                                            Log.i("MIGHTIER", fullPath)
                                            list.add(fullPath)
                                        }
                                        currentItem++;
                                    }
                                    runOnUiThread(list, true, true)

                                } else {
                                    runOnUiThread("Unknown activity error, please fill an issue.", false, true)
                                }
                            } else {
                                runOnUiThread("Unknown activity error, please fill an issue.", false, true)
                            }
                        }).start()
                        return true

                    } else if (requestCode == REQUEST_CODE && resultCode == Activity.RESULT_CANCELED) {
                        result?.success(null)
                        return true
                    } else if (requestCode == REQUEST_CODE) {
                        result?.error(TAG, "Unknown activity error, please fill an issue.", null)
                    }
                    return false
                }
            })

        }

        private fun runOnUiThread(o: Any?, success: Boolean, multi: Boolean) {
            instance?.activity()?.runOnUiThread {
                when {
                    success && multi -> result?.success(o as ArrayList<String>)
                    success && !multi -> result?.success(o as String)
                    o != null -> result?.error(TAG, o as String?, null)
                    else -> result?.notImplemented()
                }
            }
        }
    }

    fun getAudioMetadata(uri: Uri, context: Context) {
        val metadataRetriever = MediaMetadataRetriever()
        val metadataMap = HashMap<String, String?>()

        try {
            metadataRetriever.setDataSource(context, uri)
            val title = metadataRetriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_TITLE)
            val artist = metadataRetriever.extractMetadata(MediaMetadataRetriever.METADATA_KEY_ARTIST)

            metadataMap["title"] = title
            metadataMap["artist"] = artist

        } catch (e: Exception) {
            // Handle any exceptions here (e.g., invalid Uri or missing permissions)
            // You can log the error or handle it as needed.
            e.printStackTrace()
            Log.e("getAudioMetadata", "Error retrieving audio metadata: ${e.message}")
        } finally {
            metadataRetriever.release()
            result?.success(metadataMap)
        }
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        if (call.method == "pick_audio") {
            AudioPickerPlugin.result = result
            openAudioPicker(false)
        } else if (call.method == "pick_audio_multiple") {
            AudioPickerPlugin.result = result
            openAudioPicker(true)
        } else if (call.method == "get_metadata") {
            AudioPickerPlugin.result = result
            val uriString = call.argument<String>("uri")
            val uri = Uri.parse(uriString)
            instance?.context()?.let { getAudioMetadata(uri, it) }
        } else {
            result.notImplemented()
        }
    }
    
    private fun openAudioPicker(multiple: Boolean) {
        val intent: Intent

        intent = Intent(Intent.ACTION_GET_CONTENT)
        val uri = Uri.parse(Environment.getExternalStorageDirectory().path + separator)
        intent.setDataAndType(uri, "audio/*")
        intent.type = "audio/*"
        intent.addCategory(Intent.CATEGORY_OPENABLE)
        if (multiple)
            intent.putExtra(Intent.EXTRA_ALLOW_MULTIPLE, true)

        instance?.activity()?.let {
            if (intent.resolveActivity(it.packageManager) != null) {
                instance?.activity()?.startActivityForResult(intent, REQUEST_CODE)
            } else {
                Log.e(TAG, "Can't find a valid activity to handle the request. Make sure you've a file explorer installed.")
                result?.error(TAG, "Can't handle the provided file type.", null)
            }
        }
    }
}