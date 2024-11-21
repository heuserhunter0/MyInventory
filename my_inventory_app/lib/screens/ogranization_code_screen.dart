// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api, avoid_print, use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OrganizationCodeScreen extends StatefulWidget {
  @override
  _OrganizationCodeScreenState createState() => _OrganizationCodeScreenState();
}

class _OrganizationCodeScreenState extends State<OrganizationCodeScreen> {
  String? _orgId;
  final TextEditingController _orgCodeController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _fetchOrgId();
  }

  Future<void> _fetchOrgId() async {
    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();

      if (userDoc.exists) {
        setState(() {
          _orgId = userDoc['orgId'];
          _orgCodeController.text = _orgId!; // Pre-fill the text field with the current orgId
        });
      }
    } catch (e) {
      print('Error fetching organization code: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to load organization code'),
      ));
    }
  }

  Future<void> _updateOrgCode(String newCode) async {
    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;

      // Update the org code in the user document
      await FirebaseFirestore.instance.collection('users').doc(userId).update({'orgId': newCode});

      // Optionally, update the orgId in any related collections (e.g., items):
      await FirebaseFirestore.instance
          .collection('items')
          .where('orgId', isEqualTo: _orgId)
          .get()
          .then((querySnapshot) {
        for (var doc in querySnapshot.docs) {
          doc.reference.update({'orgId': newCode});
        }
      });

      setState(() {
        _orgId = newCode;
        _isEditing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Organization code updated successfully'),
      ));
    } catch (e) {
      print('Error updating organization code: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to update organization code'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Organization Code'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _orgId == null
            ? Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Organization Code:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  _isEditing
                      ? TextField(
                          controller: _orgCodeController,
                          decoration: InputDecoration(
                            labelText: 'Edit Organization Code',
                            border: OutlineInputBorder(),
                          ),
                        )
                      : Text(
                          _orgId!,
                          style: TextStyle(fontSize: 16, color: Colors.blueGrey),
                        ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      if (_isEditing)
                        ElevatedButton(
                          onPressed: () {
                            if (_orgCodeController.text.isNotEmpty) {
                              _updateOrgCode(_orgCodeController.text);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text('Organization code cannot be empty'),
                              ));
                            }
                          },
                          child: Text('Save'),
                        ),
                      if (_isEditing)
                        SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _isEditing = !_isEditing;
                            if (!_isEditing) {
                              _orgCodeController.text = _orgId ?? '';
                            }
                          });
                        },
                        child: Text(_isEditing ? 'Cancel' : 'Edit'),
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }
}