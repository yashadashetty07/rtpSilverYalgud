import 'package:flutter/material.dart';
import 'package:rtp_silver_yalgud/screens/employee_management.dart';
import 'package:rtp_silver_yalgud/screens/work_management.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.orangeAccent,
          title: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.home,color: Colors.black,), text: 'Home Page'),
              Tab(icon: Icon(Icons.person,color: Colors.black), text: 'Employees'),
              Tab(icon: Icon(Icons.work,color: Colors.black), text: 'Works'),
            ],padding: EdgeInsets.symmetric(vertical: 10,horizontal: 1),
          ),
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
    return Container(
      color: const Color.fromRGBO(238, 233, 239, 1.0),
      child: const Center(
        child: SingleChildScrollView(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image(
                image: AssetImage("assets/images/rtp_logo2.png"),
                width: 300,
                height: 300,
              ),
              SizedBox(width: 30),
              Padding(
                padding: EdgeInsets.symmetric(vertical: 30, horizontal: 10),
                child: Column(
                  children: [
                    Text(
                      'Welcome to',
                      style: TextStyle(
                        fontSize: 20,
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
                          fontSize: 28,
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
