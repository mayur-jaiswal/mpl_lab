// screens/add_skill_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'skill.dart';
import 'database_service.dart';
import 'user_model.dart';

class AddSkillPage extends StatefulWidget {
  final String userName;

  const AddSkillPage({Key? key, required this.userName}) : super(key: key);

  @override
  _AddSkillPageState createState() => _AddSkillPageState();
}

class _AddSkillPageState extends State<AddSkillPage> {
  final _skillController = TextEditingController();
  final DatabaseService _databaseService = DatabaseService();
  UserModel? user;
  String? address;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      try {
        user = await _databaseService.getUser(currentUser.uid);
        setState(() {
          address = user?.address;
        });

      } catch (error) {
        print('Error loading user data: $error');
      }
    }
  }

  Future<void> _addSkill() async {
    try {
      final userId = FirebaseAuth.instance.currentUser!.uid;
      final skill = Skill(
          userId: userId,
          userName: widget.userName,
          skillName: _skillController.text,
          address: address?? "No Address"
      );
      await _databaseService.addSkill(skill);
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add skill: ${e.toString()}')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Skill')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _skillController,
              decoration: InputDecoration(labelText: 'Skill'),
            ),
            SizedBox(height: 16),
            ElevatedButton(onPressed: _addSkill, child: Text('Add')),
          ],
        ),
      ),
    );
  }
}