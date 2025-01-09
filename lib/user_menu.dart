import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

import 'login_page.dart';

class UserMenu extends StatefulWidget {
  @override
  _UserMenuState createState() => _UserMenuState();
}

class _UserMenuState extends State<UserMenu> {
  final TextEditingController tglPinjamController = TextEditingController();
  final TextEditingController jamPinjamController = TextEditingController();
  final TextEditingController jamSelesaiController = TextEditingController();
  final TextEditingController keteranganController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();

  String? _selectedRuangan;
  List<dynamic> _ruanganList = [];
  Set<String> _usedKdPinjam = Set();
  String? _username;
  String? _idLogin;

  @override
  void initState() {
    super.initState();
    _fetchRuangan();
    _loadUserData();
  }

  Future<void> _fetchRuangan() async {
    final url = Uri.parse('https://tinoganteng.com/apii/api.php');
    final response = await http.post(
      url,
      body: json.encode({'action': 'getRuangan'}),
      headers: {"Content-Type": "application/json"},
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      if (responseData['success']) {
        setState(() {
          _ruanganList = responseData['ruangan'];
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengambil data ruangan')),
        );
      }
    }
  }

  Future<void> _loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? username = prefs.getString('username');
    String? idLogin = prefs.getString('id_login');

    if (username != null && idLogin != null) {
      setState(() {
        _username = username;
        _idLogin = idLogin;
        usernameController.text = username;
      });
    } else {
      await _fetchUsername();
    }
  }

  Future<void> _fetchUsername() async {
    final url = Uri.parse('https://tinoganteng.com/apii/api.php');
    final response = await http.post(
      url,
      body: json.encode({'action': 'getUsername'}),
      headers: {"Content-Type": "application/json"},
    );

    final responseData = json.decode(response.body);
    if (responseData['success']) {
      setState(() {
        _username = responseData['username'];
        _idLogin = responseData['id_login'];
        usernameController.text = responseData['username'];
      });

      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString('username', responseData['username']);
      prefs.setString('id_login', responseData['id_login']);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mengambil username')),
      );
    }
  }

  Future<void> addPinjam() async {
    if (_selectedRuangan == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Harap pilih ruangan')),
      );
      return;
    }

    if (tglPinjamController.text.isEmpty ||
        jamPinjamController.text.isEmpty ||
        jamSelesaiController.text.isEmpty ||
        keteranganController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Harap lengkapi semua data')),
      );
      return;
    }

    if (_username == null || _idLogin == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User belum terdaftar, silakan login kembali')),
      );
      return;
    }

    final kdPinjam = generateKdPinjam();
    final url = Uri.parse('https://tinoganteng.com/apii/api.php');

    try {
      final response = await http.post(
        url,
        body: json.encode({
          'action': 'savePinjaman',
          'kd_pinjam': kdPinjam,
          'kd_ruangan': _selectedRuangan,
          'tgl_pinjam': tglPinjamController.text,
          'jam_pinjam': jamPinjamController.text,
          'jam_selesai': jamSelesaiController.text,
          'keterangan_kegunaan': keteranganController.text,
          'username': _username,
          'id_login': _idLogin,
        }),
        headers: {"Content-Type": "application/json"},
      );

      final responseData = json.decode(response.body);

      if (responseData['success']) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Peminjaman Berhasil'),
              content: Text('Tunggu Konfirmasi Akademik'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    // Bersihkan form
                    tglPinjamController.clear();
                    jamPinjamController.clear();
                    jamSelesaiController.clear();
                    keteranganController.clear();
                    setState(() {
                      _selectedRuangan = null;
                    });

                    // Navigasi ke tab history
                    Navigator.of(context).pop();
                    navigateToHistory();
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengajukan peminjaman')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Terjadi kesalahan: ${e.toString()}')),
      );
    }
  }

  String generateKdPinjam() {
    final random = Random();
    String kdPinjam;
    do {
      kdPinjam = 'P' + (random.nextInt(99999) + 1).toString().padLeft(5, '0');
    } while (_usedKdPinjam.contains(kdPinjam));

    _usedKdPinjam.add(kdPinjam);
    return kdPinjam;
  }

  Future<void> navigateToHistory() async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HistoryPage(username: _username!),
      ),
    );
  }

  void logout() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();  // Clear all stored data
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),  // Redirect to login screen
    );
  }

  String formatTimeOfDay(TimeOfDay time) {
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    return "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
  }
