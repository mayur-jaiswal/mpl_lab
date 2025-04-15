// models/user_model.dart
class UserModel {
  final String uid;
  final String email;
  final String name;
  final String address;
  final List<String> skills;

  const UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.address,
    required this.skills,
  });

  factory UserModel.fromMap(Map<String, dynamic>? map) {
    return UserModel(
      uid: map?['uid'] ?? '',
      email: map?['email'] ?? 'No Email',
      name: map?['name'] ?? 'Unknown',
      address: map?['address'] ?? 'No Address',
      skills: List<String>.from(map?['skills'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'address': address,
      'skills': skills,
    };
  }
}