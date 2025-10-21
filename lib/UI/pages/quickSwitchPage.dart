import 'package:flutter/material.dart';
import '../../bluetooth/devices/NuxDevice.dart';
import 'package:mighty_plug_manager/bluetooth/NuxDeviceControl.dart';
import 'package:mighty_plug_manager/audio/setlist_player/setlistPlayerState.dart';
import '../../../bluetooth/devices/presets/Preset.dart';

class QuickSwitch extends StatefulWidget {
  const QuickSwitch({super.key});

  @override
  _QuickSwitchState createState() => _QuickSwitchState();
}

class _QuickSwitchState extends State<QuickSwitch> {
  late NuxDevice device;
  late List<Preset> _presets;

  static int _storedGridCount = 3;
  static List<int> _storedAssignedChannels = [1, 2, 3];

  int _gridCount = 4; // number of buttons (2–4)
  List<int> _assignedChannels = [1, 2, 3]; // channel mapping per button

  @override
  void initState() {
    super.initState();
    _restoreState();
    device = NuxDeviceControl.instance().device;
    device.addListener(onDeviceDataChanged);
    NuxDeviceControl.instance().addListener(onDeviceChanged);
    SetlistPlayerState.instance().addListener(onJamTracksStateChange);
    _presets = device.getPresetsList();
  }

  @override
  void dispose() {
    device.removeListener(onDeviceDataChanged);
    NuxDeviceControl.instance().removeListener(onDeviceChanged);
    SetlistPlayerState.instance().removeListener(onJamTracksStateChange);
    super.dispose();
  }

  void onDeviceChanged() {
    if (device != NuxDeviceControl.instance().device) {
      device.removeListener(onDeviceDataChanged);
      device = NuxDeviceControl.instance().device;
      device.addListener(onDeviceDataChanged);
    }
    setState(() {});
  }

  void onDeviceDataChanged() => setState(() {});
  void onJamTracksStateChange() => setState(() {});

  // --- change channel on amp ---
  void _switchChannel(BuildContext context, int channel) async {
    final targetChannelIndex = channel - 1;
    if (targetChannelIndex < 0 || targetChannelIndex >= device.channelsCount) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Selected channel is not available on this device'),
          duration: Duration(milliseconds: 800)));
      return;
    }

    if (device.selectedChannel == targetChannelIndex) return;
    device.setSelectedChannel(targetChannelIndex,
        notifyBT: true, sendFullPreset: false, notifyUI: true);
    device.getPreset(device.selectedChannel).setupPresetFromNuxData();

    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Switched to channel $channel'),
        duration: const Duration(milliseconds: 800)));
  }

  // --- picker overlay on long press ---
  Future<void> _showChannelPicker(BuildContext context, int index) async {
    final selected = await showModalBottomSheet<int>(
      context: context,
      builder: (_) {
        return Container(
          padding: const EdgeInsets.all(12),
          child: ListView.builder(
            itemCount: 7,
            itemBuilder: (_, i) {
              final ch = i + 1;
              return ListTile(
                title: Text('Channel $ch'),
                onTap: () => Navigator.pop(context, ch),
              );
            },
          ),
        );
      },
    );

    if (selected != null) {
      setState(() {
        _assignedChannels[index] = selected;
      });
      _persistState();
    }
  }

  @override
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;
    final isPortrait = orientation == Orientation.portrait;
    return Scaffold(
      appBar: AppBar(title: const Text('Quick Channel Switch')),
      body: Column(
        children: [
          // --- dynamic height area for the list of buttons ---
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final totalHeight = constraints.maxHeight;
                final buttonHeight = totalHeight / _gridCount;

                final isLandscape = !isPortrait;
                const buttonPadding =
                    EdgeInsets.symmetric(horizontal: 8, vertical: 4);

                return Flex(
                  direction: isPortrait ? Axis.vertical : Axis.horizontal,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_gridCount, (index) {
                    final channel = _assignedChannels[index];
                    final presetIndex = channel - 1;
                    final isActive = device.selectedChannel == presetIndex;
                    final presetColor =
                        (presetIndex >= 0 && presetIndex < _presets.length)
                            ? _presets[presetIndex].channelColor
                            : Colors.grey.shade400;

                    final button = GestureDetector(
                      onDoubleTap: () => _showChannelPicker(context, index),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              isActive ? presetColor : Colors.grey.shade400,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () => _switchChannel(context, channel),
                        child: Text(
                          'Channel $channel',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );

                    if (isLandscape) {
                      return Expanded(
                        child: Padding(
                          padding: buttonPadding,
                          child: SizedBox.expand(child: button),
                        ),
                      );
                    }

                    return SizedBox(
                      height: buttonHeight,
                      width: double.infinity,
                      child: Padding(
                        padding: buttonPadding,
                        child: button,
                      ),
                    );
                  }),
                );
              },
            ),
          ),
          // --- +/- buttons at bottom ---
          if (isPortrait)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 36),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildActionButton('-', _decreaseGrid),
                  const SizedBox(width: 16),
                  _buildActionButton('+', _increaseGrid),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActionButton(String label, VoidCallback onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      onPressed: onPressed,
      child: Text(label, style: const TextStyle(fontSize: 24)),
    );
  }

  void _increaseGrid() {
    if (_gridCount >= 3) return;
    setState(() {
      _gridCount++;
      _assignedChannels.add(_nextAvailableChannel());
    });
    _persistState();
  }

  void _decreaseGrid() {
    if (_gridCount <= 2) return;
    setState(() {
      _gridCount--;
      _assignedChannels.removeLast();
    });
    _persistState();
  }

  void _restoreState() {
    _gridCount = _storedGridCount.clamp(2, 3);
    _assignedChannels = List<int>.from(_storedAssignedChannels);
    _syncAssignedChannelsWithGrid();
    _persistState();
  }

  void _persistState() {
    _storedGridCount = _gridCount;
    _storedAssignedChannels = List<int>.from(_assignedChannels);
  }

  void _syncAssignedChannelsWithGrid() {
    if (_assignedChannels.length > _gridCount) {
      _assignedChannels = _assignedChannels.sublist(0, _gridCount);
    } else {
      while (_assignedChannels.length < _gridCount) {
        _assignedChannels.add(_nextAvailableChannel());
      }
    }
  }

  int _nextAvailableChannel() {
    const maxChannel = 7;
    final used = _assignedChannels.toSet();
    for (var ch = 1; ch <= maxChannel; ch++) {
      if (!used.contains(ch)) {
        return ch;
      }
    }
    return _assignedChannels.isEmpty ? 1 : _assignedChannels.last;
  }
}
