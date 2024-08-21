import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rtp_silver_yalgud/auth/email_auth.dart';
import 'package:rtp_silver_yalgud/screens/home_page.dart';
import 'package:rtp_silver_yalgud/screens/shikkaManagement.dart';
import 'package:rtp_silver_yalgud/screens/work_management.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Firebase initialization for all platforms
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'AIzaSyCZVjGVXlhSSIUajMerRo0C17DUWM9LH_A',
        appId: '1:813229464460:web:948b8de01942778102d4a9',
        messagingSenderId: '813229464460',
        projectId: 'rtpsilveryalgud-33042',
        authDomain: 'rtpsilveryalgud-33042.firebaseapp.com',
        storageBucket: 'rtpsilveryalgud-33042.appspot.com',
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
        debugShowCheckedModeBanner: false,
      home: WorkManagement(), // Set EmployeeManagement as the home screen
    );
  }
}
