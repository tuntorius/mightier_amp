enum ControllerHandleId {
  unknown,
  gateOff,
  gateOn,
  gateToggle,
  gatePrev,
  gateNext,
  compOff,
  compOn,
  compToggle,
  compPrev,
  compNext,
  modOff,
  modOn,
  modToggle,
  modPrev,
  modNext,
  efxOff,
  efxOn,
  efxToggle,
  efxPrev,
  efxNext,
  ampOff,
  ampOn,
  ampToggle,
  ampPrev,
  ampNext,
  cabOff,
  cabOn,
  cabToggle,
  cabPrev,
  cabNext,
  eqOff,
  eqOn,
  eqToggle,
  eqPrev,
  eqNext,
  reverbOff,
  reverbOn,
  reverbToggle,
  reverbPrev,
  reverbNext,
  delayOff,
  delayOn,
  delayToggle,
  delayPrev,
  delayNext,

  gateSense,
  gateDecay,

  compLevel,
  compSustain,
  compThreshold,
  compRatio,

  efxLevel,
  efxGain,
  efxTone,
  efxRate,
  efxDepth,
  efxBass,

  ampGain,
  ampVolume,
  ampBass,
  ampMiddle,
  ampTreble,
  ampTone,

  cabLevel,
  cabLoCut,
  cabHiCut,

  delayLevel,
  delayTime,
  delayRepeat,
  delayMod,

  reverbDecay,
  reverbMix,
  reverbTone,

  modRate,
  modDepth,
  modIntensity
}

class MidiControllerHandle {
  final String label;
  final ControllerHandleId id;
  const MidiControllerHandle(this.label, this.id);
}

class MidiControllerHandles {
  //on;off;toggle;prev;next handles
  static const MidiControllerHandle gateOff =
      MidiControllerHandle("", ControllerHandleId.gateOff);
  static const MidiControllerHandle gateOn =
      MidiControllerHandle("", ControllerHandleId.gateOn);
  static const MidiControllerHandle gateToggle =
      MidiControllerHandle("", ControllerHandleId.gateToggle);
  static const MidiControllerHandle gatePrev =
      MidiControllerHandle("", ControllerHandleId.gatePrev);
  static const MidiControllerHandle gateNext =
      MidiControllerHandle("", ControllerHandleId.gateNext);
  static const MidiControllerHandle compOff =
      MidiControllerHandle("", ControllerHandleId.compOff);
  static const MidiControllerHandle compOn =
      MidiControllerHandle("", ControllerHandleId.compOn);
  static const MidiControllerHandle compToggle =
      MidiControllerHandle("", ControllerHandleId.compToggle);
  static const MidiControllerHandle compPrev =
      MidiControllerHandle("", ControllerHandleId.compPrev);
  static const MidiControllerHandle compNext =
      MidiControllerHandle("", ControllerHandleId.compNext);
  static const MidiControllerHandle modOff =
      MidiControllerHandle("", ControllerHandleId.modOff);
  static const MidiControllerHandle modOn =
      MidiControllerHandle("", ControllerHandleId.modOn);
  static const MidiControllerHandle modToggle =
      MidiControllerHandle("", ControllerHandleId.modToggle);
  static const MidiControllerHandle modPrev =
      MidiControllerHandle("", ControllerHandleId.modPrev);
  static const MidiControllerHandle modNext =
      MidiControllerHandle("", ControllerHandleId.modNext);
  static const MidiControllerHandle efxOff =
      MidiControllerHandle("", ControllerHandleId.efxOff);
  static const MidiControllerHandle efxOn =
      MidiControllerHandle("", ControllerHandleId.efxOn);
  static const MidiControllerHandle efxToggle =
      MidiControllerHandle("", ControllerHandleId.efxToggle);
  static const MidiControllerHandle efxPrev =
      MidiControllerHandle("", ControllerHandleId.efxPrev);
  static const MidiControllerHandle efxNext =
      MidiControllerHandle("", ControllerHandleId.efxNext);
  static const MidiControllerHandle ampOff =
      MidiControllerHandle("", ControllerHandleId.ampOff);
  static const MidiControllerHandle ampOn =
      MidiControllerHandle("", ControllerHandleId.ampOn);
  static const MidiControllerHandle ampToggle =
      MidiControllerHandle("", ControllerHandleId.ampToggle);
  static const MidiControllerHandle ampPrev =
      MidiControllerHandle("", ControllerHandleId.ampPrev);
  static const MidiControllerHandle ampNext =
      MidiControllerHandle("", ControllerHandleId.ampNext);
  static const MidiControllerHandle cabOff =
      MidiControllerHandle("", ControllerHandleId.cabOff);
  static const MidiControllerHandle cabOn =
      MidiControllerHandle("", ControllerHandleId.cabOn);
  static const MidiControllerHandle cabToggle =
      MidiControllerHandle("", ControllerHandleId.cabToggle);
  static const MidiControllerHandle cabPrev =
      MidiControllerHandle("", ControllerHandleId.cabPrev);
  static const MidiControllerHandle cabNext =
      MidiControllerHandle("", ControllerHandleId.cabNext);
  static const MidiControllerHandle eqOff =
      MidiControllerHandle("", ControllerHandleId.eqOff);
  static const MidiControllerHandle eqOn =
      MidiControllerHandle("", ControllerHandleId.eqOn);
  static const MidiControllerHandle eqToggle =
      MidiControllerHandle("", ControllerHandleId.eqToggle);
  static const MidiControllerHandle eqPrev =
      MidiControllerHandle("", ControllerHandleId.eqPrev);
  static const MidiControllerHandle eqNext =
      MidiControllerHandle("", ControllerHandleId.eqNext);
  static const MidiControllerHandle reverbOff =
      MidiControllerHandle("", ControllerHandleId.reverbOff);
  static const MidiControllerHandle reverbOn =
      MidiControllerHandle("", ControllerHandleId.reverbOn);
  static const MidiControllerHandle reverbToggle =
      MidiControllerHandle("", ControllerHandleId.reverbToggle);
  static const MidiControllerHandle reverbPrev =
      MidiControllerHandle("", ControllerHandleId.reverbPrev);
  static const MidiControllerHandle reverbNext =
      MidiControllerHandle("", ControllerHandleId.reverbNext);
  static const MidiControllerHandle delayOff =
      MidiControllerHandle("", ControllerHandleId.delayOff);
  static const MidiControllerHandle delayOn =
      MidiControllerHandle("", ControllerHandleId.delayOn);
  static const MidiControllerHandle delayToggle =
      MidiControllerHandle("", ControllerHandleId.delayToggle);
  static const MidiControllerHandle delayPrev =
      MidiControllerHandle("", ControllerHandleId.delayPrev);
  static const MidiControllerHandle delayNext =
      MidiControllerHandle("", ControllerHandleId.delayNext);

