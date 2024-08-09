import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditUserScreen extends StatefulWidget {
  final String userId;
  final String initialEmail;
  final String initialRole;

  EditUserScreen({
    required this.userId,
    required this.initialEmail,
    required this.initialRole,
  });

  @override
  _EditUserScreenState createState() => _EditUserScreenState();
}

class _EditUserScreenState extends State<EditUserScreen> {
  late TextEditingController _emailController;
  late String _selectedRole;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail);
    _selectedRole = widget.initialRole;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit User'),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            SizedBox(height: 20.0),
            DropdownButtonFormField(
              value: _selectedRole,
              items: [
                DropdownMenuItem(
                  value: 'Admin',
                  child: Text('Admin'),
                ),
                DropdownMenuItem(
                  value: 'User',
                  child: Text('User'),
                ),
                DropdownMenuItem(
                  value: 'Safety Officer',
                  child: Text('Safety Officer'),
                ),
                // Add more role options as needed
              ],
              onChanged: (String? value) {
                setState(() {
                  _selectedRole = value!;
                });
              },
              decoration: InputDecoration(labelText: 'Role'),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                updateUserDetails();
              },
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void updateUserDetails() async {
    String email = _emailController.text.trim();

    // Update email and role in Firestore
    try {
      await FirebaseFirestore.instance.collection('users').doc(widget.userId).update({
        'email': email,
        'role': _selectedRole,
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('User details updated successfully.'),
      ));

      Navigator.pop(context);
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to update user details: $error'),
      ));
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }
}
