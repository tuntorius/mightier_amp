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

  late final CloudStorageListener _storageListener = CloudStorageListener(pb);

  void initialize() async {
    pb.authStore.onChange.listen(_onAuthChange);

    _signedIn = pb.authStore.isValid;
    print("PocketBase initialized. Signed in = $_signedIn");

    PresetsStorage().registerPresetStorageListener(_storageListener);

    //TEST syncing or sth
    if (_signedIn) {
      var sw = Stopwatch()..start();
      pb
          .collection("presets")
          .getList(filter: 'user_id = "$userId"')
          .then((value) {
        sw.stop();
        print("List time ${sw.elapsedMilliseconds} ms");
        print(value.items.length);
      });
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
    print("Event: ${event.model}");
    print("Token: ${event.token}");

    _signedIn = event.model != null;
    notifyListeners();
  }

  /// Presets handling

  Future<RecordModel> createPreset(Map preset) {
    return pb.collection('presets').create(body: {
      'name': preset["name"],
      'uuid': preset['uuid'],
      'data': preset,
      "user_id": CloudManager.instance.userId
    });
  }
}
