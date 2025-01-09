import 'package:flutter/material.dart';
import './models/user.dart';
import './services/user_service.dart';

class KelolaUserPage extends StatefulWidget {
  @override
  _KelolaUserPageState createState() => _KelolaUserPageState();
}

class _KelolaUserPageState extends State<KelolaUserPage> {
  final UserService _userService = UserService();
  List<User> _users = [];
  bool _isLoading = true;

  // Variabel untuk menyimpan daftar mahasiswa
  List<String> _mahasiswaList = [];
  String? _selectedMahasiswa;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
    _fetchMahasiswaList(); // Memuat daftar mahasiswa
  }

  Future<void> _fetchUsers() async {
    try {
      final users = await _userService.getUsers();
      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching users: $e');
    }
  }

  Future<void> _fetchMahasiswaList() async {
    try {
      final mahasiswa = await _userService.getMahasiswa();
      setState(() {
        _mahasiswaList = mahasiswa;
      });
    } catch (e) {
      debugPrint('Error fetching mahasiswa: $e');
    }
  }
