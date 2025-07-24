import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/home_screen.dart'; // 👈 make sure this is imported

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final auth = AuthService();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: StreamBuilder<User?>(
        stream: auth.userChanges,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return const Center(child: CircularProgressIndicator());

          if (snapshot.hasData) {
            return const HomeScreen(); // 👈 show HomeScreen after login
          }

          return Scaffold(
            body: Center(
              child: ElevatedButton(
                child: const Text("Sign in with Google"),
                onPressed: () => auth.signInWithGoogle(),
              ),
            ),
          );
        },
      ),
    );
  }
}
