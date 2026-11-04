import 'package:flutter/foundation.dart';

import '../NuxConstants.dart';
import '../NuxDevice.dart';
import '../NuxFXID.dart';
import '../presets/NamProPreset.dart';
import 'plugProCommunication.dart';

const List<int> _kNfHeader = [0x43, 0x58, 0x70, 0x04, 0x02, 0x4E, 0x46, 0x01];
const int _kNfReplyMinLength = 50;
const int _kNfOpOffset = 11; 
const int _kNfPayloadOffset = 17; 

class NamProCommunication extends PlugProCommunication {
  int _nfNonce = 0;
  
  // Track the active model CRC harvested from the proprietary "NP" diagnostic poll
  List<int> activeModelCrc = [0, 0, 0, 0, 0];
  bool _crcReady = false;

  NamProCommunication(NuxDevice device, NuxDeviceConfiguration config)
      : super(device, config);

  /// Requests the active model CRC from the firmware's diagnostic "NP" Page 5.
  void requestModelCrc() {
    if (!device.deviceControl.isConnected) return;
    _crcReady = false;
    
    // Proprietary command: [F0, 43, 58, 70, 04, 02, 4E, 50, 05, F7]
    // 4E 50 = "NP" (Nam Page), 05 = Page 5 (Checksum)
    final List<int> frame = [
      0x80, 0x80, // BLE MIDI timestamp
      MidiMessageValues.sysExStart, 
      0x43, 0x58, SysexPrivacy.kSYSEX_PRIVATE, 0x04, 0x02, 
      0x4E, 0x50, // 'N', 'P'
      0x05,       // Page 5
      MidiMessageValues.sysExEnd
    ];
    device.deviceControl.sendBLEData(frame);
  }

  void sendNfPayload(List<int> config32) {
    if (!device.deviceControl.isConnected) return;

    // If we haven't harvested the CRC yet, request it and wait. 
    // The reply handler will automatically resend the payload once it arrives.
    if (!_crcReady) {
      requestModelCrc();
      return;
    }

    _nfNonce = (_nfNonce % 16383) + 1;
    final int token = _nfNonce;
    final int slot = device.selectedChannel;

    debugPrint(">>> TRANSMITTING NF SYSEX (${config32.length} bytes) | CRC: $activeModelCrc");

    // Strict 52-byte MIDI SysEx (from F0 to F7) with 2-byte BLE header.
    final List<int> payload = [
      0x80, 0x80, 
      MidiMessageValues.sysExStart, 
      0x43, 0x58, SysexPrivacy.kSYSEX_PRIVATE, 0x04, 0x02, 0x4E, 0x46, 0x01,
      0x01, // Write Op
      slot == 255 ? 127 : slot,
      token & 127,
      (token >> 7) & 127,
      0x00,
      ...activeModelCrc, // 5 model checksum bytes satisfying the firmware security lock
      ...config32, // Exactly 32 bytes Faust configuration payload
      MidiMessageValues.sysExEnd
    ];

    device.deviceControl.sendBLEData(payload);
  }

  @override
  void sendSlotOrder() {
    if (!device.deviceControl.isConnected) return;
    final preset = device.getPreset(device.selectedChannel);

    if (preset is NamProPreset) {
      final List<NuxFXID> stockBlocks = preset.processorAtSlot
          .where((id) => id != MightyNamFXID.fxA && id != MightyNamFXID.fxB)
          .toList();

      final List<int> nuxOrder = [stockBlocks.length];
      for (var fxid in stockBlocks) {
        nuxOrder.add(fxid.toInt());
      }

      final stockMsg = createSysExMessagePro(
        SysexPrivacy.kSYSEX_PRIVATE,
        SyxMsg.kSYX_MODULELINK,
        SyxDir.kSYXDIR_SET,
        nuxOrder,
      );
      device.deviceControl.sendBLEData(stockMsg);
      sendNfPayload(preset.generateNfPayload());
    } else {
      super.sendSlotOrder();
    }
  }

  @override
  void saveCurrentPreset(int index) {
    var preset = device.getPreset(index);
    if (preset is NamProPreset) {
      sendNfPayload(preset.generateNfPayload());
    }
    super.saveCurrentPreset(index);
  }

  void requestNfPayload({int op = 0, int? slot}) {
    if (!device.deviceControl.isConnected) return;
    _nfNonce = (_nfNonce % 16383) + 1;
    final int token = _nfNonce;
    final int targetSlot = slot ?? device.selectedChannel;

    final List<int> frame = [
      0x80, 0x80, 
      MidiMessageValues.sysExStart, 
      0x43, 0x58, SysexPrivacy.kSYSEX_PRIVATE, 0x04, 0x02, 0x4E, 0x46, 0x01,
      op & 0x7F, 
      targetSlot == 255 ? 127 : targetSlot,
      token & 127,
      (token >> 7) & 127,
      MidiMessageValues.sysExEnd, 
    ];

    device.deviceControl.sendBLEData(frame);
  }

  bool _isNfReply(List<int> data) {
    if (data.length < _kNfReplyMinLength) return false;
    if (data[2] != MidiMessageValues.sysExStart) return false;
    for (int i = 0; i < _kNfHeader.length; i++) {
      if (data[3 + i] != _kNfHeader[i]) return false;
    }
    return true;
  }

  void _handleNfReply(List<int> data) {
    final int opEcho = data[_kNfOpOffset];
    final int requestedOp = opEcho & ~0x40;
    if (requestedOp == 1) return;

    final int payloadStart = _kNfPayloadOffset;
    if (data.length < payloadStart + 32) return;

    final List<int> config32 = data.sublist(payloadStart, payloadStart + 32);
    final preset = device.getPreset(device.selectedChannel);
    if (preset is NamProPreset) {
      preset.applyNfPayload(config32);
      device.deviceControl.forceNotifyListeners();
    }
  }

  @override
  void onDataReceive(List<int> data) {
    // 1. Check for proprietary "NP" diagnostic page replies (specifically Page 5 for the CRC)
    if (data.length >= 17 &&
        data[2] == MidiMessageValues.sysExStart &&
        data[3] == 0x43 && data[4] == 0x58 && data[5] == 0x70 &&
        data[6] == 0x04 && data[7] == 0x02 && data[8] == 0x01) {
      
      final int page = data[9];
      final int status = data[10];

      // Page 5 contains the active model CRC
      if (page == 0x05 && status == 0) {
        activeModelCrc = data.sublist(11, 16);
        _crcReady = true;
        debugPrint("NamProComm: Harvested Active Model CRC: $activeModelCrc");
        
        // Resend the slider data now that we have the authorization key
        final preset = device.getPreset(device.selectedChannel);
        if (preset is NamProPreset) {
           sendNfPayload(preset.generateNfPayload());
        }
      }
      return;
    }

    // 2. Check for "NF" parameter read replies
    if (_isNfReply(data)) {
      _handleNfReply(data);
      return;
    }

    // 3. Fallback to standard NUX processing
    if (data.length > 9 &&
        data[2] == MidiMessageValues.sysExStart &&
        data[5] == SysexPrivacy.kSYSEX_PRIVATE &&
        data[6] == SyxMsg.kSYX_CURPRESET &&
        data[9] == 0x32) {
      super.onDataReceive(data);
      
      // When channel changes, request the new model CRC, which will auto-trigger parameter syncing
      requestModelCrc();
      requestNfPayload(op: 0);
      return;
    }

    super.onDataReceive(data);
  }
}