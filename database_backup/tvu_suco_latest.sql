-- MySQL dump 10.13  Distrib 8.0.30, for Win64 (x86_64)
--
-- Host: localhost    Database: tvu_suco
-- ------------------------------------------------------
-- Server version	8.0.30

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `danh_gia_nghiem_thu`
--

DROP TABLE IF EXISTS `danh_gia_nghiem_thu`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `danh_gia_nghiem_thu` (
  `ma_danh_gia` int NOT NULL AUTO_INCREMENT,
  `ma_su_co_id` int NOT NULL,
  `nguoi_danh_gia_id` int NOT NULL,
  `so_sao_hai_long` int NOT NULL,
  `y_kien_phan_hoi` text COLLATE utf8mb4_unicode_ci,
  `ngay_danh_gia` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`ma_danh_gia`),
  KEY `fk_danhgia_suco` (`ma_su_co_id`),
  KEY `fk_danhgia_nguoidanhgia` (`nguoi_danh_gia_id`),
  CONSTRAINT `fk_danhgia_nguoidanhgia` FOREIGN KEY (`nguoi_danh_gia_id`) REFERENCES `nguoi_dung` (`ma_nguoi_dung`),
  CONSTRAINT `fk_danhgia_suco` FOREIGN KEY (`ma_su_co_id`) REFERENCES `su_co` (`ma_su_co_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `danh_gia_nghiem_thu`
--

LOCK TABLES `danh_gia_nghiem_thu` WRITE;
/*!40000 ALTER TABLE `danh_gia_nghiem_thu` DISABLE KEYS */;
/*!40000 ALTER TABLE `danh_gia_nghiem_thu` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `day_nha`
--

DROP TABLE IF EXISTS `day_nha`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `day_nha` (
  `ma_day_nha` int NOT NULL AUTO_INCREMENT,
  `ma_khuon_vien` int NOT NULL,
  `ten_day_nha` varchar(250) COLLATE utf8mb4_unicode_ci NOT NULL,
  `ma_toa` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `tong_so_tang` int NOT NULL,
  PRIMARY KEY (`ma_day_nha`),
  KEY `fk_daynha_khuonvien` (`ma_khuon_vien`),
  CONSTRAINT `fk_daynha_khuonvien` FOREIGN KEY (`ma_khuon_vien`) REFERENCES `khuon_vien` (`ma_khuon_vien`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `day_nha`
--

LOCK TABLES `day_nha` WRITE;
/*!40000 ALTER TABLE `day_nha` DISABLE KEYS */;
INSERT INTO `day_nha` VALUES (1,1,'Tòa nhà B21','B21',4),(2,1,'Tòa nhà B31','B31',4),(3,1,'Tòa nhà D71','D71',5),(4,1,'Tòa nhà A11','A11',3),(5,1,'Tòa nhà C31','C31',4),(6,3,'Tòa nhà A24','A24',3);
/*!40000 ALTER TABLE `day_nha` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `failed_jobs`
--

DROP TABLE IF EXISTS `failed_jobs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `failed_jobs` (
  `id` bigint unsigned NOT NULL AUTO_INCREMENT,
  `uuid` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `connection` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `queue` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `payload` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `exception` longtext COLLATE utf8mb4_unicode_ci NOT NULL,
  `failed_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `failed_jobs_uuid_unique` (`uuid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `failed_jobs`
--

LOCK TABLES `failed_jobs` WRITE;
/*!40000 ALTER TABLE `failed_jobs` DISABLE KEYS */;
/*!40000 ALTER TABLE `failed_jobs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `hinh_anh_su_co`
--

DROP TABLE IF EXISTS `hinh_anh_su_co`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `hinh_anh_su_co` (
  `ma_hinh_anh` int NOT NULL AUTO_INCREMENT,
  `ma_su_co_id` int NOT NULL,
  `duong_dan_anh` varchar(500) COLLATE utf8mb4_unicode_ci NOT NULL,
  `loai_hinh_anh` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `ngay_chup_anh` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `nguoi_chup_id` int NOT NULL,
  PRIMARY KEY (`ma_hinh_anh`),
  KEY `fk_hinhanh_suco` (`ma_su_co_id`),
  KEY `fk_hinhanh_nguoichup` (`nguoi_chup_id`),
  CONSTRAINT `fk_hinhanh_nguoichup` FOREIGN KEY (`nguoi_chup_id`) REFERENCES `nguoi_dung` (`ma_nguoi_dung`),
  CONSTRAINT `fk_hinhanh_suco` FOREIGN KEY (`ma_su_co_id`) REFERENCES `su_co` (`ma_su_co_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `hinh_anh_su_co`
--

LOCK TABLES `hinh_anh_su_co` WRITE;
/*!40000 ALTER TABLE `hinh_anh_su_co` DISABLE KEYS */;
INSERT INTO `hinh_anh_su_co` VALUES (1,2,'http://localhost:8000/storage/incidents/tx4TELb0AiZyaVDTnwrUGtlmRbN3UhjaW59KgiQ2.png','Hiện trường','2026-11-26 18:31:52',2);
/*!40000 ALTER TABLE `hinh_anh_su_co` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `khuon_vien`
--

DROP TABLE IF EXISTS `khuon_vien`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `khuon_vien` (
  `ma_khuon_vien` int NOT NULL AUTO_INCREMENT,
  `ten_khuon_vien` varchar(250) COLLATE utf8mb4_unicode_ci NOT NULL,
  `ma_viet_tat` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `dia_chi` varchar(500) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `mo_ta` varchar(1000) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`ma_khuon_vien`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `khuon_vien`
--

LOCK TABLES `khuon_vien` WRITE;
/*!40000 ALTER TABLE `khuon_vien` DISABLE KEYS */;
INSERT INTO `khuon_vien` VALUES (1,'Khu I - Đại học Trà Vinh','Khu I','126 Nguyễn Thiện Thành, Phường 5, Trà Vinh',NULL),(2,'Khu I - Trường Đại học Trà Vinh','Khu I','126 Nguyễn Thiện Thành, Phường 5, TP. Trà Vinh',NULL),(3,'Khu II - Trường Đại học Trà Vinh','Khu II','Đường Kiên Thị Nhẫn',NULL);
/*!40000 ALTER TABLE `khuon_vien` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `lich_su_xu_ly`
--

DROP TABLE IF EXISTS `lich_su_xu_ly`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `lich_su_xu_ly` (
  `ma_lich_su` int NOT NULL AUTO_INCREMENT,
  `ma_su_co_id` int NOT NULL,
  `nguoi_thuc_hien_id` int NOT NULL,
  `trang_thai_cu` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `trang_thai_moi` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `noi_dung_ghi_chu` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `thoi_gian_cap_nhat` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`ma_lich_su`),
  KEY `fk_lichsu_suco` (`ma_su_co_id`),
  KEY `fk_lichsu_nguoithuchien` (`nguoi_thuc_hien_id`),
  CONSTRAINT `fk_lichsu_nguoithuchien` FOREIGN KEY (`nguoi_thuc_hien_id`) REFERENCES `nguoi_dung` (`ma_nguoi_dung`),
  CONSTRAINT `fk_lichsu_suco` FOREIGN KEY (`ma_su_co_id`) REFERENCES `su_co` (`ma_su_co_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `lich_su_xu_ly`
--

LOCK TABLES `lich_su_xu_ly` WRITE;
/*!40000 ALTER TABLE `lich_su_xu_ly` DISABLE KEYS */;
INSERT INTO `lich_su_xu_ly` VALUES (1,1,2,NULL,'Chờ tiếp nhận','Sinh viên gửi báo cáo sự cố mới qua ứng dụng.','2026-10-21 17:19:51'),(2,1,4,'Chờ tiếp nhận','Đang xử lý','Phân công cho KTV: KTV. Lê Hoàng Nam','2026-10-21 17:21:04'),(3,2,2,NULL,'Chờ tiếp nhận','Sinh viên gửi báo cáo sự cố mới qua ứng dụng (1 ảnh).','2026-11-26 18:31:52');
/*!40000 ALTER TABLE `lich_su_xu_ly` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `loai_su_co`
--

DROP TABLE IF EXISTS `loai_su_co`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `loai_su_co` (
  `ma_loai_su_co` int NOT NULL AUTO_INCREMENT,
  `ten_loai_su_co` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL,
  `bieu_tuong` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `mo_ta_chi_tiet` varchar(1000) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`ma_loai_su_co`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `loai_su_co`
--

LOCK TABLES `loai_su_co` WRITE;
/*!40000 ALTER TABLE `loai_su_co` DISABLE KEYS */;
INSERT INTO `loai_su_co` VALUES (1,'Điện - Quạt - Máy lạnh','ac_unit','Hỏng quạt, máy lạnh chảy nước, mất điện ổ cắm'),(2,'Máy chiếu - Tivi - HDMI','tv','Màn hình mờ, dây cáp HDMI đứt, mất tín hiệu'),(3,'Đèn chiếu sáng','lightbulb','Bóng đèn nhấp nháy hoặc không sáng'),(4,'Bàn ghế - Cửa - Bảng viết','chair','Gãy bàn ghế, kẹt khóa cửa, bảng trầy xước'),(5,'Máy tính - Bàn phím - CPU','computer','Màn hình không lên, liệt bàn phím, CPU không khởi động, hỏng chuột');
/*!40000 ALTER TABLE `loai_su_co` ENABLE KEYS */;
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
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `migrations`
--

LOCK TABLES `migrations` WRITE;
/*!40000 ALTER TABLE `migrations` DISABLE KEYS */;
INSERT INTO `migrations` VALUES (1,'2014_10_12_000000_create_users_table',1),(2,'2014_10_12_100000_create_password_reset_tokens_table',1),(3,'2019_08_19_000000_create_failed_jobs_table',1),(4,'2019_12_14_000001_create_personal_access_tokens_table',1);
/*!40000 ALTER TABLE `migrations` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `nguoi_dung`
--

DROP TABLE IF EXISTS `nguoi_dung`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `nguoi_dung` (
  `ma_nguoi_dung` int NOT NULL AUTO_INCREMENT,
  `ten_dang_nhap` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `ho_va_ten` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL,
  `email_tvu` varchar(200) COLLATE utf8mb4_unicode_ci NOT NULL,
  `so_dien_thoai` varchar(50) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `mat_khau_ma_hoa` varchar(500) COLLATE utf8mb4_unicode_ci NOT NULL,
  `vai_tro` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `lop_hoac_don_vi` varchar(200) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `ngay_tao` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `dang_hoat_dong` tinyint(1) NOT NULL DEFAULT '1',
  PRIMARY KEY (`ma_nguoi_dung`),
  UNIQUE KEY `ten_dang_nhap` (`ten_dang_nhap`),
  UNIQUE KEY `email_tvu` (`email_tvu`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `nguoi_dung`
--

LOCK TABLES `nguoi_dung` WRITE;
/*!40000 ALTER TABLE `nguoi_dung` DISABLE KEYS */;
INSERT INTO `nguoi_dung` VALUES (1,'110123030','Nguyễn Như Ngọc','110123030@st.tvu.edu.vn',NULL,'$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi','Sinh viên','DA23TTA','2026-10-20 18:24:50',1),(2,'gv001','ThS. Trần Văn Hùng','gv001@tvu.edu.vn','0912345678','$2y$12$PLoPQUPep1fFeJkToWYFIOd6Jhi/g3IVwkCf424dyTnC1Vl8lkDxu','Giảng viên','Khoa Kỹ thuật & Công nghệ','2026-10-22 00:09:18',1),(3,'ktv001','KTV. Lê Hoàng Nam','ktv001@tvu.edu.vn','0987654321','$2y$12$q0wtoyIQZgtCEM9Six4hSucxsiJ2b8cVXen/pHQ63i39I529DFlrG','Kỹ thuật viên','Phòng Quản trị Thiết bị','2026-10-22 00:09:18',1),(4,'admin','Ban Quản Lý CSVC TVU','admin@tvu.edu.vn','02943855246','$2y$12$XwVi327iXCNRkXWYND5Mwu4FXVqIuvuB2dIXe43AXw5nK.JTggh0O','Admin','Ban Giám Hiệu & Quản trị','2026-10-22 00:09:18',1),(5,'110123040','KKK','110123040@st.tvu.edu.vn','9522','$2y$12$KN8LLZPV8/8ZCLHd1K9CKOd9lGgb1NE5Twh9Lbf/MZtIMN1mzuVXa','Sinh viên','DA24TTA','2026-10-21 18:10:11',1);
/*!40000 ALTER TABLE `nguoi_dung` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `password_reset_tokens`
--

DROP TABLE IF EXISTS `password_reset_tokens`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `password_reset_tokens` (
  `email` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `token` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `password_reset_tokens`
--

LOCK TABLES `password_reset_tokens` WRITE;
/*!40000 ALTER TABLE `password_reset_tokens` DISABLE KEYS */;
/*!40000 ALTER TABLE `password_reset_tokens` ENABLE KEYS */;
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
  `name` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `token` varchar(64) COLLATE utf8mb4_unicode_ci NOT NULL,
  `abilities` text COLLATE utf8mb4_unicode_ci,
  `last_used_at` timestamp NULL DEFAULT NULL,
  `expires_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `personal_access_tokens_token_unique` (`token`),
  KEY `personal_access_tokens_tokenable_type_tokenable_id_index` (`tokenable_type`,`tokenable_id`)
) ENGINE=InnoDB AUTO_INCREMENT=67 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `personal_access_tokens`
--

LOCK TABLES `personal_access_tokens` WRITE;
/*!40000 ALTER TABLE `personal_access_tokens` DISABLE KEYS */;
INSERT INTO `personal_access_tokens` VALUES (1,'App\\Models\\User',1,'tvu_mobile_token','396f897b0f694a7690f84221d602e320c9ef31e9ada11872200324434dd4d315','[\"*\"]',NULL,NULL,'2026-10-21 09:52:19','2026-10-21 09:52:19'),(2,'App\\Models\\User',1,'tvu_mobile_token','c2b95a16dacd2aee8414cd46e77125a081b7882d44fe1d0f959d16f9a4b6cbe3','[\"*\"]',NULL,NULL,'2026-10-21 09:52:32','2026-10-21 09:52:32'),(3,'App\\Models\\User',1,'tvu_mobile_token','896a37f36ec8237f3a395c9f5f61932d942dbed6417f684f31f1d674f7cd5432','[\"*\"]',NULL,NULL,'2026-10-21 09:52:37','2026-10-21 09:52:37'),(4,'App\\Models\\User',1,'tvu_mobile_token','c2592a6251ec148bc413914619a717e9bdab033049b782ccfed7f089b4d45160','[\"*\"]',NULL,NULL,'2026-10-21 09:52:38','2026-10-21 09:52:38'),(5,'App\\Models\\User',1,'tvu_mobile_token','f80dbffec85d37dfe9733985ce9364cd2873877b8dc615b44596a3b7e36493ac','[\"*\"]',NULL,NULL,'2026-10-21 09:52:39','2026-10-21 09:52:39'),(6,'App\\Models\\User',1,'tvu_mobile_token','be5719c124e3a758862fe77ec163af8d4826a3bc900cc6289d4a2c6404d33be1','[\"*\"]',NULL,NULL,'2026-10-21 10:05:38','2026-10-21 10:05:38'),(7,'App\\Models\\User',1,'tvu_mobile_token','bdafb12c1320b6d5c321aa6d8479b456cba2b8e51c4292e1dc8f3175b816265b','[\"*\"]',NULL,NULL,'2026-10-21 10:05:40','2026-10-21 10:05:40'),(8,'App\\Models\\User',1,'tvu_mobile_token','5bb90b410f73a473646d9e2a5392944f579ff2155d1a424a2961953e4fefaeda','[\"*\"]',NULL,NULL,'2026-10-21 10:14:03','2026-10-21 10:14:03'),(9,'App\\Models\\User',1,'tvu_mobile_token','2914329ec2d0362485fc96bfd57e0d2316594652d0c50b166f8a631b818d4887','[\"*\"]',NULL,NULL,'2026-10-21 10:14:05','2026-10-21 10:14:05'),(10,'App\\Models\\User',1,'tvu_mobile_token','de7724d8f1af9f7b5c4217bea76b49dd525b89c658bd468653388a1b2df3bc9e','[\"*\"]',NULL,NULL,'2026-10-21 10:14:06','2026-10-21 10:14:06'),(11,'App\\Models\\User',2,'tvu_mobile_token','e2d5dc19f6d19e6fa5eeb2cf9e59612f6dec888bfd524a6e9a882db058184aef','[\"*\"]',NULL,NULL,'2026-10-21 10:14:34','2026-10-21 10:14:34'),(12,'App\\Models\\User',2,'tvu_mobile_token','6aafcaae6d04654510275791590605c73ad52723d78b8f1cb40f65f165e7e124','[\"*\"]','2026-10-21 10:23:17',NULL,'2026-10-21 10:17:22','2026-10-21 10:23:17'),(13,'App\\Models\\User',4,'tvu_mobile_token','4d726f906d95688430ea67af56a8152fc643fbafa1ba2f4ab6c89e22755eeb6f','[\"*\"]','2026-10-21 10:21:07',NULL,'2026-10-21 10:17:45','2026-10-21 10:21:07'),(14,'App\\Models\\User',3,'tvu_mobile_token','ca0cbfe60de5db4c9503b4e25c1ca5910a16adb87bb53179bf740b260f9b2312','[\"*\"]','2026-10-21 10:22:24',NULL,'2026-10-21 10:22:13','2026-10-21 10:22:24'),(15,'App\\Models\\User',4,'tvu_mobile_token','4918b17ddd49e5226832b9f3c8aef2d6691495c038e615df947ce88b9f5fa0aa','[\"*\"]','2026-10-21 10:29:31',NULL,'2026-10-21 10:23:29','2026-10-21 10:29:31'),(16,'App\\Models\\User',3,'tvu_mobile_token','c22019a0cf7e0c712996fbc06f0e7908534f8103d0ab41b8c0410bbda9c5d135','[\"*\"]','2026-10-21 10:29:43',NULL,'2026-10-21 10:29:42','2026-10-21 10:29:43'),(17,'App\\Models\\User',2,'tvu_mobile_token','e6c8368650c5797fd7555f6520eb1cbc8b14d9222f17ec5538e66a793dcc9330','[\"*\"]','2026-10-21 10:36:01',NULL,'2026-10-21 10:35:59','2026-10-21 10:36:01'),(18,'App\\Models\\User',2,'tvu_mobile_token','f7a70616a0965851bacacf6ab47c1b85b3b885e9cac479391b4afb7e5a4bc2bf','[\"*\"]','2026-10-21 10:37:58',NULL,'2026-10-21 10:37:55','2026-10-21 10:37:58'),(19,'App\\Models\\User',4,'tvu_mobile_token','748afcd3d18f0c2a4ad25188bd6ba831b1c59833ec2c7024a2f7a337679aa6bc','[\"*\"]','2026-10-21 10:40:02',NULL,'2026-10-21 10:39:59','2026-10-21 10:40:02'),(20,'App\\Models\\User',4,'tvu_mobile_token','5ad87ffeb2542fbadc667bcb53a7909cd2923792a935fa6fb0812d80184ace63','[\"*\"]','2026-10-21 10:44:01',NULL,'2026-10-21 10:43:58','2026-10-21 10:44:01'),(21,'App\\Models\\User',2,'tvu_mobile_token','2c52ce722ad1481854fd2470b3aaf51c11f4684c794e23a5153d3a5495d17403','[\"*\"]','2026-10-21 10:46:17',NULL,'2026-10-21 10:44:10','2026-10-21 10:46:17'),(22,'App\\Models\\User',2,'tvu_mobile_token','bfba7f20cb9a765d8370794590fe9ba1d166cda55a0b21c18a5dd3dda3e98148','[\"*\"]','2026-10-21 10:54:03',NULL,'2026-10-21 10:44:55','2026-10-21 10:54:03'),(23,'App\\Models\\User',2,'tvu_mobile_token','e1f071748cc3d1af05c2af7ce3f387441ed063141af830c07a6164afd77f8f15','[\"*\"]','2026-10-21 10:54:33',NULL,'2026-10-21 10:54:20','2026-10-21 10:54:33'),(24,'App\\Models\\User',4,'tvu_mobile_token','f2501c68ee9ea139ae9c619b34b52f77a7a05b3f5e0562d2a074c78f486a719e','[\"*\"]','2026-10-21 10:54:42',NULL,'2026-10-21 10:54:40','2026-10-21 10:54:42'),(25,'App\\Models\\User',2,'tvu_mobile_token','3ec219f8641646ec490c557b0e9faa7a3701bc250e93773c03c2fb79e7e8038c','[\"*\"]','2026-10-21 10:55:11',NULL,'2026-10-21 10:55:09','2026-10-21 10:55:11'),(26,'App\\Models\\User',4,'tvu_mobile_token','e567a500d0f59cda626d67ad61e05e87b068addfccc1cd5267af6cff2d0d2488','[\"*\"]','2026-10-21 11:10:14',NULL,'2026-10-21 11:08:46','2026-10-21 11:10:14'),(27,'App\\Models\\User',2,'tvu_mobile_token','05f6d7be0b8309b1162356818d0b8c7cfcb1248ff1016aef174688e522394316','[\"*\"]','2026-10-21 11:11:52',NULL,'2026-10-21 11:08:52','2026-10-21 11:11:52'),(29,'App\\Models\\User',4,'tvu_mobile_token','1ab853a9a937b7da2b6b1d1808ea9f518f7af8bb1d189718ca327997daeb67b1','[\"*\"]','2026-10-21 11:18:43',NULL,'2026-10-21 11:14:07','2026-10-21 11:18:43'),(30,'App\\Models\\User',4,'tvu_mobile_token','27156ceb68ce32015a59c3c1acc4d578ebb6bafb4f99d9ef122035324401b42e','[\"*\"]','2026-10-21 11:20:01',NULL,'2026-10-21 11:18:58','2026-10-21 11:20:01'),(31,'App\\Models\\User',2,'tvu_mobile_token','fd815d4bc764cb4032dce0b877c168e04ee9ed53d92986aa759c8cbc2a5bf3c5','[\"*\"]','2026-10-21 11:20:50',NULL,'2026-10-21 11:19:06','2026-10-21 11:20:50'),(32,'App\\Models\\User',2,'tvu_mobile_token','e6126e692cfb90bba6f27d89a5980bfec2dea35040718cd3d51d9de433f9e112','[\"*\"]','2026-10-27 02:04:12',NULL,'2026-10-27 02:00:48','2026-10-27 02:04:12'),(33,'App\\Models\\User',2,'tvu_mobile_token','ac12497036896ffe473e91392ac829f5f2702174eff2b873844a565d1ebdfe6a','[\"*\"]','2026-10-27 02:14:38',NULL,'2026-10-27 02:14:08','2026-10-27 02:14:38'),(34,'App\\Models\\User',4,'tvu_mobile_token','4487938763665fa32e42dc7c62fd34598f04410d1126f7bee4145efe2a2eb970','[\"*\"]','2026-10-27 02:17:35',NULL,'2026-10-27 02:17:00','2026-10-27 02:17:35'),(35,'App\\Models\\User',2,'tvu_mobile_token','d366452c6ecaee3eb8d04e69166343cb19d5c9a59c8847eef973efc20ea66966','[\"*\"]','2026-10-27 02:23:40',NULL,'2026-10-27 02:23:27','2026-10-27 02:23:40'),(36,'App\\Models\\User',4,'tvu_mobile_token','ffecb40acc84e27426437d0fdc372d99e0167c613f858cb8316e8fddd19031a0','[\"*\"]','2026-10-27 02:41:28',NULL,'2026-10-27 02:41:24','2026-10-27 02:41:28'),(38,'App\\Models\\User',4,'tvu_mobile_token','9d125675d3dc05e9861fdebcf7aa7cd9a86047d72496621748eeb80a513647bf','[\"*\"]','2026-10-27 02:50:34',NULL,'2026-10-27 02:50:31','2026-10-27 02:50:34'),(41,'App\\Models\\User',2,'tvu_mobile_token','0209ce2ef12483d55ebb95258490173b0ba2a025f0332ab200430ebf967c2d1b','[\"*\"]','2026-10-27 03:46:52',NULL,'2026-10-27 03:24:19','2026-10-27 03:46:52'),(42,'App\\Models\\User',3,'tvu_mobile_token','49658d62e0861248888eefde5dad252bd50e98164c7b1d2945ba890ac51a6367','[\"*\"]','2026-10-27 04:14:07',NULL,'2026-10-27 04:13:53','2026-10-27 04:14:07'),(45,'App\\Models\\User',2,'tvu_mobile_token','24b46fbbbf6e8953a0a8a3e8c8c3f66417940745a88a33d2b726c689ac3e5f6e','[\"*\"]','2026-10-27 04:26:28',NULL,'2026-10-27 04:25:48','2026-10-27 04:26:28'),(52,'App\\Models\\User',4,'tvu_mobile_token','f083e400cbbfa39b170d4fedd77663541fe0c1b5c15e27859216e424d45d76b7','[\"*\"]','2026-11-05 00:10:32',NULL,'2026-11-05 00:10:25','2026-11-05 00:10:32'),(55,'App\\Models\\User',2,'tvu_mobile_token','8672ff0a78aa5e31682c050c4d8a370a8e79f8f9db10c5043284131a92d2f4a4','[\"*\"]','2026-11-05 00:29:15',NULL,'2026-11-05 00:28:40','2026-11-05 00:29:15'),(56,'App\\Models\\User',4,'tvu_mobile_token','dc65c5130ef4b83823d6db9e4434903983762e5ccd8d515fa68b3346f8cc9eed','[\"*\"]',NULL,NULL,'2026-11-26 11:10:23','2026-11-26 11:10:23'),(57,'App\\Models\\User',4,'tvu_mobile_token','de94ef3ee8c7f4e012c141181eb2b5c22789aec6b2711c34c6a692c13ee2621e','[\"*\"]',NULL,NULL,'2026-11-26 11:10:33','2026-11-26 11:10:33'),(59,'App\\Models\\User',2,'tvu_mobile_token','3e04caea4a6f15976d0150d0aed6851bdee22466a7796e5f5be37469fda32275','[\"*\"]','2026-11-26 11:12:26',NULL,'2026-11-26 11:11:59','2026-11-26 11:12:26'),(63,'App\\Models\\User',2,'tvu_mobile_token','1647ccec7949864e1383d1c8b72c22c9670d9557dd5668fa320b1fee6163f78a','[\"*\"]','2026-11-26 11:26:15',NULL,'2026-11-26 11:25:44','2026-11-26 11:26:15'),(64,'App\\Models\\User',4,'tvu_mobile_token','caa28ca53bbe25edc7391efbdbbacdc63cd4188e8f5e023c45d16a22439ba672','[\"*\"]','2026-11-26 11:31:56',NULL,'2026-11-26 11:26:06','2026-11-26 11:31:56'),(66,'App\\Models\\User',4,'tvu_mobile_token','fa3f52d26ea0bb112ffcfaad454ea1d528e8b100508922b3d6efa16418e521c7','[\"*\"]','2026-11-26 11:47:15',NULL,'2026-11-26 11:32:39','2026-11-26 11:47:15');
/*!40000 ALTER TABLE `personal_access_tokens` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `phong_hoc`
--

DROP TABLE IF EXISTS `phong_hoc`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `phong_hoc` (
  `ma_phong_hoc` int NOT NULL AUTO_INCREMENT,
  `ma_day_nha` int NOT NULL,
  `so_phong` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `loai_phong` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL,
  `tang_so` int NOT NULL,
  `ma_qr_dinh_danh` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `so_may_lanh` int NOT NULL DEFAULT '2',
  `so_quat` int NOT NULL DEFAULT '2',
  `loai_quat` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Quạt trần',
  `so_tivi` int NOT NULL DEFAULT '1',
  `so_cong_hdmi` int NOT NULL DEFAULT '1',
  `so_bang_viet` int NOT NULL DEFAULT '1',
  `so_ban_sinh_vien` int NOT NULL DEFAULT '16',
  `so_ban_giao_vien` int NOT NULL DEFAULT '1',
  `mo_ta_hien_trang` varchar(1000) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `dang_su_dung` tinyint(1) NOT NULL DEFAULT '1',
  `so_may_tinh` int NOT NULL DEFAULT '0',
  `so_ban_phim` int NOT NULL DEFAULT '0',
  `so_cpu` int NOT NULL DEFAULT '0',
  `so_chuot` int NOT NULL DEFAULT '0',
  PRIMARY KEY (`ma_phong_hoc`),
  UNIQUE KEY `ma_qr_dinh_danh` (`ma_qr_dinh_danh`),
  KEY `fk_phonghoc_daynha` (`ma_day_nha`),
  CONSTRAINT `fk_phonghoc_daynha` FOREIGN KEY (`ma_day_nha`) REFERENCES `day_nha` (`ma_day_nha`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `phong_hoc`
--

LOCK TABLES `phong_hoc` WRITE;
/*!40000 ALTER TABLE `phong_hoc` DISABLE KEYS */;
INSERT INTO `phong_hoc` VALUES (2,1,'102','Lý thuyết',1,'TVU-B21-102',2,4,'Quạt trần',1,1,1,20,1,NULL,1,0,0,0,0),(7,3,'102','Thực hành Máy tính',1,'TVU-D71-102',2,2,'Quạt trần',1,1,1,20,1,NULL,1,40,40,40,40);
/*!40000 ALTER TABLE `phong_hoc` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `su_co`
--

DROP TABLE IF EXISTS `su_co`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `su_co` (
  `ma_su_co_id` int NOT NULL AUTO_INCREMENT,
  `ma_phieu_su_co` varchar(100) COLLATE utf8mb4_unicode_ci NOT NULL,
  `tieu_de` varchar(300) COLLATE utf8mb4_unicode_ci NOT NULL,
  `mo_ta_hu_hong` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `ma_phong_hoc` int NOT NULL,
  `ma_loai_su_co` int NOT NULL,
  `vi_tri_trong_phong` varchar(250) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `muc_do_uu_tien` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Bình thường',
  `trang_thai` varchar(50) COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'Chờ tiếp nhận',
  `nguoi_bao_cao_id` int NOT NULL,
  `ky_thuat_vien_id` int DEFAULT NULL,
  `ngay_gui_bao_cao` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `ngay_phan_cong` datetime DEFAULT NULL,
  `ngay_hoan_thanh` datetime DEFAULT NULL,
  `ngay_dong_phieu` datetime DEFAULT NULL,
  PRIMARY KEY (`ma_su_co_id`),
  UNIQUE KEY `ma_phieu_su_co` (`ma_phieu_su_co`),
  KEY `fk_suco_phonghoc` (`ma_phong_hoc`),
  KEY `fk_suco_loaisuco` (`ma_loai_su_co`),
  KEY `fk_suco_nguoibaocao` (`nguoi_bao_cao_id`),
  KEY `fk_suco_kythuatvien` (`ky_thuat_vien_id`),
  CONSTRAINT `fk_suco_kythuatvien` FOREIGN KEY (`ky_thuat_vien_id`) REFERENCES `nguoi_dung` (`ma_nguoi_dung`),
  CONSTRAINT `fk_suco_loaisuco` FOREIGN KEY (`ma_loai_su_co`) REFERENCES `loai_su_co` (`ma_loai_su_co`),
  CONSTRAINT `fk_suco_nguoibaocao` FOREIGN KEY (`nguoi_bao_cao_id`) REFERENCES `nguoi_dung` (`ma_nguoi_dung`),
  CONSTRAINT `fk_suco_phonghoc` FOREIGN KEY (`ma_phong_hoc`) REFERENCES `phong_hoc` (`ma_phong_hoc`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `su_co`
--

LOCK TABLES `su_co` WRITE;
/*!40000 ALTER TABLE `su_co` DISABLE KEYS */;
INSERT INTO `su_co` VALUES (1,'SC-20261021-281','Sự cố tại phòng #2','bị bể kính',2,4,'cửa chính','Bình thường','Đang xử lý',2,3,'2026-10-21 17:19:51','2026-10-21 17:21:04',NULL,NULL),(2,'SC-20261126-712','Sự cố tại phòng #2','bị tối , giật chớp liên tục',2,3,'2 đèn của phòng','Bình thường','Chờ tiếp nhận',2,NULL,'2026-11-26 18:31:51',NULL,NULL,NULL);
/*!40000 ALTER TABLE `su_co` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `thong_bao`
--

DROP TABLE IF EXISTS `thong_bao`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `thong_bao` (
  `ma_thong_bao` int NOT NULL AUTO_INCREMENT,
  `nguoi_nhan_id` int NOT NULL,
  `tieu_de` varchar(250) COLLATE utf8mb4_unicode_ci NOT NULL,
  `noi_dung_thong_bao` text COLLATE utf8mb4_unicode_ci NOT NULL,
  `ma_su_co_id` int DEFAULT NULL,
  `da_doc` tinyint(1) NOT NULL DEFAULT '0',
  `ngay_gui` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`ma_thong_bao`),
  KEY `fk_thongbao_nguoinhan` (`nguoi_nhan_id`),
  KEY `fk_thongbao_suco` (`ma_su_co_id`),
  CONSTRAINT `fk_thongbao_nguoinhan` FOREIGN KEY (`nguoi_nhan_id`) REFERENCES `nguoi_dung` (`ma_nguoi_dung`) ON DELETE CASCADE,
  CONSTRAINT `fk_thongbao_suco` FOREIGN KEY (`ma_su_co_id`) REFERENCES `su_co` (`ma_su_co_id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `thong_bao`
--

LOCK TABLES `thong_bao` WRITE;
/*!40000 ALTER TABLE `thong_bao` DISABLE KEYS */;
/*!40000 ALTER TABLE `thong_bao` ENABLE KEYS */;
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
  `email_verified_at` timestamp NULL DEFAULT NULL,
  `password` varchar(255) COLLATE utf8mb4_unicode_ci NOT NULL,
  `remember_token` varchar(100) COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `users_email_unique` (`email`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
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

-- Dump completed on 2026-11-27  2:07:01
