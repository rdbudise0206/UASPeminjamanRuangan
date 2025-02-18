import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'admin/konfirmasi_peminjaman_page.dart';
import 'admin/log_peminjaman_page.dart';
import 'admin/kelola_ruangan_page.dart';
import 'admin/kelola_user_page.dart';
import 'login_page.dart';

class AdminMenu extends StatefulWidget {
  @override
  _AdminMenuState createState() => _AdminMenuState();
}

class _AdminMenuState extends State<AdminMenu> {
  List mahasiswaList = [];
  List logList = [];

  void logout() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),  // Redirect to login screen
    );
  }

  Future<void> fetchMahasiswa() async {
    final url = Uri.parse('https://tinoganteng.com/apii/api.php');
    final response = await http.post(
      url,
      body: json.encode({'action': 'get_mahasiswa'}),
      headers: {"Content-Type": "application/json"},
    );

    final responseData = json.decode(response.body);
    setState(() {
      mahasiswaList = responseData;
    });
  }

  Future<void> fetchLogs() async {
    final url = Uri.parse('https://tinoganteng.com/apii/api.php');
    final response = await http.post(
      url,
      body: json.encode({'action': 'get_pinjam_ruangan'}),
      headers: {"Content-Type": "application/json"},
    );

    final responseData = json.decode(response.body);
    setState(() {
      logList = responseData;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchMahasiswa();
    fetchLogs();
  }
@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Menu'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: logout,
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue,
              ),
              child: Text(
                'Admin Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.check_circle),
              title: Text('Konfirmasi Peminjaman'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => KonfirmasiPeminjamanPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.history),
              title: Text('Riwayat Peminjaman'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => LogPeminjamanPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.room),
              title: Text('Kelola Ruangan'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => KelolaRuanganPage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.people),
              title: Text('Kelola User'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => KelolaUserPage()),
                );
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: logout,
            ),
          ],
        ),
      ),
      body: Center(
        child: Text('Select an option from the sidebar'),
      ),
    );
  }
}
