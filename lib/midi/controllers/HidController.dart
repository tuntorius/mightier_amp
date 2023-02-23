import 'package:mighty_plug_manager/midi/controllers/MidiController.dart';

class HidController extends MidiController {
  HidController(super.onHotkeyReceived);

  @override
  Future<bool> connect() {
    return Future.value(true);
  }

  @override
  // HID is always connected
  bool get connected => true;

  @override
  // TODO: implement id
  String get id => "__hid__";

  @override
  // TODO: implement name
  String get name => "HID Input";

  @override
  // TODO: implement type
  ControllerType get type => ControllerType.Hid;
}
