import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Import intl package for date formatting

void main() {
  runApp(MaterialApp(
    home: EmergencyPage(),
  ));
}

class EmergencyPage extends StatefulWidget {
  @override
  _EmergencyPageState createState() => _EmergencyPageState();
}

class _EmergencyPageState extends State<EmergencyPage> {
  final _firestore = FirebaseFirestore.instance;
  final _nameController = TextEditingController();
  final _contactController = TextEditingController();
  String? _selectedDescription;
  final _locationController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Emergency Reports'),
        backgroundColor: Color(0xFFB388FF),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('emergency_reports')
                  .where('approvedByAdmin', isEqualTo: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }
                final reports = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: reports.length,
                  itemBuilder: (context, index) {
                    var data = reports[index].data() as Map<String, dynamic>;
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListTile(
                        title: Text(
                          data['description'] ?? 'No Description',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18, // Adjusted font size
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Location: ${data['location'] ?? 'No Location'}',
                              style: TextStyle(fontSize: 16), // Adjusted font size
                            ),
                            Text(
                              'Date: ${_formatDate(data['date'])}',
                              style: TextStyle(fontSize: 16), // Adjusted font size
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
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: () {
                _showAddReportDialog(context);
              },
              icon: Icon(Icons.add),
              label: Text('Add Report', style: TextStyle(fontSize: 18)), // Adjusted font size
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFB388FF),
                padding: EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showAddReportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Emergency Report', style: TextStyle(fontSize: 20)), // Adjusted font size
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField(_nameController, 'Name'),
                SizedBox(height: 10),
                _buildTextField(_contactController, 'Contact'),
                SizedBox(height: 10),
                _buildDropdownButton(),
                SizedBox(height: 10),
                _buildTextField(_locationController, 'Location'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _addEmergencyReport();
                Navigator.of(context).pop();
              },
              child: Text('Add', style: TextStyle(fontSize: 18)), // Adjusted font size
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFB388FF),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFB388FF)),
          borderRadius: BorderRadius.circular(8.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFB388FF), width: 2.0),
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    );
  }

  Widget _buildDropdownButton() {
    return DropdownButtonFormField<String>(
      value: _selectedDescription,
      onChanged: (value) {
        setState(() {
          _selectedDescription = value;
        });
      },
      items: [
        'Drought',
        'Earthquake',
        'Flood',
        'Landslide',
        'Storm',
        'Wildfire',
      ].map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      decoration: InputDecoration(
        labelText: 'Description',
        border: OutlineInputBorder(),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFB388FF)),
          borderRadius: BorderRadius.circular(8.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFFB388FF), width: 2.0),
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    );
  }

  Future<void> _addEmergencyReport() async {
    try {
      await _firestore.collection('emergency_reports').add({
        'name': _nameController.text,
        'contact': _contactController.text,
        'description': _selectedDescription,
        'location': _locationController.text,
        'date': DateTime.now().toString(),
        'approvedBySafetyOfficer': false,
        'approvedByAdmin': false,
      });
      _nameController.clear();
      _contactController.clear();
      _selectedDescription = null;
      _locationController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Emergency report added successfully'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print('Error adding report: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add emergency report'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  String _formatDate(String? dateString) {
    if (dateString != null) {
      DateTime date = DateTime.parse(dateString);
      return '${DateFormat('dd-MM-yyyy hh:mm a').format(date)}'; // Format with AM/PM
    } else {
      return 'No Date';
    }
  }
}
