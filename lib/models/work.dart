class Works {
  int? id;
  String empName;
  String shikka;
  String category;
  double assignWeight;
  double submitWeight;
  DateTime assignDate;
  DateTime submitDate;
  bool workDone = false;
  String? msg;

  Works({
    this.msg,
    this.id,
    required this.empName,
    required this.shikka,
    required this.category,
    required this.assignDate,
    required this.submitDate,
    required this.assignWeight,
    required this.submitWeight,
    required this.workDone,
  });

  // Convert a Works object into a Map object
  Map<String, dynamic> toMap() {
    return {
      'msg':msg,
      'id': id,
      'empName': empName,
      'shikka': shikka,
      'category': category,
      'assignWeight': assignWeight,
      'assignDate': assignDate.toString(), // Convert DateTime to a string
      'submitWeight':assignWeight,
      'submitDate': submitDate.toString(), // Convert DateTime to a string
      'workDone':workDone,
    };
  }

  // Convert a Map object into a Works object
  factory Works.fromMap(Map<String, dynamic> map) {
    return Works(
      id: map['id'],
      empName: map['empName'],
      shikka: map['shikka'],
      category: map['category'],
      assignWeight: map['assignWeight'],
      assignDate: map['assignDate'],
      workDone: map['workDone'],
      submitDate: map['submitDate'],
      submitWeight: map['submitWeight']
    );
  }
}
