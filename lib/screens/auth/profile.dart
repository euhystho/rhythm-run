import 'package:flutter/material.dart';
import 'package:rhythmrun/data/services/authentication.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  //get auth service
  final authService = Authentication();

  // logout button pressed:
  void logout() async {
    await authService.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final currentEmail = authService.getCurrentUserEmail();


    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        actions: [
          //logout button
          IconButton(
            onPressed: logout, 
            icon: const Icon(Icons.logout)
          )
        ]
      ),
      body: Center(child: Text(currentEmail.toString()),)
    );
  }
}