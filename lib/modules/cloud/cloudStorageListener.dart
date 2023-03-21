import 'dart:collection';

import 'package:mighty_plug_manager/modules/cloud/cloudManager.dart';
import 'package:mighty_plug_manager/platform/presetStorageListener.dart';
import 'package:pocketbase/pocketbase.dart';

class CloudStorageListener implements PresetStorageListener {
  final PocketBase pb;

  CloudStorageListener(this.pb);

  final ListQueue<Map<String, dynamic>> _creationQueue = ListQueue();
  final ListQueue<String> _deletionQueue = ListQueue();

  @override
  void onPresetCreated(Map<String, dynamic> preset) {
    var queueLength = _creationQueue.length;
    _creationQueue.add(preset);

    if (queueLength == 0) _creationQueueHandler();
  }

  @override
  void onPresetDeleted(String uuid) {
    var queueLength = _deletionQueue.length;
    _deletionQueue.add(uuid);
    if (queueLength == 0) _deletionQueueHandler();
  }

  void _creationQueueHandler() async {
    while (_creationQueue.isNotEmpty) {
      var data = _creationQueue.first;
      try {
        var sw = Stopwatch()..start();
        final record = await pb.collection('presets').create(body: {
          'name': data["name"],
          'uuid': data['uuid'],
          'data': data,
          "user_id": CloudManager.instance.userId
        });
        _creationQueue.removeFirst();
        sw.stop();
        print("Created in ${sw.elapsedMilliseconds} ms");
      } on ClientException catch (e) {
        print(e);
        _creationQueue.removeFirst();
      } finally {}
    }
  }

  void _deletionQueueHandler() async {
    while (_deletionQueue.isNotEmpty) {
      var data = _deletionQueue.first;

      try {
        var sw = Stopwatch()..start();
        var result = await pb
            .collection('presets')
            .getFirstListItem(''); //'uuid="$data"');

        var delresult = await pb.collection('presets').delete(result.id);
        _deletionQueue.removeFirst();
        sw.stop();
        print("Deleted in ${sw.elapsedMilliseconds} ms");
      } on ClientException catch (e) {
        print(e);
        //await Future.delayed(Duration(milliseconds: 500));
        _deletionQueue.removeFirst();
      } finally {}
    }
  }

  @override
  void onPresetUpdated(Map<String, dynamic> preset) {
    // TODO: implement onPresetUpdated
  }
}
