// ignore_for_file: avoid_print, use_build_context_synchronously, non_constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class EmployeeManagement extends StatefulWidget {
  const EmployeeManagement({super.key});

  @override
  State<EmployeeManagement> createState() => _EmployeeManagementState();
}

class _EmployeeManagementState extends State<EmployeeManagement> {
  String? empName;
  String? empPhone;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black26,
      // appBar: AppBar(
      //   title: const Text("Employees"),
      //   centerTitle: true,
      //   backgroundColor: Colors.black54,
      // ),
      body:Container(

        child:  EmployeesList(),
      ),
      floatingActionButton: addEmpButton(),
    );
  }

  Widget addEmpButton() {
    return FloatingActionButton(
      backgroundColor: Colors.black,
      foregroundColor: Colors.white,
      onPressed: () {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text("Add new Employee"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    prefixIcon: const Icon(Icons.person),
                    hintText: "Enter employee name",
                  ),
                  onChanged: (value) {
                    empName = value;
                  },
                ),
                const SizedBox(height: 10),
                TextField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    prefixIcon: const Icon(Icons.phone),
                    hintText: "Enter employee phone",
                  ),
                  onChanged: (value) {
                    empPhone = value;
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  if (empName != null && empPhone != null) {
                    FirebaseFirestore.instance
                        .collection("employees")
                        .doc(empPhone)
                        .set({
                      "empName": empName,
                      "empPhone": empPhone,
                    });
                    empName = null;
                    empPhone = null;
                    Navigator.pop(context);
                  }
                },
                child: const Text("Add"),
              ),
            ],
          ),
        );
      },
      child: const Icon(Icons.add),
    );
  }

  Widget EmployeesList() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection("employees").snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text("No Data Found"),
          );
        }
        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            var data = snapshot.data!.docs[index];
            return Card(
              elevation: 5,
              margin: const EdgeInsets.all(5),
              shadowColor: Colors.black87,
              child: ListTile(
                leading: CircleAvatar(
                  child: Text("${index + 1}"),
                ),
                title: Text(data["empName"],
                  style: const TextStyle(
                  fontSize: 22,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Roboto',
                  ),
                ),
                subtitle: Text(data["empPhone"].toString(),
                  style: const TextStyle(
                      fontSize: 20,
                    fontWeight: FontWeight.w500
                  ),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        updateData(data.id, data["empName"], data["empPhone"]);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (_) => deleteConfirmationDialog(data.id),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget deleteConfirmationDialog(String empPhone) {
    return AlertDialog(
      title: const Text("Delete This Employee?"),
      actions: [
        ElevatedButton(
          onPressed: () {
            deleteEmployees(empPhone);
            Navigator.pop(context);
          },
          child: const Text("Delete"),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text("Cancel"),
        ),
      ],
    );
  }

  void deleteEmployees(String empPhone) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    DocumentReference documentRef =
        firestore.collection('employees').doc(empPhone);
    try {
      await documentRef.delete();
      Fluttertoast.showToast(msg: 'Document successfully deleted!');
    } catch (e) {
      Fluttertoast.showToast(msg: 'Error deleting document: $e');
    }
  }

  void updateData(String documentId, String currentName, String currentPhone) {
    showDialog(
      context: context,
      builder: (context) {
        TextEditingController nameController =
            TextEditingController(text: currentName);
        TextEditingController phoneController =
            TextEditingController(text: currentPhone);

        return AlertDialog(
          title: const Text("Update Employee"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  prefixIcon: const Icon(Icons.person),
                  hintText: "Enter employee name",
                  labelText: "Name",
                ),
                controller: nameController,
              ),
              const SizedBox(height: 10),
              TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  prefixIcon: const Icon(Icons.phone),
                  hintText: "Enter employee phone",
                  labelText: "Phone",
                ),
                controller: phoneController,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                String? newName = nameController.text;
                String? newPhone = phoneController.text;

                if (newName.isNotEmpty && newPhone.isNotEmpty) {
                  DocumentReference docRef = FirebaseFirestore.instance
                      .collection('employees')
                      .doc(documentId);

                  try {
                    await docRef.update({
                      'empName': newName,
                      'empPhone': newPhone,
                    });
                    Fluttertoast.showToast(
                        msg: 'Document successfully updated!');
                  } catch (e) {
                    Fluttertoast.showToast(msg: 'Error updating document: $e');
                  }

                  Navigator.pop(context);
                }
              },
              child: const Text("Update"),
            ),
          ],
        );
      },
    );
  }

//end of code
}
