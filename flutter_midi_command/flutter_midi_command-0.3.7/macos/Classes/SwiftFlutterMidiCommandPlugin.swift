
#if os(macOS)
    import FlutterMacOS
 #else
    import Flutter
 #endif

import CoreMIDI
import os.log
import CoreBluetooth
import Foundation

///
/// Credit to
/// http://mattg411.com/coremidi-swift-programming/
/// https://github.com/genedelisa/Swift3MIDI
/// http://www.gneuron.com/?p=96
/// https://learn.sparkfun.com/tutorials/midi-ble-tutorial/all


public class SwiftFlutterMidiCommandPlugin: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate, FlutterPlugin {

    // MIDI
    var midiClient = MIDIClientRef()
    var connectedDevices = Dictionary<String, ConnectedDevice>()
    
    // Flutter
    var midiRXChannel:FlutterEventChannel?
    var rxStreamHandler = StreamHandler()
    var midiSetupChannel:FlutterEventChannel?
    var setupStreamHandler = StreamHandler()

    #if os(iOS)
    // Network Session
    var session:MIDINetworkSession?
    #endif

    // BLE
    var manager:CBCentralManager!
    var discoveredDevices:Set<CBPeripheral> = []
    

    let midiLog = OSLog(subsystem: "com.invisiblewrench.FlutterMidiCommand", category: "MIDI")

    public static func register(with registrar: FlutterPluginRegistrar) {
        #if os(macOS)
            let channel = FlutterMethodChannel(name: "plugins.invisiblewrench.com/flutter_midi_command", binaryMessenger: registrar.messenger)
        #else
            let channel = FlutterMethodChannel(name: "plugins.invisiblewrench.com/flutter_midi_command", binaryMessenger: registrar.messenger())
        #endif
        let instance = SwiftFlutterMidiCommandPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)

