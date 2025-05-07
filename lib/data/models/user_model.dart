// lib/data/models/user_model.dart

class UserModel {
  final String id;
  final String firstName;
  final String username;

  UserModel({
    required this.id,
    required this.firstName,
    required this.username,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      firstName: json['first_name'] ?? '',
      username: json['username'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'first_name': firstName,
    'username': username,
  };
}
