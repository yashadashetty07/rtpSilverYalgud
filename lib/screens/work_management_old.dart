// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:rtp_silver_yalgud /models/work.dart';
// import 'package:rtp_silver_yalgud /screens/employee_management.dart';
// import 'package:rtp_silver_yalgud /screens/home_page.dart';
// import 'package:rtp_silver_yalgud /services/emp_database_service.dart';
// import 'package:rtp_silver_yalgud /services/work_database_service.dart';
// import 'package:pdf/widgets.dart' as pw;
//
// class WorkManagementOld extends StatefulWidget {
//   const WorkManagementOld({super.key});
//
//   @override
//   _WorkManagementOldState createState() => _WorkManagementOldState();
// }
//
// class _WorkManagementOldState extends State<WorkManagementOld> {
//   String? selectedEmployee;
//   String? selectedCategory;
//   String? selectedShikka;
//   final weightController = TextEditingController();
//   final searchController = TextEditingController();
//   final _formKey = GlobalKey<FormState>();
//   DateTime selectedDate = DateTime.now();
//
//   final WorkDatabaseService _workdatabaseService = WorkDatabaseService.instance;
//   final EmpDatabaseService _empDatabaseService = EmpDatabaseService.instance;
//
//   bool _isMultiSelectMode = false;
//   final Set<int> _selectedWorks = <int>{};
//   String _searchTerm = '';
//   String _sortCriteria = 'date';
//   bool _sortAscending = true;
//
//   Future<void> _selectDate(BuildContext context) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: selectedDate,
//       firstDate: DateTime(2000),
//       lastDate: DateTime(2101),
//     );
//     if (picked != null && picked != selectedDate) {
//       setState(() {
//         selectedDate = picked;
//       });
//     }
//   }
//
//   Future<List<String>> _getEmployees() async {
//     final employees = await _empDatabaseService.getEmployees();
//     return employees.map((e) => e.name).toList();
//   }
//
//   void _refreshWorkList() {
//     setState(() {});
//   }
//
//   void _onSearchTextChanged(String text) {
//     setState(() {
//       _searchTerm = text.toLowerCase();
//     });
//   }
//
//   void _onSortCriteriaChanged(String criteria) {
//     setState(() {
//       if (_sortCriteria == criteria) {
//         _sortAscending = !_sortAscending;
//       } else {
//         _sortCriteria = criteria;
//         _sortAscending = true;
//       }
//     });
//   }
//
//   Future<void> _generatePdf() async {
//     final pdf = pw.Document();
//
//     final works = await _workdatabaseService.getWorks();
//     final selectedWorksList = _selectedWorks.toList();
//
//     pdf.addPage(pw.MultiPage(
//       build: (context) => [
//         pw.Header(level: 0, child: pw.Text('Selected Works')),
//         for (var index in selectedWorksList)
//           pw.Container(
//             margin: const pw.EdgeInsets.all(10),
//             child: pw.Column(
//               crossAxisAlignment: pw.CrossAxisAlignment.start,
//               children: [
//                 pw.Text('Employee Name: ${works[index].employeeName}'),
//                 pw.Text('Category: ${works[index].category}'),
//                 pw.Text('Weight: ${works[index].weight} kg'),
//                 pw.Text('Date: ${works[index].date.toIso8601String()}'),
//                 pw.Divider(),
//               ],
//             ),
//           ),
//       ],
//     ));
//
//     final output = await getExternalStorageDirectory();
//     final file = File('${output!.path}/selected_works.pdf');
//     await file.writeAsBytes(await pdf.save());
//
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('PDF generated and saved')),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       floatingActionButton: _isMultiSelectMode ? _deleteSelectedButton() : _addWorkButton(),
//       body: Column(
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: TextField(
//               controller: searchController,
//               decoration: InputDecoration(
//                 labelText: 'Search',
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(5),
//                 ),
//                 suffixIcon: IconButton(
//                   icon: const Icon(Icons.clear),
//                   onPressed: () {
//                     searchController.clear();
//                     _onSearchTextChanged('');
//                   },
//                 ),
//               ),
//               onChanged: _onSearchTextChanged,
//             ),
//           ),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//             children: [
//               _buildSortButton('Date', 'date'),
//               _buildSortButton('Employee', 'employeeName'),
//               _buildSortButton('Category', 'category'),
//             ],
//           ),
//           Expanded(child: _worksList()),
//         ],
//       ),
//     );
//   }
//
//   Widget _addWorkButton() {
//     return FloatingActionButton(
//       onPressed: () {
//         showDialog(
//           context: context,
//           builder: (_) => AlertDialog(
//             title: const Text(
//               "Assign Work",
//               textAlign: TextAlign.center,
//             ),
//             content: StatefulBuilder(
//               builder: (BuildContext context, StateSetter setState) {
//                 return SingleChildScrollView(
//                   child: FutureBuilder<List<String>>(
//                     future: _getEmployees(),
//                     builder: (context, snapshot) {
//                       if (snapshot.connectionState == ConnectionState.waiting) {
//                         return const CircularProgressIndicator();
//                       } else if (snapshot.hasError) {
//                         return Text('Error: ${snapshot.error}');
//                       } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
//                         return const Text('No employees available');
//                       } else {
//                         List<String> employees = snapshot.data!;
//                         return Form(
//                           key: _formKey,
//                           child: Column(
//                             mainAxisSize: MainAxisSize.min,
//                             crossAxisAlignment: CrossAxisAlignment.stretch,
//                             children: [
//                               DropdownButtonFormField<String>(
//                                 value: selectedEmployee,
//                                 decoration: InputDecoration(
//                                   border: OutlineInputBorder(
//                                     borderRadius: BorderRadius.circular(5),
//                                   ),
//                                   labelText: 'Select Employee',
//                                 ),
//                                 items: employees.map((employee) {
//                                   return DropdownMenuItem<String>(
//                                     value: employee,
//                                     child: Text(employee),
//                                   );
//                                 }).toList(),
//                                 onChanged: (String? newValue) {
//                                   setState(() {
//                                     selectedEmployee = newValue;
//                                   });
//                                 },
//                                 validator: (value) {
//                                   if (value == null || value.isEmpty) {
//                                     return 'Please select an employee';
//                                   }
//                                   return null;
//                                 },
//                               ),
//                               const SizedBox(height: 10),
//                               DropdownButtonFormField<String>(
//                                 value: selectedShikka,
//                                 decoration: InputDecoration(
//                                   border: OutlineInputBorder(
//                                     borderRadius: BorderRadius.circular(5),
//                                   ),
//                                   labelText: 'Select Shikka',
//                                 ),
//                                 items: ['s1', 's2', 's3'].map((shikka) {
//                                   return DropdownMenuItem<String>(
//                                     value: shikka,
//                                     child: Text(shikka),
//                                   );
//                                 }).toList(),
//                                 onChanged: (String? newValue) {
//                                   setState(() {
//                                     selectedShikka = newValue;
//                                   });
//                                 },
//                                 validator: (value) {
//                                   if (value == null || value.isEmpty) {
//                                     return 'Please select a shikka';
//                                   }
//                                   return null;
//                                 },
//                               ),
//                               const SizedBox(height: 10),
//                               DropdownButtonFormField<String>(
//                                 value: selectedCategory,
//                                 decoration: InputDecoration(
//                                   border: OutlineInputBorder(
//                                     borderRadius: BorderRadius.circular(5),
//                                   ),
//                                   labelText: 'Select Category',
//                                 ),
//                                 items: ['Category 1', 'Category 2', 'Category 3'].map((category) {
//                                   return DropdownMenuItem<String>(
//                                     value: category,
//                                     child: Text(category),
//                                   );
//                                 }).toList(),
//                                 onChanged: (String? newValue) {
//                                   setState(() {
//                                     selectedCategory = newValue;
//                                   });
//                                 },
//                                 validator: (value) {
//                                   if (value == null || value.isEmpty) {
//                                     return 'Please select a category';
//                                   }
//                                   return null;
//                                 },
//                               ),
//                               const SizedBox(height: 10),
//                               TextFormField(
//                                 controller: weightController,
//                                 decoration: InputDecoration(
//                                   border: OutlineInputBorder(
//                                     borderRadius: BorderRadius.circular(5),
//                                   ),
//                                   labelText: 'Enter Weight',
//                                 ),
//                                 keyboardType: TextInputType.number,
//                                 validator: (value) {
//                                   if (value == null || value.isEmpty) {
//                                     return 'Please enter the weight';
//                                   }
//                                   return null;
//                                 },
//                               ),
//                               const SizedBox(height: 10),
//                               Row(
//                                 children: [
//                                   Expanded(
//                                     child: Text(
//                                       "${selectedDate.toLocal()}".split(' ')[0],
//                                       style: const TextStyle(fontSize: 16),
//                                     ),
//                                   ),
//                                   const SizedBox(width: 20.0),
//                                   ElevatedButton(
//                                     onPressed: () => _selectDate(context),
//                                     child: const Text('Select date'),
//                                   ),
//                                 ],
//                               ),
//                               const SizedBox(height: 20),
//                               ElevatedButton(
//                                 onPressed: () async {
//                                   if (_formKey.currentState!.validate()) {
//                                     final newWork = Work(
//                                       employeeName: selectedEmployee!,
//                                       shikka: selectedShikka!,
//                                       category: selectedCategory!,
//                                       weight: double.parse(weightController.text),
//                                       date: selectedDate,
//                                       taskAddingTime: DateTime.now(),
//                                     );
//
//                                     await _workdatabaseService.addWork(newWork);
//
//                                     ScaffoldMessenger.of(context).showSnackBar(
//                                       const SnackBar(content: Text('Work Assigned')),
//                                     );
//
//                                     setState(() {
//                                       selectedEmployee = null;
//                                       selectedShikka = null;
//                                       selectedCategory = null;
//                                       weightController.clear();
//                                       selectedDate = DateTime.now();
//                                     });
//
//                                     Navigator.pop(context);
//                                     _refreshWorkList(); // Refresh the list after adding a new work
//                                   }
//                                 },
//                                 child: const Text('Assign Work'),
//                               ),
//                             ],
//                           ),
//                         );
//                       }
//                     },
//                   ),
//                 );
//               },
//             ),
//           ),
//         );
//       },
//       child: const Icon(Icons.add),
//     );
//   }
//
//   Widget _deleteSelectedButton() {
//     return FloatingActionButton(
//       onPressed: _deleteSelectedWorks,
//       backgroundColor: Colors.red,
//       child: const Icon(Icons.delete),
//     );
//   }
//
//   Widget _worksList() {
//     return FutureBuilder<List<Work>>(
//       future: _workdatabaseService.getWorks(),
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Center(
//             child: CircularProgressIndicator(),
//           );
//         } else if (snapshot.hasError) {
//           return Center(
//             child: Text('Error: ${snapshot.error}'),
//           );
//         } else if (!snapshot.hasData || snapshot.data == null || snapshot.data!.isEmpty) {
//           return const Center(
//             child: Text('No works available'),
//           );
//         } else {
//           List<Work> works = snapshot.data!;
//           works = works.where((work) {
//             return work.employeeName.toLowerCase().contains(_searchTerm) ||
//                 work.category.toLowerCase().contains(_searchTerm) ||
//                 work.shikka.toLowerCase().contains(_searchTerm);
//           }).toList();
//           works.sort((a, b) {
//             int comparison = 0;
//             switch (_sortCriteria) {
//               case 'date':
//                 comparison = a.date.compareTo(b.date);
//                 break;
//               case 'employeeName':
//                 comparison = a.employeeName.compareTo(b.employeeName);
//                 break;
//               case 'category':
//                 comparison = a.category.compareTo(b.category);
//                 break;
//             }
//             return _sortAscending ? comparison : -comparison;
//           });
//           return Column(
//             children: [
//               ElevatedButton(
//                 onPressed: _selectedWorks.isEmpty ? null : _generatePdf,
//                 child: const Text('Export Selected as PDF'),
//               ),
//               Expanded(
//                 child: ListView.builder(
//                   itemCount: works.length,
//                   itemBuilder: (context, index) {
//                     Work work = works[index];
//                     bool isSelected = _selectedWorks.contains(index);
//                     return ListTile(
//                       tileColor: isSelected ? Colors.grey[300] : null,
//                       title: Text(work.employeeName),
//                       subtitle: Text(work.category),
//                       trailing: Text('${work.weight} kg'),
//                       onTap: () {
//                         if (_isMultiSelectMode) {
//                           setState(() {
//                             if (isSelected) {
//                               _selectedWorks.remove(index);
//                             } else {
//                               _selectedWorks.add(index);
//                             }
//                           });
//                         }
//                       },
//                       onLongPress: () {
//                         setState(() {
//                           _isMultiSelectMode = !_isMultiSelectMode;
//                           if (_isMultiSelectMode) {
//                             _selectedWorks.add(index);
//                           } else {
//                             _selectedWorks.clear();
//                           }
//                         });
//                       },
//                     );
//                   },
//                 ),
//               ),
//             ],
//           );
//         }
//       },
//     );
//   }
//
//   Widget _buildSortButton(String title, String criteria) {
//     return ElevatedButton(
//       onPressed: () => _onSortCriteriaChanged(criteria),
//       child: Row(
//         children: [
//           Text(title),
//           if (_sortCriteria == criteria)
//             Icon(_sortAscending ? Icons.arrow_upward : Icons.arrow_downward),
//         ],
//       ),
//     );
//   }
//
//   void _deleteSelectedWorks() async {
//     final works = await _workdatabaseService.getWorks();
//     final selectedWorksList = _selectedWorks.toList();
//     selectedWorksList.sort((b, a) => a.compareTo(b)); // Sort in descending order
//
//     for (var index in selectedWorksList) {
//       await _workdatabaseService.deleteWork(works[index].id!);
//     }
//
//     setState(() {
//       _selectedWorks.clear();
//       _isMultiSelectMode = false;
//     });
//
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('Selected works deleted')),
//     );
//     _refreshWorkList();
//   }
// }
//
// class MainPage extends StatefulWidget {
//   const MainPage({super.key});
//
//   @override
//   _MainPageState createState() => _MainPageState();
// }
//
// class _MainPageState extends State<MainPage> {
//   int _selectedIndex = 0;
//
//   static final List<Widget> _widgetOptions = <Widget>[
//     const HomePage(),
//     const EmployeeManagement(),
//     const WorkManagementOld(),
//   ];
//
//   void _onItemTapped(int index) {
//     setState(() {
//       _selectedIndex = index;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: _widgetOptions.elementAt(_selectedIndex),
//       bottomNavigationBar: BottomNavigationBar(
//         items: const <BottomNavigationBarItem>[
//           BottomNavigationBarItem(
//             icon: Icon(Icons.home),
//             label: 'Home',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.person),
//             label: 'Employee Management',
//           ),
//           BottomNavigationBarItem(
//             icon: Icon(Icons.work),
//             label: 'Works Management',
//           ),
//         ],
//         currentIndex: _selectedIndex,
//         selectedItemColor: Colors.cyanAccent,
//         onTap: _onItemTapped,
//       ),
//     );
//   }
// }