        instance.setup(registrar)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        MIDIClientDispose(midiClient)
    }

    func setup(_ registrar: FlutterPluginRegistrar) {
        // Stream setup
        #if os(macOS)
            midiRXChannel = FlutterEventChannel(name: "plugins.invisiblewrench.com/flutter_midi_command/rx_channel", binaryMessenger: registrar.messenger)
        #else
            midiRXChannel = FlutterEventChannel(name: "plugins.invisiblewrench.com/flutter_midi_command/rx_channel", binaryMessenger: registrar.messenger())
        #endif
        midiRXChannel?.setStreamHandler(rxStreamHandler)


        #if os(macOS)
            midiSetupChannel = FlutterEventChannel(name: "plugins.invisiblewrench.com/flutter_midi_command/setup_channel", binaryMessenger: registrar.messenger)
        #else
            midiSetupChannel = FlutterEventChannel(name: "plugins.invisiblewrench.com/flutter_midi_command/setup_channel", binaryMessenger: registrar.messenger())
        #endif
        midiSetupChannel?.setStreamHandler(setupStreamHandler)

        // MIDI client with notification handler
        MIDIClientCreateWithBlock("plugins.invisiblewrench.com.FlutterMidiCommand" as CFString, &midiClient) { (notification) in
            self.handleMIDINotification(notification)
        }

        manager = CBCentralManager.init(delegate: self, queue: DispatchQueue.global(qos: .userInteractive))

#if os(iOS)
         session = MIDINetworkSession.default()
         session?.isEnabled = true
         session?.connectionPolicy = MIDINetworkConnectionPolicy.anyone
         #endif
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
//        print("call method \(call.method)")
        switch call.method {
        case "scanForDevices":
            print("\(manager.state.rawValue)")
            if manager.state == CBManagerState.poweredOn {
                print("Start discovery")
                discoveredDevices.removeAll()
                manager.scanForPeripherals(withServices: [CBUUID(string: "03B80E5A-EDE8-4B33-A751-6CE34EC4C700")], options: nil)
                result(nil)
            } else {
                print("BT not ready")
                result(FlutterError(code: "MESSAGEERROR", message: "bluetoothNotAvailable", details: call.arguments))
            }
            break
        case "stopScanForDevices":
            manager.stopScan()
            break
        case "getDevices":
            let devices = getDevices()
            print("--- devices ---\n\(devices)")
            result(devices)
            break
        case "connectToDevice":
            if let args = call.arguments as? Dictionary<String, Any> {
                if let deviceInfo = args["device"] as? Dictionary<String, Any> {
                    if let deviceId = deviceInfo["id"] as? String {
                        if connectedDevices[deviceId] != nil {
                            result(FlutterError.init(code: "MESSAGEERROR", message: "Device already connected", details: call.arguments))
                        } else {
                            connectToDevice(deviceId: deviceInfo["id"] as! String, type: deviceInfo["type"] as! String, ports: nil)
                        }
                        result(nil)
                    } else {
                        result(FlutterError.init(code: "MESSAGEERROR", message: "No device Id", details: deviceInfo))
                    }
                } else {
                    result(FlutterError.init(code: "MESSAGEERROR", message: "Could not parse deviceInfo", details: call.arguments))
                }
            } else {
                result(FlutterError.init(code: "MESSAGEERROR", message: "Could not parse args", details: call.arguments))
            }
            break
        case "disconnectDevice":
            if let deviceInfo = call.arguments as? Dictionary<String, Any> {
                if let deviceId = deviceInfo["id"] as? String {
                    disconnectDevice(deviceId: deviceId)
                } else {
                    result(FlutterError.init(code: "MESSAGEERROR", message: "No device Id", details: call.arguments))
                }
                result(nil)
            } else {
                result(FlutterError.init(code: "MESSAGEERROR", message: "Could not parse device id", details: call.arguments))
            }
            result(nil)
            break

        case "sendData":
            if let packet = call.arguments as? Dictionary<String, Any> {
                sendData(packet["data"] as! FlutterStandardTypedData, deviceId: packet["deviceId"] as? String, timestamp: packet["timestamp"] as? UInt64)
                result(nil)
            } else {
                result(FlutterError.init(code: "MESSAGEERROR", message: "Could not form midi packet", details: call.arguments))
            }
            break
        case "teardown":
            teardown()
            break
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    func teardown() {
        for device in connectedDevices {
            disconnectDevice(deviceId: device.value.id)
        }
        #if os(iOS)
        session?.isEnabled = false
        #endif
    }


    func connectToDevice(deviceId:String, type:String, ports:[Port]?) {
        print("connect \(deviceId) \(type)")
                
        if type == "BLE" {
            if let periph = discoveredDevices.filter({ (p) -> Bool in p.identifier.uuidString == deviceId }).first {
                let device = ConnectedBLEDevice(id: deviceId, type: type, streamHandler: rxStreamHandler, peripheral: periph, ports:ports)
                connectedDevices[deviceId] = device
                manager.stopScan()
                manager.connect(periph, options: nil)
            } else {
                print("error connecting to device \(deviceId) [\(type)]")
            }
        } else if type == "native" {
            let device = ConnectedNativeDevice(id: deviceId, type: type, streamHandler: rxStreamHandler, client: midiClient, ports:ports)
            connectedDevices[deviceId] = device
            setupStreamHandler.send(data: "deviceConnected")
        }
    }

    func disconnectDevice(deviceId:String) {
        let device = connectedDevices[deviceId]
        print("disconnect \(String(describing: device)) for id \(deviceId)")
        if let device = device {
            if device.deviceType == "BLE" {
                //let p = (device as! ConnectedBLEDevice).peripheral
                //manager.cancelPeripheralConnection(p)
                device.close()
            } else {
                print("disconmmected MIDI")
                device.close()
                setupStreamHandler.send(data: "deviceDisconnected")
            }
            connectedDevices.removeValue(forKey: deviceId)
        }
    }


    func sendData(_ data:FlutterStandardTypedData, deviceId: String?, timestamp: UInt64?) {
        let bytes = [UInt8](data.data)
        
        if let deviceId = deviceId {
            if let device = connectedDevices[deviceId] {
                device.send(bytes: bytes, timestamp: timestamp)
//                _sendDataToDevice(device: device, data: data, timestamp: timestamp)
            }
        } else {
            connectedDevices.values.forEach({ (device) in
                device.send(bytes: bytes, timestamp: timestamp)
//                _sendDataToDevice(device: device, data: data, timestamp: timestamp)
            })
        }
    }
    

    static func getMIDIProperty(_ prop:CFString, fromObject obj:MIDIObjectRef) -> String {
        var param: Unmanaged<CFString>?
        var result: String = "Error"
        let err: OSStatus = MIDIObjectGetStringProperty(obj, prop, &param)
        if err == OSStatus(noErr) { result = param!.takeRetainedValue() as String }
        return result
    }
    

    func createPortDict(count:Int) -> Array<Dictionary<String, Any>> {
        return (0..<count).map { (id) -> Dictionary<String, Any> in
            return ["id": id, "connected" : false]
        }
    }

    
    func getDevices() -> [Dictionary<String, Any>] {
        var devices:[Dictionary<String, Any>] = []

        //  Native
        var nativeDevices = Dictionary<MIDIEntityRef, Dictionary<String, Any>>()
        
        let destinationCount = MIDIGetNumberOfDestinations()
        for d in 0..<destinationCount {
            let destination = MIDIGetDestination(d)
//            print("dest \(destination) \(SwiftFlutterMidiCommandPlugin.getMIDIProperty(kMIDIPropertyName, fromObject: destination))")
            
            var entity : MIDIEntityRef = 0
            var status = MIDIEndpointGetEntity(destination, &entity)
            let entityName = SwiftFlutterMidiCommandPlugin.getMIDIProperty(kMIDIPropertyName, fromObject: entity)
//            print("entity \(entity) status \(status) \(entityName)")
            
            var device : MIDIDeviceRef = 0
            status = MIDIEntityGetDevice(entity, &device)
            let deviceName = SwiftFlutterMidiCommandPlugin.getMIDIProperty(kMIDIPropertyName, fromObject: device)
//            print("device \(device) status \(status) \(deviceName)")
            
            let entityCount = MIDIDeviceGetNumberOfEntities(device)
//            print("entityCount \(entityCount)")
            
            var entityIndex = 0;
            for e in 0..<entityCount {
                let ent = MIDIDeviceGetEntity(device, e)
//                print("ent \(ent)")
                if (ent == entity) {
                    entityIndex = e
                }
            }
//            print("entityIndex \(entityIndex)")
            
            let entityDestinationCount = MIDIEntityGetNumberOfDestinations(entity)
//            print("entiry dest count \(entityDestinationCount)")
            
            nativeDevices[entity] = [
                "name" : "\(deviceName) \(entityName)",
                "id" : "\(device):\(entityIndex)",
                "type" : "native",
                "connected":(connectedDevices.keys.contains(String(entity)) ? "true" : "false"),
                "outputs" : createPortDict(count: entityDestinationCount)
                ]
        }
        
        
        let sourceCount = MIDIGetNumberOfSources()
        for s in 0..<sourceCount {
            let source = MIDIGetSource(s)
//            print("src \(source) \(SwiftFlutterMidiCommandPlugin.getMIDIProperty(kMIDIPropertyName, fromObject: source))")
            
            var entity : MIDIEntityRef = 0
            var status = MIDIEndpointGetEntity(source, &entity)
            let entityName = SwiftFlutterMidiCommandPlugin.getMIDIProperty(kMIDIPropertyName, fromObject: entity)
//            print("entity \(entity) status \(status) \(entityName)")
            
            var device : MIDIDeviceRef = 0
            status = MIDIEntityGetDevice(entity, &device)
            let deviceName = SwiftFlutterMidiCommandPlugin.getMIDIProperty(kMIDIPropertyName, fromObject: device)
//            print("device \(device) status \(status) \(deviceName)")
            
            let entityCount = MIDIDeviceGetNumberOfEntities(device)
//            print("entityCount \(entityCount)")
            
            var entityIndex = 0;
            for e in 0..<entityCount {
                let ent = MIDIDeviceGetEntity(device, e)
//                print("ent \(ent)")
                if (ent == entity) {
                    entityIndex = e
                }
            }
//            print("entityIndex \(entityIndex)")
            
            let entitySourceCount = MIDIEntityGetNumberOfSources(entity)
//            print("entiry source count \(entitySourceCount)")
            
            if var deviceDict = nativeDevices[entity] {
//                print("add inputs to dict")
                deviceDict["inputs"] = createPortDict(count: entitySourceCount)
//                print(type(of: createPortDict(count: entitySourceCount)))
                nativeDevices[entity] = deviceDict
            } else {
//                print("create inputs dict")
                nativeDevices[entity] = [
                    "name" : "\(deviceName) \(entityName)",
                    "id" : "\(device):\(entityIndex)",
                    "type" : "native",
                    "connected":(connectedDevices.keys.contains(String(entity)) ? "true" : "false"),
                    "inputs" : createPortDict(count: entitySourceCount)
                    ]
            }
        }
        
        devices.append(contentsOf: nativeDevices.values)
        
        // BLE
        for periph:CBPeripheral in discoveredDevices {
            let id = periph.identifier.uuidString
            devices.append([
                "name" : periph.name ?? "Unknown",
                "id" : id,
                "type" : "BLE",
                "connected":(connectedDevices.keys.contains(id) ? "true" : "false"),
                "inputs" : [["id":0, "connected":false]],
                "outputs" : [["id":0, "connected":false]]
                ])
        }

        return devices;
    }


    func handleMIDINotification(_ midiNotification: UnsafePointer<MIDINotification>) {
        print("\ngot a MIDINotification!")

        let notification = midiNotification.pointee
        print("MIDI Notify, messageId= \(notification.messageID)")
        print("MIDI Notify, messageSize= \(notification.messageSize)")

        setupStreamHandler.send(data: "\(notification.messageID)")

        switch notification.messageID {

        // Some aspect of the current MIDISetup has changed.  No data.  Should ignore this  message if messages 2-6 are handled.
        case .msgSetupChanged:
            print("MIDI setup changed")
            let ptr = UnsafeMutablePointer<MIDINotification>(mutating: midiNotification)
            //            let ptr = UnsafeMutablePointer<MIDINotification>(midiNotification)
            let m = ptr.pointee
            print(m)
            print("id \(m.messageID)")
            print("size \(m.messageSize)")
            break


        // A device, entity or endpoint was added. Structure is MIDIObjectAddRemoveNotification.
        case .msgObjectAdded:

            print("added")
            //            let ptr = UnsafeMutablePointer<MIDIObjectAddRemoveNotification>(midiNotification)

            midiNotification.withMemoryRebound(to: MIDIObjectAddRemoveNotification.self, capacity: 1) {
                let m = $0.pointee
                print(m)
                print("id \(m.messageID)")
                print("size \(m.messageSize)")
                print("child \(m.child)")
                print("child type \(m.childType)")
                showMIDIObjectType(m.childType)
                print("parent \(m.parent)")
                print("parentType \(m.parentType)")
                showMIDIObjectType(m.parentType)
                //                print("childName \(String(describing: getDisplayName(m.child)))")
            }


            break

        // A device, entity or endpoint was removed. Structure is MIDIObjectAddRemoveNotification.
        case .msgObjectRemoved:
            print("kMIDIMsgObjectRemoved")
            //            let ptr = UnsafeMutablePointer<MIDIObjectAddRemoveNotification>(midiNotification)
            midiNotification.withMemoryRebound(to: MIDIObjectAddRemoveNotification.self, capacity: 1) {

                let m = $0.pointee
                print(m)
                print("id \(m.messageID)")
                print("size \(m.messageSize)")
                print("child \(m.child)")
                print("child type \(m.childType)")
                print("parent \(m.parent)")
                print("parentType \(m.parentType)")

                //                print("childName \(String(describing: getDisplayName(m.child)))")
            }
            break

        // An object's property was changed. Structure is MIDIObjectPropertyChangeNotification.
        case .msgPropertyChanged:
            print("kMIDIMsgPropertyChanged")
            midiNotification.withMemoryRebound(to: MIDIObjectPropertyChangeNotification.self, capacity: 1) {

                let m = $0.pointee
                print(m)
                print("id \(m.messageID)")
                print("size \(m.messageSize)")
                print("object \(m.object)")
                print("objectType  \(m.objectType)")
                print("propertyName  \(m.propertyName)")
                print("propertyName  \(m.propertyName.takeUnretainedValue())")

                if m.propertyName.takeUnretainedValue() as String == "apple.midirtp.session" {
                    print("connected")
                }
            }

            break

        //     A persistent MIDI Thru connection wasor destroyed.  No data.
        case .msgThruConnectionsChanged:
            print("MIDI thru connections changed.")
            break

        //A persistent MIDI Thru connection was created or destroyed.  No data.
        case .msgSerialPortOwnerChanged:
            print("MIDI serial port owner changed.")
            break

        case .msgIOError:
            print("MIDI I/O error.")

            //let ptr = UnsafeMutablePointer<MIDIIOErrorNotification>(midiNotification)
            midiNotification.withMemoryRebound(to: MIDIIOErrorNotification.self, capacity: 1) {
                let m = $0.pointee
                print(m)
                print("id \(m.messageID)")
                print("size \(m.messageSize)")
                print("driverDevice \(m.driverDevice)")
                print("errorCode \(m.errorCode)")
            }
            break
        @unknown default:
            break
        }
    }

    func showMIDIObjectType(_ ot: MIDIObjectType) {
        switch ot {
        case .other:
            os_log("midiObjectType: Other", log: midiLog, type: .debug)
            break

        case .device:
            os_log("midiObjectType: Device", log: midiLog, type: .debug)
            break

        case .entity:
            os_log("midiObjectType: Entity", log: midiLog, type: .debug)
            break

        case .source:
            os_log("midiObjectType: Source", log: midiLog, type: .debug)
            break

        case .destination:
            os_log("midiObjectType: Destination", log: midiLog, type: .debug)
            break

        case .externalDevice:
            os_log("midiObjectType: ExternalDevice", log: midiLog, type: .debug)
            break

        case .externalEntity:
            print("midiObjectType: ExternalEntity")
            os_log("midiObjectType: ExternalEntity", log: midiLog, type: .debug)
            break

        case .externalSource:
            os_log("midiObjectType: ExternalSource", log: midiLog, type: .debug)
            break

        case .externalDestination:
            os_log("midiObjectType: ExternalDestination", log: midiLog, type: .debug)
            break
        @unknown default:
            break
        }

    }

    #if os(iOS)
    /// MIDI Network Session
     @objc func midiNetworkChanged(notification:NSNotification) {
            print("\(#function)")
            print("\(notification)")
            if let session = notification.object as? MIDINetworkSession {
                print("session \(session)")
                for con in session.connections() {
                    print("con \(con)")
                }
                print("isEnabled \(session.isEnabled)")
                print("sourceEndpoint \(session.sourceEndpoint())")
                print("destinationEndpoint \(session.destinationEndpoint())")
                print("networkName \(session.networkName)")
                print("localName \(session.localName)")

                //            if let name = getDeviceName(session.sourceEndpoint()) {
                //                print("source name \(name)")
                //            }
                //
                //            if let name = getDeviceName(session.destinationEndpoint()) {
                //                print("destination name \(name)")
                //            }
            }
            setupStreamHandler.send(data: "\(#function) \(notification)")
        }

    @objc func midiNetworkContactsChanged(notification:NSNotification) {
        print("\(#function)")
        print("\(notification)")
        if let session = notification.object as? MIDINetworkSession {
            print("session \(session)")
            for con in session.contacts() {
                print("contact \(con)")
            }
        }
        setupStreamHandler.send(data: "\(#function) \(notification)")
    }
    #endif

    /// BLE handling

    // Central
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("central did update state \(central.state.rawValue)")
    }

    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("central didDiscover \(peripheral)")
        if !discoveredDevices.contains(peripheral) {
            discoveredDevices.insert(peripheral)
            setupStreamHandler.send(data: "deviceFound")
        }
    }

    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("central did connect \(peripheral)")
