import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'edit_user_screen.dart';

class ManageUserProfiles extends StatefulWidget {
  @override
  _ManageUserProfilesState createState() => _ManageUserProfilesState();
}

class _ManageUserProfilesState extends State<ManageUserProfiles> {
  late TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Users'),
        backgroundColor: Color(0xFFB388FF),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search',
                labelStyle: TextStyle(color: Color(0xFFB388FF)),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFB388FF)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFFB388FF)),
                ),
                suffixIcon: IconButton(
                  icon: Icon(Icons.clear, color: Color(0xFFB388FF)),
                  onPressed: () {
                    _searchController.clear();
                  },
                ),
              ),
              onChanged: (value) {
                // Implement search functionality
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('users').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text('No users found'));
                }

                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot userSnapshot = snapshot.data!.docs[index];
                    String userId = userSnapshot.id;
                    Map<String, dynamic>? data = userSnapshot.data() as Map<String, dynamic>?;

                    if (data == null || !data.containsKey('email') || !data.containsKey('role')) {
                      return ListTile(
                        title: Text('Incomplete user data'),
                      );
                    }

                    String email = data['email'];
                    String role = data['role'];

                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                      child: ListTile(
                        title: Text(email),
                        subtitle: Text('Role: $role'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit, color: Color(0xFFB388FF)),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditUserScreen(
                                      userId: userId,
                                      initialEmail: email,
                                      initialRole: role,
                                    ),
                                  ),
                                );
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.redAccent),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text('Delete User'),
                                      content: Text('Are you sure you want to delete this user?'),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: Text('Cancel'),
                                        ),
                                        TextButton(
                                          onPressed: () {
                                            deleteUser(userId);
                                            Navigator.pop(context);
                                          },
                                          child: Text('Delete', style: TextStyle(color: Colors.redAccent)),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AddUserDialog();
            },
          );
        },
        backgroundColor: Color(0xFFB388FF),
        child: Icon(Icons.add),
      ),
    );
  }

  void deleteUser(String userId) {
    FirebaseFirestore.instance.collection('users').doc(userId).delete().then((_) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('User deleted successfully.'),
      ));
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to delete user: $error'),
      ));
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class AddUserDialog extends StatefulWidget {
  @override
  _AddUserDialogState createState() => _AddUserDialogState();
}

class _AddUserDialogState extends State<AddUserDialog> {
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late String _selectedRole;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _selectedRole = 'Admin'; // Set default role or choose as per your requirement
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add User'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _emailController,
            decoration: InputDecoration(
              labelText: 'Email',
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFB388FF)),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFB388FF)),
              ),
            ),
          ),
          SizedBox(height: 10),
          TextField(
            controller: _passwordController,
            decoration: InputDecoration(
              labelText: 'Password',
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFB388FF)),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFB388FF)),
              ),
            ),
          ),
          SizedBox(height: 10),
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
            decoration: InputDecoration(
              labelText: 'Role',
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFB388FF)),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Color(0xFFB388FF)),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Cancel', style: TextStyle(color: Color(0xFFB388FF))),
        ),
        TextButton(
          onPressed: () {
            addUser();
          },
          child: Text('Add', style: TextStyle(color: Color(0xFFB388FF))),
        ),
      ],
    );
  }

  void addUser() {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String role = _selectedRole;

    if (email.isEmpty || password.isEmpty || role.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please fill in all fields.'),
      ));
      return;
    }

    // Add user to Firestore
    FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
    ).then((authResult) {
      FirebaseFirestore.instance.collection('users').doc(authResult.user!.uid).set({
        'email': email,
        'role': role,
      }).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('User added successfully.'),
        ));
        Navigator.pop(context);
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to add user: $error'),
        ));
      });
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to add user: $error'),
      ));
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
