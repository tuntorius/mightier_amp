import 'package:flutter/widgets.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseUtils extends ChangeNotifier {
  /// private constructor
  SupabaseUtils._();

  /// the one and only instance of this singleton
  static final instance = SupabaseUtils._();

  User? _user;
  bool get signedIn => _user != null;
  void initialize() async {
    await Supabase.initialize(
      url: "https://kdcinbiacovsvgkfddkz.supabase.co",
      anonKey:
          "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtkY2luYmlhY292c3Zna2ZkZGt6Iiwicm9sZSI6ImFub24iLCJpYXQiOjE2NzY2NjEzMTYsImV4cCI6MTk5MjIzNzMxNn0.-IagnkfAwxW0Jwwhd3Mu0yDhTV8ke8T-WgjufpuR7Ng",
    );

    Supabase.instance.client.auth.onAuthStateChange.listen(_onAuthStateChange);
  }

  void _onAuthStateChange(AuthState authState) {
    print("OnStateChange ${authState.event}");
    _user = authState.session?.user;
    notifyListeners();
  }
}
