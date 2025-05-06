import 'dart:async';
import 'package:flutter/material.dart';
import 'package:rhythmrun/data/services/authentication.dart';
import 'package:rhythmrun/screens/auth/register_screen.dart';
import 'package:rhythmrun/utils/theme.dart';


class LoginScreenPage extends StatefulWidget {
  const LoginScreenPage({super.key});

  @override
  State<LoginScreenPage> createState() => _LoginScreenPageState();
}

class _LoginScreenPageState extends State<LoginScreenPage> {
  // get the authentication service
  final authService = Authentication();

  // text controllers
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // When the login button is pressed
  void login() async {
    final email = _emailController.text;
    final password = _passwordController.text;

    try {
      await authService.signInWithEmail(email, password);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Error: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 50),
        children: [
          // email
          TextField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: "Email"),
          ),
          //password
          TextField(
            controller: _passwordController,
            decoration: const InputDecoration(labelText: "Password"),
          ),

          const SizedBox(height: 12),

          //Login button
          ElevatedButton(onPressed: login, child: const Text("Login")),

          const SizedBox(height: 12),

          // Sign-Up Button
          GestureDetector(
            onTap:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RegisterPage()),
                ),
            child: Center(child: Text("Don't have an account? Sign Up")),
          ),
        ],
      ),
    );
  }
}

Future<void> main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      //Toggle the Debug Banner on the side :)
      debugShowCheckedModeBanner: false,
      title: 'RhythmRun',
      theme: RhythmRunTheme.lightTheme,
      darkTheme: RhythmRunTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const LoginScreenPage(),
    );
  }
}
