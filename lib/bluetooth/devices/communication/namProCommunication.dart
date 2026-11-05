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

  List<int> activeModelCrc = [0, 0, 0, 0, 0];
  bool _crcReady = false;
  bool _crcRequestPending = false; 
  
  List<int>? _pendingNfPayload;

  NamProCommunication(NuxDevice device, NuxDeviceConfiguration config)
      : super(device, config);

  void requestModelCrc() {
    if (!device.deviceControl.isConnected) return;
    
    if (_crcRequestPending) return;
    _crcRequestPending = true;
    _crcReady = false;

    final List<int> frame = [
      0x80,
      0x80,
      MidiMessageValues.sysExStart,
      0x43,
      0x58,
      SysexPrivacy.kSYSEX_PRIVATE,
      0x04,
      0x02,
      0x4E,
      0x50, 
      0x05, 
      MidiMessageValues.sysExEnd
    ];
    device.deviceControl.sendBLEData(frame);
  }

  void sendNfPayload(List<int> config32) {
    if (!device.deviceControl.isConnected) return;

    if (!_crcReady) {
      _pendingNfPayload = config32;
      requestModelCrc();
      return;
    }

    _nfNonce = (_nfNonce % 16383) + 1;
    final int token = _nfNonce;
    final int slot = device.selectedChannel;

    final List<int> payload = [
      0x80, 0x80,
      MidiMessageValues.sysExStart,
      0x43, 0x58, SysexPrivacy.kSYSEX_PRIVATE, 0x04, 0x02, 0x4E, 0x46, 0x01,
      0x01, 
      slot == 255 ? 127 : slot,
      token & 127,
      (token >> 7) & 127,
      0x00,
      ...activeModelCrc, 
      ...config32, 
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

  @override
  List<int> setChannel(int channel) {
    _crcReady = false;
    _crcRequestPending = false;
    _pendingNfPayload = null;
    
    final result = super.setChannel(channel);
    
    Future.delayed(const Duration(milliseconds: 200), () {
      if (device.deviceControl.isConnected) {
        requestModelCrc();
        requestNfPayload(op: 0, slot: channel);
      }
    });
    return result;
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
    final int requestedOp = data[_kNfOpOffset] & ~0x40;

    if (requestedOp == 1) return;

    final int payloadStart = _kNfPayloadOffset;
    if (data.length < payloadStart + 32) return;

    final List<int> config32 = data.sublist(payloadStart, payloadStart + 32);
    final preset = device.getPreset(device.selectedChannel);
    
    if (preset is NamProPreset) {
      preset.applyNfPayload(config32);
      device.deviceControl.forceNotifyListeners();
      
      // FIRMWARE SYNC WORKAROUND:
      // The firmware sometimes fails to apply saved NF parameters to the active DSP matrix 
      // when a Program Change occurs. By echoing the payload back as a write immediately, 
      // we guarantee the active sound physically perfectly matches the saved screen layout!
      if (requestedOp == 0) { 
        sendNfPayload(config32);
      }
    }
  }

  @override
  void onDataReceive(List<int> data) {
    if (data.length >= 17 &&
        data[2] == MidiMessageValues.sysExStart &&
        data[3] == 0x43 &&
        data[4] == 0x58 &&
        data[5] == 0x70 &&
        data[6] == 0x04 &&
        data[7] == 0x02 &&
        data[8] == 0x01) {
      final int page = data[9];
      final int status = data[10];

      if (page == 0x05 && status == 0) {
        activeModelCrc = data.sublist(11, 16);
        _crcReady = true;
        _crcRequestPending = false; 

        if (_pendingNfPayload != null) {
          sendNfPayload(_pendingNfPayload!);
          _pendingNfPayload = null;
        } else {
          final preset = device.getPreset(device.selectedChannel);
          if (preset is NamProPreset) {
            sendNfPayload(preset.generateNfPayload());
          }
        }
      }
      return;
    }

    if (_isNfReply(data)) {
      _handleNfReply(data);
      return;
    }

    if (data.length >= 4 &&
        (data[2] & 0xF0) == MidiMessageValues.programChange) {
      
      int targetChannel = data[3];
      if (targetChannel != device.selectedChannel) {
        _crcReady = false;
        _crcRequestPending = false;
        _pendingNfPayload = null;
        
        super.onDataReceive(data); 
        
        device.deviceControl.clearDataQueue();
        requestModelCrc();
        requestNfPayload(op: 0);
      }
      return;
    }

    if (data.length > 9 &&
        data[2] == MidiMessageValues.sysExStart &&
        data[5] == SysexPrivacy.kSYSEX_PRIVATE &&
        data[6] == SyxMsg.kSYX_CURPRESET &&
        data[9] == 0x32) {
      super.onDataReceive(data);

      requestModelCrc();
      requestNfPayload(op: 0);
      return;
    }

    super.onDataReceive(data);
  }
}