import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_ui_class/models/task_model.dart';
import 'package:flutter_ui_class/repositories/task_repository.dart';
import 'package:flutter_ui_class/utils/validators.dart';
import 'package:flutter_ui_class/widgets/core_input_field.dart';
import 'package:flutter_ui_class/widgets/password_input_filed.dart';

class AddTaskPage extends StatefulWidget {
  final TaskModel? task;

  const AddTaskPage({super.key, this.task});

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final _titleController = TextEditingController();
  final _assignedToController = TextEditingController();
  final _phoneNumberController = TextEditingController();
  final _passwordController = TextEditingController();
  final _descriptionController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final TaskRepository _taskRepository = TaskRepository();

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();

    if (widget.task != null) {
      _titleController.text = widget.task!.title;
      _assignedToController.text = widget.task!.assignedTo;
      _phoneNumberController.text = widget.task!.phoneNumber;
      _passwordController.text = widget.task!.password;
      _descriptionController.text = widget.task!.description;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _assignedToController.dispose();
    _phoneNumberController.dispose();
    _passwordController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Task"),
        backgroundColor: Colors.purpleAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              CoreInputField(
                controller: _titleController,
                keyboardType: TextInputType.text,
                maxLines: 1,
                labelText: "Task Title",
                validator: CustomValidators.validateTaskTitle,
              ),

              const SizedBox(height: 20),
              CoreInputField(
                controller: _assignedToController,
                keyboardType: TextInputType.text,
                maxLines: 1,
                labelText: "Assigned To",
                validator: CustomValidators.validateAssignedTo,
              ),

              const SizedBox(height: 20),
              CoreInputField(
                controller: _phoneNumberController,
                keyboardType: TextInputType.phone,
                maxLines: 1,
                labelText: "Phone Number",
                validator: CustomValidators.validatePhoneNumber,
              ),

              const SizedBox(height: 20),
              PasswordInputFiled(controller: _passwordController),

              const SizedBox(height: 40),
              CoreInputField(
                controller: _descriptionController,
                keyboardType: TextInputType.multiline,
                maxLines: 6,
                labelText: "Task Description",
                validator: CustomValidators.validateDescription,
              ),

              const SizedBox(height: 24),
              if (_isSaving) const CircularProgressIndicator(),
            ],
          ),
        ),
      ),

      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
        child: ElevatedButton(
          onPressed:
              _isSaving
                  ? null
                  : () async {
                    if (!_formKey.currentState!.validate()) {
                      return;
                    }

                    setState(() {
                      _isSaving = true;
                    });

                    final isEditing = widget.task != null;
                    final task = TaskModel(
                      id: widget.task?.id ?? '',
                      title: _titleController.text.trim(),
                      description: _descriptionController.text.trim(),
                      assignedTo: _assignedToController.text.trim(),
                      phoneNumber: _phoneNumberController.text.trim(),
                      password: _passwordController.text,
                      createdAt: widget.task?.createdAt,
                    );

                    try {
                      if (isEditing) {
                        await _taskRepository.updateTask(task);
                      } else {
                        await _taskRepository.addTask(task);
                      }

                      if (!context.mounted) {
                        return;
                      }

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isEditing
                                ? 'Task updated successfully!'
                                : 'Task added successfully!',
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );
                      Navigator.of(context).pop();
                    } on FirebaseException catch (error) {
                      if (!context.mounted) {
                        return;
                      }

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(error.message ?? error.code),
                          backgroundColor: Colors.red,
                        ),
                      );
                    } finally {
                      if (context.mounted) {
                        setState(() {
                          _isSaving = false;
                        });
                      }
                    }
                  },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.purpleAccent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          child: Text(widget.task != null ? 'Save Task' : 'Add Task'),
        ),
      ),
    );
  }
}
