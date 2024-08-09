import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late TextEditingController _displayNameController;
  late TextEditingController _emailController;
  late TextEditingController _locationController;
  late TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    User? currentUser = _auth.currentUser;
    _displayNameController =
        TextEditingController(text: currentUser?.displayName ?? '');
    _emailController = TextEditingController(text: currentUser?.email ?? '');
    _locationController = TextEditingController(text: ''); // Initialize empty
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _emailController.dispose();
    _locationController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _saveChanges() async {
    User? currentUser = _auth.currentUser;
    String newDisplayName = _displayNameController.text.trim();
    String newEmail = _emailController.text.trim();
    String newPassword = _passwordController.text.trim();
    String newLocation = _locationController.text.trim(); // Retrieve location

    try {
      if (newDisplayName.isNotEmpty && newDisplayName != currentUser?.displayName) {
        await currentUser?.updateDisplayName(newDisplayName);
        // Refresh currentUser to reflect changes
        currentUser = _auth.currentUser;
      }
      if (newEmail.isNotEmpty && newEmail != currentUser?.email) {
        await currentUser?.updateEmail(newEmail);
        // Refresh currentUser to reflect changes
        currentUser = _auth.currentUser;
      }
      if (newPassword.isNotEmpty) {
        await currentUser?.updatePassword(newPassword);
      }
      // Update location in your database or any other storage method

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile updated successfully')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update profile: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
        backgroundColor: Color(0xFFB388FF),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            SizedBox(height: 20),
            Text(
              'Edit Profile',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            _buildTextField(
              controller: _displayNameController,
              labelText: 'Display Name',
              icon: Icons.person,
            ),
            SizedBox(height: 10),
            _buildTextField(
              controller: _emailController,
              labelText: 'Email',
              icon: Icons.email,
            ),
            SizedBox(height: 10),
            _buildTextField(
              controller: _locationController,
              labelText: 'Location',
              icon: Icons.location_on,
            ),
            SizedBox(height: 10),
            _buildTextField(
              controller: _passwordController,
              labelText: 'New Password (optional)',
              icon: Icons.lock,
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveChanges,
              child: Text('Save Changes'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFB388FF),
                padding: EdgeInsets.symmetric(vertical: 16),
                minimumSize: Size(double.infinity, 0),
                textStyle: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    bool obscureText = false,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFB388FF)),
          borderRadius: BorderRadius.circular(10.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFB388FF), width: 2.0),
          borderRadius: BorderRadius.circular(10.0),
        ),
      ),
    );
  }
}
