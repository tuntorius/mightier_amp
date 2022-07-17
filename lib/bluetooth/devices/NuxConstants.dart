// (c) 2020-2021 Dian Iliev (Tuntorius)
// This code is licensed under MIT license (see LICENSE.md for details)

class AppConstants {
  static const patcherUrl =
      "https://github.com/tuntorius/nux-ir-patcher#nux-ir-patcher";
}

class EProductNo {
  static const CHERUB_VID = 8721;
  static const TAPECORE_PID = 0;
  static const STAGEMAN_PID = 16;
  static const CERBERUS_PID = 32;
  static const MIGHTYBT_PID = 48;
  static const MIGHTYLITE_PID = 64;
  static const TAP5_PID = 102;
}

class CherubSysExMessageID {
  static const cSysExRollCallMsgID = 0;
  static const cSysExDeviceSpecMsgID = 7;
}

class SysCtrlState {
  static const syscmd_null = 0;
  static const syscmd_save = 48;
  static const syscmd_resetall = 50;
  static const syscmd_refresh_preset = 51;
  static const syscmd_bt = 64;
  static const syscmd_eco_pro = 65;
  static const syscmd_dsprun_battery = 66;
  static const syscmd_usbaudio = 67;
}

class DeviceMessageID {
  static const devReqFwID = 0;
  static const devReqMIDIParaMsgID = 0;
  static const devGetMIDIParaMsgID = 1;
  static const devSetMIDIParaMsgID = 2;
  static const devReqCurCCMsgID = 3;
  static const devReqCurNRPNMsgID = 4;
  static const devSysCtrlMsgID = 5;
  static const devReqPresetMsgID = 6; //request preset
  static const devGetPresetMsgID = 7;
  static const devSetPresetMsgID = 8;
  static const devReqCurLoopMsgID = 9;
  static const devProjectMsgID = 16;
  static const devReqManuMsgID = 22;
  static const devGetManuMsgID = 23;
  static const devSetManuMsgID = 24;
  static const devSetPresetNameMsgID = 32;
  static const devNullDataID = 80;
  static const devParaDataID = 81;
  static const devCabDataSetID = 88;
  static const devCabDataGetID = 89;
  static const devCrcNameGetId = 92;
  static const devCablevelGetId = 94;
  static const devCabLCGetId = 96;
  static const devCabHCGetId = 98;
  static const devOpenTapLedMsgID = 10;
  static const padReqCurCCMsgID = 19;
  static const devHadrWareTestID = 100;
  static const devDfuEnterID = 102;
  static const devSysStateID = 103;
  static const devDfuDataSetID = 104;
  static const devDfuDataGetID = 105;
}

class PresetDataIndexPlugAir {
  static const effectTypesIndex = [
    0, //not used but there must be a value here
    efxtype,
    amptype,
    cabtype,
    modfxtype,
    delaytype,
    reverbtype
  ];

  static const effectEnabledIndex = [
    ngenable,
    efxenable,
    ampenable,
    cabenable,
    modfxenable,
    delayenable,
    reverbenable
  ];

  static const ngenable = 0;
  static const ngthresold = 1;
  static const ngsustain = 2;
  static const efxenable = 3;
  static const efxtype = 4;
  static const efxvar1 = 5;
  static const efxvar2 = 6;
  static const efxvar3 = 7;
  static const ampenable = 8;
  static const amptype = 9;
  static const ampgain = 10;
  static const amplevel = 11;
  static const ampbass = 12;
  static const ampmiddle = 13;
  static const amptreble = 14;
  static const amptone = 15;
  static const cabenable = 16;
  static const cabtype = 17;
  static const cabgain = 18;
  static const modfxenable = 19;
  static const modfxtype = 20;
  static const modfxrate = 21;
  static const modfxvar1rate = 21;
  static const modfxdepth = 22;
  static const modfxvar2depth = 22;
  static const modfxmix = 23;
  static const modfxvar3mix = 23;
  static const delayenable = 24;
  static const delaytype = 25;
  static const delaytime = 26;
  static const delayvar1time = 26;
  static const delayfeedback = 27;
  static const delayvar2feedback = 27;
  static const delaymix = 28;
  static const delayvar3mix = 28;
  static const reverbenable = 29;
  static const reverbtype = 30;
  static const reverbdecay = 31;
  static const reverbvar1decay = 31;
  static const reverbdamp = 32;
  static const reverbvar2damp = 32;
  static const reverbmix = 33;
  static const reverbvar3mix = 33;
}

class PresetDataIndex8BT {
  //use PresetDataIndexLite for most of the constants

}

