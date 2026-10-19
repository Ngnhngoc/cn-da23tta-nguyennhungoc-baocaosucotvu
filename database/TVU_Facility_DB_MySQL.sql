-- =========================================================================================
-- ĐỒ ÁN / BÁO CÁO: HỆ THỐNG BÁO CÁO VÀ THEO DÕI SỰ CỐ CƠ SỞ VẬT CHẤT (TVU FACILITY)
-- ĐƠN VỊ: TRƯỜNG ĐẠI HỌC TRÀ VINH (TRA VINH UNIVERSITY - TVU)
-- TẬP TIN SCRIPT DÀNH CHO: MYSQL 8.0 / LARAGON / PHPMYADMIN / NAVICAT
-- CHUẨN HÓA 100% TÊN BẢNG & THUỘC TÍNH BẰNG TIẾNG VIỆT
-- =========================================================================================

CREATE DATABASE IF NOT EXISTS `tvu_facility_db` 
CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE `tvu_facility_db`;

-- XÓA BẢNG CŨ THEO THỨ TỰ RÀNG BUỘC KHÓA NGOẠI
SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS `thong_bao`;
DROP TABLE IF EXISTS `danh_gia_nghiem_thu`;
DROP TABLE IF EXISTS `lich_su_xu_ly`;
DROP TABLE IF EXISTS `hinh_anh_su_co`;
DROP TABLE IF EXISTS `su_co`;
DROP TABLE IF EXISTS `phong_hoc`;
DROP TABLE IF EXISTS `day_nha`;
DROP TABLE IF EXISTS `khuon_vien`;
DROP TABLE IF EXISTS `loai_su_co`;
DROP TABLE IF EXISTS `nguoi_dung`;
SET FOREIGN_KEY_CHECKS = 1;

