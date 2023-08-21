import 'package:flutter/material.dart';
import 'package:task_management/database/database_helper.dart';

import 'screens/task_screen.dart';

/// Task Screen
///  Today
///   Task 1
///   Task 2
///
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  final dbHelper = DatabaseHelper().database;
  runApp(Home());
}

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: TaskScreen(),
    );
  }
}
