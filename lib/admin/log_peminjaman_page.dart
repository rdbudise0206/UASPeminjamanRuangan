import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class LogPeminjamanPage extends StatefulWidget {
  @override
  _LogPeminjamanPageState createState() => _LogPeminjamanPageState();
}

class _LogPeminjamanPageState extends State<LogPeminjamanPage> {
  List _logList = [];
  bool _isLoading = true;
  final String baseUrl = 'https://tinoganteng.com/apii/api.php';

  @override
  void initState() {
    super.initState();
    _fetchLogData();
  }

  Future<void> _fetchLogData() async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        body: json.encode({'action': 'getLogPinjam'}),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          setState(() {
            _logList = data['logPinjam'];
            _isLoading = false;
          });
        } else {
          throw Exception('Failed to load data: ${data['message']}');
        }
      } else {
        throw Exception('Failed to connect to the server');
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Log Peminjaman'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _logList.isEmpty
          ? Center(child: Text('No data available'))
          : ListView.builder(
        itemCount: _logList.length,
        itemBuilder: (context, index) {
          final log = _logList[index];
          return Card(
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: ListTile(
              leading: CircleAvatar(
                child: Text(log['id_log'].toString()),
              ),
              title: Text('Status: ${log['status']}'),
              subtitle: Text('Waktu: ${log['waktu_perubahan']}'),
            ),
          );
        },
      ),
    );
  }
}
