// lib/screens/manage_children/widgets/child_form_dialog.dart
// Dialog لإضافة/تعديل طفل - مرتبط بـ ApiService.addChild و updateChild
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/child_model.dart';
import '../services/api_service.dart';

class ChildFormDialog extends StatefulWidget {
  final Child? child;
  const ChildFormDialog({super.key, this.child});

  @override
  State<ChildFormDialog> createState() => _ChildFormDialogState();
}

class _ChildFormDialogState extends State<ChildFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late String _fullName;
  late String _dateOfBirth;
  String _gender = 'Male';
  String _condition = 'ASD';
  String _photo = '';
  String _medicalHistory = '';
  File? _pickedImage;
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _dateController = TextEditingController();
  List<Map<String, dynamic>> _institutions = [];
  int? _selectedInstitution;

  @override
  void initState() {
    super.initState();
    _fullName = widget.child?.fullName ?? '';
    _dateOfBirth = widget.child?.dateOfBirth ?? '';
    _gender = widget.child?.gender ?? 'Male';
    _condition = widget.child?.condition ?? 'ASD';
    _photo = widget.child?.photo ?? '';
    _medicalHistory = widget.child?.medicalHistory ?? '';
    _dateController.text = _dateOfBirth;
    _loadInstitutions();

  }

  Future<void> _loadInstitutions() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    final data = await ApiService.getInstitutions(token); // جديد
    setState(() {
      _institutions = data;
    });
  }


  Future<void> _pickImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) {
      setState(() {
        _pickedImage = File(picked.path);
        _photo = ''; // سنستخدم الملف بدلاً من رابط
      });
    }
  }

  int _calculateAge(String dob) {
    try {
      if (dob.isEmpty) return 0;
      final birth = DateTime.tryParse(dob);
      if (birth == null) return 0;
      final today = DateTime.now();
      int age = today.year - birth.year;
      if (today.month < birth.month || (today.month == birth.month && today.day < birth.day)) age--;
      return age;
    } catch (_) {
      return 0;
    }
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    _formKey.currentState?.save();

    final age = _calculateAge(_dateController.text);

    final newChild = Child(
      id: widget.child?.id ?? 0,
      fullName: _fullName,
      dateOfBirth: _dateController.text,
      gender: _gender,
      diagnosisId: widget.child?.diagnosisId,
      photo: _pickedImage != null ? _pickedImage!.path : (_photo),
      medicalHistory: _medicalHistory,
      condition: _condition,
      age: age,
      lastSessionDate: widget.child?.lastSessionDate,
      status: widget.child?.status ?? 'Active',
      institutionId: _selectedInstitution, // جديد
    );

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token') ?? '';
      if (widget.child == null) {
        await ApiService.addChild(token, newChild);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Child added')));
      } else {
        await ApiService.updateChild(token, widget.child!.id, newChild);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Child updated')));
      }
      Navigator.pop(context, true); // إشارة أن هناك تغيير
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Save failed: $e')));
    }
  }

  Future<void> _pickDate() async {
    DateTime initial = DateTime.tryParse(_dateController.text) ?? DateTime.now();
    final picked = await showDatePicker(context: context, initialDate: initial, firstDate: DateTime(1950), lastDate: DateTime.now());
    if (picked != null) {
      _dateController.text = '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.child != null;
    return AlertDialog(
      title: Text(isEdit ? 'Edit Child' : 'Add Child'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: _fullName,
                decoration: const InputDecoration(labelText: 'Full name'),
                validator: (v) => v == null || v.isEmpty ? 'Enter name' : null,
                onSaved: (v) => _fullName = v ?? '',
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _dateController,
                readOnly: true,
                decoration: InputDecoration(
                  labelText: 'Date of birth',
                  suffixIcon: IconButton(icon: const Icon(Icons.calendar_today), onPressed: _pickDate),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Select date' : null,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _gender,
                decoration: const InputDecoration(labelText: 'Gender'),
                items: const [
                  DropdownMenuItem(value: 'Male', child: Text('Male')),
                  DropdownMenuItem(value: 'Female', child: Text('Female')),
                ],
                onChanged: (v) => setState(() => _gender = v ?? 'Male'),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _condition,
                decoration: const InputDecoration(labelText: 'Condition'),
                items: const [
                  DropdownMenuItem(value: 'ASD', child: Text('ASD')),
                  DropdownMenuItem(value: 'ADHD', child: Text('ADHD')),
                  DropdownMenuItem(value: 'Down Syndrome', child: Text('Down Syndrome')),
                  DropdownMenuItem(value: 'Speech & Language Disorder', child: Text('Speech & Language Disorder')),
                ],
                onChanged: (v) => setState(() => _condition = v ?? 'ASD'),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<int>(
                value: _selectedInstitution,
                decoration: const InputDecoration(labelText: 'Institution'),
                items: _institutions.map((inst) {
                  return DropdownMenuItem<int>(
                    value: inst['institution_id'],
                    child: Text(inst['name']),
                  );
                }).toList(),
                onChanged: (v) => setState(() => _selectedInstitution = v),
                validator: (v) => v == null ? 'Select institution' : null,
              ),

              const SizedBox(height: 8),
              TextFormField(
                initialValue: _medicalHistory,
                decoration: const InputDecoration(labelText: 'Medical history'),
                maxLines: 2,
                onSaved: (v) => _medicalHistory = v ?? '',
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: _photo,
                      decoration: const InputDecoration(labelText: 'Photo URL (optional)'),
                      onSaved: (v) => _photo = v ?? '',
                    ),
                  ),
                  IconButton(icon: const Icon(Icons.photo_library), onPressed: _pickImage),
                ],
              ),
              const SizedBox(height: 8),
              if (_pickedImage != null) Image.file(_pickedImage!, width: 100, height: 100, fit: BoxFit.cover),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
        ElevatedButton(onPressed: _save, child: Text(isEdit ? 'Save' : 'Add')),
      ],
    );
  }
}
