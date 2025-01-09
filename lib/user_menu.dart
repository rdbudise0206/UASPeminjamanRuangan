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
   @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Peminjaman Ruangan'),
        actions: [
          IconButton(
            icon: Icon(Icons.history),
            onPressed: navigateToHistory,
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: logout,  // Logout function
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Visibility(
              visible: false, // Ubah menjadi true untuk menampilkan
              child: TextField(
                controller: usernameController,
                readOnly: true,
                enabled: false,
                decoration: InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedRuangan,
              decoration: InputDecoration(
                labelText: "Pilih Ruangan",
                border: OutlineInputBorder(),
              ),
              items: _ruanganList.map<DropdownMenuItem<String>>((ruangan) {
                return DropdownMenuItem<String>(
                  value: ruangan['kd_ruangan'],
                  child: Text("${ruangan['kd_ruangan']} - ${ruangan['nama_ruangan']}"),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedRuangan = value),
            ),
            SizedBox(height: 16),
            TextField(
              controller: tglPinjamController,
              decoration: InputDecoration(
                labelText: 'Tanggal Pinjam',
                suffixIcon: IconButton(
                  icon: Icon(Icons.calendar_today),
                  onPressed: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2101),
                    );
                    if (pickedDate != null) {
                      setState(() {
                        tglPinjamController.text = pickedDate.toLocal().toString().split(' ')[0];
                      });
                    }
                  },
                ),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: jamPinjamController,
              decoration: InputDecoration(
                labelText: 'Jam Mulai',
                suffixIcon: IconButton(
                  icon: Icon(Icons.access_time),
                  onPressed: () async {
                    TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (pickedTime != null) {
                      setState(() {
                        jamPinjamController.text = formatTimeOfDay(pickedTime);
                      });
                    }
                  },
                ),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: jamSelesaiController,
              decoration: InputDecoration(
                labelText: 'Jam Selesai',
                suffixIcon: IconButton(
                  icon: Icon(Icons.access_time),
                  onPressed: () async {
                    TimeOfDay? pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (pickedTime != null) {
                      setState(() {
                        jamSelesaiController.text = formatTimeOfDay(pickedTime);
                      });
                    }
                  },
                ),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: keteranganController,
              decoration: InputDecoration(
                labelText: 'Keterangan',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: addPinjam,
              child: Text('Ajukan Peminjaman'),
            ),
          ],
        ),
      ),
    );
  }
}


// HISTORY PAGE
class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key, required String username}) : super(key: key);

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late Future<List<dynamic>> _historyData;
  String? _username;

  @override
  void initState() {
    super.initState();
    _loadUserDataAndFetchHistory();
  }

  Future<void> _loadUserDataAndFetchHistory() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _username = prefs.getString('username');
      _historyData = _fetchHistory();
    });
  }

  Future<List<dynamic>> _fetchHistory() async {
    if (_username == null) {
      throw Exception('Username not found in SharedPreferences');
    }

    final url = Uri.parse('https://tinoganteng.com/apii/api.php');
    try {
      final response = await http.post(
        url,
        body: json.encode({
          'action': 'getHistory',
          'username': _username,
        }),
        headers: {"Content-Type": "application/json"},
      );

      final responseData = json.decode(response.body);

      if (responseData['success']) {
        return responseData['data'] ?? [];
      } else {
        throw Exception(responseData['message'] ?? 'Failed to load history');
      }
    } catch (e) {
      throw Exception('Error fetching history: $e');
    }
  }

  Color _getStatusColor(String? status) {
    if (status == null) return Colors.grey;

    switch (status.toUpperCase()) {
      case 'SETUJU':
        return Colors.blue;
      case 'DITOLAK':
        return Colors.red;
      case 'MENUNGGU KONFIRMASI':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  Icon _getStatusIcon(String? status) {
    if (status == null)
      return const Icon(Icons.hourglass_empty, color: Colors.grey);

    switch (status.toUpperCase()) {
      case 'SETUJU':
        return const Icon(Icons.check_circle, color: Colors.blue);
      case 'DITOLAK':
        return const Icon(Icons.cancel, color: Colors.red);
      case 'PENDING':
        return const Icon(Icons.hourglass_bottom, color: Colors.orange);
      default:
        return const Icon(Icons.help_outline, color: Colors.grey);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Peminjaman'),
      ),
      body: _username == null
          ? const Center(child: Text('Please login first'))
          : FutureBuilder<List<dynamic>>(
        future: _historyData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Error: ${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final historyList = snapshot.data ?? [];

          if (historyList.isEmpty) {
            return const Center(
              child: Text('Tidak ada riwayat peminjaman'),
            );
          }

          return ListView.builder(
            itemCount: historyList.length,
            itemBuilder: (context, index) {
              final history = historyList[index];
              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: ListTile(
                  title: Text(
                    "Ruangan: ${history['kd_ruangan']}",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Nama Ruangan: ${history['nama_ruangan']}"),
                      Text("Lantai: ${history['lantai']}"),
                      Text("Nama Gedung: ${history['nama_gedung']}"),
                      Text("Tanggal: ${history['tgl_pinjam']}"),
                      Text("Waktu: ${history['jam_pinjam']} - ${history['jam_selesai']}"),
                      Text("Keterangan: ${history['keterangan_kegunaan']}"),
                    ],
                  ),
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 6.0,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(history['status_pinjam']),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Text(
                      (history['status_pinjam'] ?? 'PENDING').toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12.0,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

}
