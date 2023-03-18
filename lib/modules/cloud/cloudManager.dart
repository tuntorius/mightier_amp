import 'package:flutter/widgets.dart';
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

  void initialize() async {
    pb.authStore.onChange.listen(_onAuthChange);

    _signedIn = pb.authStore.isValid;
  }

  Future<RecordAuth> signIn({required String email, required String password}) {
    return pb.collection('users').authWithPassword(email, password);
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
}
