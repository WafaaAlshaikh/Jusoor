import 'package:flutter/material.dart';
import '../models/child_model.dart';
import '../services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ManageChildrenScreen extends StatefulWidget {
  const ManageChildrenScreen({super.key});

  @override
  State<ManageChildrenScreen> createState() => _ManageChildrenScreenState();
}

class _ManageChildrenScreenState extends State<ManageChildrenScreen> {
  List<Child> children = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchChildren();
  }

  Future<void> _fetchChildren() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      if (token.isEmpty) throw Exception('Token not found');

      final fetched = await ApiService.getChildren(token);
      setState(() {
        children = fetched;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load children: $e';
        _isLoading = false;
      });
    }
  }

  void _showChildForm({Child? child}) {
    final _formKey = GlobalKey<FormState>();
    String fullName = child?.fullName ?? '';
    String dateOfBirth = child?.dateOfBirth ?? '';
    String gender = child?.gender ?? '';
    String photo = child?.photo ?? '';
    String medicalHistory = child?.medicalHistory ?? '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(child == null ? 'Add Child' : 'Edit Child'),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                initialValue: fullName,
                decoration: const InputDecoration(labelText: 'Full Name'),
                validator: (val) => val == null || val.isEmpty ? 'Enter name' : null,
                onSaved: (val) => fullName = val ?? '',
              ),
              TextFormField(
                initialValue: dateOfBirth,
                decoration: const InputDecoration(labelText: 'Date of Birth (YYYY-MM-DD)'),
                onSaved: (val) => dateOfBirth = val ?? '',
              ),
              TextFormField(
                initialValue: gender,
                decoration: const InputDecoration(labelText: 'Gender'),
                onSaved: (val) => gender = val ?? '',
              ),
              TextFormField(
                initialValue: medicalHistory,
                decoration: const InputDecoration(labelText: 'Medical History'),
                onSaved: (val) => medicalHistory = val ?? '',
              ),
              TextFormField(
                initialValue: photo,
                decoration: const InputDecoration(labelText: 'Photo URL'),
                onSaved: (val) => photo = val ?? '',
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                _formKey.currentState!.save();
                Navigator.pop(context);

                final prefs = await SharedPreferences.getInstance();
                final token = prefs.getString('token') ?? '';
                final childData = Child(
                  id: child?.id ?? 0,
                  fullName: fullName,
                  dateOfBirth: dateOfBirth,
                  gender: gender,
                  photo: photo,
                  medicalHistory: medicalHistory,
                );

                try {
                  if (child == null) {
                    await ApiService.addChild(token, childData);
                  } else {
                    await ApiService.updateChild(token, child.id, childData);
                  }
                  await _fetchChildren();
                } catch (e) {
                  ScaffoldMessenger.of(context)
                      .showSnackBar(SnackBar(content: Text('Error saving child: $e')));
                }
              }
            },
            child: Text(child == null ? 'Add' : 'Save'),
          ),
        ],
      ),
    );
  }

  void _deleteChild(Child child) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    try {
      await ApiService.deleteChild(token, child.id);
      await _fetchChildren();
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error deleting child: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Manage Children'), backgroundColor: Colors.teal),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)))
          : ListView.builder(
        itemCount: children.length,
        itemBuilder: (context, index) {
          final child = children[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: child.photo.isNotEmpty ? NetworkImage(child.photo) : null,
              child: child.photo.isEmpty ? Text(child.fullName[0].toUpperCase()) : null,
            ),
            title: Text(child.fullName),
            subtitle: Text(child.medicalHistory),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(icon: const Icon(Icons.edit), onPressed: () => _showChildForm(child: child)),
                IconButton(icon: const Icon(Icons.delete), onPressed: () => _deleteChild(child)),
              ],
            ),
            onTap: () => _showChildForm(child: child),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showChildForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
