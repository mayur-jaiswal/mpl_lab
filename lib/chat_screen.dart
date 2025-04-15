import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'message.dart';
import 'database_service.dart';

class ChatScreen extends StatefulWidget {
  final String receiverId;
  final String receiverName;
  final String? certificateLicenseNo;

  const ChatScreen({super.key, required this.receiverId, required this.receiverName, this.certificateLicenseNo});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final DatabaseService _databaseService = DatabaseService();
  final String currentUserId = FirebaseAuth.instance.currentUser!.uid;

  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _scheduleSession() async {
    final scheduledDateTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    try {
      await FirebaseFirestore.instance.collection('sessions').add({
        'timestamp': scheduledDateTime,
        'user1Id': currentUserId,
        'user2Id': widget.receiverId,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Session scheduled successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to schedule session: $e')),
      );
    }
  }

  void _showScheduleDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Schedule Session'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}"),
                  ElevatedButton(
                    onPressed: () => _selectDate(context),
                    child: Text('Pick Date'),
                  ),
                  SizedBox(height: 10),
                  Text("Time: ${_selectedTime.format(context)}"),
                  ElevatedButton(
                    onPressed: () => _selectTime(context),
                    child: Text('Pick Time'),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    _scheduleSession();
                    Navigator.of(context).pop();
                  },
                  child: Text('Schedule'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    print("Building ChatScreen with AppBar");

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.receiverName),
        actions: [
          IconButton(
            icon: Icon(Icons.calendar_month),
            onPressed: () {
              print("Schedule session button pressed!");
              _showScheduleDialog();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (widget.certificateLicenseNo != null && widget.certificateLicenseNo!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("Certificate/License No: ${widget.certificateLicenseNo}"),
            ),
          Expanded(
            child: StreamBuilder<List<Message>>(
              stream: _databaseService.getMessages(currentUserId, widget.receiverId),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasData) {
                  final messages = snapshot.data!;
                  return ListView.builder(
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      return ListTile(
                        title: Text(message.text),
                        subtitle: Text(message.senderId == currentUserId ? 'You' : widget.receiverName),
                        trailing: Text(DateFormat('yyyy-MM-dd HH:mm').format(message.timestamp)),
                      );
                    },
                  );
                } else {
                  return Center(child: Text('No messages yet.'));
                }
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(hintText: 'Type a message...'),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: () {
                    if (_messageController.text.isNotEmpty) {
                      final message = Message(
                        senderId: currentUserId,
                        receiverId: widget.receiverId,
                        text: _messageController.text,
                        timestamp: DateTime.now(),
                      );
                      _databaseService.sendMessage(message);
                      _messageController.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}