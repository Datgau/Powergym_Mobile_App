class User {
  final int id;
  final String username;
  final String email;
  final String? fullName;
  final String? phoneNumber;
  final String role;
  final String? avatarUrl;
  
  User({
    required this.id,
    required this.username,
    required this.email,
    this.fullName,
    this.phoneNumber,
    required this.role,
    this.avatarUrl,
  });
  
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      username: json['username'] as String,
      email: json['email'] as String,
      fullName: json['fullName'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      role: json['role'] as String,
      avatarUrl: json['avatarUrl'] as String?,
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'role': role,
      'avatarUrl': avatarUrl,
    };
  }
  
  bool get isTrainer => role == 'TRAINER';
  bool get isUser => role == 'USER';
  bool get isAdmin => role == 'ADMIN';
}
