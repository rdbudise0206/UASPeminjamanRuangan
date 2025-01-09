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
void _showUserForm({User? user}) {
    final TextEditingController passwordController = TextEditingController();
    _selectedMahasiswa = user?.username; // Pre-fill untuk edit
    String selectedLevel = user?.level ?? 'user';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(user == null ? 'Add User' : 'Edit User'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: _selectedMahasiswa,
                onChanged: (value) {
                  setState(() {
                    _selectedMahasiswa = value!;
                  });
                },
                items: _mahasiswaList.map((kdMahasiswa) {
                  return DropdownMenuItem(
                    value: kdMahasiswa,
                    child: Text(kdMahasiswa),
                  );
                }).toList(),
                decoration: InputDecoration(labelText: 'Username'),
              ),
              TextField(
                controller: passwordController,
                decoration: InputDecoration(labelText: 'Password'),
                obscureText: true,
              ),
              DropdownButtonFormField<String>(
                value: selectedLevel,
                onChanged: (value) {
                  setState(() {
                    selectedLevel = value!;
                  });
                },
                items: [
                  DropdownMenuItem(value: 'admin', child: Text('Admin')),
                  DropdownMenuItem(value: 'user', child: Text('User')),
                ],
                decoration: InputDecoration(labelText: 'Level'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (_selectedMahasiswa == null || passwordController.text.isEmpty) {
                  debugPrint('Please fill all fields');
                  return;
                }

                if (user == null) {
                  await _userService.createUsername(
                    _selectedMahasiswa!,
                    passwordController.text,
                    selectedLevel,
                  );
                } else {
                  await _userService.updateUsername(
                    user.idLogin,
                    _selectedMahasiswa!,
                    passwordController.text,
                    selectedLevel,
                  );
                }

                Navigator.pop(context);
                _fetchUsers();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }
  Future<void> _deleteUser(int idLogin) async {
    await _userService.deleteUsername(idLogin);
    _fetchUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kelola User'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _users.length,
        itemBuilder: (context, index) {
          final user = _users[index];
          return ListTile(
            title: Text(user.username),
            subtitle: Text(user.level),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () => _showUserForm(user: user),
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => _deleteUser(user.idLogin),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showUserForm(),
        child: Icon(Icons.add),
      ),
    );
  }
}
