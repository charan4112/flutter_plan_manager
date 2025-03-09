import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Plan Manager',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: PlanManagerScreen(),
    );
  }
}

class PlanManagerScreen extends StatefulWidget {
  @override
  _PlanManagerScreenState createState() => _PlanManagerScreenState();
}

class _PlanManagerScreenState extends State<PlanManagerScreen> {
  final List<Map<String, dynamic>> _plans = [];

  // Add Plan
  void _addPlan(String name, String description, DateTime date, String priority) {
    setState(() {
      _plans.add({
        'name': name,
        'description': description,
        'date': date,
        'completed': false,
        'priority': priority
      });

      // Sort Plans by Priority
      _plans.sort((a, b) => _priorityOrder(a['priority']).compareTo(_priorityOrder(b['priority'])));
    });
  }

  // Priority Order Logic
  int _priorityOrder(String priority) {
    switch (priority) {
      case 'High':
        return 1;
      case 'Medium':
        return 2;
      case 'Low':
        return 3;
      default:
        return 4;
    }
  }

  // Update Plan
  void _updatePlan(int index, String newName, String newDescription, String priority) {
    setState(() {
      _plans[index]['name'] = newName;
      _plans[index]['description'] = newDescription;
      _plans[index]['priority'] = priority;

      // Sort Plans by Priority
      _plans.sort((a, b) => _priorityOrder(a['priority']).compareTo(_priorityOrder(b['priority'])));
    });
  }

  // Mark Plan as Completed
  void _toggleComplete(int index) {
    setState(() {
      _plans[index]['completed'] = !_plans[index]['completed'];
    });
  }

  // Delete Plan
  void _deletePlan(int index) {
    setState(() {
      _plans.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Plan Manager')),
      body: ListView.builder(
        itemCount: _plans.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onLongPress: () => _showEditPlanModal(context, index),
            onDoubleTap: () => _deletePlan(index),
            child: Dismissible(
              key: ValueKey(_plans[index]['name']),
              direction: DismissDirection.endToStart,
              onDismissed: (_) => _toggleComplete(index),
              background: Container(
                color: Colors.green,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 20),
                child: const Icon(Icons.check, color: Colors.white),
              ),
              child: ListTile(
                title: Text('${_plans[index]['name']} [${_plans[index]['priority']}]'),
                subtitle: Text(_plans[index]['description']),
                trailing: Icon(
                  _plans[index]['completed'] ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: _plans[index]['completed'] ? Colors.green : Colors.grey,
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddPlanModal(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  // Modal for Adding Plan
  void _showAddPlanModal(BuildContext context) {
    final _nameController = TextEditingController();
    final _descriptionController = TextEditingController();
    DateTime _selectedDate = DateTime.now();
    String _selectedPriority = 'Medium';

    showModalBottomSheet(
      context: context,
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Plan Name'),
              ),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _selectedPriority,
                items: ['High', 'Medium', 'Low'].map((priority) {
                  return DropdownMenuItem(
                    value: priority,
                    child: Text(priority),
                  );
                }).toList(),
                onChanged: (value) => _selectedPriority = value ?? 'Medium',
                decoration: const InputDecoration(labelText: 'Priority'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  _addPlan(
                    _nameController.text,
                    _descriptionController.text,
                    _selectedDate,
                    _selectedPriority,
                  );
                  Navigator.of(context).pop();
                },
                child: const Text('Add Plan'),
              ),
            ],
          ),
        );
      },
    );
  }

  // Modal for Editing Plan
  void _showEditPlanModal(BuildContext context, int index) {
    final _nameController = TextEditingController(text: _plans[index]['name']);
    final _descriptionController = TextEditingController(text: _plans[index]['description']);
    String _selectedPriority = _plans[index]['priority'];

    showModalBottomSheet(
      context: context,
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Edit Plan Name'),
              ),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Edit Description'),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: _selectedPriority,
                items: ['High', 'Medium', 'Low'].map((priority) {
                  return DropdownMenuItem(
                    value: priority,
                    child: Text(priority),
                  );
                }).toList(),
                onChanged: (value) => _selectedPriority = value ?? 'Medium',
                decoration: const InputDecoration(labelText: 'Priority'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () {
                  _updatePlan(
                    index,
                    _nameController.text,
                    _descriptionController.text,
                    _selectedPriority,
                  );
                  Navigator.of(context).pop();
                },
                child: const Text('Update Plan'),
              ),
            ],
          ),
        );
      },
    );
  }
}
