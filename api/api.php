<?php
// ================SETTINGAN======================
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE');
header('Access-Control-Allow-Headers: Content-Type');

// Database connection
$host = "localhost";
$db   = "tinoganteng_mobil";
$user = "tinoganteng_mobil";
$pass = "flutterglobal123@";

try {
    $pdo = new PDO("mysql:host=$host;dbname=$db;charset=utf8mb4", $user, $pass);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
} catch (PDOException $e) {
    die(json_encode(["success" => false, "message" => "Database connection failed: " . $e->getMessage()]));
}

// Start session
session_start();

// Handle incoming API requests
$request = json_decode(file_get_contents("php://input"), true);
$action = $request['action'] ?? null;

// Utility function to send JSON responses
function sendResponse($data) {
    echo json_encode($data);
    exit();
}
// ================END SETTINGAN======================
// API Actions
switch ($action) {
    // ================LOGIN======================
        case 'login':
            $username = $request['username'] ?? '';
            $password = $request['password'] ?? '';
    
            // Hash password using MD5 (Note: MD5 is not recommended for security, use bcrypt instead)
            $hashedPassword = md5($password);
    
            $stmt = $pdo->prepare("SELECT * FROM login WHERE username = ? AND password = ?");
            $stmt->execute([$username, $hashedPassword]);
            $user = $stmt->fetch(PDO::FETCH_ASSOC);
    
            if ($user) {
                // Start session and store user ID for further use
                $_SESSION['user_id'] = $user['id_login'];  // Storing user_id in session
    
                // Send response including username and id_login
                sendResponse([
                    "success" => true,
                    "message" => "Login successful",
                    "level" => $user['level'],
                    "id_login" => $user['id_login'], // Send id_login
                    "username" => $user['username']  // Send username
                ]);
            } else {
                sendResponse(["success" => false, "message" => "Invalid credentials"]);
            }
            break;
    // ================END LOGIN======================
    
    // ================DATA MAHASISWA======================
        case 'getMahasiswa':
        try {
            $stmt = $pdo->prepare("SELECT id_mahasiswa, kd_mahasiswa FROM mahasiswa");
            $stmt->execute();
    
            $mahasiswa = $stmt->fetchAll(PDO::FETCH_ASSOC);
            sendResponse(["success" => true, "mahasiswa" => $mahasiswa]);
        } catch (PDOException $e) {
            sendResponse(["success" => false, "message" => "Error: " . $e->getMessage()]);
        }
        break;
        
        // Save or Update Mahasiswa (Admin)
        case 'saveMahasiswa':
            $id = $request['id_mahasiswa'] ?? null;
            $data = [
                $request['kd_mahasiswa'],
                $request['nama_mahasiswa'],
                $request['kelas_mahasiswa'],
                $request['prodi_mahasiswa'],
                $request['nohp_mahasiswa']
            ];
    
            if ($id) {
                $data[] = $id;
                $stmt = $pdo->prepare("UPDATE mahasiswa SET kd_mahasiswa = ?, nama_mahasiswa = ?, kelas_mahasiswa = ?, prodi_mahasiswa = ?, nohp_mahasiswa = ? WHERE id_mahasiswa = ?");
                $stmt->execute($data);
            } else {
                $stmt = $pdo->prepare("INSERT INTO mahasiswa (kd_mahasiswa, nama_mahasiswa, kelas_mahasiswa, prodi_mahasiswa, nohp_mahasiswa) VALUES (?, ?, ?, ?, ?)");
                $stmt->execute($data);
            }
            sendResponse(["success" => true, "message" => "Mahasiswa saved"]);
            break;
    
        // Delete Mahasiswa (Admin)
        case 'deleteMahasiswa':
            $id = $request['id_mahasiswa'] ?? null;
            if ($id) {
                $stmt = $pdo->prepare("DELETE FROM mahasiswa WHERE id_mahasiswa = ?");
                $stmt->execute([$id]);
                sendResponse(["success" => true, "message" => "Mahasiswa deleted"]);
            } else {
                sendResponse(["success" => false, "message" => "ID is required"]);
            }
            break;
    // ================END DATA MAHASISWA======================
            
    // ================PEMINJAMAN API======================
        // CREATE PINJAM
        case 'createPeminjaman':
            $kd_ruangan = $request['kd_ruangan'] ?? '';
            $tgl_pinjam = $request['tgl_pinjam'] ?? '';
            $jam_pinjam = $request['jam_pinjam'] ?? '';
            $jam_selesai = $request['jam_selesai'] ?? '';
            $keterangan = $request['keterangan_kegunaan'] ?? '';
                
            if ($kd_ruangan && $tgl_pinjam && $jam_pinjam && $jam_selesai && $keterangan) {
                $kd_pinjam = uniqid('PINJAM_');
                $stmt = $pdo->prepare("INSERT INTO pinjam_ruangan (kd_pinjam, kd_ruangan, tgl_pinjam, jam_pinjam, jam_selesai, keterangan_kegunaan) VALUES (?, ?, ?, ?, ?, ?)");
                $success = $stmt->execute([$kd_pinjam, $kd_ruangan, $tgl_pinjam, $jam_pinjam, $jam_selesai, $keterangan]);
                        if ($success) 
                        {
                            sendResponse(["success" => true, "message" => "Peminjaman berhasil diajukan"]);
                        } else {
                            sendResponse(["success" => false, "message" => "Gagal mengajukan peminjaman"]);
                        }
                        } else {
                            sendResponse(["success" => false, "message" => "Semua data harus diisi"]);
                        }
                        break;
                
        // Get Pinjaman Ruangan (Admin/User)
            case 'getPinjaman':
                $stmt = $pdo->query("SELECT * FROM pinjam_ruangan");
                    sendResponse(["success" => true, "data" => $stmt->fetchAll(PDO::FETCH_ASSOC)]);
                    break;
                
        // Save or Update Pinjaman Ruangan (User)
            case 'savePinjaman':
            // Ambil username dari inputan user (misalnya dari request)
                $username = $request['username'] ?? null;
            // Pastikan username ada dalam inputan
                    if (!$username) {
                        sendResponse(["success" => false, "message" => "Username tidak ditemukan dalam inputan"]);
                        break;
                    }
                
                    // Fetch other data from the request
                    $kd_pinjam = $request['kd_pinjam'] ?? null;
                    $kd_ruangan = $request['kd_ruangan'] ?? null;
                    $tgl_pinjam = $request['tgl_pinjam'] ?? null;
                    $jam_pinjam = $request['jam_pinjam'] ?? null;
                    $jam_selesai = $request['jam_selesai'] ?? null;
                    $keterangan_kegunaan = $request['keterangan_kegunaan'] ?? null;
                
                    // Validate required fields
                    if (!$kd_pinjam || !$kd_ruangan || !$tgl_pinjam || !$jam_pinjam || !$jam_selesai || !$keterangan_kegunaan) {
                        sendResponse(["success" => false, "message" => "Data tidak lengkap. Pastikan semua data terisi dengan benar."]);
                        break;
                    }
                
                    // Data to be inserted or updated, including username
                    $data = [
                        $kd_pinjam,
                        $kd_ruangan,
                        $tgl_pinjam,
                        $jam_pinjam,
                        $jam_selesai,
                        $keterangan_kegunaan,
                        $username  // Menggunakan username yang diterima dari inputan
                    ];
                
                    try {
                        // Jika ID pinjaman sudah ada, lakukan update; jika tidak, lakukan insert
                        if (isset($request['id_pinjam'])) {
                            $id = $request['id_pinjam'];
                            // Update data pinjam_ruangan
                            $data[] = $id;
                            $stmt = $pdo->prepare("UPDATE pinjam_ruangan SET kd_pinjam = ?, kd_ruangan = ?, tgl_pinjam = ?, jam_pinjam = ?, jam_selesai = ?, keterangan_kegunaan = ?, username = ? WHERE id_pinjam = ?");
                            $stmt->execute($data);
                            sendResponse(["success" => true, "message" => "Pinjaman berhasil diperbarui"]);
                        } else {
                            // Insert data pinjam_ruangan baru
                            $stmt = $pdo->prepare("INSERT INTO pinjam_ruangan (kd_pinjam, kd_ruangan, tgl_pinjam, jam_pinjam, jam_selesai, keterangan_kegunaan, username) VALUES (?, ?, ?, ?, ?, ?, ?)");
                            $stmt->execute($data);
                            sendResponse(["success" => true, "message" => "Pinjaman berhasil disimpan"]);
                        }
                    } catch (Exception $e) {
                        sendResponse(["success" => false, "message" => "Terjadi kesalahan saat memproses data: " . $e->getMessage()]);
                    }
                    break;
                    
        // UPDATESTAUS PINJAM
        case 'updateStatus':
        // Ambil parameter dari permintaan
            $input = json_decode(file_get_contents('php://input'), true);
            file_put_contents('php://stderr', print_r($input, true)); // Debug: Cetak input
        
            $idPinjam = $input['id_pinjam'] ?? null;
            $newStatus = $input['status_pinjam'] ?? null;
        
            // Validasi parameter
            if (!$idPinjam || !$newStatus) {
                file_put_contents('php://stderr', "Invalid parameters: id_pinjam=$idPinjam, status_pinjam=$newStatus\n"); // Debug
                sendResponse(["success" => false, "message" => "Invalid parameters"]);
                break;
            }
        
            try {
                $pdo->beginTransaction(); // Mulai transaksi
        
                // Perbarui status pinjaman
                $stmt = $pdo->prepare("UPDATE pinjam_ruangan SET status_pinjam = ? WHERE id_pinjam = ?");
                $success = $stmt->execute([$newStatus, $idPinjam]);
        
                if ($success && $newStatus === 'SETUJU') {
                    // Ambil kd_ruangan berdasarkan id_pinjam
                    $stmt = $pdo->prepare("SELECT kd_ruangan FROM pinjam_ruangan WHERE id_pinjam = ?");
                    $stmt->execute([$idPinjam]);
                    $kdRuangan = $stmt->fetchColumn();
                    file_put_contents('php://stderr', "kd_ruangan=$kdRuangan\n"); // Debug
        
                    if ($kdRuangan) {
                        // Perbarui status ruangan menjadi 'DIPINJAM'
                        $stmt = $pdo->prepare("UPDATE ruangan SET status_ruangan = 'DIPINJAM' WHERE kd_ruangan = ?");
                        $stmt->execute([$kdRuangan]);
                    }
                }
        
                $pdo->commit(); // Commit transaksi
                sendResponse(["success" => true, "message" => "Status berhasil diperbarui"]);
            } catch (Exception $e) {
                $pdo->rollBack(); // Rollback jika terjadi kesalahan
                file_put_contents('php://stderr', "Error: " . $e->getMessage() . "\n"); // Debug
                sendResponse(["success" => false, "message" => "Database error: " . $e->getMessage()]);
            }
        break;
    
    
        // getpinjamandetails
        case 'getPinjamanDetails':
            $stmt = $pdo->query("
                SELECT 
                    p.id_pinjam,
                    p.kd_pinjam, 
                    p.tgl_pinjam, 
                    p.jam_pinjam, 
                    p.jam_selesai, 
                    r.nama_ruangan, 
                    r.nama_gedung, 
                    r.lantai, 
                    m.nama_mahasiswa, 
                    p.status_pinjam
                FROM pinjam_ruangan p
                JOIN ruangan r ON p.kd_ruangan = r.kd_ruangan
                JOIN mahasiswa m ON p.username = m.kd_mahasiswa
                WHERE p.status_pinjam = 'MENUNGGU KONFIRMASI'
            ");
            $pinjamanDetails = $stmt->fetchAll(PDO::FETCH_ASSOC);
            sendResponse(["success" => true, "data" => $pinjamanDetails]);
        break;
        
        // LOG PINJAM API
        case 'getLogPinjam':
            $stmt = $pdo->prepare("SELECT id_log, status_baru AS status, waktu_perubahan FROM log_pinjam");
            $stmt->execute();
            $logPinjam = $stmt->fetchAll(PDO::FETCH_ASSOC);
            sendResponse(["success" => true, "logPinjam" => $logPinjam]);
        break;
        // END LOG PINJM
    // ================END PEMINJAMAN API======================
                    
    // ================RUANGAN API======================
        case 'getRuangan':
                $stmt = $pdo->prepare("SELECT id_ruangan, kd_ruangan, nama_ruangan, lantai FROM ruangan WHERE status_ruangan = 'tersedia'");
                $stmt->execute();
                $ruangan = $stmt->fetchAll(PDO::FETCH_ASSOC);
                    sendResponse(["success" => true, "ruangan" => $ruangan]);
        break;
                            
        case 'createRuangan':
            try {
                $data = json_decode(file_get_contents('php://input'), true);
                                
                $stmt = $pdo->prepare("INSERT INTO ruangan (kd_ruangan, nama_ruangan, nama_gedung, lantai, status_ruangan) 
                                                     VALUES (?, ?, ?, ?, ?)");
                                
                $stmt->execute([
                    $data['kd_ruangan'],
                    $data['nama_ruangan'],
                    $data['nama_gedung'],
                    $data['lantai'],
                    $data['status_ruangan']
                ]);
                                
                sendResponse([
                    "success" => true, 
                    "message" => "Ruangan berhasil ditambahkan",
                    "id" => $pdo->lastInsertId()
                ]);
                    } catch(PDOException $e) {
                        sendResponse(["success" => false, "message" => $e->getMessage()]);
                    }
        break;
    
    
       case 'updateRuangan':
            try {
            // Ambil data yang dikirim dalam request
                $data = json_decode(file_get_contents('php://input'), true);
            
            // Cek apakah data yang dibutuhkan ada
                $kdRuangan = isset($data['kd_ruangan']) ? $data['kd_ruangan'] : null;
                $namaRuangan = isset($data['nama_ruangan']) ? $data['nama_ruangan'] : null;
                $namaGedung = isset($data['nama_gedung']) ? $data['nama_gedung'] : null;
                $lantai = isset($data['lantai']) ? $data['lantai'] : null;
                $statusRuangan = isset($data['status_ruangan']) ? $data['status_ruangan'] : null;
    
            // Validasi input
                if (!$kdRuangan || !$namaRuangan || !$namaGedung || !$lantai || !$statusRuangan) {
                    sendResponse(["success" => false, "message" => "Data tidak lengkap"]);
                    break;
                }
    
            // Query update
                $stmt = $pdo->prepare("UPDATE ruangan SET nama_ruangan = ?, nama_gedung = ?, lantai = ?, status_ruangan = ? WHERE kd_ruangan = ?");
                $stmt->execute([$namaRuangan, $namaGedung, $lantai, $statusRuangan, $kdRuangan]);
        
                // Cek apakah data berhasil diperbarui
                if ($stmt->rowCount() > 0) {
                    sendResponse(["success" => true, "message" => "Ruangan berhasil diperbarui"]);
                } else {
                    sendResponse(["success" => false, "message" => "Ruangan tidak ditemukan atau data tidak berubah"]);
                }
            } catch(PDOException $e) {
                sendResponse(["success" => false, "message" => $e->getMessage()]);
        }
        break;
    
    
        // Delete room
        case 'deleteRuangan':
            try {
                // Ambil id_ruangan dari body request (POST)
                $data = json_decode(file_get_contents('php://input'), true);
        
                // Debugging: Log data yang diterima
                error_log(print_r($data, true));  // Pastikan data yang dikirim diterima dengan benar
        
                // Ambil ID dari data yang dikirim
                $id = isset($data['id_ruangan']) ? $data['id_ruangan'] : null;
        
                // Pastikan ID tidak kosong
                if (!$id) {
                    sendResponse(["success" => false, "message" => "ID ruangan tidak ditemukan"]);
                    break;
                }
        
                // Cek apakah ID ruangan ada di database sebelum menghapus
                $stmtCheck = $pdo->prepare("SELECT * FROM ruangan WHERE id_ruangan = ?");
                $stmtCheck->execute([$id]);
                $ruangan = $stmtCheck->fetch();
        
                // Jika tidak ada, kirimkan error
                if (!$ruangan) {
                    sendResponse(["success" => false, "message" => "ID ruangan tidak ditemukan di database"]);
                    break;
                }
        
                // Jika ID ada, lakukan penghapusan
                $stmt = $pdo->prepare("DELETE FROM ruangan WHERE id_ruangan = ?");
                $stmt->execute([$id]);
        
                sendResponse(["success" => true, "message" => "Ruangan berhasil dihapus"]);
            } catch(PDOException $e) {
                sendResponse(["success" => false, "message" => $e->getMessage()]);
        }
        break;
    // ================END API RUANGAN======================
    
    // ================API USER======================
        
     // Get Users
        case 'getUsers':
            try {
                $stmt = $pdo->prepare("SELECT id_login, username, level FROM login");
                $stmt->execute();
        
                $users = $stmt->fetchAll(PDO::FETCH_ASSOC);
                sendResponse(["success" => true, "users" => $users]);
            } catch (PDOException $e) {
                sendResponse(["success" => false, "message" => "Error fetching users: " . $e->getMessage()]);
            }
        break;
    
    // Create Users
        case 'createUsername':
            try {
                $data = json_decode(file_get_contents('php://input'), true);
        
                if (empty($data['username']) || empty($data['password']) || empty($data['level'])) {
                    sendResponse(["success" => false, "message" => "Username, password, dan level harus diisi"]);
                    break;
                }
        
                // Pastikan username ada di tabel mahasiswa
                $stmtCheck = $pdo->prepare("SELECT kd_mahasiswa FROM mahasiswa WHERE kd_mahasiswa = ?");
                $stmtCheck->execute([$data['username']]);
                if (!$stmtCheck->fetch()) {
                    sendResponse(["success" => false, "message" => "kd_mahasiswa tidak ditemukan"]);
                    break;
                }
        
                $hashedPassword = md5($data['password']);
                $stmt = $pdo->prepare("INSERT INTO login (username, password, level) VALUES (?, ?, ?)");
                $stmt->execute([$data['username'], $hashedPassword, $data['level']]);
        
                sendResponse(["success" => true, "message" => "User berhasil ditambahkan"]);
            } catch (PDOException $e) {
                sendResponse(["success" => false, "message" => "Error creating user: " . $e->getMessage()]);
            }
        break;
    
    // Update User
        case 'updateUsername':
            try {
                $data = json_decode(file_get_contents('php://input'), true);
        
                $idLogin = $data['id_login'] ?? null;
                $username = $data['username'] ?? null;
                $password = $data['password'] ?? null;
                $level = $data['level'] ?? null;
        
                if (!$idLogin || !$username || !$password || !$level) {
                    sendResponse(["success" => false, "message" => "Data tidak lengkap"]);
                    break;
                }
        
                $hashedPassword = md5($password);
        
                $stmt = $pdo->prepare("UPDATE login SET username = ?, password = ?, level = ? WHERE id_login = ?");
                $stmt->execute([$username, $hashedPassword, $level, $idLogin]);
        
                sendResponse([
                    "success" => $stmt->rowCount() > 0,
                    "message" => $stmt->rowCount() > 0 ? "User berhasil diperbarui" : "User tidak ditemukan atau data tidak berubah",
                    "debug" => ["id_login" => $idLogin, "username" => $username, "level" => $level]
                ]);
            } catch (PDOException $e) {
                sendResponse(["success" => false, "message" => "Error updating user: " . $e->getMessage()]);
            }
        break;
    
    // Delete User
        case 'deleteUsername':
            try {
                $data = json_decode(file_get_contents('php://input'), true);
        
                $idLogin = $data['id_login'] ?? null;
        
                if (!$idLogin) {
                    sendResponse(["success" => false, "message" => "ID Login tidak ditemukan"]);
                    break;
                }
        
                $stmtCheck = $pdo->prepare("SELECT * FROM login WHERE id_login = ?");
                $stmtCheck->execute([$idLogin]);
        
                if (!$stmtCheck->fetch()) {
                    sendResponse(["success" => false, "message" => "User tidak ditemukan di database"]);
                    break;
                }
        
                $stmt = $pdo->prepare("DELETE FROM login WHERE id_login = ?");
                $stmt->execute([$idLogin]);
        
                sendResponse([
                    "success" => true,
                    "message" => "User berhasil dihapus",
                    "debug" => ["id_login" => $idLogin]
                ]);
            } catch (PDOException $e) {
                sendResponse(["success" => false, "message" => "Error deleting user: " . $e->getMessage()]);
            }
        break;
    
    // ================END API USER======================
            
    // ================API ADMIN======================
        
        case 'getHistory':
            $data = json_decode(file_get_contents('php://input'), true);
            
            // Pastikan username ada dalam request
            if (isset($data['username'])) {
                $username = $data['username'];
                try {
                    // Ambil data riwayat peminjaman berdasarkan username
                    $stmt = $pdo->prepare("
                        SELECT 
                            pr.kd_pinjam,
                            pr.kd_ruangan,
                            pr.tgl_pinjam,
                            pr.jam_pinjam,
                            pr.jam_selesai,
                            pr.keterangan_kegunaan,
                            pr.status_pinjam,
                            r.nama_ruangan,
                            r.lantai,
                            r.nama_gedung -- Pastikan ini ada
                        FROM pinjam_ruangan pr
                        LEFT JOIN ruangan r ON pr.kd_ruangan = r.kd_ruangan
                        WHERE pr.username = ?
                        ORDER BY pr.tgl_pinjam DESC, pr.jam_pinjam DESC
                    ");
                    
                    $stmt->execute([$username]);
                    $history = $stmt->fetchAll(PDO::FETCH_ASSOC);
                    
                    sendResponse([
                        "success" => true,
                        "data" => $history,
                        "message" => count($history) > 0 ? "History found" : "No history found"
                    ]);
                } catch (PDOException $e) {
                    sendResponse([
                        "success" => false,
                        "message" => "Database error: " . $e->getMessage()
                    ]);
                }
            } else {
                sendResponse([
                    "success" => false,
                    "message" => "Username is required"
                ]);
            }
        break;
        
    // ================END API ADMIN======================
        // Default case
        default:
            sendResponse(["success" => false, "message" => "Invalid action"]);
}
?>
