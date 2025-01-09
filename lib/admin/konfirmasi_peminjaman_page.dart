import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class KonfirmasiPeminjamanPage extends StatefulWidget {
  @override
  _KonfirmasiPeminjamanPageState createState() =>
      _KonfirmasiPeminjamanPageState();
}

class _KonfirmasiPeminjamanPageState extends State<KonfirmasiPeminjamanPage> {
  final String baseUrl = 'https://tinoganteng.com/apii/api.php';
  List _pinjamanList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPinjamanData();
  }

  Future<void> _fetchPinjamanData() async {
    try {
      print('Fetching data from API...');
      final response = await http.post(
        Uri.parse(baseUrl),
        body: json.encode({'action': 'getPinjamanDetails'}),
        headers: {'Content-Type': 'application/json'},
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          setState(() {
            _pinjamanList = data['data']
                .where((item) => item['status_pinjam'] == 'MENUNGGU KONFIRMASI')
                .toList();
            _isLoading = false;
          });
        } else {
          throw Exception('Failed to load data: ${data['message']}');
        }
      } else {
        throw Exception('Failed to connect to the server');
      }
    } catch (e) {
      print('Error fetching data: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateStatus(int idPinjam, String newStatus) async {
    if (idPinjam == null || newStatus.isEmpty) {
      print('Error: Invalid parameters');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Parameter tidak valid')),
      );
      return;
    }

    try {
      final requestBody = {
        'action': 'updateStatus',
        'id_pinjam': idPinjam,
        'status_pinjam': newStatus,
      };

      print('Request body: ${json.encode(requestBody)}');

      final response = await http.post(
        Uri.parse(baseUrl),
        body: json.encode(requestBody),
        headers: {'Content-Type': 'application/json'},
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Status berhasil diperbarui')),
          );
          _fetchPinjamanData(); // Refresh data
        } else {
          throw Exception('Failed to update status: ${data['message']}');
        }
      } else {
        throw Exception('Failed to connect to the server');
      }
    } catch (e) {
      print('Error updating status: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memperbarui status')),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Konfirmasi Peminjaman'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _pinjamanList.isEmpty
          ? Center(child: Text('Tidak ada data yang perlu dikonfirmasi'))
          : ListView.builder(
        itemCount: _pinjamanList.length,
        itemBuilder: (context, index) {
          final pinjaman = _pinjamanList[index];
          final int idPinjam = pinjaman['id_pinjam'];

          return Card(
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: ListTile(
              title: Text(
                  'Pinjaman: ${pinjaman['kd_pinjam']} - ${pinjaman['nama_ruangan']}'),
              subtitle: Text(
                'Tanggal: ${pinjaman['tgl_pinjam']}\n'
                    'Waktu: ${pinjaman['jam_pinjam']} - ${pinjaman['jam_selesai']}\n'
                    'Nama Mahasiswa: ${pinjaman['nama_mahasiswa']}\n'
                    'Gedung: ${pinjaman['nama_gedung']} (Lantai: ${pinjaman['lantai']})',
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.check, color: Colors.green),
                    onPressed: () => _updateStatus(idPinjam, 'SETUJU'),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.red),
                    onPressed: () => _updateStatus(idPinjam, 'DITOLAK'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
