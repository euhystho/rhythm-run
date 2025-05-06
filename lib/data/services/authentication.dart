import 'package:supabase_flutter/supabase_flutter.dart';

class Authentication {
  final SupabaseClient _supabase = Supabase.instance.client;

  //Sign in with email and password
  Future<AuthResponse> signInWithEmail(String email, String password) async {
    return await _supabase.auth.signInWithPassword(email: email, password: password);
  }

  //Sign up with email and password
  Future<AuthResponse> signUpWithEmail(String email, String password) async {
    return await _supabase.auth.signUp(email: email, password: password);
  }

  //Sign out
  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  //Get user Email
  String? getCurrentUserEmail(){
    final session = _supabase.auth.currentSession;
    final user = session?.user;
    return user?.email;
  }
}

