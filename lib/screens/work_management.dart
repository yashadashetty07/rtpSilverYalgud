// ignore_for_file: unused_field, avoid_print, unused_local_variable, unused_element

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class WorkManagement extends StatefulWidget {
  const WorkManagement({super.key});

  @override
  _WorkManagementState createState() => _WorkManagementState();
}

class _WorkManagementState extends State<WorkManagement> {
  DateTime assignDate = DateTime.now();
  String? empName;
  final shikka = TextEditingController();
  final category = TextEditingController();
  final matiWeight = TextEditingController();
  final designWeight = TextEditingController();
  final netWeight = TextEditingController();
  DateTime? submitDate;
  final submitWeight = TextEditingController();
  final amount = TextEditingController();
  bool paymentDone = false;
  DateTime? paymentDate;
  final note = TextEditingController();
  bool workDone = false;

  final _formKey = GlobalKey<FormState>();
  final searchController = TextEditingController();
  final bool _isMultiSelectMode = false;
  final Set<int> _selectedWorks = <int>{};
  final String _searchTerm = '';
  final DateFormat dateFormat = DateFormat('dd/MM/yyyy');
  @override
  void dispose() {
    shikka.dispose();
    category.dispose();
    matiWeight.dispose();
    designWeight.dispose();
    netWeight.dispose();
    submitWeight.dispose();
    searchController.dispose();
    note.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isAssignDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isAssignDate ? assignDate : submitDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && mounted) {
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

        List<DataRow> rows = [];
        for (var data in snapshot.data!.docs) {
          bool workDone = data['workDone'] ?? false;
          DateTime? assignDate;
          DateTime? submitDate;
          DateTime? paymentDate;

          // Handle assignDate
          if (data['assignDate'] is Timestamp) {
            assignDate = (data['assignDate'] as Timestamp).toDate();
          } else if (data['assignDate'] is String) {
            assignDate = DateTime.tryParse(data['assignDate']);
          }

          // Handle submitDate
          if (data['submitDate'] is Timestamp) {
            submitDate = (data['submitDate'] as Timestamp).toDate();
          } else if (data['submitDate'] is String) {
            submitDate = DateTime.tryParse(data['submitDate']);
          }

          // Handle paymentDate
          if (data['paymentDate'] is Timestamp) {
            paymentDate = (data['paymentDate'] as Timestamp).toDate();
          } else if (data['paymentDate'] is String) {
            paymentDate = DateTime.tryParse(data['paymentDate']);
          }

          rows.add(
            DataRow(
              cells: [
                DataCell(Text(
                  assignDate != null ? dateFormat.format(assignDate) : 'N/A',
                )),
                DataCell(
                    TextButton(
                        onPressed: () {
                  _editWork(context, data);
                },
                child:Text(data['empName'] ?? ''))),
                DataCell(Text(data['shikka'] ?? '')),
                DataCell(Text(data['category'] ?? '')),
                DataCell(Text((data['matiWeight'] ?? 0).toString())),
                DataCell(Text((data['designWeight'] ?? 0).toString())),
                DataCell(Text((data['netWeight'] ?? 0).toString())),
                DataCell(Text(
                  submitDate != null ? dateFormat.format(submitDate) : 'N/A',
                )),
                DataCell(Text((data['submitWeight'] ?? 0).toString())),
                DataCell(Text(workDone.toString())),
                DataCell(Text(data['amount'] ?? '')),
                DataCell(Text((data['paymentDone'] ?? false).toString())),
                DataCell(Text(
                  paymentDate != null ? dateFormat.format(paymentDate) : 'N/A',
                )),
                DataCell(Text(data['note'] ?? 'No note')),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(decoration: BoxDecoration(
            border: Border.all(color: Colors.blueAccent, width: 2), // Customize border color and width
            borderRadius: BorderRadius.circular(8), // Optional: adds rounded corners
          ),columnSpacing: 65,
            columns: const [
              DataColumn(label: Text('तारीख',style: TextStyle(fontWeight: FontWeight.bold),)),
              DataColumn(label: Text('नाव',style: TextStyle(fontWeight: FontWeight.bold),)),
              DataColumn(label: Text('शिक्का',style: TextStyle(fontWeight: FontWeight.bold),)),
              DataColumn(label: Text('कॅटेगरी',style: TextStyle(fontWeight: FontWeight.bold),)),
              DataColumn(label: Text('माटी\nवजन',style: TextStyle(fontWeight: FontWeight.bold),)),
              DataColumn(label: Text('डिझाईन\nवजन',style: TextStyle(fontWeight: FontWeight.bold),)),
              DataColumn(label: Text('ए.वजन',style: TextStyle(fontWeight: FontWeight.bold),)),
              DataColumn(label: Text('जमा\nतारीख',style: TextStyle(fontWeight: FontWeight.bold),)),
              DataColumn(label: Text('जमा\nवजन',style: TextStyle(fontWeight: FontWeight.bold),)),
              DataColumn(label: Text('काम\nपूर्ण',style: TextStyle(fontWeight: FontWeight.bold),)),
              DataColumn(label: Text('रक्कम',style: TextStyle(fontWeight: FontWeight.bold),)),
              DataColumn(label: Text('बिल\nझाले',style: TextStyle(fontWeight: FontWeight.bold),)),
              DataColumn(label: Text('बिल\nतारीख',style: TextStyle(fontWeight: FontWeight.bold),)),
              DataColumn(label: Text('Note',style: TextStyle(fontWeight: FontWeight.bold),)),
            ],
            rows: rows,
          ),
        );
      },
    );
  }

  void _editWork(BuildContext context, QueryDocumentSnapshot data) {
    // Initialize form field values
    assignDate = _parseDate(data['assignDate'])!;
    empName = data['empName'];
    shikka.text = data['shikka'] ?? '';
    category.text = data['category'] ?? '';
    matiWeight.text = (data['matiWeight'] ?? 0).toString();
    designWeight.text = (data['designWeight'] ?? 0).toString();
    int matiWeightValue = int.tryParse(matiWeight.text) ?? 0;
    int designWeightValue = int.tryParse(designWeight.text) ?? 0;
    netWeight.text = (matiWeightValue + designWeightValue).toString();
    submitDate = _parseDate(data['submitDate']);
    submitWeight.text = (data['submitWeight'] ?? 0).toString();
    workDone = data['workDone'] ?? false;
    paymentDone = data['paymentDone'] ?? false;
    paymentDate = _parseDate(data['paymentDate']);
    note.text = data['note'] ?? '';

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
                              labelText: 'कामगार नाव ',
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
                              labelText: 'शिक्का ',
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
                              labelText: 'कॅटेगरी ',
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
                            controller: matiWeight,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              labelText: 'माटी वजन ',
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter the Mati weight';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: designWeight,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              labelText: 'डिझाईन वजन ',
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter design weight';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: netWeight,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              labelText: 'नेट वजन ',
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter the net weight';
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
                              labelText: 'Submit Weight',
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
                          SwitchListTile(
                            title: const Text('Work Done'),
                            value: workDone,
                            onChanged: (value) {
                              setState(() {
                                workDone = value;
                              });
                            },
                          ),
                          SwitchListTile(
                            title: const Text('Payment Done'),
                            value: paymentDone,
                            onChanged: (value) {
                              setState(() {
                                paymentDone = value;
                              });
                            },
                          ),
                          const SizedBox(height: 10),
                          TextFormField(
                            controller: note,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              labelText: 'Note',
                            ),
                            maxLines: 3,
                          ),
                          const SizedBox(height: 10),
                          TextButton(
                            onPressed: () {
                              if (_formKey.currentState?.validate() ?? false) {
                                // Perform update
                                FirebaseFirestore.instance
                                    .collection("works")
                                    .doc(data.id)
                                    .update({
                                  'assignDate': assignDate.toIso8601String(),
                                  'empName': empName,
                                  'shikka': shikka.text,
                                  'category': category.text,
                                  'matiWeight': int.tryParse(matiWeight.text) ?? 0,
                                  'designWeight': int.tryParse(designWeight.text) ?? 0,
                                  'netWeight': int.tryParse(netWeight.text) ?? 0,
                                  'submitDate': submitDate?.toIso8601String() ?? '',
                                  'submitWeight': int.tryParse(submitWeight.text) ?? 0,
                                  'workDone': workDone,
                                  'amount': amount.text,
                                  'paymentDone': paymentDone,
                                  'paymentDate': paymentDate?.toIso8601String() ?? '',
                                  'note': note.text,
                                }).then((_) {
                                  Navigator.pop(context);
                                }).catchError((error) {
                                  print('Failed to update work: $error');
                                });
                              }
                            },
                            child: const Text('Save Changes'),
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
      ),
    );
  }

