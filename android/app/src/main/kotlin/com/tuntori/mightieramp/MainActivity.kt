// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

package com.tuntori.mightieramp

import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

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
import java.io.DataOutputStream

import java.nio.ShortBuffer

class MainActivity: FlutterActivity() {
    
    internal var WRITE_REQUEST_CODE = 77777 //unique request code
    internal var OPEN_REQUEST_CODE = 22222
    internal var OPEN_REQUEST_CODE_BYTEARRAY = 33333
    internal var _result: Result? = null
    internal var _data: String = ""
    internal var _dataBa: ByteArray? = null
    internal var saveByteArray: Boolean = false 

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        configureFileSaveAPI(flutterEngine)
    }

    fun configureFileSaveAPI(@NonNull flutterEngine: FlutterEngine) {
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "com.msvcode.filesaver/files")
        .setMethodCallHandler { call, result ->
            if (call.method == "saveFile") {
                _result = result
                saveByteArray = call.argument<Boolean?>("byteArray") ?: false
                if (saveByteArray)
                    _dataBa = call.argument<ByteArray>("data")
                else
                    _data = call.argument<String>("data") ?: ""
                var mime: String? = call.argument<String?>("mime")
                var name: String? = call.argument<String?>("name")
                if (mime != null && name != null)
                    createFile(mime, name)
            } else if (call.method == "openFile") {
                _result = result
                var mime: String? = call.argument<String?>("mime")
                var byteArray: Boolean? = call.argument<Boolean?>("byte_array")
                if (mime != null)
                    openFile(mime, byteArray)
            } else {
                result.notImplemented()
            }
        }
    }

    private fun createFile(mimeType: String, fileName: String) {
        val intent = Intent(Intent.ACTION_CREATE_DOCUMENT).apply {
            addCategory(Intent.CATEGORY_OPENABLE)
            type = mimeType
            putExtra(Intent.EXTRA_TITLE, fileName)
        }

        startActivityForResult(intent, WRITE_REQUEST_CODE)
    }

    private fun openFile(mimeType: String, byteArray: Boolean?) {
        val intent = Intent(Intent.ACTION_GET_CONTENT).apply {
            addCategory(Intent.CATEGORY_OPENABLE)
            type = mimeType
        }
        if (byteArray == true)
            startActivityForResult(intent, OPEN_REQUEST_CODE_BYTEARRAY)
        else
            startActivityForResult(intent, OPEN_REQUEST_CODE)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        
        if (requestCode == WRITE_REQUEST_CODE) {
            if (resultCode == Activity.RESULT_OK) {
                if (data?.data != null) {
                    writeInFile(data.data!!)
                } else {
                    _result?.error("NO DATA", "No data", null)
                }
            } else {
                _result?.error("CANCELED", "User cancelled", null)
            }
        } else if (requestCode == OPEN_REQUEST_CODE || requestCode == OPEN_REQUEST_CODE_BYTEARRAY) {
            if (resultCode == Activity.RESULT_OK) {
                if (data?.data != null) {
                    if (requestCode == OPEN_REQUEST_CODE)
                        readFile(data.data!!, false)
                    else
                        readFile(data.data!!, true)
                } else {
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
            outputStream = contentResolver.openOutputStream(uri)
            if (outputStream != null) {
                if (saveByteArray && _dataBa != null) {
                    outputStream.write(_dataBa)
                    outputStream.close()
                } else {
                    outputStream.write(_data.toByteArray(Charsets.UTF_8))
                    outputStream.close()
                }
                _result?.success("SUCCESS")
            } else {
                _result?.error("ERROR", "writeInFile: Output stream is null", null)
            }
        } catch (e: Exception) {
            _result?.error("ERROR", "Unable to write. Exception: $e", null)
            e.printStackTrace()
        }
    }

    private fun readFile(uri: Uri, dataArray: Boolean) {
        val inputStream: InputStream?
        val inputStreamReader: InputStreamReader
        try {
            inputStream = contentResolver.openInputStream(uri)
            if (inputStream != null) {
                inputStreamReader = InputStreamReader(inputStream)
                if (!dataArray) {
                    val br = BufferedReader(inputStreamReader)
                    val fileContent = br.use { inputStreamReader.readText() }
                    br.close()
                    _result?.success(fileContent)
                } else {
                    val array = inputStream.readBytes()
                    inputStream.close()
                    _result?.success(array)
                }
            }
        } catch (e: Exception) {
            _result?.error("ERROR", "Unable to read", null)
        }
    }
}