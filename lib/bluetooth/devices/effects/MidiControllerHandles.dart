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
  srOff, // Added Send/Return
  srOn,
  srToggle,
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
  efxMode, // Added Katana Boost, TouchWah Type
  ampGain,
  ampVolume,
  ampBass,
  ampMiddle,
  ampTreble,
  ampTone,
  ampBright, // Added Twin/Jazz Bright, Starlift Contour
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
  reverbDepth, // Added Damp Depth
  modRate,
  modDepth,
  modIntensity,
  modMode, // Added Vibe/SCF Mode
  eqVolume, // Added EQ Master Volume
  eqBand1,
  eqBand2,
  eqBand3,
  eqBand4,
  eqBand5,
  eqBand6,
  eqBand7,
  eqBand8,
  eqBand9,
  eqBand10,
  srParam1, // Send/Return parameters
  srParam2,

  // FX A Slot & Parameters
  fxAOff,
  fxAOn,
  fxAToggle,
  fxAPrev,
  fxANext,
  fxAPitch,
  fxARate,
  fxADepth,
  fxAFeedback,
  fxASensitivity,
  fxAResonance,
  fxAMix,

  // FX B Slot & Parameters
  fxBOff,
  fxBOn,
  fxBToggle,
  fxBPrev,
  fxBNext,
  fxBPitch,
  fxBRate,
  fxBDepth,
  fxBFeedback,
  fxBSensitivity,
  fxBResonance,
  fxBMix,
}

class MidiControllerHandle {
  final String label;
  final ControllerHandleId id;
  const MidiControllerHandle(this.label, this.id);
}

class MidiControllerHandles {
  // on;off;toggle;prev;next handles
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

  // Send/Return Toggles
  static const MidiControllerHandle srOff =
      MidiControllerHandle("", ControllerHandleId.srOff);
  static const MidiControllerHandle srOn =
      MidiControllerHandle("", ControllerHandleId.srOn);
  static const MidiControllerHandle srToggle =
      MidiControllerHandle("", ControllerHandleId.srToggle);

  // FX A Slot Controls
  static const MidiControllerHandle fxAOff =
      MidiControllerHandle("", ControllerHandleId.fxAOff);
  static const MidiControllerHandle fxAOn =
      MidiControllerHandle("", ControllerHandleId.fxAOn);
  static const MidiControllerHandle fxAToggle =
      MidiControllerHandle("", ControllerHandleId.fxAToggle);
  static const MidiControllerHandle fxAPrev =
      MidiControllerHandle("", ControllerHandleId.fxAPrev);
  static const MidiControllerHandle fxANext =
      MidiControllerHandle("", ControllerHandleId.fxANext);

  // FX B Slot Controls
  static const MidiControllerHandle fxBOff =
      MidiControllerHandle("", ControllerHandleId.fxBOff);
  static const MidiControllerHandle fxBOn =
      MidiControllerHandle("", ControllerHandleId.fxBOn);
  static const MidiControllerHandle fxBToggle =
      MidiControllerHandle("", ControllerHandleId.fxBToggle);
  static const MidiControllerHandle fxBPrev =
      MidiControllerHandle("", ControllerHandleId.fxBPrev);
  static const MidiControllerHandle fxBNext =
      MidiControllerHandle("", ControllerHandleId.fxBNext);

  // Gate
  static const MidiControllerHandle gateSense =
      MidiControllerHandle("Threshold", ControllerHandleId.gateSense);
  static const MidiControllerHandle gateDecay =
      MidiControllerHandle("Decay", ControllerHandleId.gateDecay);

  // Comp
  static const MidiControllerHandle compLevel =
      MidiControllerHandle("Level", ControllerHandleId.compLevel);
  static const MidiControllerHandle compSustain =
      MidiControllerHandle("Sustain", ControllerHandleId.compSustain);
  static const MidiControllerHandle compThreshold =
      MidiControllerHandle("Threshold", ControllerHandleId.compThreshold);
  static const MidiControllerHandle compRatio =
      MidiControllerHandle("Ratio", ControllerHandleId.compRatio);

  // EFX
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
  static const MidiControllerHandle efxMode =
      MidiControllerHandle("Mode/Switch", ControllerHandleId.efxMode);

  // Amps
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
  static const MidiControllerHandle ampBright =
      MidiControllerHandle("Bright/Contour", ControllerHandleId.ampBright);

  // Cabs
  static const MidiControllerHandle cabLevel =
      MidiControllerHandle("Level", ControllerHandleId.cabLevel);
  static const MidiControllerHandle cabLoCut =
      MidiControllerHandle("Low Cut", ControllerHandleId.cabLoCut);
  static const MidiControllerHandle cabHiCut =
      MidiControllerHandle("High Cut", ControllerHandleId.cabHiCut);

