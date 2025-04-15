// screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'skill.dart';
import 'database_service.dart';
import 'chat_screen.dart';
import 'add_skill_screen.dart';
import 'profile_screen.dart';
import 'message.dart';
import 'user_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final DatabaseService _databaseService = DatabaseService();
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;
  final String currentUserName =
  FirebaseAuth.instance.currentUser!.email!.split('@')[0];

  List<Map<String, dynamic>> pendingMessages = [];

  @override
  void initState() {
    super.initState();
    _loadPendingMessages();
  }

  Future<void> _loadPendingMessages() async {
    final messages = await _databaseService.getPendingMessages(currentUserId);
    List<Map<String, dynamic>> messagesWithUsernames = [];

    for (var message in messages) {
      final user = await _databaseService.getUser(message.senderId);
      messagesWithUsernames.add({
        'message': message,
        'username': user.name,
      });
    }

    setState(() {
      pendingMessages = messagesWithUsernames;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Skill Swap'),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.notifications),
                onPressed: () {
                  _showNotificationDialog();
                },
              ),
              if (pendingMessages.isNotEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    constraints: BoxConstraints(
                      minWidth: 16,
                      minHeight: 16,
                    ),
                    child: Text(
                      '${pendingMessages.length}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
          IconButton(
            icon: Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileScreen(userId: currentUserId),
                ),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Skill>>(
        stream: _databaseService.getSkills(currentUserId),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasData) {
            final skills = snapshot.data!;
            if (skills.isEmpty) {
              return Center(child: Text('No skills available yet.'));
            }

            return ListView.builder(
              itemCount: skills.length,
              itemBuilder: (context, index) {
                final skill = skills[index];
                return Card(
                  elevation: 5,
                  margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column( // Use a Column to stack image and ListTile
                    children: [
                      if (skill.imageUrl != null && skill.imageUrl!.isNotEmpty)
                        Image.network(
                          skill.imageUrl!,
                          height: 150, // Adjust height as needed
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ListTile(
                        title: Text(skill.skillName ?? 'No skill name'),
                        subtitle: Text(skill.userName ?? 'User name missing'),
                        trailing: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatScreen(
                                  receiverId: skill.userId ?? '',
                                  receiverName: skill.userName ?? 'User',
                                ),
                              ),
                            );
                          },
                          child: Text('Connect'),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          } else {
            return Center(child: Text('An unexpected error occurred.'));
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    AddSkillPage(userName: currentUserName)),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showNotificationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Pending Notifications'),
          content: SingleChildScrollView(
            child: ListBody(
              children: pendingMessages.map((item) {
                return ListTile(
                  title: Text('New message from ${item['username']}'),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatScreen(
                          receiverId: item['message'].senderId,
                          receiverName: item['username'],
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              child: Text('Close'),
              onPressed: () {
                setState(() {
                  pendingMessages = [];
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}