class PresetDataIndexLite {
  static const effectTypesIndex = [
    0, //not used but there must be a value here
    drivetype,
    modfxtype,
    efxtype,
  ];

  static const effectEnabledIndex = [ngenable, modfxenable, efxenable];

  static const ngenable = 0;
  static const ngthresold = 1;
  static const ngsustain = 2;

  static const drivetype = 3;
  static const drivesubtype1 = 4;
  static const drivesubtype2 = 5;
  static const drivesubtype3 = 6;
  static const drivegain = 7;
  static const drivelevel = 8;
  static const drivebass = 9;
  static const drivemid = 10;
  static const drivetreble = 11;
  static const drivetone = 12;

  static const modfxenable = 13;
  static const modfxtype = 14;
  static const modfxrate = 15;
  static const modfxdepth = 16;
  static const modfxmix = 17;

  static const efxenable = 18;
  static const efxtype = 19;
  static const reverbtype = 20;
  static const reverbdecay = 21;
  static const reverbmix = 22;

  static const delaytype = 23;
  static const delaytime = 24;
  static const delayfeedback = 25;
  static const delaymix = 26;

  static const tap_time_flag = 27;
  static const tap_time_bpm_h = 28;
  static const tap_time_bpm_l = 29;
  static const tap_time_value_h = 30;
  static const tap_time_value_l = 31;
  static const reverbenable = 32;
  static const delayenable = 33;
  static const miclevel = 34;
  static const micambsend = 35;
}

class PresetDataIndexPlugPro {
  static const Head_iWAH = 0;
  static const Head_iCMP = 1;
  static const Head_iEFX = 2;
  static const Head_iAMP = 3;
  static const Head_iEQ = 4;
  static const Head_iNG = 5;
  static const Head_iMOD = 6;
  static const Head_iDLY = 7;
  static const Head_iRVB = 8;
  static const Head_iCAB = 9;
  static const Head_iSR = 10;
  static const WAH_Count = 11;
  static const WAH_Para1 = 12;
  static const WAH_Para2 = 13;
  static const CMP_Count = 14;
  static const CMP_Para1 = 15;
  static const CMP_Para2 = 16;
  static const CMP_Para3 = 17;
  static const CMP_Para4 = 18;
  static const EFX_Count = 19;
  static const EFX_Para1 = 20;
  static const EFX_Para2 = 21;
  static const EFX_Para3 = 22;
  static const EFX_Para4 = 23;
  static const EFX_Para5 = 24;
  static const EFX_Para6 = 25;
  static const AMP_Count = 26;
  static const AMP_Para1 = 27;
  static const AMP_Para2 = 28;
  static const AMP_Para3 = 29;
  static const AMP_Para4 = 30;
  static const AMP_Para5 = 31;
  static const AMP_Para6 = 32;
  static const AMP_Para7 = 33;
  static const AMP_Para8 = 34;
  static const EQ_Count = 35;
  static const EQ_Para1 = 36;
  static const EQ_Para2 = 37;
  static const EQ_Para3 = 38;
  static const EQ_Para4 = 39;
  static const EQ_Para5 = 40;
  static const EQ_Para6 = 41;
  static const EQ_Para7 = 42;
  static const EQ_Para8 = 43;
  static const EQ_Para9 = 44;
  static const EQ_Para10 = 45;
  static const EQ_Para11 = 46;
  static const EQ_Para12 = 47;
  static const NG_Count = 48;
  static const NG_Para1 = 49;
  static const NG_Para2 = 50;
  static const NG_Para3 = 51;
  static const NG_Para4 = 52;
  static const MOD_Count = 53;
  static const MOD_Para1 = 54;
  static const MOD_Para2 = 55;
  static const MOD_Para3 = 56;
  static const MOD_Para4 = 57;
  static const MOD_Para5 = 58;
  static const MOD_Para6 = 59;
  static const DLY_Count = 60;
  static const DLY_Para1 = 61;
  static const DLY_Para2 = 62;
  static const DLY_Para3 = 63;
  static const DLY_Para4 = 64;
  static const DLY_Para5 = 65;
  static const DLY_Para6 = 66;
  static const DLY_Para7 = 67;
  static const DLY_Para8 = 68;
  static const RVB_Count = 69;
  static const RVB_Para1 = 70;
  static const RVB_Para2 = 71;
  static const RVB_Para3 = 72;
  static const RVB_Para4 = 73;
  static const CAB_Count = 74;
  static const CAB_Para1 = 75;
  static const CAB_Para2 = 76;
  static const CAB_Para3 = 77;
  static const CAB_Para4 = 78;
  static const CAB_Para5 = 79;
  static const CAB_Para6 = 80;
  static const SR_Count = 81;
  static const SR_Para1 = 82;
  static const SR_Para2 = 83;
  static const MASTER = 84;
  static const delay_time_flag = 85;
  static const bpmH = 86;
  static const bpmL = 87;
  static const BITCTRL = 88;
  static const LINK1 = 89;
  static const LINK2 = 90;
  static const LINK3 = 91;
  static const LINK4 = 92;
  static const LINK5 = 93;
  static const LINK6 = 94;
  static const LINK7 = 95;
  static const LINK8 = 96;
  static const LINK9 = 97;
  static const LINK10 = 98;
  static const LINK11 = 99;
  static const UserName1 = 100;
  static const UserName2 = 101;
  static const UserName3 = 102;
  static const UserName4 = 103;
  static const UserName5 = 104;
  static const UserName6 = 105;
  static const UserName7 = 106;
  static const UserName8 = 107;
  static const UserName9 = 108;
  static const UserName10 = 109;
  static const UserName11 = 110;
  static const UserName12 = 111;
  static const UserName13 = 112;
  static const UserName14 = 113;
  static const UserName15 = 114;
  static const UserName16 = 115;
  static const swsel1 = 116;
  static const swsel2 = 117;
  static const swsel3 = 118;
  static const pdsel1 = 119;
  static const pdsel2 = 120;
  static const version = 121;
  static const scene1 = 122;
  static const scene2 = 123;
  static const scene3 = 124;
}

