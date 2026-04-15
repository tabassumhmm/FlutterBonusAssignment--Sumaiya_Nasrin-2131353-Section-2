import 'package:flutter_ui_class/models/task_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_ui_class/repositories/task_repository.dart';
import 'package:flutter_ui_class/screens/add_task_page.dart';
import 'package:flutter_ui_class/widgets/task_card_widget.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UiPage extends StatelessWidget {
  const UiPage({super.key});

  static final TaskRepository _taskRepository = TaskRepository();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("UI PAGE"),
        backgroundColor: Colors.purpleAccent,
      ),

      body: StreamBuilder<List<TaskModel>>(
        stream: _taskRepository.watchTasks(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return _TaskMessage(
              message: 'Could not load tasks.\n${snapshot.error}',
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final tasks = snapshot.data ?? const <TaskModel>[];

          if (tasks.isEmpty) {
            return const _TaskMessage(
              message: 'No tasks yet.\nTap the + button to add one.',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              final task = tasks[index];

              return TaskCardWidget(
                title: task.title,
                subtitle:
                    '${task.detailsText}\n\nCreated at: ${task.createdAtLabel}',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => AddTaskPage(task: task),
                    ),
                  );
                },
                onDelete: () async {
                  try {
                    await _taskRepository.deleteTask(task.id);
                    if (!context.mounted) {
                      return;
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Task deleted successfully.'),
                      ),
                    );
                  } on FirebaseException catch (error) {
                    if (!context.mounted) {
                      return;
                    }
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(error.message ?? error.code)),
                    );
                  }
                },
              );
            },
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (context) => const AddTaskPage()));
        },
        backgroundColor: Colors.purpleAccent,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _TaskMessage extends StatelessWidget {
  final String message;

  const _TaskMessage({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
