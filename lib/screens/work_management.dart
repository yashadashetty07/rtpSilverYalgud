// ignore_for_file: unused_field, avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WorkManagement extends StatefulWidget {
  const WorkManagement({super.key});

  @override
  _WorkManagementState createState() => _WorkManagementState();
}

class _WorkManagementState extends State<WorkManagement> {
  String? empName;
 // String? category;
  //String? shikka;
  String? id;

  final  shikka = TextEditingController();
  final  category = TextEditingController();
  final assignWeight = TextEditingController();
  final submitWeight = TextEditingController();
  final searchController = TextEditingController();
  final msgController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  DateTime assignDate = DateTime.now();
  DateTime? submitDate;
  bool workDone = false;

  final bool _isMultiSelectMode = false;
  final Set<int> _selectedWorks = <int>{};
  final String _searchTerm = '';
  final DateFormat dateFormat = DateFormat('dd/MM/yyyy');

  Future<void> _selectDate(BuildContext context, bool isAssignDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isAssignDate ? assignDate : submitDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        if (isAssignDate) {
          assignDate = picked;
        } else {
          submitDate = picked;
        }
      });
    }
  }

  Widget getWorks() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection("works")
          .orderBy('assignDate', descending: true)
          .snapshots(),
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
            bool workDone = data['workDone'] ?? false;
            return Card(
              elevation: 12,
              margin: const EdgeInsets.all(10),
              shadowColor: Colors.black,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Employee Name: ${data['empName']}',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 5),
                          Text('Shikka: ${data['shikka']}'),
                          const SizedBox(height: 5),
                          Text('Category: ${data['category']}'),
                          const SizedBox(height: 5),
                          Text('Assign Weight: ${data['assignWeight']}'),
                          const SizedBox(height: 5),
                          Text('Assign Date: ${dateFormat.format((data['assignDate'] as Timestamp).toDate())}'),
                          const SizedBox(height: 5),
                          Text('Submit Weight: ${data['submitWeight']}'),
                          const SizedBox(height: 5),
                          Text('Submit Date: ${data['submitDate'] != null ? dateFormat.format((data['submitDate'] as Timestamp).toDate()) : 'N/A'}'),
                          const SizedBox(height: 5),
                          Text('Work Done: ${data['workDone']}'),
                          const SizedBox(height: 5),
                          Text('Note: ${data['msg'] ?? 'No note'}'),
                        ],
                      ),
                    ),
                    Checkbox(
                      value: workDone,
                      onChanged: (bool? value) {
                        setState(() {
                          workDone = value ?? false;
                          if (workDone) {
                            _selectDate(context, false).then((_) {
                              FirebaseFirestore.instance
                                  .collection("works")
                                  .doc(data.id)
                                  .update({"workDone": workDone, "submitDate": submitDate});
                            });
                          } else {
                            FirebaseFirestore.instance
                                .collection("works")
                                .doc(data.id)
                                .update({"workDone": workDone, "submitDate": null});
                          }
                        });
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        _editWork(context, data);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        _confirmDelete(context, data);
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

  void _editWork(BuildContext context, QueryDocumentSnapshot data) {
    empName = data['empName'];
    // shikka = data['shikka'];
    // category = data['category'];
    shikka.text = data['shikka'];
    category.text = data['category'];
    assignWeight.text = data['assignWeight'].toString();
    submitWeight.text = data['submitWeight'].toString();
    assignDate = (data['assignDate'] as Timestamp).toDate();
    submitDate = data['submitDate'] != null ? (data['submitDate'] as Timestamp).toDate() : null;
    workDone = data['workDone'] ?? false;
    msgController.text = data['msg'] ?? '';

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(
          "Edit Work",
          textAlign: TextAlign.center,
        ),
        content: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return SingleChildScrollView(
              child: FutureBuilder<List<String>>(
                future: _getEmployees(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text('No Works available');
                  } else {
                    List<String> employees = snapshot.data!;
                    return Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          DropdownButtonFormField<String>(
                            value: empName,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              labelText: 'Select Employee',
                            ),
                            items: employees.map((employee) {
                              return DropdownMenuItem<String>(
                                value: employee,
                                child: Text(employee),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                empName = newValue;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select an employee';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: shikka,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              labelText: 'Enter Shikka',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a shikka';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: category,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              labelText: 'Enter Category',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a category';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 10),
                          TextFormField(
                            controller: assignWeight,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              labelText: 'Enter Assign Weight',
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter the assign weight';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: submitWeight,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              labelText: 'Enter Submit Weight',
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter the submit weight';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const Text('Assign Date: '),
                              TextButton(
                                onPressed: () => _selectDate(context, true),
                                child: Text(dateFormat.format(assignDate)),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              const Text('Submit Date: '),
                              TextButton(
                                onPressed: () => _selectDate(context, false),
                                child: Text(submitDate != null
                                    ? dateFormat.format(submitDate!)
                                    : 'N/A'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          CheckboxListTile(
                            title: const Text('Work Done'),
                            value: workDone,
                            onChanged: (bool? value) {
                              setState(() {
                                workDone = value ?? false;
                              });
                            },
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: msgController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              labelText: 'Add a note',
                            ),
                            maxLines: 3,
                          ),
                        ],
                      ),
                    );
                  }
                },
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                FirebaseFirestore.instance.collection('works').doc(data.id).update({
                  'empName': empName,
                  'shikka': shikka.text,
                  'category': category.text,
                  'assignWeight': int.parse(assignWeight.text),
                  'submitWeight': int.parse(submitWeight.text),
                  'assignDate': assignDate,
                  'submitDate': submitDate,
                  'workDone': workDone,
                  'msg': msgController.text,
                }).then((_) {
                  Navigator.of(context).pop(); // Close the dialog after editing work
                }).catchError((error) {
                  print("Failed to update work: $error");
                  // Handle error if necessary
                });
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, QueryDocumentSnapshot data) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirm Delete"),
        content: const Text("Are you sure you want to delete this work?"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              FirebaseFirestore.instance.collection('works').doc(data.id).delete().then((_) {
                Navigator.of(context).pop(); // Close the dialog
              }).catchError((error) {
                print("Failed to delete work: $error");
                // Handle error if necessary
              });
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<List<String>> _getEmployees() async {
    var querySnapshot = await FirebaseFirestore.instance.collection("employees").get();
    List<String> employees = [];
    for (var doc in querySnapshot.docs) {
      employees.add(doc.get('empName'));
    }
    return employees;
  }

  void _addNewWork(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(
          "Add New Work",
          textAlign: TextAlign.center,
        ),
        content: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return SingleChildScrollView(
              child: FutureBuilder<List<String>>(
                future: _getEmployees(), // Replace this with your actual method to get employees
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Error: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text('No Employees available');
                  } else {
                    List<String> employees = snapshot.data!;
                    return Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          DropdownButtonFormField<String>(
                            value: empName,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              labelText: 'Select Employee',
                            ),
                            items: employees.map((employee) {
                              return DropdownMenuItem<String>(
                                value: employee,
                                child: Text(employee),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                empName = newValue!;
                              });
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select an employee';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: shikka,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              labelText: 'Enter Shikka',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a shikka';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: category,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              labelText: 'Enter Category',
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter a category';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: assignWeight,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              labelText: 'Enter Assign Weight',
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter the assign weight';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: submitWeight,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              labelText: 'Enter Submit Weight',
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter the submit weight';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              const Text('Assign Date: '),
                              TextButton(
                                onPressed: () => _selectDate(context, true),
                                child: Text(dateFormat.format(assignDate)),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              const Text('Submit Date: '),
                              TextButton(
                                onPressed: () => _selectDate(context, false),
                                child: Text(submitDate != null
                                    ? dateFormat.format(submitDate!)
                                    : 'N/A'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          CheckboxListTile(
                            title: const Text('Work Done'),
                            value: workDone,
                            onChanged: (bool? value) {
                              setState(() {
                                workDone = value ?? false;
                              });
                            },
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: msgController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              labelText: 'Add a note',
                            ),
                            maxLines: 3,
                          ),
                        ],
                      ),
                    );
                  }
                },
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                FirebaseFirestore.instance.collection('works').add({
                  'empName': empName,
                  'shikka': shikka.text,
                  'category': category.text,
                  'assignWeight': int.parse(assignWeight.text),
                  'submitWeight': int.parse(submitWeight.text),
                  'assignDate': assignDate,
                  'submitDate': submitDate,
                  'workDone': workDone,
                  'msg': msgController.text,
                }).then((_) {
                  resetValues();
                  Navigator.of(context).pop();
                  // Close the dialog after adding work
                }).catchError((error) {
                  print("Failed to add work: $error");
                  // Handle error if necessary
                });
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black26,
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              onChanged: (value) {
                setState(() {});
              },
              decoration: const InputDecoration(
                labelText: 'Search',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: getWorks(),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _addNewWork(context);
          resetValues();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void resetValues() {
    setState(() {
      empName = null;
      shikka.clear();
      category.clear();
      assignWeight.clear();
      submitWeight.clear();
      assignDate = DateTime.now();
      submitDate = null;
      workDone = false;
      msgController.clear();
    });
  }

}

