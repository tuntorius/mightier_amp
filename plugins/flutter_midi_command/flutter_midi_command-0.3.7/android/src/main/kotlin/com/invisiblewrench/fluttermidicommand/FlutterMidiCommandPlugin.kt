package com.invisiblewrench.fluttermidicommand

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.EventChannel

import android.app.Activity
import android.os.Handler
import android.media.midi.*
import android.content.Context.MIDI_SERVICE
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothDevice
import android.bluetooth.BluetoothManager
import android.bluetooth.le.*
import android.content.pm.PackageManager
import android.os.ParcelUuid
import android.Manifest
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import io.flutter.plugin.common.BinaryMessenger

import android.util.Log

/** FlutterMidiCommandPlugin */
public class FlutterMidiCommandPlugin : FlutterPlugin, ActivityAware, MethodCallHandler {

  lateinit var context: Context
  private var activity: Activity? = null
  lateinit var messenger: BinaryMessenger

  private lateinit var midiManager: MidiManager
  private lateinit var handler: Handler

  private var connectedDevices = mutableMapOf<String, ConnectedDevice>()

  lateinit var rxChannel: EventChannel
  lateinit var rxStreamHandler: FlutterStreamHandler
  lateinit var setupChannel: EventChannel
  lateinit var setupStreamHandler: FlutterStreamHandler

  var bluetoothAdapter: BluetoothAdapter? = null
  var bluetoothScanner: BluetoothLeScanner? = null
  private val PERMISSIONS_REQUEST_ACCESS_LOCATION = 95453 // arbitrary

  var discoveredDevices = mutableSetOf<BluetoothDevice>()

