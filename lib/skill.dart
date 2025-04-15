// models/skill.dart
class Skill {
  final String? userId;
  final String? userName;
  final String? skillName;
  final String? address;
  final String? imageUrl; // Added imageUrl field

  Skill({
    this.userId,
    this.userName,
    this.skillName,
    this.address,
    this.imageUrl, // Added imageUrl parameter
  });

  factory Skill.fromMap(Map<String, dynamic> map) {
    return Skill(
      userId: map['userId'],
      userName: map['userName'],
      skillName: map['skillName'],
      address: map['address'],
      imageUrl: map['imageUrl'], // Added imageUrl from map
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'skillName': skillName,
      'address': address,
      'imageUrl': imageUrl, // Added imageUrl to map
    };
  }
}