//        connectedPeripheral = peripheral
//        peripheral.delegate = self
//        peripheral.discoverServices([CBUUID(string: "03B80E5A-EDE8-4B33-A751-6CE34EC4C700")])
        setupStreamHandler.send(data: "deviceConnected")
        
        (connectedDevices[peripheral.identifier.uuidString] as! ConnectedBLEDevice).setupBLE()
    }

    public func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("central did fail to connect state \(peripheral)")
//        connectingDevice = nil
        
        setupStreamHandler.send(data: "connectionFailed")
        connectedDevices.removeValue(forKey: peripheral.identifier.uuidString)
    }

    public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("central didDisconnectPeripheral \(peripheral)")
        
//        connectedPeripheral = nil
//        connectedCharacteristic = nil
        setupStreamHandler.send(data: "deviceDisconnected")
    }    
}

class StreamHandler : NSObject, FlutterStreamHandler {

    var sink:FlutterEventSink?

    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        sink = events
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        sink = nil
        return nil
    }

    func send(data: Any) {
        if let sink = sink {
            sink(data)
//        } else {
//            print("no sink")
        }
    }
}

class Port {
    var id:Int
    var type:String
    
    init(id:Int, type:String) {
        self.id = id;
        self.type = type
    }
}

class ConnectedDevice : NSObject {
    var id:String
    var deviceType:String
    var streamHandler : StreamHandler
    
