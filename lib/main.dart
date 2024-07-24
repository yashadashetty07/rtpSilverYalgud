import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rtp_silver_yalgud/screens/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Firebase initialization for all platforms
    await Firebase.initializeApp(
      options: const FirebaseOptions(
      apiKey: 'AIzaSyCxkMEKQ7OR9_WIR_IEq1NgV6ofjTkEIW4',
      appId: '1:605835190676:web:5ac6d2463318c47ff22f81',
      messagingSenderId: '605835190676',
      projectId: 'rtpsilveryalgud',
      authDomain: 'rtpsilveryalgud.firebaseapp.com',
      storageBucket: 'rtpsilveryalgud.appspot.com',
    ),
    );
  } catch (e) {
    Fluttertoast.showToast(msg:'Error initializing Firebase: $e');
    // You can add more error handling code as needed, such as showing a dialog to the user
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomePage(), // Set EmployeeManagement as the home screen
    );
  }
}