-- 1. KHUÔN VIÊN
CREATE TABLE `khuon_vien` (
  `ma_khuon_vien` INT NOT NULL AUTO_INCREMENT,
  `ten_khuon_vien` VARCHAR(250) NOT NULL,
  `ma_viet_tat` VARCHAR(50) NOT NULL,
  `dia_chi` VARCHAR(500) DEFAULT NULL,
  `mo_ta` LONGTEXT DEFAULT NULL,
  PRIMARY KEY (`ma_khuon_vien`),
  UNIQUE KEY `UQ_khuon_vien_ma` (`ma_viet_tat`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 2. DÃY NHÀ
CREATE TABLE `day_nha` (
  `ma_day_nha` INT NOT NULL AUTO_INCREMENT,
  `ma_khuon_vien` INT NOT NULL,
  `ten_day_nha` VARCHAR(250) NOT NULL,
  `ma_toa` VARCHAR(50) NOT NULL,
  `tong_so_tang` INT NOT NULL DEFAULT 1,
  PRIMARY KEY (`ma_day_nha`),
  UNIQUE KEY `UQ_day_nha_ma_toa` (`ma_toa`),
  CONSTRAINT `FK_day_nha_khuon_vien` FOREIGN KEY (`ma_khuon_vien`) REFERENCES `khuon_vien` (`ma_khuon_vien`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 3. PHÒNG HỌC & TRANG THIẾT BỊ (Khu A & B: 2 máy lạnh, quạt trần/điện, 1 TV, 1 HDMI, 1 bảng, 14-18 bàn SV, 1 bàn GV)
CREATE TABLE `phong_hoc` (
  `ma_phong_hoc` INT NOT NULL AUTO_INCREMENT,
  `ma_day_nha` INT NOT NULL,
  `so_phong` VARCHAR(50) NOT NULL,
  `loai_phong` VARCHAR(50) NOT NULL DEFAULT 'LectureHall',
  `tang_so` INT NOT NULL DEFAULT 1,
  `ma_qr_dinh_danh` VARCHAR(100) NOT NULL,
  `so_may_lanh` INT NOT NULL DEFAULT 2,
  `so_quat` INT NOT NULL DEFAULT 2,
  `loai_quat` VARCHAR(50) NOT NULL DEFAULT 'Quạt trần',
  `so_tivi` INT NOT NULL DEFAULT 1,
  `so_cong_hdmi` INT NOT NULL DEFAULT 1,
  `so_bang_viet` INT NOT NULL DEFAULT 1,
  `so_ban_sinh_vien` INT NOT NULL DEFAULT 16,
  `so_ban_giao_vien` INT NOT NULL DEFAULT 1,
  `mo_ta_hien_trang` LONGTEXT DEFAULT NULL,
  `dang_su_dung` TINYINT(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (`ma_phong_hoc`),
  UNIQUE KEY `UQ_phong_hoc_qr` (`ma_qr_dinh_danh`),
  CONSTRAINT `FK_phong_hoc_day_nha` FOREIGN KEY (`ma_day_nha`) REFERENCES `day_nha` (`ma_day_nha`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 4. DANH MỤC LOẠI SỰ CỐ
CREATE TABLE `loai_su_co` (
  `ma_loai_su_co` INT NOT NULL AUTO_INCREMENT,
  `ten_loai_su_co` VARCHAR(200) NOT NULL,
  `bieu_tuong` VARCHAR(100) NOT NULL DEFAULT 'build',
  `mo_ta_chi_tiet` LONGTEXT DEFAULT NULL,
  PRIMARY KEY (`ma_loai_su_co`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 5. NGƯỜI DÙNG HỆ THỐNG
CREATE TABLE `nguoi_dung` (
  `ma_nguoi_dung` INT NOT NULL AUTO_INCREMENT,
  `ten_dang_nhap` VARCHAR(100) NOT NULL,
  `ho_va_ten` VARCHAR(200) NOT NULL,
  `email_tvu` VARCHAR(200) NOT NULL,
  `so_dien_thoai` VARCHAR(50) DEFAULT NULL,
  `mat_khau_ma_hoa` VARCHAR(500) NOT NULL,
  `vai_tro` VARCHAR(50) NOT NULL DEFAULT 'Student',
  `lop_hoac_don_vi` VARCHAR(200) DEFAULT NULL,
  `ngay_tao` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `dang_hoat_dong` TINYINT(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (`ma_nguoi_dung`),
  UNIQUE KEY `UQ_nguoi_dung_ten_dang_nhap` (`ten_dang_nhap`),
  UNIQUE KEY `UQ_nguoi_dung_email` (`email_tvu`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 6. PHIẾU BÁO CÁO SỰ CỐ
CREATE TABLE `su_co` (
  `ma_su_co_id` INT NOT NULL AUTO_INCREMENT,
  `ma_phieu_su_co` VARCHAR(100) NOT NULL,
  `tieu_de` VARCHAR(300) NOT NULL,
  `mo_ta_hu_hong` LONGTEXT NOT NULL,
  `ma_phong_hoc` INT NOT NULL,
  `ma_loai_su_co` INT NOT NULL,
  `vi_tri_trong_phong` VARCHAR(250) DEFAULT NULL,
  `muc_do_uu_tien` VARCHAR(50) NOT NULL DEFAULT 'Medium',
  `trang_thai` VARCHAR(50) NOT NULL DEFAULT 'Pending',
  `nguoi_bao_cao_id` INT NOT NULL,
  `ky_thuat_vien_id` INT DEFAULT NULL,
  `ngay_gui_bao_cao` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `ngay_phan_cong` DATETIME DEFAULT NULL,
  `ngay_hoan_thanh` DATETIME DEFAULT NULL,
  `ngay_dong_phieu` DATETIME DEFAULT NULL,
  PRIMARY KEY (`ma_su_co_id`),
  UNIQUE KEY `UQ_su_co_ma_phieu` (`ma_phieu_su_co`),
  CONSTRAINT `FK_su_co_phong_hoc` FOREIGN KEY (`ma_phong_hoc`) REFERENCES `phong_hoc` (`ma_phong_hoc`),
  CONSTRAINT `FK_su_co_loai_su_co` FOREIGN KEY (`ma_loai_su_co`) REFERENCES `loai_su_co` (`ma_loai_su_co`),
  CONSTRAINT `FK_su_co_nguoi_bao_cao` FOREIGN KEY (`nguoi_bao_cao_id`) REFERENCES `nguoi_dung` (`ma_nguoi_dung`),
  CONSTRAINT `FK_su_co_ky_thuat_vien` FOREIGN KEY (`ky_thuat_vien_id`) REFERENCES `nguoi_dung` (`ma_nguoi_dung`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 7. HÌNH ẢNH SỰ CỐ
CREATE TABLE `hinh_anh_su_co` (
  `ma_hinh_anh` INT NOT NULL AUTO_INCREMENT,
  `ma_su_co_id` INT NOT NULL,
  `duong_dan_anh` VARCHAR(500) NOT NULL,
  `loai_hinh_anh` VARCHAR(50) NOT NULL DEFAULT 'Report',
  `ngay_chup_anh` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `nguoi_chup_id` INT NOT NULL,
  PRIMARY KEY (`ma_hinh_anh`),
  CONSTRAINT `FK_hinh_anh_su_co_su_co` FOREIGN KEY (`ma_su_co_id`) REFERENCES `su_co` (`ma_su_co_id`) ON DELETE CASCADE,
  CONSTRAINT `FK_hinh_anh_su_co_nguoi_chup` FOREIGN KEY (`nguoi_chup_id`) REFERENCES `nguoi_dung` (`ma_nguoi_dung`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 8. LỊCH SỬ TIẾN TRÌNH XỬ LÝ
CREATE TABLE `lich_su_xu_ly` (
  `ma_lich_su` INT NOT NULL AUTO_INCREMENT,
  `ma_su_co_id` INT NOT NULL,
  `nguoi_thuc_hien_id` INT NOT NULL,
  `trang_thai_cu` VARCHAR(50) DEFAULT NULL,
  `trang_thai_moi` VARCHAR(50) NOT NULL,
  `noi_dung_ghi_chu` LONGTEXT NOT NULL,
  `thoi_gian_cap_nhat` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`ma_lich_su`),
  CONSTRAINT `FK_lich_su_xu_ly_su_co` FOREIGN KEY (`ma_su_co_id`) REFERENCES `su_co` (`ma_su_co_id`) ON DELETE CASCADE,
  CONSTRAINT `FK_lich_su_xu_ly_nguoi_thuc_hien` FOREIGN KEY (`nguoi_thuc_hien_id`) REFERENCES `nguoi_dung` (`ma_nguoi_dung`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 9. ĐÁNH GIÁ NGHIỆM THU
CREATE TABLE `danh_gia_nghiem_thu` (
  `ma_danh_gia` INT NOT NULL AUTO_INCREMENT,
  `ma_su_co_id` INT NOT NULL,
  `nguoi_danh_gia_id` INT NOT NULL,
  `so_sao_hai_long` INT NOT NULL,
  `y_kien_phan_hoi` LONGTEXT DEFAULT NULL,
  `ngay_danh_gia` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`ma_danh_gia`),
  UNIQUE KEY `UQ_danh_gia_su_co` (`ma_su_co_id`),
  CONSTRAINT `FK_danh_gia_su_co` FOREIGN KEY (`ma_su_co_id`) REFERENCES `su_co` (`ma_su_co_id`) ON DELETE CASCADE,
  CONSTRAINT `FK_danh_gia_nguoi_danh_gia` FOREIGN KEY (`nguoi_danh_gia_id`) REFERENCES `nguoi_dung` (`ma_nguoi_dung`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 10. THÔNG BÁO HỆ THỐNG
CREATE TABLE `thong_bao` (
  `ma_thong_bao` INT NOT NULL AUTO_INCREMENT,
  `nguoi_nhan_id` INT NOT NULL,
  `tieu_de` VARCHAR(250) NOT NULL,
  `noi_dung_thong_bao` LONGTEXT NOT NULL,
  `ma_su_co_id` INT DEFAULT NULL,
  `da_doc` TINYINT(1) NOT NULL DEFAULT 0,
  `ngay_gui` DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`ma_thong_bao`),
  CONSTRAINT `FK_thong_bao_nguoi_nhan` FOREIGN KEY (`nguoi_nhan_id`) REFERENCES `nguoi_dung` (`ma_nguoi_dung`) ON DELETE CASCADE,
  CONSTRAINT `FK_thong_bao_su_co` FOREIGN KEY (`ma_su_co_id`) REFERENCES `su_co` (`ma_su_co_id`) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- =========================================================================================
-- SEED DATA TIẾNG VIỆT CHUẨN ĐẠI HỌC TRÀ VINH
-- =========================================================================================

-- Khuôn viên
INSERT INTO `khuon_vien` (`ma_khuon_vien`, `ten_khuon_vien`, `ma_viet_tat`, `dia_chi`, `mo_ta`) VALUES
(1, 'Khu 1 - Cơ sở chính TVU', 'KHU1', 'Số 126 Nguyễn Thiện Thành, Phường 5, TP. Trà Vinh, Tỉnh Trà Vinh', 'Khuôn viên trung tâm đào tạo, Khoa Kỹ thuật & Công nghệ, Dãy A, Dãy B, Tòa nhà A1'),
(2, 'Khu 2 - Khu Nông nghiệp & Thực nghiệm TVU', 'KHU2', 'Xã Hòa Thuận, Huyện Châu Thành, Tỉnh Trà Vinh', 'Khu thực nghiệm Nông nghiệp - Thủy sản, Bệnh viện Thú y và Ký túc xá');

-- Dãy nhà
INSERT INTO `day_nha` (`ma_day_nha`, `ma_khuon_vien`, `ma_toa`, `ten_day_nha`, `tong_so_tang`) VALUES
(1, 1, 'B3', 'Dãy B3 - Khoa Kỹ thuật & Công nghệ', 4),
(2, 1, 'A4', 'Dãy A4 - Giảng đường Lý thuyết', 4),
(3, 1, 'A1', 'Tòa nhà A1 - Nhà Hiệu bộ & Ban Quản lý CSVC TVU', 5),
(4, 1, 'D1', 'Dãy D1 - Khu Xưởng Thực hành & Thí nghiệm', 3);

-- Phòng học & Trang thiết bị (Quy chuẩn Khu A & B: 2 máy lạnh, quạt trần/điện, 1 TV, 1 HDMI, 1 bảng, 14-18 bàn SV, 1 bàn GV)
INSERT INTO `phong_hoc` (`ma_phong_hoc`, `ma_day_nha`, `so_phong`, `loai_phong`, `tang_so`, `ma_qr_dinh_danh`, `so_may_lanh`, `so_quat`, `loai_quat`, `so_tivi`, `so_cong_hdmi`, `so_bang_viet`, `so_ban_sinh_vien`, `so_ban_giao_vien`, `mo_ta_hien_trang`, `dang_su_dung`) VALUES
(1, 1, 'B31.101', 'LectureHall', 1, 'TVU-B31.101', 2, 2, 'Quạt trần', 1, 1, 1, 16, 1, 'Phòng học Dãy B (16 bàn SV, 1 bàn GV, 2 máy lạnh, 2 quạt trần, 1 Tivi, 1 cổng HDMI, 1 bảng viết)', 1),
(2, 1, 'B31.102', 'LectureHall', 1, 'TVU-B31.102', 2, 4, 'Quạt điện', 1, 1, 1, 14, 1, 'Phòng học Dãy B (14 bàn SV, 1 bàn GV, 2 máy lạnh, 4 quạt điện, 1 Tivi, 1 cổng HDMI, 1 bảng viết)', 1),
(3, 1, 'B31.103', 'LectureHall', 1, 'TVU-B31.103', 2, 2, 'Quạt trần', 1, 1, 1, 18, 1, 'Phòng học Dãy B (18 bàn SV, 1 bàn GV, 2 máy lạnh, 2 quạt trần, 1 Tivi, 1 cổng HDMI, 1 bảng viết)', 1),
(4, 1, 'B32.201', 'ComputerLab', 2, 'TVU-B32.201', 2, 4, 'Quạt điện', 1, 1, 1, 15, 1, 'Phòng thực hành máy tính Lab 1 (45 máy tính, 1 bàn GV, 2 máy lạnh, 4 quạt điện, 1 Tivi, 1 cổng HDMI, 1 bảng)', 1),
(5, 1, 'B32.202', 'ComputerLab', 2, 'TVU-B32.202', 2, 4, 'Quạt điện', 1, 1, 1, 15, 1, 'Phòng thực hành máy tính Lab 2 (45 máy tính, 1 bàn GV, 2 máy lạnh, 4 quạt điện, 1 Tivi, 1 cổng HDMI, 1 bảng)', 1),
(6, 1, 'B32.203', 'LectureHall', 2, 'TVU-B32.203', 2, 2, 'Quạt trần', 1, 1, 1, 17, 1, 'Phòng học Dãy B (17 bàn SV, 1 bàn GV, 2 máy lạnh, 2 quạt trần, 1 Tivi, 1 cổng HDMI, 1 bảng viết)', 1),
(7, 2, 'A42.101', 'LectureHall', 1, 'TVU-A42.101', 2, 4, 'Quạt điện', 1, 1, 1, 16, 1, 'Phòng học Dãy A (16 bàn SV, 1 bàn GV, 2 máy lạnh, 4 quạt điện, 1 Tivi, 1 cổng HDMI, 1 bảng viết)', 1),
(8, 2, 'A42.102', 'LectureHall', 1, 'TVU-A42.102', 2, 2, 'Quạt trần', 1, 1, 1, 14, 1, 'Phòng học Dãy A (14 bàn SV, 1 bàn GV, 2 máy lạnh, 2 quạt trần, 1 Tivi, 1 cổng HDMI, 1 bảng viết)', 1),
(9, 2, 'A42.103', 'LectureHall', 2, 'TVU-A42.103', 2, 2, 'Quạt trần', 1, 1, 1, 18, 1, 'Phòng học Dãy A (18 bàn SV, 1 bàn GV, 2 máy lạnh, 2 quạt trần, 1 Tivi, 1 cổng HDMI, 1 bảng viết)', 1),
(10, 2, 'A42.204', 'LectureHall', 2, 'TVU-A42.204', 2, 4, 'Quạt điện', 1, 1, 1, 16, 1, 'Phòng học Dãy A (16 bàn SV, 1 bàn GV, 2 máy lạnh, 4 quạt điện, 1 Tivi, 1 cổng HDMI, 1 bảng viết)', 1),
(11, 3, 'A12.201', 'Office', 2, 'TVU-A12.201', 2, 2, 'Quạt trần', 1, 1, 1, 6, 1, 'Văn phòng Ban Quản trị Thiết bị & CSVC TVU', 1);

-- Danh mục loại sự cố
INSERT INTO `loai_su_co` (`ma_loai_su_co`, `ten_loai_su_co`, `bieu_tuong`, `mo_ta_chi_tiet`) VALUES
(1, 'Hệ thống điện & Chiếu sáng', 'lightbulb', 'Đèn tuýp LED chập cháy, mất điện ổ cắm bục giảng, công tắc hư hỏng, aptomat nhảy'),
(2, 'Máy lạnh & Quạt làm mát', 'ac_unit', 'Máy lạnh chảy nước ngưng, không lạnh, remote hết pin; quạt trần kêu to, quạt điện đứng cánh'),
(3, 'Thiết bị Tivi, HDMI & CNTT', 'tv', 'Tivi không lên nguồn, cổng cáp HDMI lỏng/gãy không truyền hình ảnh từ laptop, lỗi mạng Lab'),
(4, 'Bàn ghế & Bảng giảng dạy', 'chair', 'Bàn học sinh viên gãy chân, lung lay; hỏng bàn giáo viên; bảng mica viết bút dạ ố mờ khó tẩy xóa'),
(5, 'Cấp thoát nước & Vệ sinh', 'water_drop', 'Vòi nước rò rỉ, bồn rửa mặt lavabo tắc nghẽn, van xả nước gãy, thấm dột nhà vệ sinh'),
(6, 'Vệ sinh môi trường & An toàn', 'cleaning_services', 'Thùng rác hành lang tồn đọng, mùi khó chịu, kẹt khóa cửa phòng học, bình PCCC quá hạn');

-- Người dùng (Mật khẩu: Tvu@123456)
INSERT INTO `nguoi_dung` (`ma_nguoi_dung`, `ten_dang_nhap`, `ho_va_ten`, `email_tvu`, `so_dien_thoai`, `mat_khau_ma_hoa`, `vai_tro`, `lop_hoac_don_vi`, `ngay_tao`, `dang_hoat_dong`) VALUES
(1, 'admin_csvc', 'ThS. Nguyễn Văn Quản (Quản lý CSVC TVU)', 'csvc@tvu.edu.vn', '02943855246', '$2a$11$N.csqw2fV2G08J73QcR6kOMWvF/i9qO14uP7iR264J0vB039a0U8K', 'Admin', 'Phòng Quản trị Thiết bị & CSVC TVU', '2026-01-01 00:00:00', 1),
(2, 'ktv_dienlanh', 'Trần Kỹ Thuật (Tổ Cơ Điện - Điện Lạnh)', 'dienlanh@tvu.edu.vn', '0912345678', '$2a$11$N.csqw2fV2G08J73QcR6kOMWvF/i9qO14uP7iR264J0vB039a0U8K', 'Technician', 'Tổ Cơ điện & Điện lạnh TVU', '2026-01-01 00:00:00', 1),
(3, 'ktv_it', 'Lê Tin Học (Tổ Hỗ trợ Thiết bị CNTT & Lab)', 'it_support@tvu.edu.vn', '0987654321', '$2a$11$N.csqw2fV2G08J73QcR6kOMWvF/i9qO14uP7iR264J0vB039a0U8K', 'Technician', 'Trung tâm Công nghệ Thông tin TVU', '2026-01-01 00:00:00', 1),
(4, '110121001', 'Nguyễn Minh Khang (Sinh viên DA21TT)', '110121001@st.tvu.edu.vn', '0939112233', '$2a$11$N.csqw2fV2G08J73QcR6kOMWvF/i9qO14uP7iR264J0vB039a0U8K', 'Student', 'Lớp Đại học CNTT Khóa 2021 (DA21TT)', '2026-01-01 00:00:00', 1),
(5, 'gv_lamthanh', 'TS. Lâm Thành (Giảng viên Khoa KT&CN)', 'lamthanh@tvu.edu.vn', '0949887766', '$2a$11$N.csqw2fV2G08J73QcR6kOMWvF/i9qO14uP7iR264J0vB039a0U8K', 'Lecturer', 'Bộ môn Công nghệ Thông tin - Khoa KT&CN', '2026-01-01 00:00:00', 1);

-- Phiếu sự cố
INSERT INTO `su_co` (`ma_su_co_id`, `ma_phieu_su_co`, `tieu_de`, `mo_ta_hu_hong`, `ma_phong_hoc`, `ma_loai_su_co`, `vi_tri_trong_phong`, `muc_do_uu_tien`, `trang_thai`, `nguoi_bao_cao_id`, `ky_thuat_vien_id`, `ngay_gui_bao_cao`, `ngay_phan_cong`, `ngay_hoan_thanh`, `ngay_dong_phieu`) VALUES
(1, 'SC-20261005-0001', 'Máy lạnh số 1 bị nghẹt máng chảy nước xuống bàn học', 'Máy lạnh số 1 góc trái cửa ra vào chảy nước rỉ rả xuống dãy bàn học sinh viên số 2, làm ẩm ướt sàn nhà', 1, 2, 'Máy lạnh số 1 góc cửa ra vào', 'High', 'InProgress', 4, 2, '2026-10-05 07:30:00', '2026-10-05 08:00:00', NULL, NULL),
(2, 'SC-20261005-0002', 'Tivi không nhận tín hiệu qua cổng cáp HDMI từ laptop', 'Giảng viên cắm dây HDMI vào laptop nhưng màn hình Tivi báo No Signal, cổng HDMI bàn giáo viên bị lỏng chân cắm', 9, 3, 'Bàn giáo viên kết nối Tivi', 'High', 'Pending', 5, NULL, '2026-10-05 08:15:00', NULL, NULL, NULL),
(3, 'SC-20261004-0003', 'Đèn tuýp LED dãy 2 bị chập chớp tắt liên tục', 'Bộ 2 bóng đèn LED giữa phòng bị chớp liên tục gây chói mắt sinh viên đang thực hành máy tính', 4, 1, 'Khu vực máy tính số 15 - 20', 'Low', 'Resolved', 4, 2, '2026-10-04 13:30:00', '2026-10-04 14:00:00', '2026-10-04 16:00:00', '2026-10-04 16:30:00'),
(4, 'SC-20261006-0004', 'Bàn học sinh viên số 05 bị gãy chân sắt lung lay', 'Bàn sinh viên số 5 hàng thứ 2 bị gãy mối hàn chân bàn bên phải, sinh viên ngồi viết bị nghiêng lệch', 2, 4, 'Bàn số 5 hàng 2 giữa phòng', 'Medium', 'Assigned', 4, 2, '2026-10-06 09:00:00', '2026-10-06 09:30:00', NULL, NULL),
(5, 'SC-20261006-0005', 'Quạt trần số 2 phát tiếng kêu to rè rè khi bật số 3', 'Quạt trần giữa phòng bị rung lắc và kêu rất to khi bật tốc độ cao, gây mất tập trung trong giờ học', 7, 2, 'Quạt trần số 2 giữa phòng', 'Medium', 'Pending', 5, NULL, '2026-10-06 10:15:00', NULL, NULL, NULL);

-- Lịch sử tiến trình
INSERT INTO `lich_su_xu_ly` (`ma_lich_su`, `ma_su_co_id`, `nguoi_thuc_hien_id`, `trang_thai_cu`, `trang_thai_moi`, `noi_dung_ghi_chu`, `thoi_gian_cap_nhat`) VALUES
(1, 1, 4, NULL, 'Pending', 'Sinh viên Nguyễn Minh Khang quét mã QR phòng B31.101 và gửi báo cáo sự cố máy lạnh', '2026-10-05 07:30:00'),
(2, 1, 1, 'Pending', 'Assigned', 'Quản lý CSVC duyệt và phân công cho KTV Trần Kỹ Thuật (Tổ Cơ Điện - Điện Lạnh)', '2026-10-05 08:00:00'),
(3, 1, 2, 'Assigned', 'InProgress', 'KTV đã tiếp nhận mang bộ dụng cụ đến phòng B31.101 thông máng thoát nước ngưng', '2026-10-05 08:20:00'),
(4, 2, 5, NULL, 'Pending', 'TS. Lâm Thành báo cáo sự cố cổng HDMI không kết nối được Tivi phòng A42.103', '2026-10-05 08:15:00'),
(5, 3, 4, NULL, 'Pending', 'Báo cáo hỏng đèn chiếu sáng phòng Lab 1 B32.201', '2026-10-04 13:30:00'),
(6, 3, 1, 'Pending', 'Assigned', 'Phân công KTV Trần Kỹ Thuật thay bóng đèn tuýp LED', '2026-10-04 14:00:00'),
(7, 3, 2, 'Assigned', 'Resolved', 'Đã thay mới 2 bóng đèn LED Duhal 18W hoạt động sáng tốt', '2026-10-04 16:00:00'),
(8, 4, 4, NULL, 'Pending', 'Sinh viên phản ánh bàn học số 5 phòng B31.102 bị gãy chân sắt', '2026-10-06 09:00:00'),
(9, 4, 1, 'Pending', 'Assigned', 'Phân công KTV hàn lại mối hàn chân bàn học', '2026-10-06 09:30:00');

-- Đánh giá nghiệm thu
INSERT INTO `danh_gia_nghiem_thu` (`ma_danh_gia`, `ma_su_co_id`, `nguoi_danh_gia_id`, `so_sao_hai_long`, `y_kien_phan_hoi`, `ngay_danh_gia`) VALUES
(1, 3, 4, 5, 'Kỹ thuật viên xử lý rất nhanh và nhiệt tình, phòng Lab đã đủ sáng để thực hành học tập!', '2026-10-04 16:30:00');

-- Thông báo
INSERT INTO `thong_bao` (`ma_thong_bao`, `nguoi_nhan_id`, `tieu_de`, `noi_dung_thong_bao`, `ma_su_co_id`, `da_doc`, `ngay_gui`) VALUES
(1, 2, 'Phân công nhiệm vụ mới', 'Bạn vừa được giao xử lý sự cố [SC-20261005-0001] tại phòng B31.101', 1, 1, '2026-10-05 08:00:00'),
(2, 4, 'Sự cố đang được xử lý', 'Sự cố máy lạnh [SC-20261005-0001] tại phòng B31.101 đang được kỹ thuật viên xử lý', 1, 0, '2026-10-05 08:20:00'),
(3, 1, 'Báo cáo sự cố mới', 'TS. Lâm Thành vừa báo cáo sự cố Tivi/HDMI tại phòng A42.103', 2, 0, '2026-10-05 08:15:00'),
(4, 2, 'Phân công nhiệm vụ mới', 'Bạn vừa được giao xử lý sự cố bàn ghế [SC-20261006-0004] tại phòng B31.102', 4, 0, '2026-10-06 09:30:00');
