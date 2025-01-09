import 'package:flutter/material.dart';
import 'dart:math';
import '././models/ruangan.dart';
import '././services/ruangan_service.dart';

class KelolaRuanganPage extends StatefulWidget {
  const KelolaRuanganPage({Key? key}) : super(key: key);

  @override
  _KelolaRuanganPageState createState() => _KelolaRuanganPageState();
}

class _KelolaRuanganPageState extends State<KelolaRuanganPage> {
  final RuanganService _ruanganService = RuanganService();
  List<Ruangan> ruanganList = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadRuangan();
  }

  // Generate random room code
  String generateKodeRuangan() {
    final Random random = Random();
    String number = '';
    for (int i = 0; i < 5; i++) {
      number = number + random.nextInt(10).toString();
    }
    return 'K$number';
  }

  // Check if generated code is unique
  bool isKodeRuanganUnique(String kode) {
    return !ruanganList.any((ruangan) => ruangan.kdRuangan == kode);
  }

  // Get unique room code
  String getUniqueKodeRuangan() {
    String kode;
    do {
      kode = generateKodeRuangan();
    } while (!isKodeRuanganUnique(kode));
    return kode;
  }

  Future<void> _loadRuangan() async {
    setState(() => isLoading = true);
    try {
      ruanganList = await _ruanganService.getRuangan();
      print(ruanganList); // Debugging data ruangan
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading data: $e')),
        );
      }
    }
    if (mounted) {
      setState(() => isLoading = false);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Kelola Ruangan'),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: ruanganList.length,
        itemBuilder: (context, index) {
          final ruangan = ruanganList[index];
          return Card(
            margin: EdgeInsets.all(8),
            child: ListTile(
              title: Text(ruangan.namaRuangan),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Kode: ${ruangan.kdRuangan}'),
                  Text('${ruangan.namaGedung} - Lantai ${ruangan.lantai}'),
                ],
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () => _showFormDialog(ruangan),
                  ),
                  IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => _showDeleteDialog(ruangan),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showFormDialog(null),
        child: Icon(Icons.add),
      ),
    );
  }

  Future<void> _showFormDialog(Ruangan? ruangan) async {
    final isEditing = ruangan != null;
    final formKey = GlobalKey<FormState>();

    // For editing, use existing code. For new entry, generate unique code
    final kdController = TextEditingController(
        text: isEditing ? ruangan.kdRuangan : getUniqueKodeRuangan()
    );
    final namaController = TextEditingController(
        text: ruangan?.namaRuangan ?? '');
    final gedungController = TextEditingController(
        text: ruangan?.namaGedung ?? '');
    final lantaiController = TextEditingController(
        text: ruangan?.lantai?.toString() ?? '');

    String? validateNonEmpty(String? value) {
      if (value == null || value
          .trim()
          .isEmpty) {
        return 'Field ini harus diisi';
      }
      return null;
    }

    String? validateNumber(String? value) {
      if (value == null || value
          .trim()
          .isEmpty) {
        return 'Field ini harus diisi';
      }
      if (int.tryParse(value) == null) {
        return 'Masukkan angka yang valid';
      }
      return null;
    }

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          AlertDialog(
            title: Text(isEditing ? 'Edit Ruangan' : 'Tambah Ruangan'),
            content: Form(
              key: formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Display kode ruangan as read-only
                    TextFormField(
                      controller: kdController,
                      decoration: InputDecoration(
                        labelText: 'Kode Ruangan',
                        hintText: 'Kode ruangan otomatis',
                      ),
                      readOnly: true, // Make it read-only
                      enabled: false, // Disable the field
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: namaController,
                      decoration: InputDecoration(
                        labelText: 'Nama Ruangan',
                        hintText: 'Masukkan nama ruangan',
                      ),
                      validator: validateNonEmpty,
                      textInputAction: TextInputAction.next,
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: gedungController,
                      decoration: InputDecoration(
                        labelText: 'Nama Gedung',
                        hintText: 'Masukkan nama gedung',
                      ),
                      validator: validateNonEmpty,
                      textInputAction: TextInputAction.next,
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: lantaiController,
                      decoration: InputDecoration(
                        labelText: 'Lantai',
                        hintText: 'Masukkan nomor lantai',
                      ),
                      keyboardType: TextInputType.number,
                      validator: validateNumber,
                      textInputAction: TextInputAction.done,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Batal'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (formKey.currentState?.validate() ?? false) {
                    try {
                      final newRuangan = Ruangan(
                        idRuangan: ruangan?.idRuangan,
                        kdRuangan: kdController.text,
                        namaRuangan: namaController.text.trim(),
                        namaGedung: gedungController.text.trim(),
                        lantai: int.parse(lantaiController.text.trim()),
                        statusRuangan: 'tersedia',
                      );

                      if (isEditing) {
                        await _ruanganService.updateRuangan(newRuangan);
                      } else {
                        await _ruanganService.createRuangan(newRuangan);
                      }

                      if (mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(isEditing
                                ? 'Ruangan berhasil diupdate'
                                : 'Ruangan berhasil ditambahkan'),
                            backgroundColor: Colors.green,
                          ),
                        );
                        _loadRuangan();
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error: ${e.toString()}'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    }
                  }
                },
                child: Text(isEditing ? 'Update' : 'Simpan'),
              ),
            ],
          ),
    );
  }

  Future<void> _showDeleteDialog(Ruangan ruangan) async {
    print('Delete dialog opened for ruangan: ${ruangan.toString()}');

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Hapus Ruangan'),
        content: Text('Yakin ingin menghapus ${ruangan.namaRuangan}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                setState(() => isLoading = true);

                // Pass the kdRuangan to the delete method
                final success = await _ruanganService.deleteRuangan(ruangan.kdRuangan);

                if (mounted) {
                  Navigator.pop(context);
                  if (success) {
                    await _loadRuangan();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Ruangan berhasil dihapus'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else {
                    throw Exception('Gagal menghapus ruangan');
                  }
                }
              } catch (e) {
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error: ${e.toString()}'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              } finally {
                if (mounted) {
                  setState(() => isLoading = false);
                }
              }
            },
            child: Text('Hapus'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
          ),
        ],
      ),
    );
  }
}
