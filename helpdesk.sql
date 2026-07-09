-- MySQL dump 10.13  Distrib 8.0.43, for Win64 (x86_64)
--
-- Host: localhost    Database: helpdesk_db
-- ------------------------------------------------------
-- Server version	8.0.30

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `attachments`
--

DROP TABLE IF EXISTS `attachments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `attachments` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `ticket_id` bigint unsigned NOT NULL,
  `file_name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `file_url` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `mime_type` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `file_size` bigint NOT NULL DEFAULT '0',
  `type` enum('image','file') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'file',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `attachments_ticket_id_foreign` (`ticket_id`),
  CONSTRAINT `attachments_ticket_id_foreign` FOREIGN KEY (`ticket_id`) REFERENCES `tickets` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `attachments`
--

LOCK TABLES `attachments` WRITE;
/*!40000 ALTER TABLE `attachments` DISABLE KEYS */;
INSERT INTO `attachments` VALUES (1,6,'scaled__7117_Screenshot 2026-07-03 225959__7160_Screenshot 2026-07-03 230008.jpeg','/storage/attachments/8iYNdknYBfQHBru6zhn49Itf8wHemC1ceUq2H7Ia.jpg','image/jpeg',97876,'image','2026-07-05 05:20:23','2026-07-05 05:20:23');
/*!40000 ALTER TABLE `attachments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cache`
--

DROP TABLE IF EXISTS `cache`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cache` (
  `key` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `value` mediumtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `expiration` bigint NOT NULL,
  PRIMARY KEY (`key`),
  KEY `cache_expiration_index` (`expiration`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cache`
--

LOCK TABLES `cache` WRITE;
/*!40000 ALTER TABLE `cache` DISABLE KEYS */;
/*!40000 ALTER TABLE `cache` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `cache_locks`
--

DROP TABLE IF EXISTS `cache_locks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `cache_locks` (
  `key` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `owner` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `expiration` bigint NOT NULL,
  PRIMARY KEY (`key`),
  KEY `cache_locks_expiration_index` (`expiration`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `cache_locks`
--

LOCK TABLES `cache_locks` WRITE;
/*!40000 ALTER TABLE `cache_locks` DISABLE KEYS */;
/*!40000 ALTER TABLE `cache_locks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `comments`
--

DROP TABLE IF EXISTS `comments`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `comments` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `ticket_id` bigint unsigned NOT NULL,
  `user_id` bigint unsigned NOT NULL,
  `content` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `is_internal` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `comments_ticket_id_foreign` (`ticket_id`),
  KEY `comments_user_id_foreign` (`user_id`),
  CONSTRAINT `comments_ticket_id_foreign` FOREIGN KEY (`ticket_id`) REFERENCES `tickets` (`id`) ON DELETE CASCADE,
  CONSTRAINT `comments_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `comments`
--

LOCK TABLES `comments` WRITE;
/*!40000 ALTER TABLE `comments` DISABLE KEYS */;
INSERT INTO `comments` VALUES (1,2,5,'pak, segera ya',0,'2026-07-02 22:26:52','2026-07-02 22:26:52'),(2,2,1,'segera diperbaiki',0,'2026-07-02 22:39:01','2026-07-02 22:39:01'),(3,2,4,'sudah resolved yaa',0,'2026-07-02 22:47:30','2026-07-02 22:47:30'),(4,3,5,'halo pak, segera yaaa biar bisa dipakai',0,'2026-07-03 07:21:49','2026-07-03 07:21:49'),(5,4,5,'bagaimana ya pakk',0,'2026-07-03 07:23:04','2026-07-03 07:23:04'),(6,3,2,'sudah saya perbaiki',0,'2026-07-03 07:28:02','2026-07-03 07:28:02');
/*!40000 ALTER TABLE `comments` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `migrations`
--

DROP TABLE IF EXISTS `migrations`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `migrations` (
  `id` int unsigned NOT NULL AUTO_INCREMENT,
  `migration` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `batch` int NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `migrations`
--

LOCK TABLES `migrations` WRITE;
/*!40000 ALTER TABLE `migrations` DISABLE KEYS */;
INSERT INTO `migrations` VALUES (1,'0001_01_01_000000_create_users_table',1),(2,'0001_01_01_000001_create_ticket_table',1),(3,'0001_01_01_000002_create_supporting_table',1),(4,'2026_06_12_022758_create_personal_access_tokens_table',1),(5,'2026_06_12_025832_create_cache_table',1),(6,'2026_06_22_033553_add_is_active_to_users',1);
/*!40000 ALTER TABLE `migrations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `notifications`
--

DROP TABLE IF EXISTS `notifications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `notifications` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `user_id` bigint unsigned NOT NULL,
  `title` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `body` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `type` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `ticket_id` bigint unsigned DEFAULT NULL,
  `is_read` tinyint(1) NOT NULL DEFAULT '0',
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `notifications_user_id_foreign` (`user_id`),
  KEY `notifications_ticket_id_foreign` (`ticket_id`),
  CONSTRAINT `notifications_ticket_id_foreign` FOREIGN KEY (`ticket_id`) REFERENCES `tickets` (`id`) ON DELETE SET NULL,
  CONSTRAINT `notifications_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=45 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notifications`
--

LOCK TABLES `notifications` WRITE;
/*!40000 ALTER TABLE `notifications` DISABLE KEYS */;
INSERT INTO `notifications` VALUES (1,1,'Tiket Baru Masuk','Tiket baru \"Wifi di ruang 202 tidak bisa dari kemarin\" dibuat oleh Cia Mahasiswa.','ticket_created',1,0,'2026-07-02 22:20:32','2026-07-02 22:20:32'),(2,2,'Tiket Baru Masuk','Tiket baru \"Wifi di ruang 202 tidak bisa dari kemarin\" dibuat oleh Cia Mahasiswa.','ticket_created',1,0,'2026-07-02 22:20:32','2026-07-02 22:20:32'),(3,3,'Tiket Baru Masuk','Tiket baru \"Wifi di ruang 202 tidak bisa dari kemarin\" dibuat oleh Cia Mahasiswa.','ticket_created',1,0,'2026-07-02 22:20:32','2026-07-02 22:20:32'),(4,4,'Tiket Baru Masuk','Tiket baru \"Wifi di ruang 202 tidak bisa dari kemarin\" dibuat oleh Cia Mahasiswa.','ticket_created',1,0,'2026-07-02 22:20:32','2026-07-02 22:20:32'),(5,4,'Tiket Baru Ditugaskan','Tiket \"Wifi di ruang 202 tidak bisa dari kemarin\" telah otomatis ditugaskan kepada Anda.','ticket_assigned',1,0,'2026-07-02 22:20:32','2026-07-02 22:20:32'),(6,1,'Tiket Baru Masuk','Tiket baru \"Wifi di ruang 202 tidak bisa dari kemarin\" dibuat oleh Cia Mahasiswa.','ticket_created',2,0,'2026-07-02 22:20:40','2026-07-02 22:20:40'),(7,2,'Tiket Baru Masuk','Tiket baru \"Wifi di ruang 202 tidak bisa dari kemarin\" dibuat oleh Cia Mahasiswa.','ticket_created',2,0,'2026-07-02 22:20:40','2026-07-02 22:20:40'),(8,3,'Tiket Baru Masuk','Tiket baru \"Wifi di ruang 202 tidak bisa dari kemarin\" dibuat oleh Cia Mahasiswa.','ticket_created',2,0,'2026-07-02 22:20:40','2026-07-02 22:20:40'),(9,4,'Tiket Baru Masuk','Tiket baru \"Wifi di ruang 202 tidak bisa dari kemarin\" dibuat oleh Cia Mahasiswa.','ticket_created',2,0,'2026-07-02 22:20:40','2026-07-02 22:20:40'),(10,4,'Tiket Baru Ditugaskan','Tiket \"Wifi di ruang 202 tidak bisa dari kemarin\" telah otomatis ditugaskan kepada Anda.','ticket_assigned',2,0,'2026-07-02 22:20:40','2026-07-02 22:20:40'),(11,5,'Tiket Sedang Ditangani','Tiket \"Wifi di ruang 202 tidak bisa dari kemarin\" ditangani oleh Helpdesk C.','ticket_assigned',2,0,'2026-07-02 22:34:36','2026-07-02 22:34:36'),(12,4,'Tiket Ditugaskan ke Anda','Tiket \"Wifi di ruang 202 tidak bisa dari kemarin\" telah ditugaskan kepada Anda.','ticket_assigned',2,0,'2026-07-02 22:34:36','2026-07-02 22:34:36'),(13,5,'Komentar Baru','Admin Sistem membalas tiket \"Wifi di ruang 202 tidak bisa dari kemarin\".','new_comment',2,0,'2026-07-02 22:39:01','2026-07-02 22:39:01'),(14,5,'Status Tiket Diperbarui','Status tiket \"Wifi di ruang 202 tidak bisa dari kemarin\" diubah menjadi resolved.','ticket_resolved',2,0,'2026-07-02 22:44:22','2026-07-02 22:44:22'),(15,5,'Komentar Baru','Helpdesk C membalas tiket \"Wifi di ruang 202 tidak bisa dari kemarin\".','new_comment',2,0,'2026-07-02 22:47:30','2026-07-02 22:47:30'),(16,5,'Status Tiket Diperbarui','Status tiket \"Wifi di ruang 202 tidak bisa dari kemarin\" diubah menjadi closed.','ticket_closed',2,0,'2026-07-02 22:47:46','2026-07-02 22:47:46'),(17,1,'Tiket Baru Masuk','Tiket baru \"Komputer di Lab. Intelligence tidak bisa dinyalakan\" dibuat oleh Cia Mahasiswa.','ticket_created',3,0,'2026-07-03 07:21:30','2026-07-03 07:21:30'),(18,2,'Tiket Baru Masuk','Tiket baru \"Komputer di Lab. Intelligence tidak bisa dinyalakan\" dibuat oleh Cia Mahasiswa.','ticket_created',3,0,'2026-07-03 07:21:30','2026-07-03 07:21:30'),(19,3,'Tiket Baru Masuk','Tiket baru \"Komputer di Lab. Intelligence tidak bisa dinyalakan\" dibuat oleh Cia Mahasiswa.','ticket_created',3,0,'2026-07-03 07:21:30','2026-07-03 07:21:30'),(20,4,'Tiket Baru Masuk','Tiket baru \"Komputer di Lab. Intelligence tidak bisa dinyalakan\" dibuat oleh Cia Mahasiswa.','ticket_created',3,0,'2026-07-03 07:21:30','2026-07-03 07:21:30'),(21,2,'Tiket Baru Ditugaskan','Tiket \"Komputer di Lab. Intelligence tidak bisa dinyalakan\" telah otomatis ditugaskan kepada Anda.','ticket_assigned',3,0,'2026-07-03 07:21:30','2026-07-03 07:21:30'),(22,1,'Tiket Baru Masuk','Tiket baru \"Akun cybercampus lupa password\" dibuat oleh Cia Mahasiswa.','ticket_created',4,0,'2026-07-03 07:22:50','2026-07-03 07:22:50'),(23,2,'Tiket Baru Masuk','Tiket baru \"Akun cybercampus lupa password\" dibuat oleh Cia Mahasiswa.','ticket_created',4,0,'2026-07-03 07:22:50','2026-07-03 07:22:50'),(24,3,'Tiket Baru Masuk','Tiket baru \"Akun cybercampus lupa password\" dibuat oleh Cia Mahasiswa.','ticket_created',4,0,'2026-07-03 07:22:50','2026-07-03 07:22:50'),(25,4,'Tiket Baru Masuk','Tiket baru \"Akun cybercampus lupa password\" dibuat oleh Cia Mahasiswa.','ticket_created',4,0,'2026-07-03 07:22:50','2026-07-03 07:22:50'),(26,3,'Tiket Baru Ditugaskan','Tiket \"Akun cybercampus lupa password\" telah otomatis ditugaskan kepada Anda.','ticket_assigned',4,0,'2026-07-03 07:22:50','2026-07-03 07:22:50'),(27,5,'Status Tiket Diperbarui','Status tiket \"Komputer di Lab. Intelligence tidak bisa dinyalakan\" diubah menjadi resolved.','ticket_resolved',3,0,'2026-07-03 07:27:47','2026-07-03 07:27:47'),(28,5,'Komentar Baru','Helpdesk A membalas tiket \"Komputer di Lab. Intelligence tidak bisa dinyalakan\".','new_comment',3,0,'2026-07-03 07:28:02','2026-07-03 07:28:02'),(29,1,'Tiket Baru Masuk','Tiket baru \"njjjjjjjjjjjjjjjjjjd\" dibuat oleh Cia Mahasiswa.','ticket_created',5,0,'2026-07-03 08:24:38','2026-07-03 08:24:38'),(30,2,'Tiket Baru Masuk','Tiket baru \"njjjjjjjjjjjjjjjjjjd\" dibuat oleh Cia Mahasiswa.','ticket_created',5,0,'2026-07-03 08:24:38','2026-07-03 08:24:38'),(31,3,'Tiket Baru Masuk','Tiket baru \"njjjjjjjjjjjjjjjjjjd\" dibuat oleh Cia Mahasiswa.','ticket_created',5,0,'2026-07-03 08:24:38','2026-07-03 08:24:38'),(32,4,'Tiket Baru Masuk','Tiket baru \"njjjjjjjjjjjjjjjjjjd\" dibuat oleh Cia Mahasiswa.','ticket_created',5,0,'2026-07-03 08:24:38','2026-07-03 08:24:38'),(33,4,'Tiket Baru Ditugaskan','Tiket \"njjjjjjjjjjjjjjjjjjd\" telah otomatis ditugaskan kepada Anda.','ticket_assigned',5,0,'2026-07-03 08:24:38','2026-07-03 08:24:38'),(34,5,'Tiket Sedang Ditangani','Tiket \"njjjjjjjjjjjjjjjjjjd\" ditangani oleh Helpdesk C.','ticket_assigned',5,0,'2026-07-03 08:57:57','2026-07-03 08:57:57'),(35,4,'Tiket Ditugaskan ke Anda','Tiket \"njjjjjjjjjjjjjjjjjjd\" telah ditugaskan kepada Anda.','ticket_assigned',5,0,'2026-07-03 08:57:57','2026-07-03 08:57:57'),(36,1,'Tiket Baru Masuk','Tiket baru \"Tidak bisa membuka aplikasi hebat\" dibuat oleh Cia Mahasiswa.','ticket_created',6,0,'2026-07-05 05:20:18','2026-07-05 05:20:18'),(37,2,'Tiket Baru Masuk','Tiket baru \"Tidak bisa membuka aplikasi hebat\" dibuat oleh Cia Mahasiswa.','ticket_created',6,0,'2026-07-05 05:20:18','2026-07-05 05:20:18'),(38,3,'Tiket Baru Masuk','Tiket baru \"Tidak bisa membuka aplikasi hebat\" dibuat oleh Cia Mahasiswa.','ticket_created',6,0,'2026-07-05 05:20:18','2026-07-05 05:20:18'),(39,4,'Tiket Baru Masuk','Tiket baru \"Tidak bisa membuka aplikasi hebat\" dibuat oleh Cia Mahasiswa.','ticket_created',6,0,'2026-07-05 05:20:18','2026-07-05 05:20:18'),(40,3,'Tiket Baru Ditugaskan','Tiket \"Tidak bisa membuka aplikasi hebat\" telah otomatis ditugaskan kepada Anda.','ticket_assigned',6,0,'2026-07-05 05:20:18','2026-07-05 05:20:18'),(41,5,'Tiket Sedang Ditangani','Tiket \"Tidak bisa membuka aplikasi hebat\" ditangani oleh Helpdesk B.','ticket_assigned',6,0,'2026-07-05 05:22:32','2026-07-05 05:22:32'),(42,3,'Tiket Ditugaskan ke Anda','Tiket \"Tidak bisa membuka aplikasi hebat\" telah ditugaskan kepada Anda.','ticket_assigned',6,0,'2026-07-05 05:22:32','2026-07-05 05:22:32'),(43,5,'Tiket Sedang Ditangani','Tiket \"Tidak bisa membuka aplikasi hebat\" ditangani oleh Helpdesk B.','ticket_assigned',6,0,'2026-07-05 05:22:34','2026-07-05 05:22:34'),(44,3,'Tiket Ditugaskan ke Anda','Tiket \"Tidak bisa membuka aplikasi hebat\" telah ditugaskan kepada Anda.','ticket_assigned',6,0,'2026-07-05 05:22:34','2026-07-05 05:22:34');
/*!40000 ALTER TABLE `notifications` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `personal_access_tokens`
--

DROP TABLE IF EXISTS `personal_access_tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `personal_access_tokens` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `tokenable_type` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `tokenable_id` bigint unsigned NOT NULL,
  `name` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `token` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `abilities` text COLLATE utf8mb4_unicode_ci,
  `last_used_at` timestamp NULL DEFAULT NULL,
  `expires_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `personal_access_tokens_token_unique` (`token`),
  KEY `personal_access_tokens_tokenable_type_tokenable_id_index` (`tokenable_type`,`tokenable_id`),
  KEY `personal_access_tokens_expires_at_index` (`expires_at`)
) ENGINE=InnoDB AUTO_INCREMENT=33 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `personal_access_tokens`
--

LOCK TABLES `personal_access_tokens` WRITE;
/*!40000 ALTER TABLE `personal_access_tokens` DISABLE KEYS */;
/*!40000 ALTER TABLE `personal_access_tokens` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `ticket_histories`
--

DROP TABLE IF EXISTS `ticket_histories`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `ticket_histories` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `ticket_id` bigint unsigned NOT NULL,
  `user_id` bigint unsigned NOT NULL,
  `action` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `ticket_histories_ticket_id_foreign` (`ticket_id`),
  KEY `ticket_histories_user_id_foreign` (`user_id`),
  CONSTRAINT `ticket_histories_ticket_id_foreign` FOREIGN KEY (`ticket_id`) REFERENCES `tickets` (`id`) ON DELETE CASCADE,
  CONSTRAINT `ticket_histories_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=20 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `ticket_histories`
--

LOCK TABLES `ticket_histories` WRITE;
/*!40000 ALTER TABLE `ticket_histories` DISABLE KEYS */;
INSERT INTO `ticket_histories` VALUES (1,1,5,'Tiket dibuat','2026-07-02 22:20:32','2026-07-02 22:20:32'),(2,1,4,'Auto-assign ke Helpdesk C (Jaringan / Internet & Email)','2026-07-02 22:20:32','2026-07-02 22:20:32'),(3,2,5,'Tiket dibuat','2026-07-02 22:20:39','2026-07-02 22:20:39'),(4,2,4,'Auto-assign ke Helpdesk C (Jaringan / Internet & Email)','2026-07-02 22:20:40','2026-07-02 22:20:40'),(5,2,1,'Tiket di-assign ke Helpdesk C','2026-07-02 22:34:36','2026-07-02 22:34:36'),(6,2,4,'Status diubah dari in_progress ke resolved','2026-07-02 22:44:22','2026-07-02 22:44:22'),(7,2,4,'Status diubah dari resolved ke closed','2026-07-02 22:47:46','2026-07-02 22:47:46'),(8,3,5,'Tiket dibuat','2026-07-03 07:21:30','2026-07-03 07:21:30'),(9,3,2,'Auto-assign ke Helpdesk A (Hardware & Printer)','2026-07-03 07:21:30','2026-07-03 07:21:30'),(10,4,5,'Tiket dibuat','2026-07-03 07:22:50','2026-07-03 07:22:50'),(11,4,3,'Auto-assign ke Helpdesk B (Software & Akun & Akses)','2026-07-03 07:22:50','2026-07-03 07:22:50'),(12,3,2,'Status diubah dari in_progress ke resolved','2026-07-03 07:27:47','2026-07-03 07:27:47'),(13,5,5,'Tiket dibuat','2026-07-03 08:24:38','2026-07-03 08:24:38'),(14,5,4,'Auto-assign ke Helpdesk C (Jaringan / Internet & Email)','2026-07-03 08:24:38','2026-07-03 08:24:38'),(15,5,1,'Tiket di-assign ke Helpdesk C','2026-07-03 08:57:57','2026-07-03 08:57:57'),(16,6,5,'Tiket dibuat','2026-07-05 05:20:18','2026-07-05 05:20:18'),(17,6,3,'Auto-assign ke Helpdesk B (Software & Akun & Akses)','2026-07-05 05:20:18','2026-07-05 05:20:18'),(18,6,1,'Tiket di-assign ke Helpdesk B','2026-07-05 05:22:32','2026-07-05 05:22:32'),(19,6,1,'Tiket di-assign ke Helpdesk B','2026-07-05 05:22:34','2026-07-05 05:22:34');
/*!40000 ALTER TABLE `ticket_histories` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `tickets`
--

DROP TABLE IF EXISTS `tickets`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `tickets` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `title` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `status` enum('open','in_progress','resolved','closed') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'open',
  `priority` enum('low','medium','high','critical') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'medium',
  `category` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `reporter_id` bigint unsigned NOT NULL,
  `assigned_to` bigint unsigned DEFAULT NULL,
  `resolved_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `tickets_reporter_id_foreign` (`reporter_id`),
  KEY `tickets_assigned_to_foreign` (`assigned_to`),
  CONSTRAINT `tickets_assigned_to_foreign` FOREIGN KEY (`assigned_to`) REFERENCES `users` (`id`) ON DELETE SET NULL,
  CONSTRAINT `tickets_reporter_id_foreign` FOREIGN KEY (`reporter_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `tickets`
--

LOCK TABLES `tickets` WRITE;
/*!40000 ALTER TABLE `tickets` DISABLE KEYS */;
INSERT INTO `tickets` VALUES (1,'Wifi di ruang 202 tidak bisa dari kemarin','Kalau dipakai ada tulisan \"No Internet\" teruis','in_progress','low','Jaringan / Internet',5,4,NULL,'2026-07-02 22:20:32','2026-07-02 22:20:32',NULL),(2,'Wifi di ruang 202 tidak bisa dari kemarin','Kalau dipakai ada tulisan \"No Internet\" teruis','closed','low','Jaringan / Internet',5,4,'2026-07-02 22:44:22','2026-07-02 22:20:39','2026-07-02 22:47:46',NULL),(3,'Komputer di Lab. Intelligence tidak bisa dinyalakan','Dari tadi pagi komputernya mati padahal sudah dicolokkan ke listrik','resolved','medium','Hardware',5,2,'2026-07-03 07:27:47','2026-07-03 07:21:30','2026-07-03 07:28:02',NULL),(4,'Akun cybercampus lupa password','Saya tiba-tiba lupa password akun cybercampus','in_progress','low','Software',5,3,NULL,'2026-07-03 07:22:50','2026-07-03 07:23:04',NULL),(5,'njjjjjjjjjjjjjjjjjjd','krwkjdwjdkkkkkkkkkk','in_progress','medium','Jaringan / Internet',5,4,NULL,'2026-07-03 08:24:38','2026-07-03 08:24:38',NULL),(6,'Tidak bisa membuka aplikasi hebat','Aplikasi tiba-tiba tertutup sendiri saat digunakan, layar tiba-tiba membeku (Not Responding).','in_progress','low','Software',5,3,NULL,'2026-07-05 05:20:18','2026-07-05 05:20:18',NULL);
/*!40000 ALTER TABLE `tickets` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `users` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `username` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `password` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `role` enum('user','helpdesk','admin') COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'user',
  `avatar_url` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `fcm_token` varchar(255) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT '1',
  `remember_token` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `users_email_unique` (`email`),
  UNIQUE KEY `users_username_unique` (`username`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'Admin Sistem','admin@helpdesk.com','admin','$2y$12$MdoPBm6MoVluP3OjmCK/YuXBBVRcSdeNjv8NqkKoIw0qJI1H3MvN.','admin',NULL,NULL,1,NULL,'2026-06-25 22:14:52','2026-06-25 22:14:52'),(2,'Helpdesk A','helpdeska@helpdesk.com','helpdeska','$2y$12$8uaKnuUiM9Il6sjtFeeENuvb1xh/uPrJF0MvelYXWTlT8wcEL7TTe','helpdesk',NULL,NULL,1,NULL,'2026-06-25 22:14:53','2026-06-25 22:14:53'),(3,'Helpdesk B','helpdeskb@helpdesk.com','helpdeskb','$2y$12$xhnyJHINI5YDd6MNg5ijg.gdFwhHBbqUQZYRpu1kS0TULgh82R.Fm','helpdesk',NULL,NULL,1,NULL,'2026-06-25 22:14:53','2026-06-25 22:14:53'),(4,'Helpdesk C','helpdeskc@helpdesk.com','helpdeskc','$2y$12$aoixvQ9Tr22kq1QseUxuOuTTyYDrT635w490e5P2Uf3jdIESa8a4i','helpdesk',NULL,NULL,1,NULL,'2026-06-25 22:14:53','2026-06-25 22:14:53'),(5,'Cia Mahasiswa','user@helpdesk.com','user','$2y$12$PweahupkL5lKPaRubrs9XOvPC32rCgUKyaS0LRFqVBeL/QC9puD3e','user',NULL,NULL,1,NULL,'2026-06-25 22:14:54','2026-06-25 22:14:54');
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-07-09  9:21:31
