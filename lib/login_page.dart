import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'admin_menu.dart';
import 'user_menu.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isChecked = false;  // Untuk checkbox 'Remember Me'
  String errorMessage = ''; // Menyimpan pesan error jika login gagal

  Future<void> login() async {
    final url = Uri.parse('https://tinoganteng.com/apii/api.php');
    final response = await http.post(
      url,
      body: json.encode({
        'action': 'login',
        'username': usernameController.text,
        'password': passwordController.text,
      }),
      headers: {"Content-Type": "application/json"},
    );

    final responseData = json.decode(response.body);

    if (responseData['success']) {
      String userLevel = responseData['level'];
      String username = responseData['username'];

      // Convert id_login to string before storing
      String idLogin = responseData['id_login'].toString();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('username', username);
      await prefs.setString('userLevel', userLevel);
      await prefs.setString('id_login', idLogin);

      if (userLevel == 'admin') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => AdminMenu()),
        );
      } else if (userLevel == 'user') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => UserMenu()),
        );
      }
    } else {
      setState(() {
        errorMessage = 'Login failed! Please check your credentials.';
      });
    }
  }
//login par2
  
  https://paste.ofcode.org/wL9YQ43Lw734nw7gpn4MNG