    init(id:String, type:String, streamHandler:StreamHandler) {
        self.id = id
        self.deviceType = type
        self.streamHandler = streamHandler
    }
    
    func openPorts() {}
    
    func send(bytes:[UInt8], timestamp: UInt64?) {}
    
    func close() {}
}

class ConnectedNativeDevice : ConnectedDevice {
    var outputPort = MIDIPortRef()
    var inputPort = MIDIPortRef()
    var client : MIDIClientRef
    var name : String?
    var outEndpoint : MIDIEndpointRef?
    var inSource : MIDIEndpointRef?
    var entity : MIDIEntityRef?
    var ports:[Port]?
    
    init(id:String, type:String, streamHandler:StreamHandler, client: MIDIClientRef, ports:[Port]?) {
        self.client = client
        self.ports = ports
        let idParts = id.split(separator: ":")
        
        // Store entity and get device/entity name
        if let deviceId = MIDIDeviceRef(idParts[0]) {
            if let entityId = Int(idParts[1]) {
                entity = MIDIDeviceGetEntity(deviceId, entityId)
                if let e = entity {
                    let entityName = SwiftFlutterMidiCommandPlugin.getMIDIProperty(kMIDIPropertyName, fromObject: e)
                    
                    var device:MIDIDeviceRef = 0
                    MIDIEntityGetDevice(e, &device)
                    let deviceName = SwiftFlutterMidiCommandPlugin.getMIDIProperty(kMIDIPropertyName, fromObject: device)
                    
                    name = "\(deviceName) \(entityName)"
                } else {
                    print("no entity")
                }
            } else {
                print("no entityId")
            }
        } else {
            print("no deviceId")
        }
        
        super.init(id: id, type: type, streamHandler: streamHandler)
        
        // MIDI Input with handler
         MIDIInputPortCreateWithBlock(client, "FlutterMidiCommand_InPort" as CFString, &inputPort) { (packetList, srcConnRefCon) in
             self.handlePacketList(packetList, srcConnRefCon: srcConnRefCon)
         }
        
        // MIDI output
        MIDIOutputPortCreate(client, "FlutterMidiCommand_OutPort" as CFString, &outputPort);

        openPorts()
    }
        