class MidiMessageValues {
  static const controlChange = 0xb0;
  static const programChange = 0xc0;
  static const sysExStart = 0xf0;
  static const sysExEnd = 0xf7;
}

class SysexPrivacy {
  final int _value;
  const SysexPrivacy._internal(this._value);
  toString() => '$_value';
  toInt() => _value;

  static const kSYSEX_PUBLIC = const SysexPrivacy._internal(0);
  static const kSYSEX_PUBLICREPLY = const SysexPrivacy._internal(16);
  static const kSYSEX_RDCTRL = const SysexPrivacy._internal(32);
  static const kSYSEX_IRCTRL = const SysexPrivacy._internal(48);
  static const kSYSEX_PRIVATE = const SysexPrivacy._internal(112);
}

class SyxMsg {
  final int _value;
  const SyxMsg._internal(this._value);
  toString() => '$_value';
  toInt() => _value;

  static const kSYX_BPM = const SyxMsg._internal(3);
  static const kSYX_LANGUAGE = const SyxMsg._internal(4);
  static const kSYX_CPURUN = const SyxMsg._internal(5);
  static const kSYX_SWAPPRESET = const SyxMsg._internal(6);
  static const kSYX_CPYPRESET = const SyxMsg._internal(7);
  static const kSYX_IRSAVEAS = const SyxMsg._internal(8);
  static const kSYX_CRCNAME = const SyxMsg._internal(9);
  static const kSYX_MANUAL = const SyxMsg._internal(10);
  static const kSYX_PRESET = const SyxMsg._internal(11);
  static const kSYX_CURPRESET = const SyxMsg._internal(12);
  static const kSYX_MODULELINK = const SyxMsg._internal(13);
  static const kSYX_GLOBLE = const SyxMsg._internal(14);
  static const kSYX_MIDICC = const SyxMsg._internal(15);
  static const kSYX_CABDATA = const SyxMsg._internal(16);
  static const kSYX_CABCURVE = const SyxMsg._internal(17);
  static const kSYX_PRESETNAME = const SyxMsg._internal(18);
  static const kSYX_PEDALSET = const SyxMsg._internal(19);
  static const kSYX_SYSTEMSET = const SyxMsg._internal(20);
  static const kSYX_CURSTATE = const SyxMsg._internal(21);
  static const kSYX_IRDELETE = const SyxMsg._internal(22);
  static const kSYX_CUTOVER = const SyxMsg._internal(23);
  static const kSYX_LOOP = const SyxMsg._internal(24);
  static const kSYX_DRUM = const SyxMsg._internal(25);
  static const kSYX_CABNAME = const SyxMsg._internal(26);
  static const kSYX_BTSET = const SyxMsg._internal(27);
  static const kSYX_PARAINIT = const SyxMsg._internal(96);
  static const kSYX_WELCOME = const SyxMsg._internal(97);
  static const kSYX_QTVERSION = const SyxMsg._internal(98);
  static const kSYX_UAC_EFFECT = const SyxMsg._internal(99);
  static const kSYX_UAC_TRANS = const SyxMsg._internal(100);
  static const kSYX_UAC_SAVE = const SyxMsg._internal(101);
  static const kSYX_VOLDISPLAY = const SyxMsg._internal(116);
  static const kSYX_SPEC_CMD = const SyxMsg._internal(117);
  static const kSYX_HW_VERSION = const SyxMsg._internal(118);
  static const kSYX_CODEC_SET = const SyxMsg._internal(119);
  static const kSYX_TFT_SET = const SyxMsg._internal(120);
  static const kSYX_SNAPSHOTCMD = const SyxMsg._internal(121);
  static const kSYX_SNAPSHOT = const SyxMsg._internal(122);
  static const kSYX_RESET = const SyxMsg._internal(123);
  static const kSYX_IRINFO = const SyxMsg._internal(124);
  static const kSYX_DEVINFO = const SyxMsg._internal(125);
  static const kSYX_SENDCMD = const SyxMsg._internal(126);
  static const kSYX_NOUSE = const SyxMsg._internal(127);
}

