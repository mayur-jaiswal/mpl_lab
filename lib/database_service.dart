// services/database_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'skill.dart';
import 'message.dart';
import 'user_model.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addUser(UserModel user) async {
    print('addUser called with user: ${user.toMap()}');
    try {
      await _firestore.collection('users').doc(user.uid).set(user.toMap());
      print('User added successfully to Firestore.');
    } catch (e) {
      print('Error adding user to Firestore: $e');
      rethrow;
    }
  }

  Future<UserModel> getUser(String userId) async {
    print('getUser called with userId: $userId');
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot =
      await _firestore.collection('users').doc(userId).get();
      if (snapshot.exists) {
        print('User found: ${snapshot.data()}');
        return UserModel.fromMap(snapshot.data());
      } else {
        print('User not found.');
        throw Exception('User not found');
      }
    } catch (e) {
      print('Error getting user from Firestore: $e');
      rethrow;
    }
  }

  Future<void> addSkill(Skill skill) async {
    print('addSkill called with skill: ${skill.toMap()}');
    try {
      await _firestore.collection('skills').add(skill.toMap());
      print('Skill added successfully.');
    } catch (e) {
      print('Error adding skill: $e');
      rethrow;
    }
  }

  Stream<List<Skill>> getSkills(String currentUserId) {
    print('getSkills called with userId: $currentUserId');
    return _firestore.collection('skills').snapshots().map((snapshot) {
      print('Snapshot received: ${snapshot.docs.length} documents');
      try {
        return snapshot.docs
            .where((doc) => doc['userId'] != currentUserId)
            .map((doc) => Skill.fromMap(doc.data()))
            .toList();
      } catch (e) {
        print('Error processing skills snapshot: $e');
        return [];
      }
    });
  }

  Stream<List<Message>> getMessages(String senderId, String receiverId) {
    print(
        'getMessages called with senderId: $senderId, receiverId: $receiverId');
    return _firestore
        .collection('messages')
        .where(Filter.or(
      Filter.and(
        Filter('senderId', isEqualTo: senderId),
        Filter('receiverId', isEqualTo: receiverId),
      ),
      Filter.and(
        Filter('senderId', isEqualTo: receiverId),
        Filter('receiverId', isEqualTo: senderId),
      ),
    ))
        .snapshots()
        .map((snapshot) {
      print('Messages snapshot received: ${snapshot.docs.length} documents');
      try {
        return snapshot.docs.map((doc) => Message.fromMap(doc.data())).toList();
      } catch (e) {
        print('Error processing messages snapshot: $e');
        return [];
      }
    });
  }
  //services/database_service.dart
  Future<List<Message>> getPendingMessages(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('messages')
          .where('receiverId', isEqualTo: userId)
          .get();
      List<Message> pending = snapshot.docs
          .map((doc) => Message.fromMap(doc.data()))
          .toList();

      return pending;
    } catch (e) {
      print('Error getting pending messages: $e');
      return [];
    }
  }
  Future<void> sendMessage(Message message) async {
    print('sendMessage called with message: ${message.toMap()}');
    try {
      await _firestore.collection('messages').add(message.toMap());
      print('Message sent successfully.');
    } catch (e) {
      print('Error sending message: $e');
      rethrow;
    }
  }
}