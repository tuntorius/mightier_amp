// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

package com.tuntori.mightieramp

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

import android.content.Intent
import android.app.Activity
import android.net.Uri

import java.io.BufferedWriter
import java.io.OutputStream
import java.io.OutputStreamWriter

import java.io.BufferedReader
import java.io.InputStream
import java.io.InputStreamReader

import java.nio.ShortBuffer

class MainActivity: FlutterActivity() {
    
    internal var WRITE_REQUEST_CODE = 77777 //unique request code
    internal var OPEN_REQUEST_CODE = 22222
    internal var OPEN_REQUEST_CODE_BYTEARRAY = 33333
    internal var _result: Result? = null
    internal var _data: String? = null

    private val CHANNEL = "mighty_plug/decoder"
    var decoder = MediaDecoder();

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine);

        configureDecoderAPI(flutterEngine);
        configureFileSaveAPI(flutterEngine);
    }

    fun configureDecoderAPI(@NonNull flutterEngine: FlutterEngine)
    {
        MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), CHANNEL)
        .setMethodCallHandler { methodCall, result ->
            var arguments = methodCall.arguments<Map<String, String>>();
            if (methodCall.method == "open")
            {
                decoder.open(arguments["path"], this);
                result.success(null);
            }
            else if (methodCall.method == "next") {
                if (decoder != null) {
                    var buffer = decoder.readShortData();
                    result.success(buffer);
                }
                else
                    result.error("decoder_unavailable", "you must open a file first", null);
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
                    result.error("decoder_unavailable", "you must open a file first", null);
            }
            else if (methodCall.method == "sampleRate") {
                if (decoder != null) {
                    var sr = decoder.getSampleRate();
                    result.success(sr);
                }
                else
                    result.error("decoder_unavailable", "you must open a file first", null);
            }
        }
    }

    fun configureFileSaveAPI(@NonNull flutterEngine: FlutterEngine)
    {
        MethodChannel(flutterEngine.getDartExecutor().getBinaryMessenger(), "com.msvcode.filesaver/files")
        .setMethodCallHandler { call, result ->
            // Note: this method is invoked on the main thread.
            if (call.method == "saveFile") {
                _result = result
                _data = call.argument<String>("data")
                var mime:String? = call.argument<String?>("mime");
                var name:String? = call.argument<String?>("name");
                if (mime!=null && name!=null)
                    createFile(mime, name)
            } else if (call.method == "openFile") {
                _result = result
                var mime:String? = call.argument<String?>("mime");
                var byteArray:Boolean? = call.argument<Boolean?>("byte_array");
                if (mime!=null)
                    openFile(mime, byteArray)
            } else {
                result.notImplemented()
            }
        }
    }

    private fun createFile(mimeType: String, fileName: String) {
        val intent = Intent(Intent.ACTION_CREATE_DOCUMENT).apply {
            // Filter to only show results that can be "opened", such as
            // a file (as opposed to a list of contacts or timezones).
            addCategory(Intent.CATEGORY_OPENABLE)

            // Create a file with the requested MIME type.
            type = mimeType
            putExtra(Intent.EXTRA_TITLE, fileName)
        }

        startActivityForResult(intent, WRITE_REQUEST_CODE)
    }

    //replace with ACTION_GET_CONTENT for just a temporary access
    //the other is ACTION_OPEN_DOCUMENT
    private fun openFile(mimeType: String, byteArray: Boolean?) {
        val intent = Intent(Intent.ACTION_GET_CONTENT).apply {
            // Filter to only show results that can be "opened", such as
            // a file (as opposed to a list of contacts or timezones).
            addCategory(Intent.CATEGORY_OPENABLE)

            // Create a file with the requested MIME type.
            type = mimeType
        }
        if (byteArray != null && byteArray == true)
            startActivityForResult(intent, OPEN_REQUEST_CODE_BYTEARRAY)
        else
            startActivityForResult(intent, OPEN_REQUEST_CODE)
    }

  override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
    super.onActivityResult(requestCode, resultCode, data)
    
    // Check which request we're responding to
    if (requestCode == WRITE_REQUEST_CODE) {
        // Make sure the request was successful
        if (resultCode == Activity.RESULT_OK) {
          if (data != null && data.getData() != null) {
            //now write the data
            writeInFile(data.getData() as Uri) //data.getData() is Uri
          } else {
            _result?.error("NO DATA", "No data", null)
          }
        } else {
          _result?.error("CANCELED", "User cancelled", null)
        }
    }
    else if (requestCode == OPEN_REQUEST_CODE || 
        requestCode == OPEN_REQUEST_CODE_BYTEARRAY) {
        if (resultCode == Activity.RESULT_OK) {
            if (data != null && data.getData() != null) {
                //now write the data
                if (requestCode == OPEN_REQUEST_CODE)
                    readFile(data.getData() as Uri, false)
                else
                    readFile(data.getData() as Uri, true)
            }else {
                _result?.error("NO DATA", "No data", null)
            }
        } else {
            _result?.error("CANCELED", "User cancelled", null)
        }
    }
  }

  private fun writeInFile(uri: Uri) {
    val outputStream: OutputStream?
    try {
      outputStream = getContentResolver().openOutputStream(uri)
      if (outputStream!=null) {
        val bw = BufferedWriter(OutputStreamWriter(outputStream))
        bw.write(_data)
        bw.flush()
        bw.close()
        _result?.success("SUCCESS");
      }
      else
        _result?.error("ERROR", "Unable to write", null)
    } catch (e:Exception){
      _result?.error("ERROR", "Unable to write", null)
    }
  }

  private fun readFile(uri: Uri, dataArray: Boolean) {
      val inputStream: InputStream?
      val inputStreamReader: InputStreamReader
      try {
            inputStream = getContentResolver().openInputStream(uri)
            inputStreamReader = InputStreamReader(inputStream)
            if (!dataArray) {
                val br = BufferedReader(inputStreamReader)
                val fileContent = br.use { inputStreamReader.readText() }
                br.close()
                _result?.success(fileContent)
            }
            else {
                if (inputStream!=null) {
                    val array = inputStream.readBytes();
                    inputStream.close();
                    _result?.success(array)
                }
            }
      } catch (e:Exception){
      _result?.error("ERROR", "Unable to read", null)
    }
  }
}
