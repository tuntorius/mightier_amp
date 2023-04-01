import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:mighty_plug_manager/modules/cloud/cloudStorageListener.dart';
import 'package:mighty_plug_manager/platform/presetsStorage.dart';
import 'package:pocketbase/pocketbase.dart';

import 'customAuthStore.dart';

class CloudManager extends ChangeNotifier {
  final pb = PocketBase('https://mightier-amp.pockethost.io/',
      authStore: CustomAuthStore());

  /// private constructor
  CloudManager._();

  /// the one and only instance of this singleton
  static final instance = CloudManager._();

  bool _signedIn = false;
  bool get signedIn => _signedIn;

  String get userId => pb.authStore.model?.id ?? "";
  String get userIdFilter => 'user_id="${CloudManager.instance.userId}"';

  late final CloudStorageListener _storageListener = CloudStorageListener(pb);

  void initialize() async {
    pb.authStore.onChange.listen(_onAuthChange);

    _signedIn = pb.authStore.isValid;
    print("PocketBase initialized. Signed in = $_signedIn");

    PresetsStorage().registerPresetStorageListener(_storageListener);

    //TEST syncing or sth
    if (_signedIn) {
      // var sw = Stopwatch()..start();
      // syncPresets().then((value) {
      //   sw.stop();
      //   print("List time ${sw.elapsedMilliseconds} ms");
      // });
    }
  }

  Future<RecordAuth> signIn({required String email, required String password}) {
    email = email.toLowerCase();
    return pb.collection('users').authWithPassword(email, password);
  }

  Future register({required String email, required String password}) {
    email = email.toLowerCase();
    return pb.collection('users').create(body: {
      "email": email,
      "password": password,
      "passwordConfirm": password,
      //username: "Random Name"
    });
  }

  Future requestValidation(String email) {
    email = email.toLowerCase();
    return pb.collection('users').requestVerification(email);
  }

  void signOut() {
    pb.authStore.clear();
  }

  _onAuthChange(AuthStoreEvent event) {
    _signedIn = event.model != null;
    notifyListeners();
  }

  /// Presets handling

  Future<RecordModel> createPreset(Map preset, String categoryId) {
    Map copy = jsonDecode(jsonEncode(preset));
    copy.remove("inactiveEffects");
    return pb.collection('presets').create(body: {
      'name': copy["name"],
      'uuid': copy['uuid'],
      'data': copy,
      "category_id": categoryId,
      "user_id": CloudManager.instance.userId
    });
  }

  Future<RecordModel> updatePreset(Map preset) async {
    final pData = await pb
        .collection('presets')
        .getFirstListItem('uuid="${preset["uuid"]}"');

    Map copy = jsonDecode(jsonEncode(preset));
    copy.remove("inactiveEffects");

    return await pb
        .collection('presets')
        .update(pData.id, body: {'name': preset["name"], 'data': copy});
  }

  void syncPresets() async {
    var sw = Stopwatch()..start();

    var futures = <Future<RecordModel>>[];

    //first create all categories
    for (int i = 0; i < PresetsStorage().presetsData.length; i++) {
      var cat = PresetsStorage().presetsData[i];
      futures.add(pb.collection('categories').create(body: {
        'name': cat["name"],
        "uuid": cat["uuid"],
        "user_id": CloudManager.instance.userId,
        "position": i
      }));
    }

    List<RecordModel> results = await Future.wait(futures);
    futures.clear();
    print("categories ready");

    //now create presets
    for (var cat in PresetsStorage().presetsData) {
      for (var preset in cat["presets"]) {
        var catId = results
            .firstWhere((element) => element.data["name"] == cat["name"]);
        futures.add(createPreset(preset, catId.id));
      }
    }
    results = await Future.wait(futures);
    // await pb.collection('presets').create(body: {
    //   'name': "AllPresets",
    //   'uuid': "95533e39-f0b8-4edc-940a-b72496c2b2a8",
    //   'data': data,
    //   "user_id": CloudManager.instance.userId
    // });
    sw.stop();
    print("List time ${sw.elapsedMilliseconds} ms");
  }
}
