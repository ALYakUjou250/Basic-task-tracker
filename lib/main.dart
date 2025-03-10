import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => TaskProvider(),
      child: TaskTrackerApp(),
    ),
  );
}

class TaskTrackerApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TASK TRACKER',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        scaffoldBackgroundColor: Colors.grey[100], // Light background
      ),
      home: TaskListScreen(),
    );
  }
}

class Task {
  String name;
  String description;
  DateTime deadline;
  bool isCompleted;

  Task({required this.name, required this.description, required this.deadline, this.isCompleted = false});
}

class TaskProvider with ChangeNotifier {
  List<Task> tasks = [];
  List<Task> doneTasks = [];
  List<Task> archivedTasks = [];

  void addTask(String name, String description, DateTime deadline) {
    tasks.add(Task(name: name, description: description, deadline: deadline));
    notifyListeners();
  }

  void deleteTask(Task task) {
    archivedTasks.add(task);
    tasks.remove(task);
    doneTasks.remove(task);
    notifyListeners();
  }

  void toggleCompletion(Task task) {
    task.isCompleted = !task.isCompleted;
    if (task.isCompleted) {
      doneTasks.add(task);
      tasks.remove(task);
    } else {
      tasks.add(task);
      doneTasks.remove(task);
    }
    notifyListeners();
  }
}

