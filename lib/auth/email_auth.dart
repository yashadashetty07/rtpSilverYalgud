import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../screens/home_page.dart'; // Import the home page

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Define a list of registered emails
  final List<String> _registeredEmails = [
    'rtpsilverapp@gmail.com',
    'yash.adashetty@gmail.com',
  ];

  void _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      // Show error if email or password is empty
      _showError('Please enter email and password');
      return;
    }

    // Check if the email is registered
    if (!_registeredEmails.contains(email)) {
      _showError('You are not registered');
      return;
    }

    try {
      // Sign in with email and password
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      // Navigate to the home page
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
    } catch (e) {
      // Handle login errors
      _showError('Login failed: ${e.toString()}');
    }
  }

  void _showError(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white70,
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(20.0),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 70,horizontal: 10),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Center(
                    child: SingleChildScrollView(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image(
                            image: AssetImage("assets/images/rtp_logo2.png"),
                            width: 200,
                            height: 200,
                          ),
                          SizedBox(width: 30),
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'Welcome to',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                Padding(
                                  padding: EdgeInsets.all(20),
                                  child: Text(
                                    'R T Patil Silver Ornaments\n Pvt. Ltd. Yalgud',
                                    style: TextStyle(
                                      fontFamily: "Roboto",
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30,),
                  SizedBox(
                    width: 450, // Reduced width
                    child: TextField(
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        prefixIcon: Icon(Icons.email),
                      ),
                      keyboardType: TextInputType.emailAddress,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: 450, // Reduced width
                    child: TextField(
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock),
                      ),
                      obscureText: true,
                    ),
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: _login,
                    style: const ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(Colors.black45),
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(10),
                      child:
                      Text('Login',style: TextStyle(
                        color: Colors.white,
                        fontSize: 20
                    ),),
                  ),
                  ),],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
