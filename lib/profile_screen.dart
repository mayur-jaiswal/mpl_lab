// screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'database_service.dart';

class ProfileScreen extends StatefulWidget {
  final String userId;

  ProfileScreen({required this.userId});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserModel? user;
  final DatabaseService _databaseService = DatabaseService();

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      UserModel fetchedUser = await _databaseService.getUser(widget.userId);
      setState(() {
        user = fetchedUser;
      });
    } catch (e) {
      print('Error fetching user data: $e');
      // Handle error, e.g., show a snackbar
    }
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: Text('Profile')),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${user!.name}', style: TextStyle(fontSize: 20)),
            SizedBox(height: 8),
            Text('Email: ${user!.email}', style: TextStyle(fontSize: 16)),
            SizedBox(height: 8),
            Text('Address: ${user!.address}', style: TextStyle(fontSize: 16)),
            SizedBox(height: 16),
            Text('Skills:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: user!.skills.map((skill) => Text('- $skill')).toList(),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                FirebaseAuth.instance.signOut();
                Navigator.pushReplacementNamed(context, "/login");
              },
              child: Text("Logout"),
            )
          ],
        ),
      ),
    );
  }
}
