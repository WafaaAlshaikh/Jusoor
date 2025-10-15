import 'package:flutter/material.dart';
class AddEvaluationScreen extends StatefulWidget {
  const AddEvaluationScreen({super.key});

  @override
  State<AddEvaluationScreen> createState() => _AddEvaluationScreenState();
}

class _AddEvaluationScreenState extends State<AddEvaluationScreen> {
  final _formKey = GlobalKey<FormState>();
  String? selectedChild;
  String evaluationType = 'Initial';
  String notes = '';
  double progressScore = 50;

  List<String> childrenNames = ['Ali', 'Sarah', 'Mohammed']; // مثال، تجيبها من API

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Evaluation')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                value: selectedChild,
                hint: const Text('Select Child'),
                items: childrenNames.map((child) {
                  return DropdownMenuItem(
                    value: child,
                    child: Text(child),
                  );
                }).toList(),
                onChanged: (val) => setState(() => selectedChild = val),
                validator: (val) => val == null ? 'Please select a child' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: evaluationType,
                items: ['Initial', 'Mid', 'Final'].map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  );
                }).toList(),
                onChanged: (val) => setState(() => evaluationType = val!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                maxLines: 4,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Notes',
                ),
                onChanged: (val) => notes = val,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('Progress Score:'),
                  Expanded(
                    child: Slider(
                      value: progressScore,
                      min: 0,
                      max: 100,
                      divisions: 100,
                      label: progressScore.round().toString(),
                      onChanged: (val) => setState(() => progressScore = val),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Call API to save
                  }
                },
                child: const Text('Save Evaluation'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
