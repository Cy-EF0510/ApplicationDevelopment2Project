import 'package:collection/collection.dart';

class Exercises {
  List<Exercise> exercises;

  Exercises({required this.exercises});

  factory Exercises.fromJson(Map<String, dynamic> json) {
    var exerciseList = json['exercises'] as List;
    List<Exercise> exerciseListParsed =
    exerciseList.map((i) => Exercise.fromJson(i)).toList();
    return Exercises(exercises: exerciseListParsed);
  }
}

class Exercise {
  String name;
  Force? force;
  Level level;
  Mechanic? mechanic;
  Equipment? equipment;
  List<AryMuscle> primaryMuscles;
  List<AryMuscle> secondaryMuscles;
  List<String> instructions;
  Category category;

  Exercise({
    required this.name,
    required this.force,
    required this.level,
    required this.mechanic,
    required this.equipment,
    required this.primaryMuscles,
    required this.secondaryMuscles,
    required this.instructions,
    required this.category,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
      return Exercise(
        name: json['name'] as String,
        force: parseForce(json['force']),
        level: parseLevel(json['level']),
        mechanic: parseMechanic(json['mechanic']),
        equipment: parseEquipment(json['equipment']),
        primaryMuscles: (json['primaryMuscles'] as List<dynamic>?)
            ?.map((name) => parseAryMuscle(name as String))
            .where((m) => m != null)  // filter nulls
            .cast<AryMuscle>()
            .toList() ?? [],
        secondaryMuscles: (json['secondaryMuscles'] as List<dynamic>?)
            ?.map((name) => parseAryMuscle(name as String))
            .where((m) => m != null)
            .cast<AryMuscle>()
            .toList() ?? [],
        instructions: (json['instructions'] as List<dynamic>?)
            ?.cast<String>() ?? [],
        category: parseCategory(json['category']),
      );
    }

      // name: json['name'] as String,
      // force: parseForce(json['force']),
      // level: parseLevel(json['level']),
      // mechanic: parseMechanic(json['mechanic']),
      // equipment: parseEquipment(json['equipment']),
      // primaryMuscles: (json['primaryMuscles'] as List<dynamic>?)
      //     ?.map((name) => parseAryMuscle(name as String))
      //     .toList() ?? [],
      // secondaryMuscles: (json['secondaryMuscles'] as List<dynamic>?)
      //     ?.map((name) => parseAryMuscle(name as String))
      //     .toList() ?? [],
      // instructions: (json['instructions'] as List<dynamic>?)
      //     ?.cast<String>() ?? [],
      // category: parseCategory(json['category']),

      // level: json['level'] as Level,
      // mechanic: json['mechanic'] as Mechanic,
      // equipment: json['equipment'] as Equipment,
      // primaryMuscles: json['primaryMuscles']! as List<AryMuscle>,
      // secondaryMuscles: json['secondaryMuscles'] as List<AryMuscle>,
      // instructions: json['String'] as List<String>,
      // category: json['category'] as Category,
}

// 1. AryMuscle (most common failure)
AryMuscle parseAryMuscle(String value) {
  final normalized = value.toLowerCase();
  return AryMuscle.values.firstWhereOrNull(
        (e) => e.toString().split('.').last.toLowerCase() == normalized,
  ) ?? AryMuscle.ABDOMINALS;  // fallback
}

// 2. Force (nullable)
Force? parseForce(String? value) {
  if (value == null) return null;
  final normalized = value.toLowerCase();
  return Force.values.firstWhereOrNull(
        (e) => e.toString().split('.').last.toLowerCase() == normalized,
  );
}

// 3. Level
Level parseLevel(String value) {
  final normalized = value.toLowerCase();
  return Level.values.firstWhereOrNull(
        (e) => e.toString().split('.').last.toLowerCase() == normalized,
  ) ?? Level.BEGINNER;  // fallback
}

// 4. Mechanic (nullable)
Mechanic? parseMechanic(String? value) {
  if (value == null) return null;
  final normalized = value.toLowerCase();
  return Mechanic.values.firstWhereOrNull(
        (e) => e.toString().split('.').last.toLowerCase() == normalized,
  );
}

// 5. Equipment (nullable)
Equipment? parseEquipment(String? value) {
  if (value == null) return null;
  final normalized = value.toLowerCase();
  return Equipment.values.firstWhereOrNull(
        (e) => e.toString().split('.').last.toLowerCase() == normalized,
  );
}

// 6. Category
Category parseCategory(String value) {
  final normalized = value.toLowerCase();
  return Category.values.firstWhereOrNull(
        (e) => e.toString().split('.').last.toLowerCase() == normalized,
  ) ?? Category.STRENGTH;  // fallback
}

enum Category {
  CARDIO,
  OLYMPIC_WEIGHTLIFTING,
  PLYOMETRICS,
  POWERLIFTING,
  STRENGTH,
  STRETCHING,
  STRONGMAN,
}

enum Equipment {
  BANDS,
  BARBELL,
  BODY_ONLY,
  CABLE,
  DUMBBELL,
  EXERCISE_BALL,
  E_Z_CURL_BAR,
  FOAM_ROLL,
  KETTLEBELLS,
  MACHINE,
  MEDICINE_BALL,
  OTHER,
}

enum Force { PULL, PUSH, STATIC }

enum Level { BEGINNER, EXPERT, INTERMEDIATE }

enum Mechanic { COMPOUND, ISOLATION }

enum AryMuscle {
  ABDOMINALS,
  ABDUCTORS,
  ADDUCTORS,
  BICEPS,
  CALVES,
  CHEST,
  FOREARMS,
  GLUTES,
  HAMSTRINGS,
  LATS,
  LOWER_BACK,
  MIDDLE_BACK,
  NECK,
  QUADRICEPS,
  SHOULDERS,
  TRAPS,
  TRICEPS,
}

// void printAllExercises(Exercises exercises) {
//   print('📋 Loaded ${exercises.exercises.length} exercises:\n');
//
//   for (int i = 0; i < exercises.exercises.length; i++) {
//     final exercise = exercises.exercises[i];
//     print('🏋️‍♂️ ${i + 1}. ${exercise.name}');
//     print('   💪 Primary: ${exercise.primaryMuscles.map((m) => m.name).join(", ")}');
//     print('   🔧 Secondary: ${exercise.secondaryMuscles.map((m) => m.name).join(", ") }');
//     print('   ⚡ Force: ${exercise.force?.name ?? "none"}');
//     print('   🎯 Category: ${exercise.category.name}');
//     print('   📝 Instructions: ${exercise.instructions.length} steps');
//     print('');
//   }
// }
//
// void main() async{
//   // List items = [];
//   // Future<void> readJson(){
//   //   final String response = await rootBundle.loadString('assets/json/exercises.json');
//   //   //json decode t=is the function that converts the stream cloud data to dart
//   //   final data = await json.decode(response)
//   // }
//   // Load your JSON file
//   final file = File('exercises.json');  // your JSON file path
//   final jsonString = await file.readAsString();
//   final jsonData = jsonDecode(jsonString);
//
//   // Parse
//   final exercises = Exercises.fromJson(jsonData);
//
//   // Print all
//   printAllExercises(exercises);
// }
