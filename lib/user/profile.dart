import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase/user/edit_profile.dart'; // Assuming this is the correct import path for EditProfilePage

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String _displayName = '';
  String _email = '';
  String _location = ''; // Add location field

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    User? user = _auth.currentUser;
    if (user != null) {
      setState(() {
        _displayName = user.displayName ?? '';
        _email = user.email ?? '';
        // Fetch location from your database or any other source
        _location = 'Some Location'; // Example location
      });
    }
  }

  void _navigateToEditProfile() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EditProfilePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        centerTitle: true,
        backgroundColor: Color(0xFFB388FF), // Updated app bar color
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Profile Picture
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(
                    'https://via.placeholder.com/150'), // Replace with user profile picture
              ),
            ),
            SizedBox(height: 20),

            // Profile Information Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: <Widget>[
                    ListTile(
                      leading: Icon(Icons.person),
                      title: Text('Display Name:'),
                      subtitle: Text(_displayName),
                    ),
                    ListTile(
                      leading: Icon(Icons.email),
                      title: Text('Email:'),
                      subtitle: Text(_email),
                    ),
                    ListTile(
                      leading: Icon(Icons.location_on),
                      title: Text('Location:'),
                      subtitle: Text(_location),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),

            // Edit Profile Button
            Center(
              child: ElevatedButton(
                onPressed: _navigateToEditProfile,
                child: Text('Edit Profile'),
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Color(0xFFB388FF), // Updated button background color
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: ProfilePage(),
  ));
}
