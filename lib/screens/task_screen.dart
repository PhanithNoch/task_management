import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sqflite/sqflite.dart';
import 'package:task_management/database/database_helper.dart';
import 'package:task_management/models/task_model.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  var isDone = false;
  final _formKey = GlobalKey<FormState>();
  final dbHelper = DatabaseHelper();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Task"),
      ),
      body: FutureBuilder<List<Task>>(
        future: _getTasks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          if (snapshot.data!.isEmpty) {
            return const Center(
              child: Text("Empty Data"),
            );
          }
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              var task = snapshot.data![index];
              return Slidable(
                // Specify a key if the Slidable is dismissible.
                key: const ValueKey(0),

                // The end action pane is the one at the right or the bottom side.
                endActionPane: ActionPane(
                  motion: ScrollMotion(),
                  children: [
                    SlidableAction(
                      // An action can be bigger than the others.
                      flex: 1,
                      onPressed: (context) {
                        DatabaseHelper.deleteTask(id: task.id!);
                        setState(() {});
                      },
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      icon: Icons.delete,
                      label: 'Delete',
                    ),
                    SlidableAction(
                      // An action can be bigger than the others.
                      flex: 1,
                      onPressed: (context) {},
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      icon: Icons.update,
                      label: 'Update',
                    ),
                  ],
                ),
                child: Card(
                  color: task.isDone == 1 ? Colors.blue : Colors.red[200],
                  child: ListTile(
                    onTap: () {
                      task.isDone = task.isDone == 1 ? 0 : 1;
                      var row = {"isDone": task.isDone};

                      DatabaseHelper.updateTask(id: task.id!, row: row);
                      setState(() {});
                    },
                    leading: Text(
                      "${task.id}",
                      style: TextStyle(color: Colors.white),
                    ),
                    title: Text(
                      "${snapshot.data![index].title}",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    trailing: Checkbox(
                      shape: CircleBorder(
                        side: BorderSide(
                          color: Colors.white,
                        ),
                      ),
                      value: task.isDone == 1 ? true : false,
                      onChanged: (value) {
                        print(value);
                        setState(() {
                          if (value!) {
                            var row = {"isDone": 1};
                            task.isDone = 1;
                            DatabaseHelper.updateTask(id: task.id!, row: row);
                          } else {
                            task.isDone = 0;
                            var row = {"isDone": 0};
                            task.isDone = 1;
                            DatabaseHelper.updateTask(id: task.id!, row: row);
                          }
                        });
                      },
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showMyDialog(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  Future<List<Task>> _getTasks() async {
    final tasks = await DatabaseHelper.getTask();
    return tasks.map((e) => Task.fromJson(e)).toList();
  }

  Future<void> _showMyDialog(BuildContext context) async {
    final taskNameController = TextEditingController();
    final taskDateController = TextEditingController();

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState2) {
          return AlertDialog(
            title: const Text("Add Task"),
            content: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: ListBody(
                  children: <Widget>[
                    TextFormField(
                      controller: taskNameController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Task',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter task';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: taskDateController,
                      onTap: () async {
                        DateTime? date = DateTime.now();
                        FocusScope.of(context).requestFocus(FocusNode());

                        date = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2022),
                            lastDate: DateTime(2024));

                        if (date == null) return;

                        /// protect null

                        String formattedDate =
                            DateFormat('yyyy-MM-dd').format(date);
                        taskDateController.text = formattedDate;
                      },
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Date',
                      ),
                    ),
                    SizedBox(height: 10),
                    CheckboxListTile(
                      title: const Text('Is Done'),
                      value: isDone,
                      onChanged: (value) {
                        setState2(() {
                          isDone = value!;
                          print(isDone);
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('Add'),
                onPressed: () async {
                  final snackBar = SnackBar(
                    content: const Text('Insert Success'),
                    action: SnackBarAction(
                      label: 'Undo',
                      onPressed: () {
                        // Some code to undo the change.
                      },
                    ),
                  );
                  if (_formKey.currentState!.validate()) {
                    final db = await dbHelper.database;
                    Map<String, dynamic> row = {
                      DatabaseHelper().columnTitle: taskNameController.text,
                      DatabaseHelper().columnIsDone: isDone ? 1 : 0,
                      DatabaseHelper().columnDate: taskDateController.text,
                    };
                    final id = await DatabaseHelper.insertTask(row);
                    if (id > 0) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);
                      setState(() {});
                    }
                  }
                },
              ),
            ],
          );
        });
      },
    );
  }
}
