import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isDarkTheme = false;

  void _toggleTheme(bool isDark) {
    setState(() {
      _isDarkTheme = isDark;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: _isDarkTheme ? ThemeData.dark() : ThemeData.light(),
      home: MainPage(onThemeChanged: _toggleTheme),
    );
  }
}

class MainPage extends StatefulWidget {
  final Function(bool) onThemeChanged;

  MainPage({required this.onThemeChanged});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    AttendancePage(),
    AssignmentsPage(),
    ExamsPage(),
    ToDoPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student Organizer', style: TextStyle(fontSize: 24.0)),
        actions: [
          IconButton(
            icon: Icon(Theme.of(context).brightness == Brightness.dark
                ? Icons.wb_sunny
                : Icons.nights_stay),
            onPressed: () {
              widget.onThemeChanged(
                  Theme.of(context).brightness == Brightness.light);
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              child: Text('Navigation', style: TextStyle(fontSize: 24.0, color: Colors.white)),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
            ),
            _buildDrawerItem(Icons.school, 'Attendance', 0),
            _buildDrawerItem(Icons.assignment, 'Assignments', 1),
            _buildDrawerItem(Icons.event, 'Exams', 2),
            _buildDrawerItem(Icons.list, 'To-Do', 3),
          ],
        ),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.school), label: 'Attendance'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment), label: 'Assignments'),
          BottomNavigationBarItem(icon: Icon(Icons.event), label: 'Exams'),
          BottomNavigationBarItem(icon: Icon(Icons.list), label: 'To-Do'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).primaryColor,
        onTap: _onItemTapped,
      ),
    );
  }

  ListTile _buildDrawerItem(IconData icon, String title, int index) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        _onItemTapped(index);
        Navigator.pop(context);
      },
    );
  }
}

class AttendancePage extends StatefulWidget {
  @override
  _AttendancePageState createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  Map<String, Map<String, int>> attendance = {
    'Math': {'present': 0, 'absent': 0},
    'Science': {'present': 0, 'absent': 0},
    'English': {'present': 0, 'absent': 0},
    'History': {'present': 0, 'absent': 0},
    'Geography': {'present': 0, 'absent': 0},
  };

  Map<String, List<Map<String, dynamic>>> attendanceLogs = {
    'Math': [],
    'Science': [],
    'English': [],
    'History': [],
    'Geography': [],
  };

  void _updateAttendance(String subject, String status) {
    DateTime now = DateTime.now();
    setState(() {
      attendance[subject]?[status] = (attendance[subject]?[status] ?? 0) + 1;
      attendanceLogs[subject]?.add({'status': status, 'date': now});
    });
  }

