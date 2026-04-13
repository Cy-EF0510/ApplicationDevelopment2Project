import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'exercise.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: LocalJSON(),
    );
  }
}

class LocalJSON extends StatefulWidget {
  const LocalJSON({super.key});

  @override
  State<LocalJSON> createState() => _LocalJSONState();
}

class _LocalJSONState extends State<LocalJSON> {
  List<Exercise> _exercises = [];  // Use your Exercise model

  // Fixed: Read YOUR JSON structure
  // Future<void> readJson() async {
  //   try {
  //     final String response = await rootBundle.loadString('assets/json/exercises.json');
  //     final data = json.decode(response);
  //
  //     // Parse using YOUR model
  //     final exercises = Exercises.fromJson(data);
  //
  //     setState(() {
  //       _exercises = exercises.exercises;  // data["exercises"], not "items"
  //     });
  //   } catch (e) {
  //     print('Error parsing JSON: $e');
  //   }
  // }

  Future<void> readJson() async {
    try {
      final String response = await rootBundle.loadString('assets/json/exercises.json');
      final data = json.decode(response);

      // DEBUG: Print raw structure
      print('Raw JSON keys: ${data.keys.toList()}');
      print('First exercise keys: ${data["exercises"]?[0].keys.toList()}');
      print('First primaryMuscles: ${data["exercises"]?[0]["primaryMuscles"]}');

      final exercises = Exercises.fromJson(data);
      setState(() {
        _exercises = exercises.exercises;
      });
    } catch (e) {
      print('Error parsing JSON: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Exercises (${_exercises.length})'),
        centerTitle: true,
        backgroundColor: Colors.cyan,
      ),
      backgroundColor: Colors.cyanAccent,
      body: Padding(
        padding: EdgeInsets.all(25),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: readJson,
              child: Text('Load Exercises'),
            ),
            SizedBox(height: 10),
            // Fixed: Use Exercise model properties
            _exercises.isNotEmpty
                ? Expanded(
              child: ListView.builder(
                itemCount: _exercises.length,
                itemBuilder: (context, index) {
                  final exercise = _exercises[index];
                  return Card(
                    margin: EdgeInsets.all(10),
                    child: ExpansionTile(  // Better UX - expandable
                      leading: CircleAvatar(
                        child: Text('${index + 1}'),
                      ),
                      title: Text(exercise.name, style: TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Force: ${exercise.force?.name ?? "N/A"}'),
                          Text('Level: ${exercise.level.name}'),
                          Text('Category: ${exercise.category.name}'),
                          Text('Primary: ${exercise.primaryMuscles.map((m) => m.name.toLowerCase()).join(", ")}'),
                          Text('Equipment: ${exercise.equipment?.name ?? "N/A"}'),
                          Text('Instructions: ${exercise.instructions.length} steps'),
                        ],
                      ),
                    ),
                  );
                },
              ),
            )
                : Center(child: Text('Press "Load Exercises"')),
          ],
        ),
      ),
    );
  }
}