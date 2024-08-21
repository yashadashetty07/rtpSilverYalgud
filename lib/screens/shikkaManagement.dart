// ignore_for_file: avoid_print, use_build_context_synchronously, non_constant_identifier_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ShikkaManagement extends StatefulWidget {
  const ShikkaManagement({super.key});

  @override
  State<ShikkaManagement> createState() => _ShikkaManagementState();
}

class _ShikkaManagementState extends State<ShikkaManagement> {
  String? shikkaNamr;
  String? shikkaPrice;

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

        child:  ShikkaList(),
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
            title: const Text("Add new Shikka"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    prefixIcon: const Icon(Icons.abc_rounded),
                    hintText: "Enter Shikka",
                  ),
                  onChanged: (value) {
                    shikkaNamr = value;
                  },
                ),
                const SizedBox(height: 10),
                TextField(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                    prefixIcon: const Icon(Icons.currency_rupee),
                    hintText: "Price",
                  ),
                  onChanged: (value) {
                    shikkaPrice = value;
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  if (shikkaNamr != null && shikkaPrice != null) {
                    FirebaseFirestore.instance
                        .collection("Shikka")
                        .doc(shikkaPrice)
                        .set({
                      "shikkaName": shikkaNamr,
                      "shikkaPrice": shikkaPrice,
                    });
                    shikkaNamr = null;
                    shikkaPrice = null;
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

  Widget ShikkaList() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance.collection("shikka").snapshots(),
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
                title: Text(data["shikkaName"],
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Roboto',
                  ),
                ),
                subtitle: Text(data["shikkaPrice"].toString(),
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
                        updateData(data.id, data["shikkaName"], data["shikkaPrice"]);
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

  Widget deleteConfirmationDialog(String shikkaPrice) {
    return AlertDialog(
      title: const Text("Delete This Shikka?"),
      actions: [
        ElevatedButton(
          onPressed: () {
            deleteShikka(shikkaPrice);
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

  void deleteShikka(String shikkaPrice) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    DocumentReference documentRef =
    firestore.collection('shikka').doc(shikkaPrice);
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
          title: const Text("Update Shikka"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  prefixIcon: const Icon(Icons.abc_rounded),
                  hintText: "Shikka",
                  labelText: "Shikka",
                ),
                controller: nameController,
              ),
              const SizedBox(height: 10),
              TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                  prefixIcon: const Icon(Icons.currency_rupee),
                  hintText: "Enter Price",
                  labelText: "Price",
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
                      .collection('shikka')
                      .doc(documentId);

                  try {
                    await docRef.update({
                      'shikkaName': newName,
                      'shikkaPrice': newPhone,
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
