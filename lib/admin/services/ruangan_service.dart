// lib/admin/services/ruangan_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/ruangan.dart';

class RuanganService {
  static const String baseUrl = 'https://tinoganteng.com/apii/api.php/';

  Future<List<Ruangan>> getRuangan() async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        body: json.encode({'action': 'getRuangan'}),
        headers: {"Content-Type": "application/json"},
      );

      print('Get Ruangan Response: ${response.body}'); // Debug print

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData.containsKey('ruangan') &&
            responseData['ruangan'] != null &&
            responseData['ruangan'] is List) {

          final ruanganList = (responseData['ruangan'] as List).map((item) {
            if (item is Map<String, dynamic>) {
              // Debug print for each item
              print('Processing ruangan item: $item');
              return Ruangan.fromJson(item);
            }
            throw Exception('Invalid data format for ruangan item');
          }).toList();

          // Debug print for created objects
          for (var ruangan in ruanganList) {
            print('Created Ruangan object: $ruangan');
          }

          return ruanganList;
        }
        return [];
      }
      throw Exception('Failed to load ruangan: Status code ${response.statusCode}');
    } catch (e) {
      print('Error in getRuangan: $e');
      throw Exception('Failed to load ruangan: $e');
    }
  }

  Future<bool> createRuangan(Ruangan ruangan) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        body: json.encode({
          'action': 'createRuangan',
          'kd_ruangan': ruangan.kdRuangan,
          'nama_ruangan': ruangan.namaRuangan,
          'nama_gedung': ruangan.namaGedung,
          'lantai': ruangan.lantai,
          'status_ruangan': ruangan.statusRuangan,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      print('Create Response: ${response.body}'); // Debug print

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData['success'] ?? false;
      }
      return false;
    } catch (e) {
      print('Error in createRuangan: $e');
      throw Exception('Failed to create ruangan: $e');
    }
  }

  Future<bool> deleteRuangan(String kdRuangan) async {
    try {
      // First, get the ruangan details to find its ID
      final ruanganList = await getRuangan();
      final ruanganToDelete = ruanganList.firstWhere(
            (ruangan) => ruangan.kdRuangan == kdRuangan,
        orElse: () => throw Exception('Ruangan tidak ditemukan'),
      );

      if (ruanganToDelete.idRuangan == null) {
        throw Exception('ID ruangan tidak ditemukan');
      }

      print('Found ruangan to delete: ${ruanganToDelete.toString()}'); // Debug print

      final response = await http.post(
        Uri.parse(baseUrl),
        body: json.encode({
          'action': 'deleteRuangan',
          'id_ruangan': ruanganToDelete.idRuangan,  // Send the ID instead of kode
        }),
        headers: {'Content-Type': 'application/json'},
      );

      print('Delete Response: ${response.body}'); // Debug print

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['success'] == true) {
          return true;
        } else {
          throw Exception(responseData['message'] ?? 'Gagal menghapus ruangan');
        }
      }
      throw Exception('Server error: ${response.statusCode}');
    } catch (e) {
      print('Error in deleteRuangan: $e');
      throw Exception(e.toString());
    }
  }


  Future<bool> updateRuangan(Ruangan ruangan) async {
    try {
      print('Attempting to update ruangan: ${ruangan.toString()}'); // Debug print

      final response = await http.post(
        Uri.parse(baseUrl),
        body: json.encode({
          'action': 'updateRuangan',
          'kd_ruangan': ruangan.kdRuangan,
          'nama_ruangan': ruangan.namaRuangan,
          'nama_gedung': ruangan.namaGedung,
          'lantai': ruangan.lantai,
          'status_ruangan': ruangan.statusRuangan,
        }),
        headers: {'Content-Type': 'application/json'},
      );

      print('Update Response Status: ${response.statusCode}'); // Debug print
      print('Update Response Body: ${response.body}'); // Debug print

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return responseData['success'] ?? false;
      }
      return false;
    } catch (e) {
      print('Error in updateRuangan: $e');
      throw Exception('Gagal mengupdate ruangan: $e');
    }
  }
}