    override func send(bytes: [UInt8], timestamp: UInt64?) {
        if let ep = outEndpoint {
            let packetList = UnsafeMutablePointer<MIDIPacketList>.allocate(capacity: 1)
            var packet = MIDIPacketListInit(packetList)
            let time = timestamp ?? mach_absolute_time()
            packet = MIDIPacketListAdd(packetList, 1024, packet, time, bytes.count, bytes)

            let status = MIDISend(outputPort, ep, packetList)
            //print("send bytes \(bytes) on port \(outputPort) \(ep) status \(status)")
            packetList.deallocate()
        } else {
            print("No MIDI destination for id \(name!)")
        }
    }
    
    override func openPorts() {
        print("open native ports")
        
        if let e = entity {

            if let ps = ports {
                for port in ps {
                    inSource = MIDIEntityGetSource(e, port.id)

                    switch port.type {
                    case "MidiPortType.IN":
                        let status = MIDIPortConnectSource(inputPort, inSource!, &name)
                        print("port open status \(status)")
                    case "MidiPortType.OUT":
                        outEndpoint = MIDIEntityGetDestination(e, port.id)
    //                    print("port endpoint \(endpoint)")
                        break
                    default:
                        print("unknown port type \(port.type)")
                    }
                }
            } else {
                print("open default ports")
                inSource = MIDIEntityGetSource(e, 0)
                let status = MIDIPortConnectSource(inputPort, inSource!, &name)
                outEndpoint = MIDIEntityGetDestination(e, 0)
            }
        }
    }
    
