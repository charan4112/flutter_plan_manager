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

  void _addPlan(String name, String description, DateTime date) {
    setState(() {
      _plans.add({
        'name': name,
        'description': description,
        'date': date,
        'completed': false,
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plan Manager'),
      ),
      body: ListView.builder(
        itemCount: _plans.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(_plans[index]['name']),
            subtitle: Text(_plans[index]['description']),
            trailing: Icon(
              _plans[index]['completed'] ? Icons.check_circle : Icons.radio_button_unchecked,
              color: _plans[index]['completed'] ? Colors.green : Colors.grey,
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

  void _showAddPlanModal(BuildContext context) {
    final _nameController = TextEditingController();
    final _descriptionController = TextEditingController();
    DateTime _selectedDate = DateTime.now();

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
              ElevatedButton(
                onPressed: () {
                  _addPlan(
                    _nameController.text,
                    _descriptionController.text,
                    _selectedDate,
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
