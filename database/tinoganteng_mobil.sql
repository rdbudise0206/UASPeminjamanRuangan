-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: localhost:3306
-- Generation Time: Jan 09, 2025 at 11:54 AM
-- Server version: 11.4.4-MariaDB
-- PHP Version: 8.3.14

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `tinoganteng_mobil`
--

-- --------------------------------------------------------

--
-- Table structure for table `login`
--

CREATE TABLE `login` (
  `id_login` int(11) NOT NULL,
  `username` varchar(20) NOT NULL,
  `password` varchar(255) NOT NULL,
  `level` enum('admin','user') NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `login`
--

INSERT INTO `login` (`id_login`, `username`, `password`, `level`) VALUES
(1, 'M001', '482c811da5d5b4bc6d497ffa98491e38', 'user'),
(2, 'M002', 'e28a09fe9d8ded87ea3a909ffc35cc45', 'user'),
(3, 'M003', '517f1f6f05a73af655fe722e51875dd0', 'admin'),
(7, 'admin', '0192023a7bbd73250516f069df18b500', 'admin');

-- --------------------------------------------------------

--
-- Table structure for table `log_pinjam`
--

CREATE TABLE `log_pinjam` (
  `id_log` int(11) NOT NULL,
  `kd_pinjam` varchar(20) NOT NULL,
  `status_lama` varchar(20) DEFAULT NULL,
  `status_baru` varchar(20) NOT NULL,
  `waktu_perubahan` timestamp NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `log_pinjam`
--

INSERT INTO `log_pinjam` (`id_log`, `kd_pinjam`, `status_lama`, `status_baru`, `waktu_perubahan`) VALUES
(1, 'P002', 'MENUNGGU KONFIRMASI', 'SETUJU', '2025-01-06 14:31:03'),
(2, 'P002', 'SETUJU', 'DITOLAK', '2025-01-06 14:31:03'),
(3, 'P10867', 'MENUNGGU KONFIRMASI', 'SETUJU', '2025-01-06 18:45:51'),
(4, 'P63089', 'MENUNGGU KONFIRMASI', 'DITOLAK', '2025-01-06 20:46:34'),
(5, 'P19317', 'MENUNGGU KONFIRMASI', 'SETUJU', '2025-01-07 00:50:19'),
(6, 'P76769', 'MENUNGGU KONFIRMASI', 'DITOLAK', '2025-01-07 01:33:17'),
(7, 'P38344', 'MENUNGGU KONFIRMASI', 'SETUJU', '2025-01-07 01:33:28'),
(8, 'P19317', 'SETUJU', 'MENUNGGU KONFIRMASI', '2025-01-07 01:33:59'),
(9, 'P76769', 'DITOLAK', 'MENUNGGU KONFIRMASI', '2025-01-07 01:34:04'),
(10, 'P38344', 'SETUJU', 'MENUNGGU KONFIRMASI', '2025-01-07 01:34:10'),
(11, 'P19317', 'MENUNGGU KONFIRMASI', 'SETUJU', '2025-01-07 01:35:16');

-- --------------------------------------------------------

--
-- Table structure for table `mahasiswa`
--

CREATE TABLE `mahasiswa` (
  `id_mahasiswa` int(11) NOT NULL,
  `kd_mahasiswa` varchar(20) NOT NULL,
  `nama_mahasiswa` varchar(100) NOT NULL,
  `kelas_mahasiswa` varchar(20) NOT NULL,
  `prodi_mahasiswa` varchar(50) NOT NULL,
  `nohp_mahasiswa` varchar(15) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `mahasiswa`
--

INSERT INTO `mahasiswa` (`id_mahasiswa`, `kd_mahasiswa`, `nama_mahasiswa`, `kelas_mahasiswa`, `prodi_mahasiswa`, `nohp_mahasiswa`) VALUES
(1, 'M001', 'Budi Santoso', '3A', 'Teknik Informatika', '081234567890'),
(2, 'M002', 'Ani Wijaya', '3B', 'Sistem Informasi', '081234567891'),
(3, 'M003', 'Citra Dewi', '3A', 'Teknik Informatika', '081234567892'),
(4, 'M004', 'Doni Prakoso', '3C', 'Manajemen Informatika', '081234567893'),
(5, 'admin', 'admin', 'admin', 'admin', '081212159211');

-- --------------------------------------------------------

--
-- Table structure for table `pinjam_ruangan`
--

CREATE TABLE `pinjam_ruangan` (
  `id_pinjam` int(11) NOT NULL,
  `kd_pinjam` varchar(20) NOT NULL,
  `kd_ruangan` varchar(20) NOT NULL,
  `tgl_pinjam` date NOT NULL,
  `jam_pinjam` time NOT NULL,
  `jam_selesai` time NOT NULL,
  `keterangan_kegunaan` text NOT NULL,
  `status_pinjam` enum('MENUNGGU KONFIRMASI','SETUJU','DITOLAK') DEFAULT 'MENUNGGU KONFIRMASI',
  `username` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `pinjam_ruangan`
--

INSERT INTO `pinjam_ruangan` (`id_pinjam`, `kd_pinjam`, `kd_ruangan`, `tgl_pinjam`, `jam_pinjam`, `jam_selesai`, `keterangan_kegunaan`, `status_pinjam`, `username`) VALUES
(1, 'P001', 'R001', '2025-01-10', '08:00:00', '10:00:00', 'Praktikum Database', 'SETUJU', ''),
(2, 'P002', 'R002', '2025-01-10', '13:00:00', '15:00:00', 'Workshop Programming', 'DITOLAK', ''),
(3, 'P003', 'R003', '2025-01-11', '09:00:00', '11:00:00', 'Rapat Himpunan', 'DITOLAK', ''),
(4, 'P004', 'R004', '2025-01-12', '10:00:00', '12:00:00', 'Seminar Tugas Akhir', 'SETUJU', ''),
(10, 'P743', 'R004', '2025-01-06', '23:11:00', '23:11:00', 'asd', 'MENUNGGU KONFIRMASI', ''),
(11, 'P97187', 'R003', '2025-01-06', '23:17:00', '23:17:00', 'test', 'MENUNGGU KONFIRMASI', ''),
(12, 'P10867', 'R002', '2025-01-07', '00:57:00', '00:57:00', 'sas', 'SETUJU', 'M001'),
(13, 'P63089', 'R004', '2025-01-07', '02:47:00', '02:47:00', 'coba', 'DITOLAK', 'M001'),
(14, 'P38344', 'R003', '2025-01-07', '03:03:00', '03:03:00', 'test', 'MENUNGGU KONFIRMASI', 'M001'),
(15, 'P76769', 'R004', '2025-01-07', '03:04:00', '03:04:00', 'coba hidden', 'MENUNGGU KONFIRMASI', 'M001'),
(16, 'P19317', 'K62008', '2025-01-07', '04:53:00', '04:53:00', 'test', 'SETUJU', 'M001'),
(17, 'P83665', 'R004', '2025-01-10', '01:00:00', '03:00:00', 'test peminjaman ruangan dari Tomo', 'MENUNGGU KONFIRMASI', 'M001'),
(18, 'P07997', 'R002', '2025-01-11', '03:00:00', '04:00:00', 'test peminjaman ruangan untuk praktek Kalilinux_ dari Tomo', 'MENUNGGU KONFIRMASI', 'M001'),
(19, 'P83356', 'R004', '2025-01-12', '22:00:00', '12:00:00', 'test peminjaman ruangan Aula dari pratomo', 'MENUNGGU KONFIRMASI', 'M001'),
(20, 'P76759', 'R003', '2025-01-13', '13:00:00', '15:00:00', 'test Peminjaman ruangan Meeting dari pratomo', 'MENUNGGU KONFIRMASI', 'M001');

--
-- Triggers `pinjam_ruangan`
--
DELIMITER $$
CREATE TRIGGER `log_status_pinjam` AFTER UPDATE ON `pinjam_ruangan` FOR EACH ROW BEGIN
    IF OLD.status_pinjam != NEW.status_pinjam THEN
        INSERT INTO log_pinjam (kd_pinjam, status_lama, status_baru)
        VALUES (NEW.kd_pinjam, OLD.status_pinjam, NEW.status_pinjam);
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `ruangan`
--

CREATE TABLE `ruangan` (
  `id_ruangan` int(11) NOT NULL,
  `kd_ruangan` varchar(20) NOT NULL,
  `nama_ruangan` varchar(100) NOT NULL,
  `nama_gedung` varchar(100) NOT NULL,
  `lantai` int(11) NOT NULL,
  `status_ruangan` enum('dipinjam','tersedia') DEFAULT 'tersedia'
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

--
-- Dumping data for table `ruangan`
--

INSERT INTO `ruangan` (`id_ruangan`, `kd_ruangan`, `nama_ruangan`, `nama_gedung`, `lantai`, `status_ruangan`) VALUES
(1, 'R001', 'Lab Komputer 1', 'Gedung A', 1, 'tersedia'),
(2, 'R002', 'Lab Komputer 2', 'Gedung A', 1, 'tersedia'),
(3, 'R003', 'Ruang Meeting', 'Gedung B', 2, 'tersedia'),
(4, 'R004', 'Aula', 'Gedung C', 1, 'tersedia'),
(5, 'K62008', 'Rara', 'ABCD', 123, 'dipinjam'),
(9, 'K53455', 'coba update', 'ccds', 1111, 'tersedia');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `login`
--
ALTER TABLE `login`
  ADD PRIMARY KEY (`id_login`),
  ADD KEY `username` (`username`);

--
-- Indexes for table `log_pinjam`
--
ALTER TABLE `log_pinjam`
  ADD PRIMARY KEY (`id_log`),
  ADD KEY `kd_pinjam` (`kd_pinjam`);

--
-- Indexes for table `mahasiswa`
--
ALTER TABLE `mahasiswa`
  ADD PRIMARY KEY (`id_mahasiswa`),
  ADD UNIQUE KEY `kd_mahasiswa` (`kd_mahasiswa`);

--
-- Indexes for table `pinjam_ruangan`
--
ALTER TABLE `pinjam_ruangan`
  ADD PRIMARY KEY (`id_pinjam`),
  ADD UNIQUE KEY `kd_pinjam` (`kd_pinjam`),
  ADD KEY `kd_ruangan` (`kd_ruangan`);

--
-- Indexes for table `ruangan`
--
ALTER TABLE `ruangan`
  ADD PRIMARY KEY (`id_ruangan`),
  ADD UNIQUE KEY `kd_ruangan` (`kd_ruangan`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `login`
--
ALTER TABLE `login`
  MODIFY `id_login` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT for table `log_pinjam`
--
ALTER TABLE `log_pinjam`
  MODIFY `id_log` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT for table `mahasiswa`
--
ALTER TABLE `mahasiswa`
  MODIFY `id_mahasiswa` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `pinjam_ruangan`
--
ALTER TABLE `pinjam_ruangan`
  MODIFY `id_pinjam` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=21;

--
-- AUTO_INCREMENT for table `ruangan`
--
ALTER TABLE `ruangan`
  MODIFY `id_ruangan` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `login`
--
ALTER TABLE `login`
  ADD CONSTRAINT `login_ibfk_1` FOREIGN KEY (`username`) REFERENCES `mahasiswa` (`kd_mahasiswa`);

--
-- Constraints for table `log_pinjam`
--
ALTER TABLE `log_pinjam`
  ADD CONSTRAINT `log_pinjam_ibfk_1` FOREIGN KEY (`kd_pinjam`) REFERENCES `pinjam_ruangan` (`kd_pinjam`);

--
-- Constraints for table `pinjam_ruangan`
--
ALTER TABLE `pinjam_ruangan`
  ADD CONSTRAINT `pinjam_ruangan_ibfk_1` FOREIGN KEY (`kd_ruangan`) REFERENCES `ruangan` (`kd_ruangan`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
