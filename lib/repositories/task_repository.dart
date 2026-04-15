import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_ui_class/models/task_model.dart';

class TaskRepository {
  TaskRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _tasksCollection =>
      _firestore.collection('tasks');

  Stream<List<TaskModel>> watchTasks() {
    return _tasksCollection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map(TaskModel.fromFirestore)
              .toList(growable: false),
        );
  }

  Future<void> addTask(TaskModel task) async {
    final docRef = _tasksCollection.doc();
    final payload =
        task.copyWith(id: docRef.id).toJson()
          ..['createdAt'] = FieldValue.serverTimestamp();

    await docRef.set(payload);
  }

  Future<void> deleteTask(String id) async {
    await _tasksCollection.doc(id).delete();
  }

  Future<void> updateTask(TaskModel task) async {
    final payload = task.toJson();
    payload.remove('createdAt');

    await _tasksCollection.doc(task.id).update(payload);
  }
}