  // Delays
  static const MidiControllerHandle delayLevel =
      MidiControllerHandle("Level", ControllerHandleId.delayLevel);
  static const MidiControllerHandle delayTime =
      MidiControllerHandle("Time", ControllerHandleId.delayTime);
  static const MidiControllerHandle delayRepeat =
      MidiControllerHandle("Repeat", ControllerHandleId.delayRepeat);
  static const MidiControllerHandle delayMod =
      MidiControllerHandle("Modulation", ControllerHandleId.delayMod);

  // Reverbs
  static const MidiControllerHandle reverbDecay =
      MidiControllerHandle("Decay", ControllerHandleId.reverbDecay);
  static const MidiControllerHandle reverbMix =
      MidiControllerHandle("Level/Mix", ControllerHandleId.reverbMix);
  static const MidiControllerHandle reverbTone =
      MidiControllerHandle("Tone/Misc", ControllerHandleId.reverbTone);
  static const MidiControllerHandle reverbDepth =
      MidiControllerHandle("Depth", ControllerHandleId.reverbDepth);

  // Modulation
  static const MidiControllerHandle modRate =
      MidiControllerHandle("Rate", ControllerHandleId.modRate);
  static const MidiControllerHandle modDepth =
      MidiControllerHandle("Depth/Width", ControllerHandleId.modDepth);
  static const MidiControllerHandle modIntensity =
      MidiControllerHandle("Intensity/Mix", ControllerHandleId.modIntensity);
  static const MidiControllerHandle modMode =
      MidiControllerHandle("Mode", ControllerHandleId.modMode);

  // EQ
  static const MidiControllerHandle eqVolume =
      MidiControllerHandle("Volume", ControllerHandleId.eqVolume);
  static const MidiControllerHandle eqBand1 =
      MidiControllerHandle("EQ Band 1", ControllerHandleId.eqBand1);
  static const MidiControllerHandle eqBand2 =
      MidiControllerHandle("EQ Band 2", ControllerHandleId.eqBand2);
  static const MidiControllerHandle eqBand3 =
      MidiControllerHandle("EQ Band 3", ControllerHandleId.eqBand3);
  static const MidiControllerHandle eqBand4 =
      MidiControllerHandle("EQ Band 4", ControllerHandleId.eqBand4);
  static const MidiControllerHandle eqBand5 =
      MidiControllerHandle("EQ Band 5", ControllerHandleId.eqBand5);
  static const MidiControllerHandle eqBand6 =
      MidiControllerHandle("EQ Band 6", ControllerHandleId.eqBand6);
  static const MidiControllerHandle eqBand7 =
      MidiControllerHandle("EQ Band 7", ControllerHandleId.eqBand7);
  static const MidiControllerHandle eqBand8 =
      MidiControllerHandle("EQ Band 8", ControllerHandleId.eqBand8);
  static const MidiControllerHandle eqBand9 =
      MidiControllerHandle("EQ Band 9", ControllerHandleId.eqBand9);
  static const MidiControllerHandle eqBand10 =
      MidiControllerHandle("EQ Band 10", ControllerHandleId.eqBand10);

  // Send/Return
  static const MidiControllerHandle srParam1 =
      MidiControllerHandle("Param 1", ControllerHandleId.srParam1);
  static const MidiControllerHandle srParam2 =
      MidiControllerHandle("Param 2", ControllerHandleId.srParam2);

  // FX A Parameters
  static const MidiControllerHandle fxAPitch =
      MidiControllerHandle("Pitch", ControllerHandleId.fxAPitch);
  static const MidiControllerHandle fxARate =
      MidiControllerHandle("Rate", ControllerHandleId.fxARate);
  static const MidiControllerHandle fxADepth =
      MidiControllerHandle("Depth", ControllerHandleId.fxADepth);
  static const MidiControllerHandle fxAFeedback =
      MidiControllerHandle("Feedback", ControllerHandleId.fxAFeedback);
  static const MidiControllerHandle fxASensitivity =
      MidiControllerHandle("Sensitivity", ControllerHandleId.fxASensitivity);
  static const MidiControllerHandle fxAResonance =
      MidiControllerHandle("Resonance", ControllerHandleId.fxAResonance);
  static const MidiControllerHandle fxAMix =
      MidiControllerHandle("Mix", ControllerHandleId.fxAMix);

  // FX B Parameters
  static const MidiControllerHandle fxBPitch =
      MidiControllerHandle("Pitch", ControllerHandleId.fxBPitch);
  static const MidiControllerHandle fxBRate =
      MidiControllerHandle("Rate", ControllerHandleId.fxBRate);
  static const MidiControllerHandle fxBDepth =
      MidiControllerHandle("Depth", ControllerHandleId.fxBDepth);
  static const MidiControllerHandle fxBFeedback =
      MidiControllerHandle("Feedback", ControllerHandleId.fxBFeedback);
  static const MidiControllerHandle fxBSensitivity =
      MidiControllerHandle("Sensitivity", ControllerHandleId.fxBSensitivity);
  static const MidiControllerHandle fxBResonance =
      MidiControllerHandle("Resonance", ControllerHandleId.fxBResonance);
  static const MidiControllerHandle fxBMix =
      MidiControllerHandle("Mix", ControllerHandleId.fxBMix);
}