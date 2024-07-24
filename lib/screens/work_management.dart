// ignore_for_file: unused_field

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
  String? category;
  String? shikka;
  String? id;

  final assignWeight = TextEditingController();
  final submitWeight = TextEditingController();
  final searchController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  DateTime assignDate = DateTime.now();
  DateTime? submitDate;
  bool workDone = false;

  final bool _isMultiSelectMode = false;
  final Set<int> _selectedWorks = <int>{};
  String _searchTerm = '';
  String _sortCriteria = 'assignDate';
  bool _sortAscending = true;

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
      stream: FirebaseFirestore.instance.collection("works").snapshots(),
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
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _refreshWorkList() {
    setState(() {});
  }

  void _onSearchTextChanged(String text) {
    setState(() {
      _searchTerm = text.toLowerCase();
    });
  }

  void _onSortCriteriaChanged(String criteria) {
    setState(() {
      if (_sortCriteria == criteria) {
        _sortAscending = !_sortAscending;
      } else {
        _sortCriteria = criteria;
        _sortAscending = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: _isMultiSelectMode ? _deleteSelectedButton() : _addWorkButton(),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                labelText: 'Search',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    searchController.clear();
                    _onSearchTextChanged('');
                  },
                ),
              ),
              onChanged: _onSearchTextChanged,
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildSortButton('Assign Date', 'assignDate'),
              _buildSortButton('Employee', 'empName'),
              _buildSortButton('Category', 'category'),
            ],
          ),
          Expanded(
            child: getWorks(),
          ),
        ],
      ),
    );
  }

  Widget _addWorkButton() {
    return FloatingActionButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text(
              "Assign Works",
              textAlign: TextAlign.center,
            ),
            content: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return SingleChildScrollView(
                  child: FutureBuilder<List<String>>(
                    future: _getEmployees(), // Replace with your employee fetching logic
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
                              DropdownButtonFormField<String>(
                                value: shikka,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  labelText: 'Select Shikka',
                                ),
                                items: ['s1', 's2', 's3'].map((shikka) {
                                  return DropdownMenuItem<String>(
                                    value: shikka,
                                    child: Text(shikka),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    shikka = newValue;
                                  });
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please select a shikka';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 10),
                              DropdownButtonFormField<String>(
                                value: category,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  labelText: 'Select Category',
                                ),
                                items: [
                                  'Category 1',
                                  'Category 2',
                                  'Category 3'
                                ].map((category) {
                                  return DropdownMenuItem<String>(
                                    value: category,
                                    child: Text(category),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    category = newValue;
                                  });
                                },
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please select a category';
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
                              ElevatedButton(
                                onPressed: () {
                                  _selectDate(context, true);
                                },
                                child: Text(
                                  "Assign Date: ${dateFormat.format(assignDate)}",
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  _selectDate(context, false);
                                },
                                child: Text(
                                  "Submit Date: ${submitDate != null ? dateFormat.format(submitDate!) : 'N/A'}",
                                ),
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
                  if (_formKey.currentState!.validate()) {
                    FirebaseFirestore.instance.collection("works").add({
                      "empName": empName,
                      "shikka": shikka,
                      "category": category,
                      "assignWeight": double.parse(assignWeight.text),
                      "submitWeight": double.parse(submitWeight.text),
                      "assignDate": assignDate,
                      "submitDate": submitDate,
                      "workDone": workDone,
                    }).then((_) {
                      Navigator.pop(context);
                      _refreshWorkList();
                    });
                  }
                },
                child: const Text('Assign Work'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
            ],
          ),
        );
      },
      child: const Icon(Icons.add),
    );
  }

  Future<List<String>> _getEmployees() async {
    // Fetch employee data from Firestore or another source
    final QuerySnapshot querySnapshot =
    await FirebaseFirestore.instance.collection('employees').get();
    return querySnapshot.docs.map((doc) => doc['name'] as String).toList();
  }

  Widget _deleteSelectedButton() {
    return FloatingActionButton(
      onPressed: () {
        // Implement delete logic here
      },
      child: const Icon(Icons.delete),
    );
  }

  Widget _buildSortButton(String label, String criteria) {
    return TextButton(
      onPressed: () {
        _onSortCriteriaChanged(criteria);
      },
      child: Text(
        label,
        style: TextStyle(
          color: _sortCriteria == criteria ? Colors.blue : Colors.black,
          fontWeight: _sortCriteria == criteria ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
}
