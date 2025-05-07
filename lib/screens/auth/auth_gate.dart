import 'package:flutter/material.dart';
import 'package:rhythmrun/screens/auth/login_screen.dart';
import 'package:rhythmrun/screens/auth/profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthGate extends StatelessWidget{
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      //Listen to auth state changed
      stream: Supabase.instance.client.auth.onAuthStateChange, 

      builder: (context, snapshot){

        if (snapshot.connectionState == ConnectionState.waiting){
          return const Scaffold(
            body: Center(child: CircularProgressIndicator())
          );
        }
        // Check if there is a valid session:
        final session = snapshot.hasData ? snapshot.data!.session : null;

        if (session != null){
          return const ProfilePage();
        } else {
          return LoginScreenPage();
        }
      });
  }
}