    override func close() {
        if let oEP = outEndpoint {
            MIDIEndpointDispose(oEP)
        }
        
        if let iS = inSource {
            MIDIPortDisconnectSource(inputPort, iS)
        }
        
        MIDIPortDispose(inputPort)
        MIDIPortDispose(outputPort)
    }
    
    func handlePacketList(_ packetList:UnsafePointer<MIDIPacketList>, srcConnRefCon:UnsafeMutableRawPointer?) {
        let packets = packetList.pointee
        let packet:MIDIPacket = packets.packet
        var ap = UnsafeMutablePointer<MIDIPacket>.allocate(capacity: 1)
        ap.initialize(to:packet)

        let deviceInfo = ["name" : name,
                          "id": String(id),
                          "type":"native"]
        
        for _ in 0 ..< packets.numPackets {
            let p = ap.pointee
            var tmp = p.data
            let data = Data(bytes: &tmp, count: Int(p.length))
            let timestamp = p.timeStamp
//            print("data \(data) timestamp \(timestamp)")
            streamHandler.send(data: ["data": data, "timestamp":timestamp, "device":deviceInfo])
            ap = MIDIPacketNext(ap)
        }
        
//        ap.deallocate()
    }
}

class ConnectedBLEDevice : ConnectedDevice, CBPeripheralDelegate {
    var peripheral:CBPeripheral
    var characteristic:CBCharacteristic?
    
    // BLE MIDI parsing
    enum BLE_HANDLER_STATE
    {
        case HEADER
        case TIMESTAMP
        case STATUS
        case STATUS_RUNNING
        case PARAMS
        case SYSTEM_RT
        case SYSEX
        case SYSEX_END
        case SYSEX_INT
    }

    var bleHandlerState = BLE_HANDLER_STATE.HEADER

    var sysExBuffer: [UInt8] = []
    var timestamp: UInt64 = 0
    var bleMidiBuffer:[UInt8] = []
    var bleMidiPacketLength:UInt8 = 0
    var bleSysExHasFinished = true
    
    init(id:String, type:String, streamHandler:StreamHandler, peripheral:CBPeripheral, ports:[Port]?) {
        self.peripheral = peripheral
        super.init(id: id, type: type, streamHandler: streamHandler)
    }
    
    func setupBLE() {
        peripheral.delegate = self
        peripheral.discoverServices([CBUUID(string: "03B80E5A-EDE8-4B33-A751-6CE34EC4C700")])
    }

    
    override func close() {
        CBCentralManager().cancelPeripheralConnection(peripheral)
        characteristic = nil
    }
    