enum SyxDir {
  kSYXDIR_GET,
  kSYXDIR_SET,
  kSYXDIR_REQ,
  kSYXDIR_ACK,
  kSYXDIR_CMD,
}

class MidiCCValues {
  static const bCC_NotUsed = -1; //for LITE amp
  static const bCC_OverDriveEnable = 111;
  static const bCC_OverDriveDrive = 13;
  static const bCC_OverDriveTone = 14;
  static const bCC_OverDriveLevel = 15;
  static const bCC_OverDriveMode = 16;
  static const bCC_DistEnable = 84;
  static const bCC_DistGain = 21;
  static const bCC_DistTone = 17;
  static const bCC_DistLevel = 10;
  static const bCC_DistMode = 12;
  static const bCC_BoostEnable = 76;
  static const bCC_BypassEnable = 9;
  static const bCC_Routing = 11;
  static const bCC_VolumePedal = 7;
  static const bCC_VolumePrePost = 47;
  static const bCC_VolumePedalMin = 46;
  static const bCC_TempoMSB = 89;
  static const bCC_TempoLSB = 90;
  static const bCC_Tap = 64;
  static const bCC_GateEnable = 22;
  static const bCC_GateThresold = 23;
  static const bCC_GateDecay = 24;
  static const bCC_CabMode = 71;
  static const bCC_CabMicsel = 70;
  static const bCC_CabEnable = 101;
  static const bCC_AmpModeSetup = 75;
  static const bCC_AmpMode = 78;
  static const bCC_AmpDrive = 79;
  static const bCC_AmpPresence = 80;
  static const bCC_AmpMaster = 81;
  static const bCC_AmpEnable = 102;
  static const bCC_AmpBass = 103;
  static const bCC_AmpMid = 104;
  static const bCC_AmpHigh = 105;
  static const bCC_ModfxMode = 58;
  static const bCC_ModfxRate = 51;
  static const bCC_ModfxDepth = 52;
  static const bCC_ChorusMode = 61;
  static const bCC_ChorusRate = 53;
  static const bCC_ChorusDepth = 54;
  static const bCC_ChorusLevel = 55;
  static const bCC_ModfxEnable = 56;
  static const bCC_ChorusEnable = 57;
  static const bCC_DelayMode = 88;
  static const bCC_DelayTime = 30;
  static const bCC_DelayRepeat = 31;
  static const bCC_ReverbMode = 37;
  static const bCC_DelayLevel = 85;
  static const bCC_ReverbDecay = 86;
  static const bCC_ReverbLevel = 87;
  static const bCC_ReverbRouting = 34;
  static const bCC_DelayEnable = 28;
  static const bCC_ReverbEnable = 36;
  static const bCC_CtrlType = 49;
  static const bCC_drumOnOff_No = 122;
  static const bCC_drumType_No = 123;
  static const bCC_drumLevel_No = 125;
  static const bCC_drumTempo1 = 0x62;
  static const bCC_drumTempo2 = 0x63;
  static const bCC_drumTempoH = 0x06;
  static const bCC_drumTempoL = 0x26;
  static const bCC_LoopLevel = 121;
  static const bCC_LoopCtrl = 124;
  static const bCC_DrumLed = 126;
  static const bCC_CtrlCmd = 127;
  static const bcc_mChrOnOff = 112;
  static const bcc_gChrOnOff = 57;
  static const bcc_mRevOnOff = 113;
  static const bcc_gRevOnOff = 36;
  static const bcc_gChrRate = 51;
  static const bcc_gChrDepth = 52;
  static const bcc_mChrRate = 53;
  static const bcc_mChrDepth = 54;
  static const bcc_gRevDecay = 91;
  static const bcc_gRevDamp = 92;
  static const bcc_mRevDecay = 93;
  static const bcc_mRevDamp = 94;
  static const bcc_gChrType = 60;
  static const bcc_mChrType = 63;
  static const bcc_gRevType = 37;
  static const bcc_mRevType = 39;
}