  lateinit var blManager: BluetoothManager

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    messenger = flutterPluginBinding.binaryMessenger
    context = flutterPluginBinding.applicationContext
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    print("detached from engine")
  }

  override fun onAttachedToActivity(p0: ActivityPluginBinding) {
    print("onAttachedToActivity")
    activity = p0.activity
    setup()
  }

  override fun onDetachedFromActivityForConfigChanges() {
    print("onDetachedFromActivityForConfigChanges")
  }

  override fun onReattachedToActivityForConfigChanges(p0: ActivityPluginBinding) {
    print("onReattachedToActivityForConfigChanges")
  }

  override fun onDetachedFromActivity() {
    print("onDetachedFromActivity")
    activity = null
  }

  private inner class MidiDeviceOpenedListener : MidiManager.OnDeviceOpenedListener {
    override fun onDeviceOpened(it: MidiDevice?) {
      Log.d("FlutterMIDICommand", "onDeviceOpened")
      it?.also {
        val id = it.info.id.toString()
        Log.d("FlutterMIDICommand", "Opened\n${it.info}")

        val device = ConnectedDevice(it)
        device.connectWithReceiver(RXReceiver(rxStreamHandler, it))
        connectedDevices[id] = device

        this@FlutterMidiCommandPlugin.setupStreamHandler.send("deviceOpened")
      }
    }
  }

  private lateinit var deviceOpenedListener: MidiDeviceOpenedListener

  private inner class MidiDeviceCallback : MidiManager.DeviceCallback() {
    override fun onDeviceAdded(device: MidiDeviceInfo?) {
      super.onDeviceAdded(device)
      device?.also {
        Log.d("FlutterMIDICommand", "device added $it")
        this@FlutterMidiCommandPlugin.setupStreamHandler.send("deviceFound")
      }
    }

    override fun onDeviceRemoved(device: MidiDeviceInfo?) {
      super.onDeviceRemoved(device)
      device?.also {
        Log.d("FlutterMIDICommand","device removed $it")
        connectedDevices[it.id.toString()]?.also {
          Log.d("FlutterMIDICommand","remove removed device $it")
          connectedDevices.remove(it.id)
        }
        this@FlutterMidiCommandPlugin.setupStreamHandler.send("deviceLost")
      }
    }

    override fun onDeviceStatusChanged(status: MidiDeviceStatus?) {
      super.onDeviceStatusChanged(status)
      Log.d("FlutterMIDICommand","device status changed ${status.toString()}")

      status?.also {
        connectedDevices[status.deviceInfo.id.toString()]?.also {
          Log.d("FlutterMIDICommand", "update device status")
          it.status = status
        }
      }
      this@FlutterMidiCommandPlugin.setupStreamHandler.send("onDeviceStatusChanged")
    }
  }

  private lateinit var deviceConnectionCallback: MidiDeviceCallback

  fun setup() {
    if (!context.packageManager.hasSystemFeature(PackageManager.FEATURE_MIDI))
      return

    deviceOpenedListener = MidiDeviceOpenedListener()
    deviceConnectionCallback = MidiDeviceCallback()

    print("setup")
    val channel = MethodChannel(messenger, "plugins.invisiblewrench.com/flutter_midi_command")
    channel.setMethodCallHandler(this)

    handler = Handler(context.mainLooper)
    midiManager = context.getSystemService(Context.MIDI_SERVICE) as MidiManager
    midiManager.registerDeviceCallback(deviceConnectionCallback, handler)

    rxStreamHandler = FlutterStreamHandler(handler)
    rxChannel = EventChannel(messenger, "plugins.invisiblewrench.com/flutter_midi_command/rx_channel")
    rxChannel.setStreamHandler(rxStreamHandler)

    setupStreamHandler = FlutterStreamHandler(handler)
    setupChannel = EventChannel(messenger, "plugins.invisiblewrench.com/flutter_midi_command/setup_channel")
    setupChannel.setStreamHandler(setupStreamHandler)
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    if (android.os.Build.VERSION.SDK_INT < android.os.Build.VERSION_CODES.M) {
      result.error("ERROR", "Needs at least Android M", null)
      return
    }
    when (call.method) {
      "sendData" -> {
        var args : Map<String,Any>? = call.arguments()
        sendData(args?.get("data") as ByteArray, args["timestamp"] as? Long, args["deviceId"]?.toString())
        result.success(null)
      }
      "getDevices" -> {
        result.success(listOfDevices())
      }
      "scanForDevices" -> {
        val errorMsg = startScanningLeDevices()
        if (errorMsg != null) {
          result.error("ERROR", errorMsg, null)
        } else {
          result.success(null)
        }
      }
      "stopScanForDevices" -> {
        stopScanningLeDevices()
        result.success(null)
      }
      "connectToDevice" -> {
        var args : Map<String,Any>? = call.arguments()
        var device = (args?.get("device") as Map<String, Any>)
        connectToDevice(device["id"].toString(), device["type"].toString())
        result.success(null)
      }
      "disconnectDevice" -> {
        var args = call.arguments<Map<String, Any>>()
        args?.get("id")?.let { disconnectDevice(it.toString()) }
        result.success(null)
      }
      "teardown" -> {
        teardown()
        result.success(null)
      }
      else -> {
        result.notImplemented()
      }
    }
  }

  private fun tryToInitBT() : String? {
    Log.d("FlutterMIDICommand", "tryToInitBT")

    if (context.checkSelfPermission(Manifest.permission.BLUETOOTH_ADMIN) != PackageManager.PERMISSION_GRANTED ||
            context.checkSelfPermission(Manifest.permission.ACCESS_FINE_LOCATION) != PackageManager.PERMISSION_GRANTED) {

      if (activity != null) {
        var currentActivity = activity!!
        if (currentActivity.shouldShowRequestPermissionRationale(Manifest.permission.BLUETOOTH_ADMIN) || currentActivity.shouldShowRequestPermissionRationale(Manifest.permission.ACCESS_FINE_LOCATION)) {
          Log.d("FlutterMIDICommand", "Show rationale for Location")
          return "showRationaleForPermission"
        } else {
          currentActivity.requestPermissions(arrayOf(Manifest.permission.BLUETOOTH_ADMIN, Manifest.permission.ACCESS_FINE_LOCATION), PERMISSIONS_REQUEST_ACCESS_LOCATION)
        }
      }
    } else {
      Log.d("FlutterMIDICommand", "Already permitted")

      blManager = context.getSystemService(Context.BLUETOOTH_SERVICE) as BluetoothManager
      bluetoothAdapter = blManager.adapter
      val adapter = bluetoothAdapter
      if (adapter != null) {
        bluetoothScanner = adapter.bluetoothLeScanner

        if (bluetoothScanner != null) {
          context.registerReceiver(broadcastReceiver, IntentFilter(BluetoothAdapter.ACTION_STATE_CHANGED))
          startScanningLeDevices()
        } else {
          Log.d("FlutterMIDICommand", "bluetoothScanner is null")
          return "bluetoothNotAvailable"
        }
      } else {
        Log.d("FlutterMIDICommand", "bluetoothAdapter is null")
      }
    }
    return null
  }

  private val broadcastReceiver = object : BroadcastReceiver() {
    override fun onReceive(context: Context, intent: Intent) {
      val action = intent.action

      if (action.equals(BluetoothAdapter.ACTION_STATE_CHANGED)) {
        val state = intent.getIntExtra(BluetoothAdapter.EXTRA_STATE, BluetoothAdapter.ERROR)

        when (state) {
          BluetoothAdapter.STATE_OFF -> {
            Log.d("FlutterMIDICommand", "BT is now off")
            bluetoothScanner = null
          }

          BluetoothAdapter.STATE_TURNING_OFF -> {
            Log.d("FlutterMIDICommand", "BT is now turning off")
          }

          BluetoothAdapter.STATE_ON -> {
            Log.d("FlutterMIDICommand", "BT is now on")
          }
        }
      }
    }
  }

  private fun startScanningLeDevices() : String? {
    return null
  }

  private fun stopScanningLeDevices() {
  }

  fun onRequestPermissionsResult(requestCode: Int, permissions: Array<String>,
                                 grantResults: IntArray) {
    Log.d("FlutterMIDICommand", "Permissions code: $requestCode grantResults: $grantResults")
    if (requestCode == PERMISSIONS_REQUEST_ACCESS_LOCATION && grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
      startScanningLeDevices()
    } else {
      Log.d("FlutterMIDICommand", "Perms failed")
    }
  }

  private fun connectToDevice(deviceId:String, type:String) {
    Log.d("FlutterMIDICommand", "connect to $type device: $deviceId")

    if (type == "BLE") {
      val bleDevices = discoveredDevices.filter { it.address == deviceId }
      if (bleDevices.count() == 0) {
        Log.d("FlutterMIDICommand", "Device not found ${deviceId}")
      } else {
        Log.d("FlutterMIDICommand", "Stop BLE Scan - Open device")
        midiManager.openBluetoothDevice(bleDevices.first(), deviceOpenedListener, handler)
      }
    } else if (type == "native") {
      val devices = midiManager.devices.filter { d -> d.id.toString() == deviceId }
      if (devices.count() == 0) {
        Log.d("FlutterMIDICommand", "not found device $devices")
      } else {
        Log.d("FlutterMIDICommand", "open device ${devices[0]}")
        midiManager.openDevice(devices[0], deviceOpenedListener, handler)
      }
    }
  }

  fun teardown() {
    if (android.os.Build.VERSION.SDK_INT < android.os.Build.VERSION_CODES.M)
      return

    Log.d("FlutterMIDICommand", "teardown")

    connectedDevices.forEach { _, connectedDevice -> connectedDevice.close() }
    connectedDevices.clear()

    Log.d("FlutterMIDICommand", "unregisterDeviceCallback")
    midiManager.unregisterDeviceCallback(deviceConnectionCallback)
    Log.d("FlutterMIDICommand", "unregister broadcastReceiver")
    try {
      context.unregisterReceiver(broadcastReceiver)
    } catch (e: Exception) {
      // The receiver was not registered.
    }
  }

  fun disconnectDevice(deviceId: String) {
    connectedDevices[deviceId]?.also {
      it.close()
      connectedDevices.remove(deviceId)
    }
  }

  fun sendData(data: ByteArray, timestamp: Long?, deviceId: String?) {
    if (deviceId != null && connectedDevices.containsKey(deviceId)) {
      connectedDevices[deviceId]?.let {
        it.send(data, timestamp)
      }
    } else {
      connectedDevices.values.forEach {
        it.send(data, timestamp)
      }
    }
  }

  fun listOfPorts(count: Int) : List<Map<String, Any>> {
    Log.d("FlutterMIDICommand", "number of ports $count")
    return (0 until count).map { mapOf("id" to it, "connected" to false) }
  }

  fun listOfDevices() : List<Map<String, Any>> {
    var list = mutableListOf<Map<String, Any>>()

    val devs: Array<MidiDeviceInfo> = midiManager.devices
    Log.d("FlutterMIDICommand", "devices $devs")

    var connectedBleDeviceIds = mutableListOf<String>()

    devs.forEach {
      if (it.type == MidiDeviceInfo.TYPE_BLUETOOTH) {
        connectedBleDeviceIds.add(it.properties.get(MidiDeviceInfo.PROPERTY_BLUETOOTH_DEVICE).toString())
      }

      list.add(mapOf(
            "name" to (it.properties.getString(MidiDeviceInfo.PROPERTY_NAME) ?: "-"),
            "id" to it.id.toString(),
            "type" to "native",
            "connected" to if (connectedDevices.contains(it.id.toString())) "true" else "false",
            "inputs" to listOfPorts(it.inputPortCount),
            "outputs" to listOfPorts(it.outputPortCount)
          )
    )}

    discoveredDevices.forEach {
      if (!connectedBleDeviceIds.contains(it.address)) {
        list.add(mapOf(
                "name" to (it.name ?: "-"),
                "id" to it.address,
                "type" to "BLE",
                "connected" to if (connectedDevices.contains(it.address)) "true" else "false",
                "inputs" to listOf(mapOf("id" to 0, "connected" to false)),
                "outputs" to listOf(mapOf("id" to 0, "connected" to false))
        ))
      }
    }

    Log.d("FlutterMIDICommand", "list $list")

    return list.toList()
  }

  class RXReceiver(stream: FlutterStreamHandler, device: MidiDevice) : MidiReceiver() {
    val stream = stream
    var isBluetoothDevice = device.info.type == MidiDeviceInfo.TYPE_BLUETOOTH

    val deviceInfo = mapOf(
      "id" to if(isBluetoothDevice) device.info.properties.get(MidiDeviceInfo.PROPERTY_BLUETOOTH_DEVICE).toString() else device.info.id.toString(),
      "name" to (device.info.properties.getString(MidiDeviceInfo.PROPERTY_NAME) ?: "-"),
      "type" to if(isBluetoothDevice) "BLE" else "native"
    )

    var sysexPart: MutableList<Byte> = mutableListOf()

    override fun onSend(msg: ByteArray?, offset: Int, count: Int, timestamp: Long) {
      msg?.also {
        var data = it.slice(IntRange(offset, offset+count-1))

        if (sysexPart.isNotEmpty()) {
          var startIndex = data.indexOf(0xF0.toByte())
          if (startIndex > -1) {
            var tailEnd = data.subList(0, startIndex)
            sysexPart.addAll(tailEnd)
            if (sysexPart.indexOf(0xF7.toByte()) == -1) {
              sysexPart.add(0xF7.toByte())
            }
            stream.send(mapOf("data" to sysexPart.toList(), "timestamp" to timestamp, "device" to deviceInfo))

            sysexPart.clear()
            sysexPart.addAll(data.subList(startIndex, data.size))
          } else {
            sysexPart.addAll(data)
          }

          var endIndex = sysexPart.indexOf(0xF7.toByte())
          if (endIndex > -1) {
            var sysexData = sysexPart.subList(0, endIndex+1)
            stream.send(mapOf("data" to sysexData, "timestamp" to timestamp, "device" to deviceInfo))
            sysexPart = sysexPart.subList(endIndex+1, sysexPart.size)
          }

        } else {
          if (data.first() == 0xF0.toByte()) {
            var endIndex = data.indexOf(0xF7.toByte())
            if (endIndex > -1) {
                var sysexData = data.subList(0, endIndex+1)
                stream.send(mapOf("data" to sysexData, "timestamp" to timestamp, "device" to deviceInfo))

                if (endIndex < data.size-1) {
                  sysexPart.clear()
                  sysexPart.addAll(data.subList(endIndex+1, data.size))
                }
            } else {
              sysexPart.clear()
              sysexPart.addAll(data)
            }
          } else {
            stream.send(mapOf("data" to data, "timestamp" to timestamp, "device" to deviceInfo))
          }
        }
      }
    }
  }

  class FlutterStreamHandler(handler: Handler) : EventChannel.StreamHandler {
    val handler = handler
    private var eventSink: EventChannel.EventSink? = null

    override fun onListen(arguments: Any?, eventSink: EventChannel.EventSink?) {
      Log.d("FlutterMIDICommand","FlutterStreamHandler onListen")
      this.eventSink = eventSink
    }

    override fun onCancel(arguments: Any?) {
      Log.d("FlutterMIDICommand","FlutterStreamHandler onCancel")
      eventSink = null
    }

    fun send(data: Any) {
      handler.post {
        eventSink?.success(data)
      }
    }
  }

  class Port {
    var id: Int
    var type: String

    constructor(id: Int, type: String) {
      this.id = id
      this.type = type
    }
  }

  class ConnectedDevice {
    var id: String
    var type: String
    lateinit var midiDevice: MidiDevice
    var inputPort: MidiInputPort? = null
    var outputPort: MidiOutputPort? = null
    var status: MidiDeviceStatus? = null
    private var receiver: MidiReceiver? = null

    constructor(device: MidiDevice) {
      this.midiDevice = device
      this.id = device.info.id.toString()
      this.type = device.info.type.toString()
      device.info.ports.forEach {
        Log.d("FlutterMIDICommand", "port on device: ${it.name} ${it.type} ${it.portNumber}")
      }
    }

    fun connectWithReceiver(receiver: MidiReceiver) {
      Log.d("FlutterMIDICommand","connectWithHandler")

      this.midiDevice.info?.let {
        if (it.inputPortCount > 0) {
          Log.d("FlutterMIDICommand", "Open input port")
          this.inputPort = this.midiDevice.openInputPort(0)
        }
        if (it.outputPortCount > 0) {
          Log.d("FlutterMIDICommand", "Open output port")
          this.outputPort = this.midiDevice.openOutputPort(0)
          this.outputPort?.connect(receiver)
        }
      }

      this.receiver = receiver
    }

    fun send(data: ByteArray, timestamp: Long?) {
      this.inputPort?.send(data, 0, data.count(), if (timestamp is Long) timestamp else 0)
    }

    fun close() {
      Log.d("FlutterMIDICommand", "Flush input port ${this.inputPort}")
      this.inputPort?.flush()
      Log.d("FlutterMIDICommand", "Close input port ${this.inputPort}")
      this.inputPort?.close()
      Log.d("FlutterMIDICommand", "Close output port ${this.outputPort}")
      this.outputPort?.close()
      Log.d("FlutterMIDICommand", "Disconnect receiver ${this.receiver}")
      this.outputPort?.disconnect(this.receiver)
      this.receiver = null
      Log.d("FlutterMIDICommand", "Close device ${this.midiDevice}")
      this.midiDevice.close()
    }
  }
}