  //Gate
  static const MidiControllerHandle gateSense =
      MidiControllerHandle("Threshold", ControllerHandleId.gateSense);
  static const MidiControllerHandle gateDecay =
      MidiControllerHandle("Decay", ControllerHandleId.gateDecay);

  //comp
  static const MidiControllerHandle compLevel =
      MidiControllerHandle("Level", ControllerHandleId.compLevel);
  static const MidiControllerHandle compSustain =
      MidiControllerHandle("Sustain", ControllerHandleId.compSustain);
  static const MidiControllerHandle compThreshold =
      MidiControllerHandle("Threshold", ControllerHandleId.compThreshold);
  static const MidiControllerHandle compRatio =
      MidiControllerHandle("Ratio", ControllerHandleId.compRatio);

  //EFX
  static const MidiControllerHandle efxLevel =
      MidiControllerHandle("Level", ControllerHandleId.efxLevel);
  static const MidiControllerHandle efxGain =
      MidiControllerHandle("Gain/Drive", ControllerHandleId.efxGain);
  static const MidiControllerHandle efxTone =
      MidiControllerHandle("Tone/Treble", ControllerHandleId.efxTone);
  static const MidiControllerHandle efxRate =
      MidiControllerHandle("Rate", ControllerHandleId.efxRate);
  static const MidiControllerHandle efxDepth =
      MidiControllerHandle("Depth/Sustain", ControllerHandleId.efxDepth);
  static const MidiControllerHandle efxBass =
      MidiControllerHandle("Bass", ControllerHandleId.efxBass);

  //Amps
  static const MidiControllerHandle ampGain =
      MidiControllerHandle("Gain", ControllerHandleId.ampGain);
  static const MidiControllerHandle ampVolume =
      MidiControllerHandle("Master Level", ControllerHandleId.ampVolume);
  static const MidiControllerHandle ampBass =
      MidiControllerHandle("Bass", ControllerHandleId.ampBass);
  static const MidiControllerHandle ampMiddle =
      MidiControllerHandle("Middle", ControllerHandleId.ampMiddle);
  static const MidiControllerHandle ampTreble =
      MidiControllerHandle("Treble", ControllerHandleId.ampTreble);
  static const MidiControllerHandle ampTone =
      MidiControllerHandle("Presence/Tone", ControllerHandleId.ampTone);

  //Cabs
  static const MidiControllerHandle cabLevel =
      MidiControllerHandle("Level", ControllerHandleId.cabLevel);
  static const MidiControllerHandle cabLoCut =
      MidiControllerHandle("Low Cut", ControllerHandleId.cabLoCut);
  static const MidiControllerHandle cabHiCut =
      MidiControllerHandle("High Cut", ControllerHandleId.cabHiCut);

  //Delays
  static const MidiControllerHandle delayLevel =
      MidiControllerHandle("Level", ControllerHandleId.delayLevel);
  static const MidiControllerHandle delayTime =
      MidiControllerHandle("Time", ControllerHandleId.delayTime);
  static const MidiControllerHandle delayRepeat =
      MidiControllerHandle("Repeat", ControllerHandleId.delayRepeat);
  static const MidiControllerHandle delayMod =
      MidiControllerHandle("Modulation", ControllerHandleId.delayMod);

  //Reverbs
  static const MidiControllerHandle reverbDecay =
      MidiControllerHandle("Decay", ControllerHandleId.reverbDecay);
  static const MidiControllerHandle reverbMix =
      MidiControllerHandle("Level/Mix", ControllerHandleId.reverbMix);
  static const MidiControllerHandle reverbTone =
      MidiControllerHandle("Tone/Misc", ControllerHandleId.reverbTone);

  static const MidiControllerHandle modRate =
      MidiControllerHandle("Rate", ControllerHandleId.modRate);
  static const MidiControllerHandle modDepth =
      MidiControllerHandle("Depth/Width", ControllerHandleId.modDepth);
  static const MidiControllerHandle modIntensity =
      MidiControllerHandle("Intensity/Mix", ControllerHandleId.modIntensity);
}
