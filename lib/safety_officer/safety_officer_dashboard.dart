import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'safety_officer_emergency_page.dart';
import 'safety_officer_forecasting.dart';

class SafetyOfficerDashboard extends StatefulWidget {
  @override
  _SafetyOfficerDashboardState createState() => _SafetyOfficerDashboardState();
}

class _SafetyOfficerDashboardState extends State<SafetyOfficerDashboard>
    with SingleTickerProviderStateMixin {
  final _firestore = FirebaseFirestore.instance;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Safety Officer Dashboard'),
        backgroundColor: Color(0xFFB388FF), // Set app bar color here
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName:
                  Text(FirebaseAuth.instance.currentUser?.displayName ?? 'User'),
              accountEmail: Text(FirebaseAuth.instance.currentUser?.email ?? ''),
              currentAccountPicture: CircleAvatar(
                child: Icon(Icons.person),
              ),
              decoration: BoxDecoration(
                color: Color(0xFFB388FF), // Drawer header color
              ),
            ),
            ListTile(
              title: Text('Home'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Weather Forecasting'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SafetyOfficerWeatherPage()),
                );
              },
            ),
            ListTile(
              title: Text('Emergency Reports'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => SafetyOfficerEmergencyPage()),
                );
              },
            ),
            ListTile(
              title: Text('Logout'),
              onTap: () {
                FirebaseAuth.instance.signOut();
                Navigator.pushReplacementNamed(context, '/');
              },
            ),
          ],
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('emergency_reports').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }
          final reports = snapshot.data!.docs;
          return ListView.builder(
            itemCount: reports.length,
            itemBuilder: (context, index) {
              var data = reports[index].data() as Map<String, dynamic>;
              return FadeTransition(
                opacity: _animation,
                child: Card(
                  child: ListTile(
                    title: Text('Name: ${data['name']}'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Contact: ${data['contact'] ?? 'N/A'}'),
                        Text('Description: ${data['description'] ?? 'N/A'}'),
                        Text('Location: ${data['location'] ?? 'N/A'}'),
                        Text('Date: ${_formatDate(data['date']) ?? 'N/A'}'),
                      ],
                    ),
                    trailing: data['approved'] == true
                      ? Text(
                          'Approved',
                          style: TextStyle(color: Colors.green),
                        )
                      : data['approved'] == false
                        ? Text(
                            'Rejected',
                            style: TextStyle(color: Colors.red),
                          )
                        : Text(
                            'Pending',
                            style: TextStyle(color: Colors.orange),
                          ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString != null) {
      DateTime date = DateTime.parse(dateString);
      return '${date.day}-${date.month}-${date.year} ${date.hour}:${date.minute}';
    } else {
      return '';
    }
  }
}
