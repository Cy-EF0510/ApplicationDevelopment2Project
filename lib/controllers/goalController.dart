import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/goal.dart';

class GoalsService {
  final _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _goalsRef() {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return _db.collection('users').doc(uid).collection('goals');
  }

  Stream<List<Goal>> goalsStream() {
    return _goalsRef().snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => Goal.fromMap(doc.id, doc.data())).toList()
    );
  }

  Future<void> addGoal(Goal goal) async {
    await _goalsRef().add(goal.toMap());
  }

  Future<void> deleteGoal(String goalId) async {
    await _goalsRef().doc(goalId).delete();
  }

  Future<void> updateGoal(Goal goal) async {
    await _goalsRef().doc(goal.id).update(goal.toMap());
  }

  Future<void> toggleTask(Goal goal, int taskIndex) async {
    goal.tasks[taskIndex].isComplete = !goal.tasks[taskIndex].isComplete;
    await updateGoal(goal);
  }
}