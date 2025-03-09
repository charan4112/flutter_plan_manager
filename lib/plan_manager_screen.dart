import 'dart:async';
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
  String _searchQuery = '';
  Timer? _debounce;

  // Add Plan
  void _addPlan(String name, String description, DateTime date, String priority) {
    setState(() {
      _plans.add({
        'name': name,
        'description': description,
        'date': date,
        'completed': false,
        'priority': priority,
      });

      _sortPlans();
    });
  }

  // Sort Plans by Priority
  void _sortPlans() {
    _plans.sort((a, b) => _priorityOrder(a['priority']).compareTo(_priorityOrder(b['priority'])));
  }

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

      _sortPlans();
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

  // Efficient Search with Debounce
  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        _searchQuery = query;
      });
    });
  }

  // Priority Colors
  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'High':
        return Colors.red;
      case 'Medium':
        return Colors.orange;
      case 'Low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredPlans = _plans
        .where((plan) => plan['name'].toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Plan Manager'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50.0),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: "Search Plans...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
              ),
            ),
          ),
        ),
      ),
      body: ListView.builder(
        itemCount: filteredPlans.length,
        itemBuilder: (context, index) {
          return Card(
            color: _getPriorityColor(filteredPlans[index]['priority']).withOpacity(0.15),
            elevation: 3,
            margin: const EdgeInsets.all(8.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: ListTile(
              onLongPress: () => _showEditPlanModal(context, index),
              onDoubleTap: () => _deletePlan(index),
              title: Text(
                '${filteredPlans[index]['name']} [${filteredPlans[index]['priority']}]',
                style: TextStyle(
                  color: _getPriorityColor(filteredPlans[index]['priority']),
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                filteredPlans[index]['description'] + '\nDate: ${filteredPlans[index]['date'].toString().split(' ')[0]}',
              ),
              trailing: Icon(
                filteredPlans[index]['completed'] ? Icons.check_circle : Icons.radio_button_unchecked,
                color: filteredPlans[index]['completed'] ? Colors.green : Colors.grey,
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
}
