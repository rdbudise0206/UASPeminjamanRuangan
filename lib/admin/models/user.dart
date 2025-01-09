class User {
  final int idLogin;
  final String username;
  final String? password; // Jadikan opsional
  final String level;

  User({
    required this.idLogin,
    required this.username,
    this.password, // Opsional
    required this.level,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      idLogin: json['id_login'],
      username: json['username'],
      password: json['password'], // Bisa null
      level: json['level'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_login': idLogin,
      'username': username,
      'password': password,
      'level': level,
    };
  }
}