class MidiCCValuesPro {
  static const Head_iWAH = 0;
  static const Head_iCMP = 1;
  static const Head_iEFX = 2;
  static const Head_iAMP = 3;
  static const Head_iEQ = 4;
  static const Head_iNG = 5;
  static const Head_iMOD = 6;
  static const Head_iDLY = 7;
  static const Head_iRVB = 8;
  static const Head_iCAB = 9;
  static const Head_iSR = 10;
  static const WAH_Para1 = 11;
  static const WAH_Para2 = 12;
  static const CMP_Para1 = 13;
  static const CMP_Para2 = 14;
  static const CMP_Para3 = 15;
  static const CMP_Para4 = 16;
  static const EFX_Para1 = 17;
  static const EFX_Para2 = 18;
  static const EFX_Para3 = 19;
  static const EFX_Para4 = 20;
  static const EFX_Para5 = 21;
  static const EFX_Para6 = 22;
  static const AMP_Para1 = 23;
  static const AMP_Para2 = 24;
  static const AMP_Para3 = 25;
  static const AMP_Para4 = 26;
  static const AMP_Para5 = 27;
  static const AMP_Para6 = 28;
  static const AMP_Para7 = 29;
  static const AMP_Para8 = 30;
  static const EQ_Para1 = 31;
  static const EQ_Para2 = 32;
  static const EQ_Para3 = 33;
  static const EQ_Para4 = 34;
  static const EQ_Para5 = 35;
  static const EQ_Para6 = 36;
  static const EQ_Para7 = 37;
  static const EQ_Para8 = 38;
  static const EQ_Para9 = 39;
  static const EQ_Para10 = 40;
  static const EQ_Para11 = 41;
  static const EQ_Para12 = 42;
  static const NG_Para1 = 43;
  static const NG_Para2 = 44;
  static const NG_Para3 = 45;
  static const NG_Para4 = 46;
  static const MOD_Para1 = 47;
  static const MOD_Para2 = 48;
  static const MOD_Para3 = 49;
  static const MOD_Para4 = 50;
  static const MOD_Para5 = 51;
  static const MOD_Para6 = 52;
  static const DLY_Para1 = 53;
  static const DLY_Para2 = 54;
  static const DLY_Para3 = 55;
  static const DLY_Para4 = 56;
  static const DLY_Para5 = 57;
  static const DLY_Para6 = 58;
  static const DLY_Para7 = 59;
  static const DLY_Para8 = 60;
  static const RVB_Para1 = 61;
  static const RVB_Para2 = 62;
  static const RVB_Para3 = 63;
  static const RVB_Para4 = 64;
  static const CAB_Para1 = 65;
  static const CAB_Para2 = 66;
  static const CAB_Para3 = 67;
  static const CAB_Para4 = 68;
  static const CAB_Para5 = 69;
  static const CAB_Para6 = 70;
  static const SR_Para1 = 71;
  static const SR_Para2 = 72;
  static const MASTER = 73;
  static const MSELECT = 74;
  static const PEDAL = 75;
  static const SCENE = 76;
  static const DRUMENABLE = 77;
  static const DRUMTYPE = 78;
  static const DRUMLEVEL = 79;
  static const LOOPLEVEL = 80;
  static const LOOPSTATE = 81;
  static const AUXEQ = 82;
  static const PRESETRANGE = 83;
  static const MICVOLUME = 84;
  static const MICMUTE = 85;
  static const USBROUNT_1 = 86;
  static const USBROUNT_2 = 87;
  static const USBROUNT_3 = 88;
  static const USBROUNT_4 = 89;
  static const AUX_MUTE = 90;
  static const AUX_PHASE = 91;
  static const AUX_BAND_1 = 92;
  static const AUX_BAND_2 = 93;
  static const AUX_BAND_3 = 94;
  static const AUX_BAND_4 = 95;
  static const AUX_BAND_5 = 96;
  static const AUX_BAND_6 = 97;
  static const AUX_BAND_7 = 98;
  static const AUX_BAND_8 = 99;
  static const AUX_BAND_9 = 100;
  static const AUX_BAND_10 = 101;
  static const AUX_BAND_11 = 102;
  static const AUX_BAND_12 = 103;
  static const DRUM_Low = 104;
  static const DRUM_Middle = 105;
  static const DRUM_High = 106;
}