    override func send(bytes:[UInt8], timestamp: UInt64?) {
//        print("ble send \(id) \(bytes)")
        if (characteristic != nil) {
            let packetSize = 20
            
            var dataBytes = Data(bytes)
            
            if bytes.first == 0xF0 && bytes.last == 0xF7 { //  this is a sysex message, handle carefully
                if bytes.count > 17 { // Split into multiple messages of 20 bytes total
                    
                    
                    // First packet
                    var packet = dataBytes.subdata(in: 0..<packetSize-2)
                    
                    print("count \(dataBytes.count)")
                    
                    // Insert header(and empty timstamp high) and timestamp low in front Sysex Start
                    packet.insert(0x80, at: 0)
                    packet.insert(0x80, at: 0)
                    
//                        print("packet \(packet)")
//                        print("packet \(hexEncodedString(packet))")
                    
                    peripheral.writeValue(packet, for: characteristic!, type: CBCharacteristicWriteType.withoutResponse)
                    
                    dataBytes = dataBytes.advanced(by: packetSize-2)
                    
                    // More packets
                    while dataBytes.count > 0 {
                        
                        print("count \(dataBytes.count)")
                        
                        let pickCount = min(dataBytes.count, packetSize-1)
//                            print("pickCount \(pickCount)")
                        packet = dataBytes.subdata(in: 0..<pickCount) // Pick bytes for packet
                        
                        // Insert header
                        packet.insert(0x80, at: 0)
                        
                        if (packet.count < packetSize) { // Last packet
                            // Timestamp before Sysex End byte
                            print("insert end")
                            packet.insert(0x80, at: packet.count-1)
                        }
                        
//                            print("packet \(hexEncodedString(packet))")
                        

                        peripheral.writeValue(packet, for: characteristic!, type: CBCharacteristicWriteType.withoutResponse)
                        
                        if (dataBytes.count > packetSize-2) {
                            dataBytes = dataBytes.advanced(by: pickCount) // Advance buffer
                        }
                        else {
                            print("done")
                            return
                        }
                    }
                } else {
                    // Insert timestamp low in front of Sysex End-byte
                    dataBytes.insert(0x80, at: bytes.count-1)
                    
                    // Insert header(and empty timstamp high) and timestamp low in front of BLE Midi message
                    dataBytes.insert(0x80, at: 0)
                    dataBytes.insert(0x80, at: 0)
                    
                    peripheral.writeValue(dataBytes, for: characteristic!, type: CBCharacteristicWriteType.withoutResponse)
                }
                return
            }
            
            // Insert header(and empty timstamp high) and timestamp low in front of BLE Midi message
            dataBytes.insert(0x80, at: 0)
            dataBytes.insert(0x80, at: 0)
            
            peripheral.writeValue(dataBytes, for: characteristic!, type: CBCharacteristicWriteType.withoutResponse)
        } else {
            print("No peripheral/characteristic in device")
        }
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print("perif didDiscoverServices  \(String(describing: peripheral.services))")
        for service:CBService in peripheral.services! {
            peripheral.discoverCharacteristics(nil, for: service)
        }
    }

    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        print("perif didDiscoverCharacteristicsFor  \(String(describing: service.characteristics))")
        for characteristic:CBCharacteristic in service.characteristics! {
            if characteristic.uuid.uuidString == "7772E5DB-3868-4112-A1A9-F2669D106BF3" {
                self.characteristic = characteristic
                peripheral.setNotifyValue(true, for: characteristic)
                print("set up characteristic for device")
            }
        }
    }
    
    func createMessageEvent(_ bytes:[UInt8], timestamp:UInt64, peripheral:CBPeripheral) {
//        print("send rx event \(bytes)")
        let data = Data(bytes: bytes, count: Int(bytes.count))
        streamHandler.send(data: ["data": data, "timestamp":timestamp, "device":[
                                                            "name" : peripheral.name ?? "-",
                                        "id":peripheral.identifier.uuidString,
                                                                    "type":"BLE"]])
    }

    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
