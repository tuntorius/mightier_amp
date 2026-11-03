import 'package:flutter/foundation.dart';

import '../NuxConstants.dart';
import '../NuxDevice.dart';
import '../NuxFXID.dart';
import '../presets/NamProPreset.dart';
import 'plugProCommunication.dart';

const List<int> _kNfHeader = [0x43, 0x58, 0x70, 0x04, 0x02, 0x4E, 0x46, 0x01];
const int _kNfReplyMinLength = 50;
const int _kNfOpOffset = 11; 
const int _kNfPayloadOffset = 21; 

class NamProCommunication extends PlugProCommunication {
  int _nfNonce = 0;
  
  // CRITICAL: Cache the active Model Checksum required to authorize slider writes
  List<int> _lastModelChecksum = [0, 0, 0, 0, 0];

  NamProCommunication(NuxDevice device, NuxDeviceConfiguration config)
      : super(device, config);

  void sendNfPayload(List<int> config32) {
    if (!device.deviceControl.isConnected) return;

    debugPrint(">>> TRANSMITTING NF SYSEX (${config32.length} bytes): $config32");

    _nfNonce = (_nfNonce % 16383) + 1;
    final int token = _nfNonce;
    final int slot = device.selectedChannel;

    // The hardware requires the ACTIVE model checksum to authorize the write.
    final List<int> payload = [
      0x80,
      0x80, 
      MidiMessageValues.sysExStart, 
      0x43, 0x58, SysexPrivacy.kSYSEX_PRIVATE, 0x04, 0x02, 0x4E, 0x46, 0x01,
      0x01, // Write Op
      slot == 255 ? 127 : slot,
      token & 127,
      (token >> 7) & 127,
      0x00,
      ..._lastModelChecksum, // 5 model checksum bytes captured from previous reads
      ...config32, // Exactly 32 bytes Faust configuration payload
      MidiMessageValues.sysExEnd // 0xF7
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
      0x80,
      0x80, 
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

    // CRITICAL: Harvest the active model checksum from the read payload
    if (data.length >= 21) {
      _lastModelChecksum = data.sublist(16, 21);
    }

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
    if (_isNfReply(data)) {
      _handleNfReply(data);
      return;
    }

    if (data.length > 9 &&
        data[2] == MidiMessageValues.sysExStart &&
        data[5] == SysexPrivacy.kSYSEX_PRIVATE &&
        data[6] == SyxMsg.kSYX_CURPRESET &&
        data[9] == 0x32) {
      super.onDataReceive(data);
      requestNfPayload(op: 0);
      return;
    }
    super.onDataReceive(data);
  }
}