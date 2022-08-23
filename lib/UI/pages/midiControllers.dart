import 'package:flutter/material.dart';
import 'package:mighty_plug_manager/UI/pages/hotkeysMainPage.dart';
import 'package:mighty_plug_manager/UI/theme.dart';
import 'package:mighty_plug_manager/UI/widgets/MidiDeviceTile.dart';
import 'package:mighty_plug_manager/bluetooth/bleMidiHandler.dart';
import 'package:mighty_plug_manager/midi/MidiControllerManager.dart';
import 'package:mighty_plug_manager/midi/controllers/MidiController.dart';

class MidiControllers extends StatefulWidget {
  const MidiControllers({Key? key}) : super(key: key);

  @override
  _MidiControllersState createState() => _MidiControllersState();
}

class _MidiControllersState extends State<MidiControllers> {
  final ctrl = MidiControllerManager();
  final midiHandler = BLEMidiHandler.instance();
  @override
  void initState() {
    super.initState();
    MidiControllerManager().addListener(onControllersUpdate);
  }

  @override
  void dispose() {
    super.dispose();
    MidiControllerManager().removeListener(onControllersUpdate);
  }

  onControllersUpdate() {
    setState(() {});
  }

  _onControllerSettings(MidiController controller) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => HotkeysMainPage(
              controller: controller,
            )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("MIDI/HID Remote Control"),
      ),
      body: StreamBuilder<MidiSetupStatus>(
          stream: midiHandler.status,
          builder: (context, snapshot) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ListTile(
                  title: Text("Available Devices",
                      style: AppThemeConfig.ListTileHeaderStyle),
                  dense: true,
                  trailing: !ctrl.isScanning
                      ? null
                      : SizedBox(
                          width: 15,
                          height: 15,
                          child: CircularProgressIndicator()),
                ),
                Flexible(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 250),
                    child: ListView.builder(
                      itemBuilder: (context, index) {
                        var dev = ctrl.controllers[index];
                        return MidiControllerTile(
                          controller: dev,
                          onTap: () async {
                            if (!dev.connected) {
                              await dev.connect();
                              setState(() {});
                            } else
                              _onControllerSettings(dev);
                          },
                          onSettings: () => _onControllerSettings(dev),
                        );
                      },
                      itemCount: ctrl.controllers.length,
                    ),
                  ),
                ),
                ElevatedButton(
                    onPressed: ctrl.isScanning ? ctrl.stopScan : ctrl.startScan,
                    child: !ctrl.isScanning
                        ? Text("Start Scanning")
                        : Text("Stop Scanning")),
                if (!midiHandler.bluetoothOn)
                  Text("Enable Bluetooth to discover BLE MIDI devices"),
                Divider(),
              ],
            );
          }),
    );
  }
}
