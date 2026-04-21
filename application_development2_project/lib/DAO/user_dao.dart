import 'package:cloud_firestore/cloud_firestore.dart';
import '../Model/user.dart';

class UserDao {
  final CollectionReference _userCollection =
      FirebaseFirestore.instance.collection('users');

  // Create User
  Future<void> createUser(User user) async {
    try {
      DocumentReference docRef = await _userCollection.add(user.toMap());
      user.id = docRef.id;
    } catch (e) {
      print("Error creating user: $e");
      rethrow;
    }
  }

  // Create User with specific ID (e.g., from Firebase Auth)
  Future<void> createUserWithId(User user, String uid) async {
    try {
      await _userCollection.doc(uid).set(user.toMap());
      user.id = uid;
    } catch (e) {
      print("Error creating user with ID: $e");
      rethrow;
    }
  }

  // Read User by ID
  Future<User?> getUser(String id) async {
    try {
      DocumentSnapshot doc = await _userCollection.doc(id).get();
      if (doc.exists) {
        return User.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    } catch (e) {
      print("Error getting user: $e");
      return null;
    }
  }

  // Read User by Email
  Future<User?> getUserByEmail(String email) async {
    try {
      QuerySnapshot query = await _userCollection
          .where('email', isEqualTo: email)
          .limit(1)
          .get();
      if (query.docs.isNotEmpty) {
        return User.fromMap(
            query.docs.first.data() as Map<String, dynamic>, query.docs.first.id);
      }
      return null;
    } catch (e) {
      print("Error getting user by email: $e");
      return null;
    }
  }

  // Read User by Username
  Future<User?> getUserByUsername(String username) async {
    try {
      QuerySnapshot query = await _userCollection
          .where('username', isEqualTo: username)
          .limit(1)
          .get();
      if (query.docs.isNotEmpty) {
        return User.fromMap(
            query.docs.first.data() as Map<String, dynamic>, query.docs.first.id);
      }
      return null;
    } catch (e) {
      print("Error getting user by username: $e");
      return null;
    }
  }

  // Update User
  Future<void> updateUser(User user) async {
    if (user.id == null) return;
    try {
      await _userCollection.doc(user.id).update(user.toMap());
    } catch (e) {
      print("Error updating user: $e");
      rethrow;
    }
  }

  // Delete User
  Future<void> deleteUser(String id) async {
    try {
      await _userCollection.doc(id).delete();
    } catch (e) {
      print("Error deleting user: $e");
      rethrow;
    }
  }

  // Get All Users
  Future<List<User>> getAllUsers() async {
    try {
      QuerySnapshot query = await _userCollection.get();
      return query.docs
          .map((doc) => User.fromMap(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      print("Error getting all users: $e");
      return [];
    }
  }

  // Stream of User data (Real-time updates)
  Stream<User?> userStream(String id) {
    return _userCollection.doc(id).snapshots().map((doc) {
      if (doc.exists) {
        return User.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }
      return null;
    });
  }
}
