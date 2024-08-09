import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AdminEmergencyPage extends StatefulWidget {
  @override
  _AdminEmergencyPageState createState() => _AdminEmergencyPageState();
}

class _AdminEmergencyPageState extends State<AdminEmergencyPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Emergency Reports'),
        backgroundColor: Color(0xFFB388FF),
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
              bool isApprovedBySafetyOfficer = data['approvedBySafetyOfficer'] ?? false;
              bool isApprovedByAdmin = data['approvedByAdmin'] ?? false;
              return Card(
                margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: ListTile(
                  title: Text('Name: ${data['name']}', style: TextStyle(color: Color(0xFFB388FF), fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Contact: ${data['contact'] ?? 'N/A'}'),
                      Text('Description: ${data['description'] ?? 'N/A'}'),
                      Text('Location: ${data['location'] ?? 'N/A'}'),
                      Text('Date: ${_formatDate(data['date']) ?? 'N/A'}'),
                    ],
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!isApprovedByAdmin)
                        IconButton(
                          icon: Icon(Icons.check, color: Colors.green),
                          onPressed: () {
                            _approveReport(reports[index]);
                          },
                        ),
                      IconButton(
                        icon: Icon(Icons.close, color: Colors.redAccent),
                        onPressed: () {
                          _deleteReport(reports[index]);
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
    _firestore
        .collection('emergency_reports')
        .doc(reportSnapshot.id)
        .update({'approvedByAdmin': true})
        .then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Report approved by admin successfully')),
      );
    }).catchError((error) {
      print('Error approving report by admin: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to approve report by admin')),
      );
    });
  }

  void _deleteReport(DocumentSnapshot reportSnapshot) {
    _firestore
        .collection('emergency_reports')
        .doc(reportSnapshot.id)
        .delete()
        .then((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Report deleted successfully')),
      );
    }).catchError((error) {
      print('Error deleting report: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete report')),
      );
    });
  }
}
