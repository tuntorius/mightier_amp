import 'package:flutter/foundation.dart';

import '../NuxConstants.dart';
import '../NuxDevice.dart';
import '../NuxFXID.dart';
import '../presets/NamProPreset.dart';
import 'plugProCommunication.dart';

/// NF SysEx header bytes (after 0xF0): C X p 0x04 0x02 N F 0x01
const List<int> _kNfHeader = [0x43, 0x58, 0x70, 0x04, 0x02, 0x4E, 0x46, 0x01];

/// Minimum raw BLE data length for a valid NF reply:
/// 2 BLE ts + 1 F0 + 8 hdr + op + slot + tok_lo + tok_hi + 0x00 + status + 32 config + F7 = 50 bytes.
const int _kNfReplyMinLength = 50;

/// Byte offset of the op byte inside the raw BLE-framed NF message.
const int _kNfOpOffset = 11; // ts(0,1) + F0(2) + hdr(3..10) -> opEcho at 11

/// Byte offset where the 32-byte config payload begins in a BLE-framed NF reply.
const int _kNfPayloadOffset = 17;

class NamProCommunication extends PlugProCommunication {
  int _nfNonce = 0;

  NamProCommunication(NuxDevice device, NuxDeviceConfiguration config)
      : super(device, config);

  /// Transmits the 32-byte Faust configuration to the custom firmware
  /// via the custom "NF" SysEx protocol.
  void sendNfPayload(List<int> config32) {
    if (!device.deviceControl.isConnected) {
      debugPrint("NamProComm: sendNfPayload skipped - Device not connected");
      return;
    }

    debugPrint(">>> TRANSMITTING NF SYSEX (${config32.length} bytes): $config32");

    _nfNonce = (_nfNonce % 16383) + 1;
    final int token = _nfNonce;
    final int slot = device.selectedChannel;

    // Fixed wire frame: exactly 52 bytes of MIDI SysEx (from 0xF0 to 0xF7).
    // Preceded by [0x80, 0x80] BLE MIDI timestamp header (total 54 bytes).
    final List<int> payload = [
      0x80,
      0x80, // BLE MIDI timestamp header
      MidiMessageValues.sysExStart, // 0xF0
      0x43, // 'C'
      0x58, // 'X'
      SysexPrivacy.kSYSEX_PRIVATE, // 0x70
      0x04,
      0x02,
      0x4E, // 'N'
      0x46, // 'F'
      0x01, // Version 1
      0x01, // Op: 1 (Write)
      slot == 255 ? 127 : slot,
      token & 127,
      (token >> 7) & 127,
      0x00,
      0x00, 0x00, 0x00, 0x00, 0x00, // 5 model checksum bytes (zero placeholder)
      ...config32, // Exactly 32 bytes Faust configuration payload
      MidiMessageValues.sysExEnd // 0xF7 (SysEx end directly; no trailing 0x80)
    ];

    device.deviceControl.sendBLEData(payload);
  }

  @override
  void sendSlotOrder() {
    if (!device.deviceControl.isConnected) return;
    final preset = device.getPreset(device.selectedChannel);

    if (preset is NamProPreset) {
      // 1. Filter out FX A and FX B: stock MODULELINK only accepts the 9 stock blocks
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

      // 2. Transmit the 32-byte NF packet containing FX A and FX B positions (0 to 10)
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

  // ---------------------------------------------------------------------------
  // NF Readback
  // ---------------------------------------------------------------------------

  void requestNfPayload({int op = 0, int? slot}) {
    if (!device.deviceControl.isConnected) return;
    _nfNonce = (_nfNonce % 16383) + 1;
    final int token = _nfNonce;
    final int targetSlot = slot ?? device.selectedChannel;

    // Strict 14-byte MIDI SysEx (F0 to F7), 16 bytes total over BLE including [0x80, 0x80]
    final List<int> frame = [
      0x80,
      0x80, // BLE MIDI timestamp header
      MidiMessageValues.sysExStart, // 0xF0
      0x43, // 'C'
      0x58, // 'X'
      SysexPrivacy.kSYSEX_PRIVATE, // 0x70
      0x04,
      0x02,
      0x4E, // 'N'
      0x46, // 'F'
      0x01, // Version 1
      op & 0x7F, // Op: 0 = read live, 2 = read saved
      targetSlot == 255 ? 127 : targetSlot,
      token & 127,
      (token >> 7) & 127,
      MidiMessageValues.sysExEnd, // 0xF7 (SysEx end directly; no trailing 0x80)
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

    // Ignore write ACK to avoid overwriting active user sliders
    if (requestedOp == 1) return;

    final int payloadStart = _kNfPayloadOffset;
    if (data.length < payloadStart + 32) {
      debugPrint(
          'NamProComm: NF reply too short (${data.length} bytes), skipping.');
      return;
    }

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