class TaskListScreen extends StatelessWidget {
  final String currentPage = 'Current Tasks';  // Track which page is active

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     appBar: AppBar(
  title: Text(
    'BASIC TASK TRACKER',
    style: TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      letterSpacing: 1.2,  // Add letter spacing for a modern look
    ),
  ),
  backgroundColor: Colors.blueAccent,
  flexibleSpace: Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [Colors.blue.shade500, Colors.purple.shade600],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
    ),
  ),
),

 drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue, Colors.purple],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Text(
                'TASK OPTIONS',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            // Conditionally render menu items based on current page
            if (currentPage == 'Current Tasks') ...[
              ListTile(
                leading: Icon(Icons.check_circle, color: Colors.green),
                title: Text('Done Tasks'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DoneTasksPage(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.archive, color: Colors.orange),
                title: Text('Archived Tasks'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ArchivedTasksPage(),
                    ),
                  );
                },
              ),
            ] else if (currentPage == 'Done Tasks') ...[
              ListTile(
                leading: Icon(Icons.task, color: Colors.blue),
                title: Text('Current Tasks'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => TaskListScreen()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.archive, color: Colors.orange),
                title: Text('Archived Tasks'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ArchivedTasksPage(),
                    ),
                  );
                },
              ),
            ] else if (currentPage == 'Archived Tasks') ...[
              ListTile(
                leading: Icon(Icons.task, color: Colors.blue),
                title: Text('Current Tasks'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => TaskListScreen()),
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.check_circle, color: Colors.green),
                title: Text('Done Tasks'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DoneTasksPage(),
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
      body: Consumer<TaskProvider>(
  builder: (context, taskProvider, child) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color.fromARGB(255, 18, 37, 50), 
            const Color.fromARGB(255, 118, 45, 129)
          ], 
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: ListView.builder(
        padding: EdgeInsets.all(15),
        itemCount: taskProvider.tasks.length,
        itemBuilder: (context, index) {
          final task = taskProvider.tasks[index];
          return AnimatedContainer(
            duration: Duration(milliseconds: 300),
            margin: EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(color: Colors.black26, blurRadius: 5, spreadRadius: 2)
              ],
              gradient: LinearGradient(
                colors: task.isCompleted
                    ? [Colors.green.shade400, Colors.green.shade700]
                    : [Colors.white, Colors.blue.shade100],
              ),
            ),
            child: ListTile(
              contentPadding: EdgeInsets.all(15),
              leading: Icon(
                task.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                color: task.isCompleted ? Colors.white : Colors.grey.shade700,
                size: 30,
              ),
              title: Text(
                task.name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: task.isCompleted ? Colors.white : Colors.black87,
                ),
              ),
              subtitle: Text(
                'Deadline: ${DateFormat('yyyy-MM-dd').format(task.deadline)}',
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  color: task.isCompleted ? Colors.white70 : Colors.black54,
                ),
              ),
              onTap: () => _showTaskDetails(context, task),
              trailing: IconButton(
                icon: Icon(Icons.delete, color: Colors.red.shade700),
                onPressed: () {
                  // Delete the task and show the Snackbar
                  taskProvider.deleteTask(task);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Successfully Deleted'),
                      backgroundColor: const Color.fromARGB(255, 255, 0, 0),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  },
),


      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _openTaskDialog(context);
        },
         child: Icon(Icons.add, color: Colors.white),
  backgroundColor: Colors.blueAccent,  // Custom background color
  elevation: 10.0, // Add some elevation
  tooltip: 'Add New Task',
  hoverElevation: 20.0,  // Hover effect for added interactivity
  focusElevation: 15.0,  // Focus effect for accessibility
      ),
    );
  }

  void openTaskDialog(BuildContext context) {
  final TextEditingController taskController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  DateTime? selectedDate;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Create Task'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: taskController,
              decoration: InputDecoration(
                labelText: 'Task Name',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 10),
              ),
            ),
            SizedBox(height: 10),
            TextField(
              controller: descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 10),
              ),
            ),
            SizedBox(height: 10),
            ListTile(
              title: Text(selectedDate == null
                  ? 'Select Deadline'
                  : 'Deadline: ${DateFormat('yyyy-MM-dd').format(selectedDate!)}'),
              trailing: Icon(Icons.calendar_today),
              onTap: () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2101),
                );
                if (picked != null && picked != selectedDate) {
                  selectedDate = picked;
                }
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            child: Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: Text('Save'),
            onPressed: () {
              if (taskController.text.isNotEmpty && descriptionController.text.isNotEmpty && selectedDate != null) {
                // Add task to the task provider
                Provider.of<TaskProvider>(context, listen: false)
                    .addTask(taskController.text, descriptionController.text, selectedDate!);

                // Close the dialog
                Navigator.of(context).pop();

                // Show success SnackBar
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Task added successfully!'),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            },
          ),
        ],
      );
    },
  );
}

  
  void _openTaskDialog(BuildContext context) {
  final TextEditingController taskController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  DateTime? selectedDate;

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        title: Text(
          'Create Task',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueAccent),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Task Name TextField
              TextField(
                controller: taskController,
                decoration: InputDecoration(
                  labelText: 'Task Name',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                  ),
                ),
              ),
              SizedBox(height: 15),

              // Description TextField
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.blueAccent, width: 2),
                  ),
                ),
              ),
              SizedBox(height: 15),

              // Deadline Picker
              GestureDetector(
                onTap: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (picked != null && picked != selectedDate) {
                    selectedDate = picked;
                  }
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blueAccent, width: 1),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, color: Colors.blueAccent),
                      SizedBox(width: 10),
                      Text(
                        selectedDate == null
                            ? 'Select Deadline'
                            : 'Deadline: ${DateFormat('yyyy-MM-dd').format(selectedDate!)}',
                        style: TextStyle(color: Colors.blueAccent),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          // Cancel Button
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: Colors.grey.shade300,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.black),
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          SizedBox(width: 10),
          // Save Button
          TextButton(
            style: TextButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Save',
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () {
              if (taskController.text.isNotEmpty && descriptionController.text.isNotEmpty && selectedDate != null) {
                Provider.of<TaskProvider>(context, listen: false)
                    .addTask(taskController.text, descriptionController.text, selectedDate!);
                Navigator.of(context).pop();
               

                // Show success SnackBar
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Task added successfully!'),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 2),
                ),
                );
              }
            },
          ),
        ],
      );
    },
  );
}


  void _showTaskDetails(BuildContext context, Task task) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(task.name),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Deadline: ${DateFormat('yyyy-MM-dd').format(task.deadline)}'),
              SizedBox(height: 10),
              Text('Description: ${task.description}'),
            ],
          ),
          actions: [
            if (!task.isCompleted)
              TextButton(
                child: Text('Mark as Done'),
                onPressed: () {
                  Provider.of<TaskProvider>(context, listen: false).toggleCompletion(task);
                  Navigator.of(context).pop();
                   ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('This task has been completed'),
                    backgroundColor: Colors.green,
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
                
              
            TextButton(
              child: Text('Archive'),
              onPressed: () {
                Provider.of<TaskProvider>(context, listen: false).deleteTask(task);
                Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Task Archived'),
                  backgroundColor: Colors.red,
                  duration: Duration(seconds: 2),
                   ),
              );
                
              },
            ),
          ],
        );
      },
    );
  }
}


class DoneTasksPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Done Tasks'),
        backgroundColor: Colors.teal, // AppBar background color
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueAccent, Colors.purpleAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Consumer<TaskProvider>(builder: (context, taskProvider, child) {
          return ListView.builder(
            itemCount: taskProvider.doneTasks.length,
            itemBuilder: (context, index) {
              final task = taskProvider.doneTasks[index];

              // List of background images for the task cards
              List<String> backgroundImages = [
                'assets/images/bg.jpg',
                'assets/images/bg2.jpg',
                'assets/images/bg3.jpg',
                'assets/images/bg4.jpg',
                'assets/images/bg5.jpg',
                // Add more images if necessary
              ];

              // Select a background image based on the index or another property
              String selectedBackgroundImage =
                  backgroundImages[index % backgroundImages.length];

              return Card(
                margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                elevation: 8,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    image: DecorationImage(
                      image: AssetImage(selectedBackgroundImage), // Dynamic background image for each card
                      fit: BoxFit.cover, // Ensures the image covers the card
                    ),
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(15),
                    leading: Icon(Icons.check_circle, color: Colors.green, size: 30),
                    title: Text(
                      task.name,
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    subtitle: Text(
                      'Deadline: ${DateFormat('yyyy-MM-dd').format(task.deadline)}',
                      style: TextStyle(color: Colors.white70),
                    ),
                    onTap: () => _showTaskDetails(context, task),
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }




  void _showTaskDetails(BuildContext context, Task task) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(task.name),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Deadline: ${DateFormat('yyyy-MM-dd').format(task.deadline)}'),
              SizedBox(height: 10),
              Text('Description: ${task.description}'),
            ],
          ),
        );
      },
    );
  }
}

class ArchivedTasksPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Archived Tasks'),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255), // AppBar background color
      ),
      body: Container(
        // Background gradient for the whole body
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color.fromARGB(255, 0, 0, 0),
              const Color.fromARGB(148, 31, 1, 1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Consumer<TaskProvider>(
          builder: (context, taskProvider, child) {
            return ListView.builder(
              itemCount: taskProvider.archivedTasks.length,
              itemBuilder: (context, index) {
                final task = taskProvider.archivedTasks[index];

                // List of background images for the task cards
                List<String> backgroundImages = [
                  'assets/images/bg.jpg',
                  'assets/images/bg2.jpg',
                  'assets/images/bg3.jpg',
                  'assets/images/bg4.jpg',
                  'assets/images/bg5.jpg',
                  // Add more images if necessary
                ];

                // Select a background image based on the index or another property
                String selectedBackgroundImage =
                    backgroundImages[index % backgroundImages.length];

                return Card(
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  elevation: 8,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      image: DecorationImage(
                        image: AssetImage(selectedBackgroundImage),  // Dynamic background image for each card
                        fit: BoxFit.cover,  // Ensures the image covers the card
                      ),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(15),
                      leading: Icon(Icons.archive, color: Colors.grey, size: 30),
                      title: Text(
                        task.name,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,  // Title text color
                        ),
                      ),
                      subtitle: Text(
                        'Deadline: ${DateFormat('yyyy-MM-dd').format(task.deadline)}',
                        style: TextStyle(color: Colors.white70),  // Subtitle text color
                      ),
                      onTap: () => _showTaskDetails(context, task),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _showTaskDetails(BuildContext context, Task task) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(task.name),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Deadline: ${DateFormat('yyyy-MM-dd').format(task.deadline)}'),
              SizedBox(height: 10),
              Text('Description: ${task.description}'),
            ],
          ),
        );
      },
    );
  }
}
