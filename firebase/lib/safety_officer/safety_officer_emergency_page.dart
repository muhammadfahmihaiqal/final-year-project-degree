import 'package:firebase/safety_officer/add_emergency_report_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SafetyOfficerEmergencyPage extends StatefulWidget {
  @override
  _SafetyOfficerEmergencyPageState createState() =>
      _SafetyOfficerEmergencyPageState();
}

class _SafetyOfficerEmergencyPageState extends State<SafetyOfficerEmergencyPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Emergency Reports'),
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
              bool isApproved = data['approved'] ?? false;

              return Card(
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
                  trailing: isApproved
                      ? Text(
                          'Approved',
                          style: TextStyle(color: Colors.green),
                        )
                      : data['approved'] == false
                          ? Text(
                              'Rejected',
                              style: TextStyle(color: Colors.red),
                            )
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.check, color: Colors.green),
                                  onPressed: () {
                                    _approveReport(reports[index]);
                                  },
                                ),
                                IconButton(
                                  icon: Icon(Icons.close, color: Colors.red),
                                  onPressed: () {
                                    _rejectReport(reports[index]);
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to the add report page
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddEmergencyReportPage()),
          );
        },
        child: Icon(Icons.add),
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

  void _approveReport(DocumentSnapshot reportSnapshot) {
    // Update the 'approved' field to true
    _firestore
        .collection('emergency_reports')
        .doc(reportSnapshot.id)
        .update({'approved': true})
        .then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Report approved successfully')),
      );
    }).catchError((error) {
      print('Error approving report: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to approve report')),
      );
    });
  }

  void _rejectReport(DocumentSnapshot reportSnapshot) {
    // Update the 'approved' field to false
    _firestore
        .collection('emergency_reports')
        .doc(reportSnapshot.id)
        .update({'approved': false})
        .then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Report rejected successfully')),
      );
    }).catchError((error) {
      print('Error rejecting report: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to reject report')),
      );
    });
  }
}
