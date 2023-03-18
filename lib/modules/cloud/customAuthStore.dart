import 'dart:convert';

import 'package:pocketbase/pocketbase.dart';

import '../../platform/simpleSharedPrefs.dart';

class CustomAuthStore extends AuthStore {
  final String key;

  CustomAuthStore({this.key = "pb_auth"}) {
    final String? raw = SharedPrefs().getValue(key, null);

    if (raw != null && raw.isNotEmpty) {
      final decoded = jsonDecode(raw);
      final token = (decoded as Map<String, dynamic>)["token"] as String? ?? "";
      final model =
          RecordModel.fromJson(decoded["model"] as Map<String, dynamic>? ?? {});

      save(token, model);
    }
  }

  @override
  void save(
    String newToken,
    dynamic /* RecordModel|AdminModel|null */ newModel,
  ) {
    super.save(newToken, newModel);

    final encoded =
        jsonEncode(<String, dynamic>{"token": newToken, "model": newModel});

    SharedPrefs().setValue(key, encoded);
  }

  @override
  void clear() {
    super.clear();

    SharedPrefs().remove(key);
  }
}