// Helper method to parse date strings or timestamps
  DateTime? _parseDate(dynamic date) {
    if (date is Timestamp) {
      return date.toDate();
    } else if (date is String) {
      return DateTime.tryParse(date);
    }
    return null;
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
              FirebaseFirestore.instance
                  .collection('works')
                  .doc(data.id)
                  .delete()
                  .then((_) {
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
    var querySnapshot =
        await FirebaseFirestore.instance.collection("employees").get();
    List<String> employees = [];
    for (var doc in querySnapshot.docs) {
      employees.add(doc.get('empName'));
    }
    return employees;
  }

  void _addNewWork(BuildContext context) {
    // Focus nodes for matiWeight and designWeight
    final FocusNode matiWeightFocusNode = FocusNode();
    final FocusNode designWeightFocusNode = FocusNode();

    // Call this method to update netWeight based on matiWeight and designWeight
    void updateNetWeight() {
      final matiWeightValue = int.tryParse(matiWeight.text) ?? 0;
      final designWeightValue = int.tryParse(designWeight.text) ?? 0;
      final netWeightValue = matiWeightValue + designWeightValue;
      // Only update netWeight if it changes
      if (netWeight.text != netWeightValue.toString()) {
        netWeight.text = netWeightValue.toString();
      }
    }

    // Set up listeners to update netWeight when both fields lose focus
    void setupFocusListeners() {
      matiWeightFocusNode.addListener(() {
        if (!matiWeightFocusNode.hasFocus) {
          // Update netWeight when matiWeight loses focus
          updateNetWeight();
        }
      });

      designWeightFocusNode.addListener(() {
        if (!designWeightFocusNode.hasFocus) {
          // Update netWeight when designWeight loses focus
          updateNetWeight();
        }
      });
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(
          "Add New Work",
          textAlign: TextAlign.center,
        ),
        content: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            setupFocusListeners(); // Setup listeners when dialog opens

            return SingleChildScrollView(
              child: FutureBuilder<List<String>>(
                future:
                    _getEmployees(), // Replace this with your actual method to get employees
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
                                labelText: 'नाव ',
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
                                labelText: 'शिक्का ',
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
                                labelText: 'कॅटेगरी ',
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
                              controller: matiWeight,
                              focusNode: matiWeightFocusNode,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                labelText: 'माटी  वजन ',
                              ),
                              keyboardType: TextInputType.number,
                              // Remove onChanged handler since we use focus node instead
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter the Mati weight';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 10),
                            TextFormField(
                              controller: designWeight,
                              focusNode: designWeightFocusNode,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                labelText: 'डिझाईन वजन ',
                              ),
                              keyboardType: TextInputType.number,
                              // Remove onChanged handler since we use focus node instead
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter the design weight';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 10),
                            TextFormField(
                              controller: netWeight,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                labelText: 'नेट वजन ',
                              ),
                              keyboardType: TextInputType.number,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter the net weight';
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
                            TextFormField(
                              controller: note,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                                labelText: 'Note',
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
                  'assignDate': assignDate.toIso8601String(),
                  'empName': empName ?? 'N/A',
                  'shikka': shikka.text.isNotEmpty ? shikka.text : 'N/A',
                  'category': category.text.isNotEmpty ? category.text : 'N/A',
                  'matiWeight': int.tryParse(matiWeight.text) ?? 0, // You might want to use 0 instead of 'N/A' for numeric values
                  'designWeight': int.tryParse(designWeight.text) ?? 0,
                  'netWeight': int.tryParse(netWeight.text) ?? 0,
                  'submitDate': submitDate?.toIso8601String() ?? 'N/A',
                  'submitWeight': int.tryParse(submitWeight.text) ?? 0,
                  'workDone': workDone, // Assuming `false` is a suitable default value for boolean fields
                  'amount': amount.text.isNotEmpty ? amount.text : 'N/A',
                  'paymentDone': paymentDone,
                  'paymentDate': paymentDate?.toIso8601String() ?? 'N/A',
                  'note': note.text.isNotEmpty ? note.text : 'N/A',
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
      backgroundColor: Colors.white,
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
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
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
      amount.clear();
      category.clear();
      designWeight.clear();
      matiWeight.clear();
      netWeight.clear();
      submitWeight.clear();
      assignDate = DateTime.now();
      submitDate = null;
      paymentDate = null;
      workDone = false;
      paymentDone = false;
      note.clear();
    });
  }
}