//        print("perif didUpdateValueFor  \(String(describing: characteristic))")
        if let value = characteristic.value {
            parseBLEPacket(value, peripheral:peripheral)
        }
    }
    
    func parseBLEPacket(_ packet:Data, peripheral:CBPeripheral) -> Void {
//        print("parse \(packet)")
        
        if (packet.count > 1)
          {
            // parse BLE message
            bleHandlerState = BLE_HANDLER_STATE.HEADER

            let header = packet[0]
            var statusByte:UInt8 = 0

            for i in 1...packet.count-1 {
                let midiByte:UInt8 = packet[i]
//              print ("bleHandlerState \(bleHandlerState) byte \(midiByte)")
                
                if ((midiByte & 0x80) == 0x80 && bleHandlerState != BLE_HANDLER_STATE.TIMESTAMP && bleHandlerState != BLE_HANDLER_STATE.SYSEX_INT) {
                    if (!bleSysExHasFinished) {
                        bleHandlerState = BLE_HANDLER_STATE.SYSEX_INT
                    } else {
                        bleHandlerState = BLE_HANDLER_STATE.TIMESTAMP
                    }
                } else {

                  // State handling
                  switch (bleHandlerState)
                  {
                  case BLE_HANDLER_STATE.HEADER:
                    if (!bleSysExHasFinished)
                    {
                      if ((midiByte & 0x80) == 0x80)
                      { // System messages can interrupt ongoing sysex
                        bleHandlerState = BLE_HANDLER_STATE.SYSEX_INT
                      }
                      else
                      {
                        // Sysex continue
                        //print("sysex continue")
                        bleHandlerState = BLE_HANDLER_STATE.SYSEX
                      }
                    }
                    break

                  case BLE_HANDLER_STATE.TIMESTAMP:
                    if ((midiByte & 0xFF) == 0xF0)
                    { // Sysex start
                      bleSysExHasFinished = false
                        sysExBuffer.removeAll()
                      bleHandlerState = BLE_HANDLER_STATE.SYSEX
                    }
                    else if ((midiByte & 0x80) == 0x80)
                    { // Status/System start
                      bleHandlerState = BLE_HANDLER_STATE.STATUS
                    }
                    else
                    {
                      bleHandlerState = BLE_HANDLER_STATE.STATUS_RUNNING
                    }
                    break

                  case BLE_HANDLER_STATE.STATUS:
                      bleHandlerState = BLE_HANDLER_STATE.PARAMS
                    break

                  case BLE_HANDLER_STATE.STATUS_RUNNING:
                    bleHandlerState = BLE_HANDLER_STATE.PARAMS
                    break;

                  case BLE_HANDLER_STATE.PARAMS: // After params can come TSlow or more params
                    break

                  case BLE_HANDLER_STATE.SYSEX:
                    break

                  case BLE_HANDLER_STATE.SYSEX_INT:
                    if ((midiByte & 0xF7) == 0xF7)
                    { // Sysex end
//                        print("sysex end")
                      bleSysExHasFinished = true
                      bleHandlerState = BLE_HANDLER_STATE.SYSEX_END
                    }
                    else
                    {
                        bleHandlerState = BLE_HANDLER_STATE.SYSTEM_RT
                    }
                    break;

                  case BLE_HANDLER_STATE.SYSTEM_RT:
                    if (!bleSysExHasFinished)
                    { // Continue incomplete Sysex
                      bleHandlerState = BLE_HANDLER_STATE.SYSEX
                    }
                    break

                  default:
                    print ("Unhandled state \(bleHandlerState)")
                    break
                  }
                }

//                print ("\(bleHandlerState) - \(midiByte) [\(String(format:"%02X", midiByte))]")

              // Data handling
              switch (bleHandlerState)
              {
              case BLE_HANDLER_STATE.TIMESTAMP:
//                print ("set timestamp")
                let tsHigh = header & 0x3f
                let tsLow = midiByte & 0x7f
                timestamp = UInt64(tsHigh) << 7 | UInt64(tsLow)
//                print ("timestamp is \(timestamp)")
                break

              case BLE_HANDLER_STATE.STATUS:

                bleMidiPacketLength = lengthOfMessageType(midiByte)
//                print("message length \(bleMidiPacketLength)")
                bleMidiBuffer.removeAll()
                bleMidiBuffer.append(midiByte)
                
                if bleMidiPacketLength == 1 {
                    createMessageEvent(bleMidiBuffer, timestamp: timestamp, peripheral:peripheral) // TODO Add timestamp
                } else {
//                    print ("set status")
                    statusByte = midiByte
                }
                break

              case BLE_HANDLER_STATE.STATUS_RUNNING:
//                print("set running status")
                bleMidiPacketLength = lengthOfMessageType(statusByte)
                bleMidiBuffer.removeAll()
                bleMidiBuffer.append(statusByte)
                bleMidiBuffer.append(midiByte)
                
                if bleMidiPacketLength == 2 {
                    createMessageEvent(bleMidiBuffer, timestamp: timestamp, peripheral:peripheral)
                }
                break

              case BLE_HANDLER_STATE.PARAMS:
//                print ("add param \(midiByte)")
                bleMidiBuffer.append(midiByte)
                
                if bleMidiPacketLength == bleMidiBuffer.count {
                    createMessageEvent(bleMidiBuffer, timestamp: timestamp, peripheral:peripheral)
                    bleMidiBuffer.removeLast(Int(bleMidiPacketLength)-1) // Remove all but status, which might be used for running msgs
                }
                break

              case BLE_HANDLER_STATE.SYSTEM_RT:
//                print("handle RT")
                createMessageEvent([midiByte], timestamp: timestamp, peripheral:peripheral)
                break

              case BLE_HANDLER_STATE.SYSEX:
//                print("add sysex")
                sysExBuffer.append(midiByte)
                break

              case BLE_HANDLER_STATE.SYSEX_INT:
//                print("sysex int")
                break

              case BLE_HANDLER_STATE.SYSEX_END:
//                print("finalize sysex")
                sysExBuffer.append(midiByte)
                createMessageEvent(sysExBuffer, timestamp: 0, peripheral:peripheral)
                break

              default:
                print ("Unhandled state (data) \(bleHandlerState)")
                break
              }
            }
          }
        }
    
    func lengthOfMessageType(_ type:UInt8) -> UInt8 {
        let midiType:UInt8 = type & 0xF0
        
        switch (type) {
            case 0xF6, 0xF8, 0xFA, 0xFB, 0xFC, 0xFF, 0xFE:
                return 1
            case 0xF1, 0xF3:
                    return 2
            default:
                break
        }
        
        switch (midiType) {
            case 0xC0, 0xD0:
                return 2
            case 0xF2, 0x80, 0x90, 0xA0, 0xB0, 0xE0:
                return 3
            default:
                break
        }
        return 0
    }
}
