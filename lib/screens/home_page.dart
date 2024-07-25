import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:rtp_silver_yalgud/screens/employee_management.dart';
import 'package:rtp_silver_yalgud/screens/work_management.dart';

import '../auth/email_auth.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.black87,
          title: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.home), text: 'Home Page'),
              Tab(icon: Icon(Icons.person), text: 'Employees'),
              Tab(icon: Icon(Icons.work), text: 'Works'),
            ],
            labelColor: Colors.yellow,
            unselectedLabelColor: Colors.white,
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 1),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
            ),
          ],
        ),
        body: const TabBarView(
          children: [
            HomeContent(),
            EmployeeManagement(),
            WorkManagement(),
          ],
        ),
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.black26,
      body: Center(
        child: SingleChildScrollView(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image(
                image: AssetImage("assets/images/rtp_logo2.png"),
                width: 400,
                height: 400,
              ),
              SizedBox(width: 80),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 30, horizontal: 10),
                child: Column(
                  children: [
                    Text(
                      'Welcome to',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: Text(
                        'R T Patil Silver Ornaments\n Pvt. Ltd. Yalgud',
                        style: TextStyle(
                          fontFamily: "Roboto",
                          fontSize: 35,
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
    );
  }
}