  double _calculateAttendancePercentage(String subject) {
    int present = attendance[subject]?['present'] ?? 0;
    int absent = attendance[subject]?['absent'] ?? 0;
    int total = present + absent;
    return total > 0 ? (present / total) * 100 : 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        children: attendance.keys.map((subject) {
          double attendancePercentage = _calculateAttendancePercentage(subject);
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AttendanceLogPage(
                    subject: subject,
                    present: attendance[subject]?['present'] ?? 0,
                    absent: attendance[subject]?['absent'] ?? 0,
                    attendancePercentage: attendancePercentage,
                    attendanceLog: attendanceLogs[subject] ?? [],
                  ),
                ),
              );
            },
            child: Card(
              margin: EdgeInsets.all(8.0),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      subject,
                      style: TextStyle(
                        fontSize: 22.0,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    SizedBox(height: 10.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: () => _updateAttendance(subject, 'present'),
                          child: Text('Present'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:Colors.green,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () => _updateAttendance(subject, 'absent'),
                          child: Text('Absent'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.0),
                    LinearProgressIndicator(
                      value: attendancePercentage / 100,
                      backgroundColor: Colors.red,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                    ),
                    SizedBox(height: 5.0),
                    Text('Attendance: ${attendancePercentage.toStringAsFixed(2)}%'),
                    Text('Present: ${attendance[subject]?['present'] ?? 0}'),
                    Text('Absent: ${attendance[subject]?['absent'] ?? 0}'),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class AttendanceLogPage extends StatelessWidget {
  final String subject;
  final int present;
  final int absent;
  final double attendancePercentage;
  final List<Map<String, dynamic>> attendanceLog;

  AttendanceLogPage({
    required this.subject,
    required this.present,
    required this.absent,
    required this.attendancePercentage,
    required this.attendanceLog,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('$subject Attendance Log'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Subject: $subject',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10.0),
            Text('Present: $present', style: TextStyle(color: Colors.green)),
            Text('Absent: $absent', style: TextStyle(color: Colors.red)),
            SizedBox(height: 10.0),
            LinearProgressIndicator(
              value: attendancePercentage / 100,
              backgroundColor: Colors.red,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
            ),
            SizedBox(height: 5.0),
            Text('Attendance: ${attendancePercentage.toStringAsFixed(2)}%'),
            SizedBox(height: 20.0),
            Text(
              'Attendance Log:',
              style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10.0),
            Expanded(
              child: ListView.builder(
                itemCount: attendanceLog.length,
                itemBuilder: (context, index) {
                  Map<String, dynamic> entry = attendanceLog[index];
                  String status = entry['status'];
                  DateTime date = entry['date'];
                  Color statusColor = status == 'present' ? Colors.green : Colors.red;

                  return ListTile(
                    leading: Icon(
                      status == 'present' ? Icons.check_circle : Icons.cancel,
                      color: statusColor,
                    ),
                    title: Text(DateFormat('yyyy-MM-dd – kk:mm').format(date)),
                    subtitle: Text('Status: $status', style: TextStyle(color: statusColor)),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AssignmentsPage extends StatefulWidget {
  @override
  _AssignmentsPageState createState() => _AssignmentsPageState();
}
class _AssignmentsPageState extends State<AssignmentsPage> {
  final List<Map<String, dynamic>> assignments = [];

  void _addAssignment(String title, String shortDescription, DateTime dueDate) {
    setState(() {
      assignments.add({
        'title': title,
        'shortDescription': shortDescription,
        'dueDate': dueDate,
        'longDescription': '',
      });
      assignments.sort((a, b) => a['dueDate'].compareTo(b['dueDate']));
    });
  }

  void _deleteAssignment(int index) {
    setState(() {
      assignments.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Assignments',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: assignments.length,
              itemBuilder: (context, index) {
                final assignment = assignments[index];
                return ListTile(
                  title: Text(assignment['title']),
                  subtitle: Text(assignment['shortDescription']),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteAssignment(index),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AssignmentDetailPage(
                          title: assignment['title'],
                          shortDescription: assignment['shortDescription'],
                          dueDate: assignment['dueDate'],
                          longDescription: assignment['longDescription'],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          final result = await showDialog(
            context: context,
            builder: (context) => AddAssignmentDialog(),
          );
          if (result != null) {
            _addAssignment(result['title'], result['shortDescription'], result['dueDate']);
          }
        },
      ),
    );
  }
}

class AddAssignmentDialog extends StatefulWidget {
  @override
  _AddAssignmentDialogState createState() => _AddAssignmentDialogState();
}

class _AddAssignmentDialogState extends State<AddAssignmentDialog> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _shortDescriptionController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Assignment'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _titleController,
            decoration: InputDecoration(labelText: 'Title'),
          ),
          TextField(
            controller: _shortDescriptionController,
            decoration: InputDecoration(labelText: 'Short Description'),
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Text('Due Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}'),
              IconButton(
                icon: Icon(Icons.calendar_today),
                onPressed: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (picked != null) {
                    setState(() {
                      _selectedDate = picked;
                    });
                  }
                },
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop({
              'title': _titleController.text,
              'shortDescription': _shortDescriptionController.text,
              'dueDate': _selectedDate,
            });
          },
          child: Text('Add'),
        ),
      ],
    );
  }
}

class AssignmentDetailPage extends StatelessWidget {
  final String title;
  final String shortDescription;
  final DateTime dueDate;
  final String longDescription;

  AssignmentDetailPage({
    required this.title,
    required this.shortDescription,
    required this.dueDate,
    required this.longDescription,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Assignment Details'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Title: $title',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10.0),
            Text('Due Date: ${DateFormat('yyyy-MM-dd').format(dueDate)}'),
            SizedBox(height: 10.0),
            Text('Short Description: $shortDescription'),
            SizedBox(height: 20.0),
            // Text(
            //   'Long Description:',
            //   style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            // ),
            // SizedBox(height: 10.0),


          ],
        ),
      ),
    );
  }
}

class ExamsPage extends StatefulWidget {
  @override
  _ExamsPageState createState() => _ExamsPageState();
}

class _ExamsPageState extends State<ExamsPage> {
  final List<Map<String, dynamic>> exams = [];

  void _addExam(String title, DateTime date) {
    setState(() {
      exams.add({
        'title': title,
        'date': date,
      });
      exams.sort((a, b) => a['date'].compareTo(b['date']));
    });
  }

  void _deleteExam(int index) {
    setState(() {
      exams.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Exams',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: exams.length,
              itemBuilder: (context, index) {
                final exam = exams[index];
                return ListTile(
                  title: Text(exam['title']),
                  subtitle: Text('Date: ${DateFormat('yyyy-MM-dd').format(exam['date'])}'),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _deleteExam(index),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          final result = await showDialog(
            context: context,
            builder: (context) => AddExamDialog(),
          );
          if (result != null) {
            _addExam(result['title'], result['date']);
          }
        },
      ),
    );
  }
}


class AddExamDialog extends StatefulWidget {
  @override
  _AddExamDialogState createState() => _AddExamDialogState();
}

class _AddExamDialogState extends State<AddExamDialog> {
  final TextEditingController _titleController = TextEditingController();
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add Exam'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _titleController,
            decoration: InputDecoration(labelText: 'Title'),
          ),
          SizedBox(height: 10),
          Row(
            children: [
              Text('Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}'),
              IconButton(
                icon: Icon(Icons.calendar_today),
                onPressed: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (picked != null) {
                    setState(() {
                      _selectedDate = picked;
                    });
                  }
                },
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop({
              'title': _titleController.text,
              'date': _selectedDate,
            });
          },
          child: Text('Add'),
        ),
      ],
    );
  }
}

class ToDoPage extends StatefulWidget {
  @override
  _ToDoPageState createState() => _ToDoPageState();
}
class _ToDoPageState extends State<ToDoPage> {
  final List<Map<String, dynamic>> toDoList = [];

  void _addToDoItem(String title) {
    setState(() {
      toDoList.add({
        'title': title,
        'completed': false,
      });
    });
  }

  void _toggleCompletion(int index) {
    setState(() {
      toDoList[index]['completed'] = !toDoList[index]['completed'];
    });
  }

  void _deleteToDoItem(int index) {
    setState(() {
      toDoList.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'To-Do List',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: toDoList.length,
              itemBuilder: (context, index) {
                final item = toDoList[index];
                return ListTile(
                  title: Text(
                    item['title'],
                    style: TextStyle(
                      decoration: item['completed'] ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(
                          item['completed'] ? Icons.check_circle : Icons.check_circle_outline,
                          color: item['completed'] ? Colors.green : null,
                        ),
                        onPressed: () => _toggleCompletion(index),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteToDoItem(index),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () async {
          final result = await showDialog(
            context: context,
            builder: (context) => AddToDoDialog(),
          );
          if (result != null) {
            _addToDoItem(result['title']);
          }
        },
      ),
    );
  }
}


class AddToDoDialog extends StatefulWidget {
  @override
  _AddToDoDialogState createState() => _AddToDoDialogState();
}

class _AddToDoDialogState extends State<AddToDoDialog> {
  final TextEditingController _titleController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add To-Do Item'),
      content: TextField(
        controller: _titleController,
        decoration: InputDecoration(labelText: 'Title'),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop({
              'title': _titleController.text,
            });
          },
          child: Text('Add'),
        ),
      ],
    );
  }
}