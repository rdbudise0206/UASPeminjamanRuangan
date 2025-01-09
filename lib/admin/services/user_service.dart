import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user.dart';

class UserService {
  static const String baseUrl = 'https://tinoganteng.com/apii/api.php/';
  Future<List<User>> getUsers() async {
    try {
      print('Fetching users...');
      final response = await http.post(
        Uri.parse(baseUrl),
        body: json.encode({'action': 'getUsers'}),
        headers: {'Content-Type': 'application/json'},
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true && data['users'] is List) {
          print('Users fetched successfully.');
          return (data['users'] as List)
              .map((userJson) => User.fromJson(userJson))
              .toList();
        } else {
          print('Invalid response structure: $data');
          throw Exception('Response tidak valid');
        }
      } else {
        print('Failed to fetch users. Status code: ${response.statusCode}');
        throw Exception('Failed to load users');
      }
    } catch (e) {
      print('Error fetching users: $e');
      rethrow;
    }
  }

  Future<void> createUsername(String username, String password, String level) async {
    try {
      print('Creating user...');
      final response = await http.post(
        Uri.parse(baseUrl),
        body: json.encode({
          'action': 'createUsername',
          'username': username,
          'password': password,
          'level': level, // Sertakan field level
        }),
        headers: {'Content-Type': 'application/json'},
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        print('User created successfully.');
      } else {
        print('Failed to create user. Status code: ${response.statusCode}');
        throw Exception('Failed to create user');
      }
    } catch (e) {
      print('Error creating user: $e');
      rethrow;
    }
  }

  Future<void> updateUsername(
      int idLogin, String username, String password, String level) async {
    try {
      print('Updating user with ID: $idLogin...');
      final response = await http.post(
        Uri.parse(baseUrl),
        body: json.encode({
          'action': 'updateUsername',
          'id_login': idLogin,
          'username': username,
          'password': password,
          'level': level, // Sertakan field level
        }),
        headers: {'Content-Type': 'application/json'},
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        print('User updated successfully.');
      } else {
        print('Failed to update user. Status code: ${response.statusCode}');
        throw Exception('Failed to update user');
      }
    } catch (e) {
      print('Error updating user: $e');
      rethrow;
    }
  }

  Future<void> deleteUsername(int idLogin) async {
    try {
      print('Deleting user with ID: $idLogin...');
      final response = await http.post(
        Uri.parse(baseUrl),
        body: json.encode({
          'action': 'deleteUsername',
          'id_login': idLogin,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        print('User deleted successfully.');
      } else {
        print('Failed to delete user. Status code: ${response.statusCode}');
        throw Exception('Failed to delete user');
      }
    } catch (e) {
      print('Error deleting user: $e');
      rethrow;
    }
  }

//   anomali
  Future<List<String>> getMahasiswa() async {
    final response = await http.post(
      Uri.parse('$baseUrl'),
      body: json.encode({'action': 'getMahasiswa'}),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success'] == true && data['mahasiswa'] is List) {
        return (data['mahasiswa'] as List)
            .map((mhs) => mhs['kd_mahasiswa'] as String)
            .toList();
      } else {
        throw Exception('Response tidak valid');
      }
    } else {
      throw Exception('Failed to fetch mahasiswa');
    }
  }

}
