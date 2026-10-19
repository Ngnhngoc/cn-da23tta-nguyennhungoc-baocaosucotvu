-- =========================================================================================
-- ĐỒ ÁN / BÁO CÁO: HỆ THỐNG BÁO CÁO VÀ THEO DÕI SỰ CỐ CƠ SỞ VẬT CHẤT (TVU FACILITY)
-- ĐƠN VỊ: TRƯỜNG ĐẠI HỌC TRÀ VINH (TRA VINH UNIVERSITY - TVU)
-- TẬP TIN SCRIPT: MICROSOFT SQL SERVER MANAGEMENT STUDIO (SSMS)
-- CHUẨN HÓA 100% TÊN BẢNG & THUỘC TÍNH BẰNG TIẾNG VIỆT
-- ĐẶC TẢ TRANG THIẾT BỊ PHÒNG HỌC KHU A & B:
-- Mỗi phòng trang bị: 2 máy lạnh, 2 quạt trần (hoặc 4 quạt điện), 1 Tivi, 1 cổng HDMI, 
--                     1 bảng viết, 14-18 bàn sinh viên, 1 bàn giáo viên.
-- =========================================================================================

PRINT N'>>> BẮT ĐẦU KHỞI TẠO CƠ SỞ DỮ LIỆU [TVU_Facility_DB] CHUẨN TIẾNG VIỆT TRÊN SQL SERVER...';
GO

-- =========================================================================================
-- 1. TẠO CƠ SỞ DỮ LIỆU (NẾU CHƯA CÓ)
-- =========================================================================================
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = N'TVU_Facility_DB')
BEGIN
    CREATE DATABASE [TVU_Facility_DB]
    COLLATE Vietnamese_CI_AS; -- Hỗ trợ tiếng Việt Unicode chuẩn tìm kiếm
    PRINT N'-> Đã tạo mới Database [TVU_Facility_DB].';
END
ELSE
BEGIN
    PRINT N'-> Database [TVU_Facility_DB] đã sẵn sàng.';
END
GO

USE [TVU_Facility_DB];
GO

-- =========================================================================================
-- 2. XÓA CÁC ĐỐI TƯỢNG CŨ THEO THỨ TỰ RÀNG BUỘC (CLEANUP SCRIPT)
-- =========================================================================================
-- Xóa Views (nếu có)
IF OBJECT_ID(N'dbo.v_BangTongHopCoSoVatChat_KhuA_B', N'V') IS NOT NULL DROP VIEW dbo.v_BangTongHopCoSoVatChat_KhuA_B;
IF OBJECT_ID(N'dbo.v_DanhSachSuCoChiTiet', N'V') IS NOT NULL DROP VIEW dbo.v_DanhSachSuCoChiTiet;
IF OBJECT_ID(N'dbo.v_ThongKeSuCoTheoPhong', N'V') IS NOT NULL DROP VIEW dbo.v_ThongKeSuCoTheoPhong;

-- Xóa Stored Procedures (nếu có)
IF OBJECT_ID(N'dbo.sp_BaoCaoSuCoMoi', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_BaoCaoSuCoMoi;
IF OBJECT_ID(N'dbo.sp_PhanCongKyThuatVien', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_PhanCongKyThuatVien;
IF OBJECT_ID(N'dbo.sp_CapNhatTienDoSuCo', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_CapNhatTienDoSuCo;

-- Xóa 10 Bảng tiếng Việt theo thứ tự khóa ngoại
IF OBJECT_ID(N'dbo.THONG_BAO', N'U') IS NOT NULL DROP TABLE dbo.THONG_BAO;
IF OBJECT_ID(N'dbo.DANH_GIA_NGHIEM_THU', N'U') IS NOT NULL DROP TABLE dbo.DANH_GIA_NGHIEM_THU;
IF OBJECT_ID(N'dbo.LICH_SU_XU_LY', N'U') IS NOT NULL DROP TABLE dbo.LICH_SU_XU_LY;
IF OBJECT_ID(N'dbo.HINH_ANH_SU_CO', N'U') IS NOT NULL DROP TABLE dbo.HINH_ANH_SU_CO;
IF OBJECT_ID(N'dbo.SU_CO', N'U') IS NOT NULL DROP TABLE dbo.SU_CO;
IF OBJECT_ID(N'dbo.PHONG_HOC', N'U') IS NOT NULL DROP TABLE dbo.PHONG_HOC;
IF OBJECT_ID(N'dbo.DAY_NHA', N'U') IS NOT NULL DROP TABLE dbo.DAY_NHA;
IF OBJECT_ID(N'dbo.KHUON_VIEN', N'U') IS NOT NULL DROP TABLE dbo.KHUON_VIEN;
IF OBJECT_ID(N'dbo.LOAI_SU_CO', N'U') IS NOT NULL DROP TABLE dbo.LOAI_SU_CO;
IF OBJECT_ID(N'dbo.NGUOI_DUNG', N'U') IS NOT NULL DROP TABLE dbo.NGUOI_DUNG;
GO

PRINT N'-> Đã dọn dẹp các đối tượng cũ sạch sẽ.';
GO

-- =========================================================================================
-- 3. TẠO CẤU TRÚC 10 BẢNG TIẾNG VIỆT CHUẨN HÓA 3NF (TABLE DEFINITIONS)
-- =========================================================================================

-- 1. BẢNG KHUÔN VIÊN TRƯỜNG (KHUON_VIEN)
CREATE TABLE dbo.KHUON_VIEN (
    ma_khuon_vien INT IDENTITY(1,1) NOT NULL,
    ten_khuon_vien NVARCHAR(250) NOT NULL,
    ma_viet_tat NVARCHAR(50) NOT NULL,
    dia_chi NVARCHAR(500) NULL,
    mo_ta NVARCHAR(MAX) NULL,
    CONSTRAINT PK_KHUON_VIEN PRIMARY KEY CLUSTERED (ma_khuon_vien ASC),
    CONSTRAINT UQ_KHUON_VIEN_Ma UNIQUE NONCLUSTERED (ma_viet_tat ASC)
);
GO

-- 2. BẢNG DÃY NHÀ / TÒA NHÀ (DAY_NHA)
CREATE TABLE dbo.DAY_NHA (
    ma_day_nha INT IDENTITY(1,1) NOT NULL,
    ma_khuon_vien INT NOT NULL,
    ten_day_nha NVARCHAR(250) NOT NULL,
    ma_toa NVARCHAR(50) NOT NULL,
    tong_so_tang INT NOT NULL DEFAULT (1),
    CONSTRAINT PK_DAY_NHA PRIMARY KEY CLUSTERED (ma_day_nha ASC),
    CONSTRAINT UQ_DAY_NHA_MaToa UNIQUE NONCLUSTERED (ma_toa ASC),
    CONSTRAINT FK_DAY_NHA_KHUON_VIEN FOREIGN KEY (ma_khuon_vien) REFERENCES dbo.KHUON_VIEN(ma_khuon_vien) ON DELETE CASCADE
);
GO

-- 3. BẢNG PHÒNG HỌC & TRANG THIẾT BỊ HIỆN TRẠNG (PHONG_HOC)
-- Lưu trữ chi tiết quy chuẩn trang bị cho Khu A và Khu B:
-- 2 máy lạnh, 2 quạt trần (hoặc 4 quạt điện), 1 Tivi, 1 cổng HDMI, 1 bảng, 14-18 bàn SV, 1 bàn GV
CREATE TABLE dbo.PHONG_HOC (
    ma_phong_hoc INT IDENTITY(1,1) NOT NULL,
    ma_day_nha INT NOT NULL,
    so_phong NVARCHAR(50) NOT NULL,                  -- Ví dụ: B31.101, A42.103
    loai_phong NVARCHAR(50) NOT NULL DEFAULT (N'LectureHall'), -- LectureHall, ComputerLab, Office
    tang_so INT NOT NULL DEFAULT (1),
    ma_qr_dinh_danh NVARCHAR(100) NOT NULL,         -- Ví dụ: TVU-B31.101
    so_may_lanh INT NOT NULL DEFAULT (2),           -- Chuẩn 2 máy lạnh
    so_quat INT NOT NULL DEFAULT (2),               -- 2 quạt trần hoặc 4 quạt điện
    loai_quat NVARCHAR(50) NOT NULL DEFAULT (N'Quạt trần'), -- N'Quạt trần' hoặc N'Quạt điện'
    so_tivi INT NOT NULL DEFAULT (1),               -- Chuẩn 1 Tivi màn hình lớn
    so_cong_hdmi INT NOT NULL DEFAULT (1),          -- Chuẩn 1 cổng HDMI tại bàn GV
    so_bang_viet INT NOT NULL DEFAULT (1),          -- Chuẩn 1 bảng viết
    so_ban_sinh_vien INT NOT NULL DEFAULT (16),     -- Từ 14 đến 18 bàn học sinh viên
    so_ban_giao_vien INT NOT NULL DEFAULT (1),      -- Chuẩn 1 bàn giáo viên kèm ghế
    mo_ta_hien_trang NVARCHAR(MAX) NULL,
    dang_su_dung BIT NOT NULL DEFAULT (1),
    CONSTRAINT PK_PHONG_HOC PRIMARY KEY CLUSTERED (ma_phong_hoc ASC),
    CONSTRAINT UQ_PHONG_HOC_Qr UNIQUE NONCLUSTERED (ma_qr_dinh_danh ASC),
    CONSTRAINT UQ_PHONG_HOC_SoPhong UNIQUE NONCLUSTERED (ma_day_nha ASC, so_phong ASC),
    CONSTRAINT FK_PHONG_HOC_DAY_NHA FOREIGN KEY (ma_day_nha) REFERENCES dbo.DAY_NHA(ma_day_nha) ON DELETE CASCADE
);
GO

-- 4. BẢNG DANH MỤC LOẠI SỰ CỐ (LOAI_SU_CO)
CREATE TABLE dbo.LOAI_SU_CO (
    ma_loai_su_co INT IDENTITY(1,1) NOT NULL,
    ten_loai_su_co NVARCHAR(200) NOT NULL,
    bieu_tuong NVARCHAR(100) NOT NULL DEFAULT (N'build'),
    mo_ta_chi_tiet NVARCHAR(MAX) NULL,
    CONSTRAINT PK_LOAI_SU_CO PRIMARY KEY CLUSTERED (ma_loai_su_co ASC)
);
GO

-- 5. BẢNG NGƯỜI DÙNG HỆ THỐNG (NGUOI_DUNG)
CREATE TABLE dbo.NGUOI_DUNG (
    ma_nguoi_dung INT IDENTITY(1,1) NOT NULL,
    ten_dang_nhap NVARCHAR(100) NOT NULL,           -- Mã số SV / CBGV / Admin
    ho_va_ten NVARCHAR(200) NOT NULL,
    email_tvu NVARCHAR(200) NOT NULL,
    so_dien_thoai NVARCHAR(50) NULL,
    mat_khau_ma_hoa NVARCHAR(500) NOT NULL,         -- BCrypt Hash
    vai_tro NVARCHAR(50) NOT NULL DEFAULT (N'Student'), -- Admin, Technician, Student, Lecturer
    lop_hoac_don_vi NVARCHAR(200) NULL,             -- Lớp DA21TT / Khoa KT&CN / Ban CSVC
    ngay_tao DATETIME2(7) NOT NULL DEFAULT (SYSUTCDATETIME()),
    dang_hoat_dong BIT NOT NULL DEFAULT (1),
    CONSTRAINT PK_NGUOI_DUNG PRIMARY KEY CLUSTERED (ma_nguoi_dung ASC),
    CONSTRAINT UQ_NGUOI_DUNG_TenDangNhap UNIQUE NONCLUSTERED (ten_dang_nhap ASC),
    CONSTRAINT UQ_NGUOI_DUNG_Email UNIQUE NONCLUSTERED (email_tvu ASC)
);
GO

-- 6. BẢNG PHIẾU BÁO CÁO SỰ CỐ (SU_CO)
CREATE TABLE dbo.SU_CO (
    ma_su_co_id INT IDENTITY(1,1) NOT NULL,
    ma_phieu_su_co NVARCHAR(100) NOT NULL,         -- Ví dụ: SC-20261019-0001
    tieu_de NVARCHAR(300) NOT NULL,
    mo_ta_hu_hong NVARCHAR(MAX) NOT NULL,
    ma_phong_hoc INT NOT NULL,
    ma_loai_su_co INT NOT NULL,
    vi_tri_trong_phong NVARCHAR(250) NULL,          -- Bàn giáo viên, Cổng HDMI, Quạt trần số 2...
    muc_do_uu_tien NVARCHAR(50) NOT NULL DEFAULT (N'Medium'), -- Low, Medium, High, Critical
    trang_thai NVARCHAR(50) NOT NULL DEFAULT (N'Pending'),    -- Pending, Assigned, InProgress, Resolved, Closed, Rejected
    nguoi_bao_cao_id INT NOT NULL,
    ky_thuat_vien_id INT NULL,
    ngay_gui_bao_cao DATETIME2(7) NOT NULL DEFAULT (SYSUTCDATETIME()),
    ngay_phan_cong DATETIME2(7) NULL,
    ngay_hoan_thanh DATETIME2(7) NULL,
    ngay_dong_phieu DATETIME2(7) NULL,
    CONSTRAINT PK_SU_CO PRIMARY KEY CLUSTERED (ma_su_co_id ASC),
    CONSTRAINT UQ_SU_CO_MaPhieu UNIQUE NONCLUSTERED (ma_phieu_su_co ASC),
    CONSTRAINT FK_SU_CO_PHONG_HOC FOREIGN KEY (ma_phong_hoc) REFERENCES dbo.PHONG_HOC(ma_phong_hoc) ON DELETE NO ACTION,
    CONSTRAINT FK_SU_CO_LOAI_SU_CO FOREIGN KEY (ma_loai_su_co) REFERENCES dbo.LOAI_SU_CO(ma_loai_su_co) ON DELETE NO ACTION,
    CONSTRAINT FK_SU_CO_NGUOI_BAO_CAO FOREIGN KEY (nguoi_bao_cao_id) REFERENCES dbo.NGUOI_DUNG(ma_nguoi_dung) ON DELETE NO ACTION,
    CONSTRAINT FK_SU_CO_KY_THUAT_VIEN FOREIGN KEY (ky_thuat_vien_id) REFERENCES dbo.NGUOI_DUNG(ma_nguoi_dung) ON DELETE SET NULL
);
GO

-- 7. BẢNG HÌNH ẢNH SỰ CỐ (HINH_ANH_SU_CO)
CREATE TABLE dbo.HINH_ANH_SU_CO (
    ma_hinh_anh INT IDENTITY(1,1) NOT NULL,
    ma_su_co_id INT NOT NULL,
    duong_dan_anh NVARCHAR(500) NOT NULL,
    loai_hinh_anh NVARCHAR(50) NOT NULL DEFAULT (N'Report'), -- Report (ảnh lúc báo) / Resolution (ảnh nghiệm thu)
    ngay_chup_anh DATETIME2(7) NOT NULL DEFAULT (SYSUTCDATETIME()),
    nguoi_chup_id INT NOT NULL,
    CONSTRAINT PK_HINH_ANH_SU_CO PRIMARY KEY CLUSTERED (ma_hinh_anh ASC),
    CONSTRAINT FK_HINH_ANH_SU_CO_SU_CO FOREIGN KEY (ma_su_co_id) REFERENCES dbo.SU_CO(ma_su_co_id) ON DELETE CASCADE,
    CONSTRAINT FK_HINH_ANH_SU_CO_NGUOI_DUNG FOREIGN KEY (nguoi_chup_id) REFERENCES dbo.NGUOI_DUNG(ma_nguoi_dung) ON DELETE NO ACTION
);
GO

-- 8. BẢNG LỊCH SỬ TIẾN TRÌNH XỬ LÝ (LICH_SU_XU_LY)
CREATE TABLE dbo.LICH_SU_XU_LY (
    ma_lich_su INT IDENTITY(1,1) NOT NULL,
    ma_su_co_id INT NOT NULL,
    nguoi_thuc_hien_id INT NOT NULL,
    trang_thai_cu NVARCHAR(50) NULL,
    trang_thai_moi NVARCHAR(50) NOT NULL,
    noi_dung_ghi_chu NVARCHAR(MAX) NOT NULL,
    thoi_gian_cap_nhat DATETIME2(7) NOT NULL DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT PK_LICH_SU_XU_LY PRIMARY KEY CLUSTERED (ma_lich_su ASC),
    CONSTRAINT FK_LICH_SU_XU_LY_SU_CO FOREIGN KEY (ma_su_co_id) REFERENCES dbo.SU_CO(ma_su_co_id) ON DELETE CASCADE,
    CONSTRAINT FK_LICH_SU_XU_LY_NGUOI_DUNG FOREIGN KEY (nguoi_thuc_hien_id) REFERENCES dbo.NGUOI_DUNG(ma_nguoi_dung) ON DELETE NO ACTION
);
GO

-- 9. BẢNG ĐÁNH GIÁ NGHIỆM THU (DANH_GIA_NGHIEM_THU)
CREATE TABLE dbo.DANH_GIA_NGHIEM_THU (
    ma_danh_gia INT IDENTITY(1,1) NOT NULL,
    ma_su_co_id INT NOT NULL,
    nguoi_danh_gia_id INT NOT NULL,
    so_sao_hai_long INT NOT NULL,                   -- Đánh giá từ 1 đến 5 sao
    y_kien_phan_hoi NVARCHAR(MAX) NULL,
    ngay_danh_gia DATETIME2(7) NOT NULL DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT PK_DANH_GIA_NGHIEM_THU PRIMARY KEY CLUSTERED (ma_danh_gia ASC),
    CONSTRAINT UQ_DANH_GIA_NGHIEM_THU_SuCo UNIQUE NONCLUSTERED (ma_su_co_id ASC),
    CONSTRAINT CK_DANH_GIA_NGHIEM_THU_Sao CHECK (so_sao_hai_long >= 1 AND so_sao_hai_long <= 5),
    CONSTRAINT FK_DANH_GIA_NGHIEM_THU_SU_CO FOREIGN KEY (ma_su_co_id) REFERENCES dbo.SU_CO(ma_su_co_id) ON DELETE CASCADE,
    CONSTRAINT FK_DANH_GIA_NGHIEM_THU_NGUOI_DUNG FOREIGN KEY (nguoi_danh_gia_id) REFERENCES dbo.NGUOI_DUNG(ma_nguoi_dung) ON DELETE NO ACTION
);
GO

-- 10. BẢNG THÔNG BÁO HỆ THỐNG (THONG_BAO)
CREATE TABLE dbo.THONG_BAO (
    ma_thong_bao INT IDENTITY(1,1) NOT NULL,
    nguoi_nhan_id INT NOT NULL,
    tieu_de NVARCHAR(250) NOT NULL,
    noi_dung_thong_bao NVARCHAR(MAX) NOT NULL,
    ma_su_co_id INT NULL,
    da_doc BIT NOT NULL DEFAULT (0),
    ngay_gui DATETIME2(7) NOT NULL DEFAULT (SYSUTCDATETIME()),
    CONSTRAINT PK_THONG_BAO PRIMARY KEY CLUSTERED (ma_thong_bao ASC),
    CONSTRAINT FK_THONG_BAO_NGUOI_DUNG FOREIGN KEY (nguoi_nhan_id) REFERENCES dbo.NGUOI_DUNG(ma_nguoi_dung) ON DELETE CASCADE,
    CONSTRAINT FK_THONG_BAO_SU_CO FOREIGN KEY (ma_su_co_id) REFERENCES dbo.SU_CO(ma_su_co_id) ON DELETE SET NULL
);
GO

PRINT N'-> Đã khởi tạo hoàn chỉnh 10 bảng Tiếng Việt cùng đầy đủ các ràng buộc PK, FK, UNIQUE, CHECK.';
GO

-- =========================================================================================
-- 4. NẠP DỮ LIỆU MẪU (SEED DATA) CHUẨN ĐẠI HỌC TRÀ VINH
-- =========================================================================================

-- 1. DỮ LIỆU KHUÔN VIÊN TRƯỜNG
SET IDENTITY_INSERT dbo.KHUON_VIEN ON;
INSERT INTO dbo.KHUON_VIEN (ma_khuon_vien, ten_khuon_vien, ma_viet_tat, dia_chi, mo_ta)
VALUES
(1, N'Khu 1 - Cơ sở chính TVU', N'KHU1', N'Số 126 Nguyễn Thiện Thành, Phường 5, TP. Trà Vinh, Tỉnh Trà Vinh', N'Khuôn viên trung tâm đào tạo, Khoa Kỹ thuật & Công nghệ, Dãy A, Dãy B, Tòa nhà A1'),
(2, N'Khu 2 - Khu Nông nghiệp & Thực nghiệm TVU', N'KHU2', N'Xã Hòa Thuận, Huyện Châu Thành, Tỉnh Trà Vinh', N'Khu thực nghiệm Nông nghiệp - Thủy sản, Bệnh viện Thú y và Ký túc xá');
SET IDENTITY_INSERT dbo.KHUON_VIEN OFF;
GO

-- 2. DỮ LIỆU DÃY NHÀ
SET IDENTITY_INSERT dbo.DAY_NHA ON;
INSERT INTO dbo.DAY_NHA (ma_day_nha, ma_khuon_vien, ma_toa, ten_day_nha, tong_so_tang)
VALUES
(1, 1, N'B3', N'Dãy B3 - Khoa Kỹ thuật & Công nghệ', 4),
(2, 1, N'A4', N'Dãy A4 - Giảng đường Lý thuyết', 4),
(3, 1, N'A1', N'Tòa nhà A1 - Nhà Hiệu bộ & Ban Quản lý CSVC TVU', 5),
(4, 1, N'D1', N'Dãy D1 - Khu Xưởng Thực hành & Thí nghiệm', 3);
SET IDENTITY_INSERT dbo.DAY_NHA OFF;
GO

-- 3. DỮ LIỆU PHÒNG HỌC & TRANG THIẾT BỊ CHI TIẾT KHU A & KHU B
SET IDENTITY_INSERT dbo.PHONG_HOC ON;
INSERT INTO dbo.PHONG_HOC (ma_phong_hoc, ma_day_nha, so_phong, loai_phong, tang_so, ma_qr_dinh_danh, 
                           so_may_lanh, so_quat, loai_quat, so_tivi, so_cong_hdmi, so_bang_viet, so_ban_sinh_vien, so_ban_giao_vien, mo_ta_hien_trang, dang_su_dung)
VALUES
-- KHU B (DÃY B3 - KHOA KT&CN)
(1, 1, N'B31.101', N'LectureHall', 1, N'TVU-B31.101', 
 2, 2, N'Quạt trần', 1, 1, 1, 16, 1, N'Phòng học Dãy B (16 bàn SV, 1 bàn GV, 2 máy lạnh, 2 quạt trần, 1 Tivi, 1 cổng HDMI, 1 bảng viết)', 1),

(2, 1, N'B31.102', N'LectureHall', 1, N'TVU-B31.102', 
 2, 4, N'Quạt điện', 1, 1, 1, 14, 1, N'Phòng học Dãy B (14 bàn SV, 1 bàn GV, 2 máy lạnh, 4 quạt điện, 1 Tivi, 1 cổng HDMI, 1 bảng viết)', 1),

(3, 1, N'B31.103', N'LectureHall', 1, N'TVU-B31.103', 
 2, 2, N'Quạt trần', 1, 1, 1, 18, 1, N'Phòng học Dãy B (18 bàn SV, 1 bàn GV, 2 máy lạnh, 2 quạt trần, 1 Tivi, 1 cổng HDMI, 1 bảng viết)', 1),

(4, 1, N'B32.201', N'ComputerLab', 2, N'TVU-B32.201', 
 2, 4, N'Quạt điện', 1, 1, 1, 15, 1, N'Phòng thực hành máy tính Lab 1 (45 máy tính, 1 bàn GV, 2 máy lạnh, 4 quạt điện, 1 Tivi, 1 cổng HDMI, 1 bảng)', 1),

(5, 1, N'B32.202', N'ComputerLab', 2, N'TVU-B32.202', 
 2, 4, N'Quạt điện', 1, 1, 1, 15, 1, N'Phòng thực hành máy tính Lab 2 (45 máy tính, 1 bàn GV, 2 máy lạnh, 4 quạt điện, 1 Tivi, 1 cổng HDMI, 1 bảng)', 1),

(6, 1, N'B32.203', N'LectureHall', 2, N'TVU-B32.203', 
 2, 2, N'Quạt trần', 1, 1, 1, 17, 1, N'Phòng học Dãy B (17 bàn SV, 1 bàn GV, 2 máy lạnh, 2 quạt trần, 1 Tivi, 1 cổng HDMI, 1 bảng viết)', 1),

-- KHU A (DÃY A4 - GIẢNG ĐƯỜNG LÝ THUYẾT & TÒA A1)
(7, 2, N'A42.101', N'LectureHall', 1, N'TVU-A42.101', 
 2, 4, N'Quạt điện', 1, 1, 1, 16, 1, N'Phòng học Dãy A (16 bàn SV, 1 bàn GV, 2 máy lạnh, 4 quạt điện, 1 Tivi, 1 cổng HDMI, 1 bảng viết)', 1),

(8, 2, N'A42.102', N'LectureHall', 1, N'TVU-A42.102', 
 2, 2, N'Quạt trần', 1, 1, 1, 14, 1, N'Phòng học Dãy A (14 bàn SV, 1 bàn GV, 2 máy lạnh, 2 quạt trần, 1 Tivi, 1 cổng HDMI, 1 bảng viết)', 1),

(9, 2, N'A42.103', N'LectureHall', 2, N'TVU-A42.103', 
 2, 2, N'Quạt trần', 1, 1, 1, 18, 1, N'Phòng học Dãy A (18 bàn SV, 1 bàn GV, 2 máy lạnh, 2 quạt trần, 1 Tivi, 1 cổng HDMI, 1 bảng viết)', 1),

(10, 2, N'A42.204', N'LectureHall', 2, N'TVU-A42.204', 
 2, 4, N'Quạt điện', 1, 1, 1, 16, 1, N'Phòng học Dãy A (16 bàn SV, 1 bàn GV, 2 máy lạnh, 4 quạt điện, 1 Tivi, 1 cổng HDMI, 1 bảng viết)', 1),

-- PHÒNG ĐIỀU PHỐI QUẢN TRỊ CSVC TÒA NHÀ A1
(11, 3, N'A12.201', N'Office', 2, N'TVU-A12.201', 
 2, 2, N'Quạt trần', 1, 1, 1, 6, 1, N'Văn phòng Ban Quản trị Thiết bị & CSVC TVU (Bàn làm việc, 2 máy lạnh, tủ hồ sơ, máy chủ giám sát)', 1);
SET IDENTITY_INSERT dbo.PHONG_HOC OFF;
GO

-- 4. DỮ LIỆU DANH MỤC LOẠI SỰ CỐ
SET IDENTITY_INSERT dbo.LOAI_SU_CO ON;
INSERT INTO dbo.LOAI_SU_CO (ma_loai_su_co, ten_loai_su_co, bieu_tuong, mo_ta_chi_tiet)
VALUES
(1, N'Hệ thống điện & Chiếu sáng', N'lightbulb', N'Đèn tuýp LED chập cháy, mất điện ổ cắm bục giảng, công tắc hư hỏng, aptomat nhảy'),
(2, N'Máy lạnh & Quạt làm mát', N'ac_unit', N'Máy lạnh chảy nước ngưng, không lạnh, remote hết pin; quạt trần kêu to, quạt điện đứng cánh'),
(3, N'Thiết bị Tivi, HDMI & CNTT', N'tv', N'Tivi không lên nguồn, cổng cáp HDMI lỏng/gãy không truyền hình ảnh từ laptop, lỗi mạng Lab'),
(4, N'Bàn ghế & Bảng giảng dạy', N'chair', N'Bàn học sinh viên gãy chân, lung lay; hỏng bàn giáo viên; bảng mica viết bút dạ ố mờ khó tẩy xóa'),
(5, N'Cấp thoát nước & Vệ sinh', N'water_drop', N'Vòi nước rò rỉ, bồn rửa mặt lavabo tắc nghẽn, van xả nước gãy, thấm dột nhà vệ sinh'),
(6, N'Vệ sinh môi trường & An toàn', N'cleaning_services', N'Thùng rác hành lang tồn đọng, mùi khó chịu, kẹt khóa cửa phòng học, bình PCCC quá hạn');
SET IDENTITY_INSERT dbo.LOAI_SU_CO OFF;
GO

-- 5. DỮ LIỆU NGƯỜI DÙNG
-- Mật khẩu mặc định: Tvu@123456 (BCrypt Hash)
SET IDENTITY_INSERT dbo.NGUOI_DUNG ON;
INSERT INTO dbo.NGUOI_DUNG (ma_nguoi_dung, ten_dang_nhap, ho_va_ten, email_tvu, so_dien_thoai, mat_khau_ma_hoa, vai_tro, lop_hoac_don_vi, ngay_tao, dang_hoat_dong)
VALUES
(1, N'admin_csvc', N'ThS. Nguyễn Văn Quản (Quản lý CSVC TVU)', N'csvc@tvu.edu.vn', N'02943855246', 
 N'$2a$11$N.csqw2fV2G08J73QcR6kOMWvF/i9qO14uP7iR264J0vB039a0U8K', N'Admin', N'Phòng Quản trị Thiết bị & CSVC TVU', '2026-01-01T00:00:00', 1),

(2, N'ktv_dienlanh', N'Trần Kỹ Thuật (Tổ Cơ Điện - Điện Lạnh)', N'dienlanh@tvu.edu.vn', N'0912345678', 
 N'$2a$11$N.csqw2fV2G08J73QcR6kOMWvF/i9qO14uP7iR264J0vB039a0U8K', N'Technician', N'Tổ Cơ điện & Điện lạnh TVU', '2026-01-01T00:00:00', 1),

(3, N'ktv_it', N'Lê Tin Học (Tổ Hỗ trợ Thiết bị CNTT & Lab)', N'it_support@tvu.edu.vn', N'0987654321', 
 N'$2a$11$N.csqw2fV2G08J73QcR6kOMWvF/i9qO14uP7iR264J0vB039a0U8K', N'Technician', N'Trung tâm Công nghệ Thông tin TVU', '2026-01-01T00:00:00', 1),

(4, N'110121001', N'Nguyễn Minh Khang (Sinh viên DA21TT)', N'110121001@st.tvu.edu.vn', N'0939112233', 
 N'$2a$11$N.csqw2fV2G08J73QcR6kOMWvF/i9qO14uP7iR264J0vB039a0U8K', N'Student', N'Lớp Đại học CNTT Khóa 2021 (DA21TT)', '2026-01-01T00:00:00', 1),

(5, N'gv_lamthanh', N'TS. Lâm Thành (Giảng viên Khoa KT&CN)', N'lamthanh@tvu.edu.vn', N'0949887766', 
 N'$2a$11$N.csqw2fV2G08J73QcR6kOMWvF/i9qO14uP7iR264J0vB039a0U8K', N'Lecturer', N'Bộ môn Công nghệ Thông tin - Khoa KT&CN', '2026-01-01T00:00:00', 1);
SET IDENTITY_INSERT dbo.NGUOI_DUNG OFF;
GO

-- 6. DỮ LIỆU SỰ CỐ MẪU THỰC TẾ
SET IDENTITY_INSERT dbo.SU_CO ON;
INSERT INTO dbo.SU_CO (ma_su_co_id, ma_phieu_su_co, tieu_de, mo_ta_hu_hong, ma_phong_hoc, ma_loai_su_co, vi_tri_trong_phong, muc_do_uu_tien, trang_thai, nguoi_bao_cao_id, ky_thuat_vien_id, ngay_gui_bao_cao, ngay_phan_cong, ngay_hoan_thanh, ngay_dong_phieu)
VALUES
(1, N'SC-20261005-0001', N'Máy lạnh số 1 bị nghẹt máng chảy nước xuống bàn học', 
 N'Máy lạnh số 1 góc trái cửa ra vào chảy nước rỉ rả xuống dãy bàn học sinh viên số 2, làm ẩm ướt sàn nhà', 
 1, 2, N'Máy lạnh số 1 góc cửa ra vào', N'High', N'InProgress', 4, 2, '2026-10-05T07:30:00', '2026-10-05T08:00:00', NULL, NULL),

(2, N'SC-20261005-0002', N'Tivi không nhận tín hiệu qua cổng cáp HDMI từ laptop', 
 N'Giảng viên cắm dây HDMI vào laptop nhưng màn hình Tivi báo No Signal, cổng HDMI bàn giáo viên bị lỏng chân cắm', 
 9, 3, N'Bàn giáo viên kết nối Tivi', N'High', N'Pending', 5, NULL, '2026-10-05T08:15:00', NULL, NULL, NULL),

(3, N'SC-20261004-0003', N'Đèn tuýp LED dãy 2 bị chập chớp tắt liên tục', 
 N'Bộ 2 bóng đèn LED giữa phòng bị chớp liên tục gây chói mắt sinh viên đang thực hành máy tính', 
 4, 1, N'Khu vực máy tính số 15 - 20', N'Low', N'Resolved', 4, 2, '2026-10-04T13:30:00', '2026-10-04T14:00:00', '2026-10-04T16:00:00', '2026-10-04T16:30:00'),

(4, N'SC-20261006-0004', N'Bàn học sinh viên số 05 bị gãy chân sắt lung lay', 
 N'Bàn sinh viên số 5 hàng thứ 2 bị gãy mối hàn chân bàn bên phải, sinh viên ngồi viết bị nghiêng lệch', 
 2, 4, N'Bàn số 5 hàng 2 giữa phòng', N'Medium', N'Assigned', 4, 2, '2026-10-06T09:00:00', '2026-10-06T09:30:00', NULL, NULL),

(5, N'SC-20261006-0005', N'Quạt trần số 2 phát tiếng kêu to rè rè khi bật số 3', 
 N'Quạt trần giữa phòng bị rung lắc và kêu rất to khi bật tốc độ cao, gây mất tập trung trong giờ học', 
 7, 2, N'Quạt trần số 2 giữa phòng', N'Medium', N'Pending', 5, NULL, '2026-10-06T10:15:00', NULL, NULL, NULL);
SET IDENTITY_INSERT dbo.SU_CO OFF;
GO

-- 7. DỮ LIỆU HÌNH ẢNH SỰ CỐ
SET IDENTITY_INSERT dbo.HINH_ANH_SU_CO ON;
INSERT INTO dbo.HINH_ANH_SU_CO (ma_hinh_anh, ma_su_co_id, duong_dan_anh, loai_hinh_anh, ngay_chup_anh, nguoi_chup_id)
VALUES
(1, 1, N'/uploads/sc01_maylanh_chaynuoc.jpg', N'Report', '2026-10-05T07:30:00', 4),
(2, 2, N'/uploads/sc02_tivi_hdmi_loi.jpg', N'Report', '2026-10-05T08:15:00', 5),
(3, 3, N'/uploads/sc03_den_choptat.jpg', N'Report', '2026-10-04T13:30:00', 4),
(4, 3, N'/uploads/sc03_den_da_thay_moi.jpg', N'Resolution', '2026-10-04T16:00:00', 2);
SET IDENTITY_INSERT dbo.HINH_ANH_SU_CO OFF;
GO

-- 8. DỮ LIỆU LỊCH SỬ TIẾN TRÌNH XỬ LÝ
SET IDENTITY_INSERT dbo.LICH_SU_XU_LY ON;
INSERT INTO dbo.LICH_SU_XU_LY (ma_lich_su, ma_su_co_id, nguoi_thuc_hien_id, trang_thai_cu, trang_thai_moi, noi_dung_ghi_chu, thoi_gian_cap_nhat)
VALUES
(1, 1, 4, NULL, N'Pending', N'Sinh viên Nguyễn Minh Khang quét mã QR phòng B31.101 và gửi báo cáo sự cố máy lạnh', '2026-10-05T07:30:00'),
(2, 1, 1, N'Pending', N'Assigned', N'Quản lý CSVC duyệt và phân công cho KTV Trần Kỹ Thuật (Tổ Cơ Điện - Điện Lạnh)', '2026-10-05T08:00:00'),
(3, 1, 2, N'Assigned', N'InProgress', N'KTV đã tiếp nhận mang bộ dụng cụ đến phòng B31.101 thông máng thoát nước ngưng', '2026-10-05T08:20:00'),
(4, 2, 5, NULL, N'Pending', N'TS. Lâm Thành báo cáo sự cố cổng HDMI không kết nối được Tivi phòng A42.103', '2026-10-05T08:15:00'),
(5, 3, 4, NULL, N'Pending', N'Báo cáo hỏng đèn chiếu sáng phòng Lab 1 B32.201', '2026-10-04T13:30:00'),
(6, 3, 1, N'Pending', N'Assigned', N'Phân công KTV Trần Kỹ Thuật thay bóng đèn tuýp LED', '2026-10-04T14:00:00'),
(7, 3, 2, N'Assigned', N'Resolved', N'Đã thay mới 2 bóng đèn LED Duhal 18W hoạt động sáng tốt', '2026-10-04T16:00:00'),
(8, 4, 4, NULL, N'Pending', N'Sinh viên phản ánh bàn học số 5 phòng B31.102 bị gãy chân sắt', '2026-10-06T09:00:00'),
(9, 4, 1, N'Pending', N'Assigned', N'Phân công KTV hàn lại mối hàn chân bàn học', '2026-10-06T09:30:00');
SET IDENTITY_INSERT dbo.LICH_SU_XU_LY OFF;
GO

-- 9. DỮ LIỆU ĐÁNH GIÁ NGHIỆM THU
SET IDENTITY_INSERT dbo.DANH_GIA_NGHIEM_THU ON;
INSERT INTO dbo.DANH_GIA_NGHIEM_THU (ma_danh_gia, ma_su_co_id, nguoi_danh_gia_id, so_sao_hai_long, y_kien_phan_hoi, ngay_danh_gia)
VALUES
(1, 3, 4, 5, N'Kỹ thuật viên xử lý rất nhanh và nhiệt tình, phòng Lab đã đủ sáng để thực hành học tập!', '2026-10-04T16:30:00');
SET IDENTITY_INSERT dbo.DANH_GIA_NGHIEM_THU OFF;
GO

-- 10. DỮ LIỆU THÔNG BÁO HỆ THỐNG
SET IDENTITY_INSERT dbo.THONG_BAO ON;
INSERT INTO dbo.THONG_BAO (ma_thong_bao, nguoi_nhan_id, tieu_de, noi_dung_thong_bao, ma_su_co_id, da_doc, ngay_gui)
VALUES
(1, 2, N'Phân công nhiệm vụ mới', N'Bạn vừa được giao xử lý sự cố [SC-20261005-0001] tại phòng B31.101', 1, 1, '2026-10-05T08:00:00'),
(2, 4, N'Sự cố đang được xử lý', N'Sự cố máy lạnh [SC-20261005-0001] tại phòng B31.101 đang được kỹ thuật viên xử lý', 1, 0, '2026-10-05T08:20:00'),
(3, 1, N'Báo cáo sự cố mới', N'TS. Lâm Thành vừa báo cáo sự cố Tivi/HDMI tại phòng A42.103', 2, 0, '2026-10-05T08:15:00'),
(4, 2, N'Phân công nhiệm vụ mới', N'Bạn vừa được giao xử lý sự cố bàn ghế [SC-20261006-0004] tại phòng B31.102', 4, 0, '2026-10-06T09:30:00');
SET IDENTITY_INSERT dbo.THONG_BAO OFF;
GO

PRINT N'-> Đã nạp thành công toàn bộ Dữ liệu mẫu (Seed Data) chuẩn Đại học Trà Vinh!';
GO

-- =========================================================================================
-- 5. TẠO CÁC VIEWS BÁO CÁO & THỐNG KÊ (MANAGEMENT VIEWS)
-- =========================================================================================

-- VIEW 1: BẢNG TỔNG HỢP HIỆN TRẠNG TRANG THIẾT BỊ CÁC PHÒNG KHU A & KHU B
CREATE VIEW dbo.v_BangTongHopCoSoVatChat_KhuA_B
AS
SELECT 
    d.ma_toa AS [Mã Dãy],
    d.ten_day_nha AS [Tên Dãy Nhà],
    p.so_phong AS [Mã Phòng],
    p.tang_so AS [Tầng],
    p.ma_qr_dinh_danh AS [Mã QR Định Danh],
    p.loai_phong AS [Loại Phòng],
    p.so_ban_sinh_vien AS [Số Bàn Sinh Viên (14-18)],
    p.so_ban_giao_vien AS [Số Bàn Giáo Viên (1)],
    p.so_may_lanh AS [Số Máy Lạnh (2)],
    CONCAT(p.so_quat, N' ', p.loai_quat) AS [Hệ Thống Quạt (2 Trần / 4 Điện)],
    p.so_tivi AS [Số Tivi (1)],
    p.so_cong_hdmi AS [Cổng HDMI (1)],
    p.so_bang_viet AS [Số Bảng Viết (1)],
    p.mo_ta_hien_trang AS [Mô Tả Hiện Trạng]
FROM dbo.PHONG_HOC p
INNER JOIN dbo.DAY_NHA d ON p.ma_day_nha = d.ma_day_nha
WHERE d.ma_toa IN (N'B3', N'A4', N'A1');
GO

-- VIEW 2: DANH SÁCH CHI TIẾT CÁC SỰ CỐ KÈM TIẾN ĐỘ & NGƯỜI PHỤ TRÁCH
CREATE VIEW dbo.v_DanhSachSuCoChiTiet
AS
SELECT 
    s.ma_su_co_id AS IncidentId,
    s.ma_phieu_su_co AS [Mã Sự Cố],
    s.tieu_de AS [Tiêu Đề],
    c.ten_loai_su_co AS [Danh Mục],
    d.ten_day_nha AS [Tòa Nhà],
    p.so_phong AS [Phòng],
    s.vi_tri_trong_phong AS [Vị Trí Cụ Thể],
    s.muc_do_uu_tien AS [Mức Ưu Tiên],
    s.trang_thai AS [Trạng Thái],
    u_rep.ho_va_ten AS [Người Báo Cáo],
    u_rep.vai_tro AS [Vai Trò Người Báo],
    ISNULL(u_ass.ho_va_ten, N'-- Chưa phân công --') AS [Kỹ Thuật Viên Phụ Trách],
    s.ngay_gui_bao_cao AS [Thời Gian Gửi],
    s.ngay_phan_cong AS [Thời Gian Phân Công],
    s.ngay_hoan_thanh AS [Thời Gian Hoàn Thành],
    fb.so_sao_hai_long AS [Số Sao Đánh Giá],
    fb.y_kien_phan_hoi AS [Ý Kiến Đánh Giá]
FROM dbo.SU_CO s
INNER JOIN dbo.PHONG_HOC p ON s.ma_phong_hoc = p.ma_phong_hoc
INNER JOIN dbo.DAY_NHA d ON p.ma_day_nha = d.ma_day_nha
INNER JOIN dbo.LOAI_SU_CO c ON s.ma_loai_su_co = c.ma_loai_su_co
INNER JOIN dbo.NGUOI_DUNG u_rep ON s.nguoi_bao_cao_id = u_rep.ma_nguoi_dung
LEFT JOIN dbo.NGUOI_DUNG u_ass ON s.ky_thuat_vien_id = u_ass.ma_nguoi_dung
LEFT JOIN dbo.DANH_GIA_NGHIEM_THU fb ON s.ma_su_co_id = fb.ma_su_co_id;
GO

-- VIEW 3: THỐNG KÊ TẦN SUẤT SỰ CỐ VÀ TỶ LỆ GIẢI QUYẾT THEO TỪNG PHÒNG
CREATE VIEW dbo.v_ThongKeSuCoTheoPhong
AS
SELECT 
    p.so_phong AS [Phòng Học],
    d.ten_day_nha AS [Tòa Nhà],
    COUNT(s.ma_su_co_id) AS [Tổng Số Sự Cố Phát Sinh],
    SUM(CASE WHEN s.trang_thai = N'Pending' THEN 1 ELSE 0 END) AS [Số Sự Cố Đang Chờ],
    SUM(CASE WHEN s.trang_thai = N'InProgress' THEN 1 ELSE 0 END) AS [Số Sự Cố Đang Sửa],
    SUM(CASE WHEN s.trang_thai = N'Resolved' THEN 1 ELSE 0 END) AS [Số Sự Cố Đã Khắc Phục],
    ISNULL(AVG(CAST(fb.so_sao_hai_long AS FLOAT)), 0) AS [Điểm Đánh Giá TB]
FROM dbo.PHONG_HOC p
INNER JOIN dbo.DAY_NHA d ON p.ma_day_nha = d.ma_day_nha
LEFT JOIN dbo.SU_CO s ON p.ma_phong_hoc = s.ma_phong_hoc
LEFT JOIN dbo.DANH_GIA_NGHIEM_THU fb ON s.ma_su_co_id = fb.ma_su_co_id
GROUP BY p.so_phong, d.ten_day_nha;
GO

PRINT N'-> Đã tạo thành công 3 Views báo cáo & thống kê quản lý.';
GO

-- =========================================================================================
-- 6. TẠO CÁC STORED PROCEDURES NGHIỆP VỤ (STORED PROCEDURES)
-- =========================================================================================

-- THỦ TỤC 1: TIẾP NHẬN BÁO CÁO SỰ CỐ MỚI (Tự sinh mã sự cố SC-YYYYMMDD-XXXX)
CREATE PROCEDURE dbo.sp_BaoCaoSuCoMoi
    @MaPhongHoc INT,
    @MaLoaiSuCo INT,
    @TieuDe NVARCHAR(300),
    @MoTaHuHong NVARCHAR(MAX),
    @ViTriTrongPhong NVARCHAR(250),
    @MucDoUuTien NVARCHAR(50),
    @NguoiBaoCaoId INT,
    @NewIncidentId INT OUTPUT,
    @NewIncidentCode NVARCHAR(100) OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;
    BEGIN TRY
        DECLARE @DateStr NVARCHAR(8) = FORMAT(GETDATE(), 'yyyyMMdd');
        DECLARE @CountToday INT;
        SELECT @CountToday = COUNT(*) + 1 
        FROM dbo.SU_CO 
        WHERE ma_phieu_su_co LIKE N'SC-' + @DateStr + N'-%';

        SET @NewIncidentCode = N'SC-' + @DateStr + N'-' + RIGHT(N'0000' + CAST(@CountToday AS NVARCHAR(10)), 4);

        INSERT INTO dbo.SU_CO (ma_phieu_su_co, tieu_de, mo_ta_hu_hong, ma_phong_hoc, ma_loai_su_co, vi_tri_trong_phong, muc_do_uu_tien, trang_thai, nguoi_bao_cao_id, ngay_gui_bao_cao)
        VALUES (@NewIncidentCode, @TieuDe, @MoTaHuHong, @MaPhongHoc, @MaLoaiSuCo, @ViTriTrongPhong, @MucDoUuTien, N'Pending', @NguoiBaoCaoId, SYSUTCDATETIME());

        SET @NewIncidentId = SCOPE_IDENTITY();

        INSERT INTO dbo.LICH_SU_XU_LY (ma_su_co_id, nguoi_thuc_hien_id, trang_thai_cu, trang_thai_moi, noi_dung_ghi_chu, thoi_gian_cap_nhat)
        VALUES (@NewIncidentId, @NguoiBaoCaoId, NULL, N'Pending', N'Người dùng gửi báo cáo sự cố mới qua ứng dụng di động', SYSUTCDATETIME());

        INSERT INTO dbo.THONG_BAO (nguoi_nhan_id, tieu_de, noi_dung_thong_bao, ma_su_co_id, da_doc, ngay_gui)
        SELECT u.ma_nguoi_dung, N'Có sự cố mới cần duyệt', N'Sự cố [' + @NewIncidentCode + N'] vừa được gửi tại phòng học', @NewIncidentId, 0, SYSUTCDATETIME()
        FROM dbo.NGUOI_DUNG u WHERE u.vai_tro = N'Admin';

        COMMIT TRANSACTION;
        PRINT N'-> Đã tạo mới sự cố thành công: ' + @NewIncidentCode;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

-- THỦ TỤC 2: PHÂN CÔNG KỸ THUẬT VIÊN & THÔNG BÁO
CREATE PROCEDURE dbo.sp_PhanCongKyThuatVien
    @MaSuCoId INT,
    @AdminUserId INT,
    @KyThuatVienId INT,
    @MucDoUuTien NVARCHAR(50) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;
    BEGIN TRY
        DECLARE @IncCode NVARCHAR(100);
        SELECT @IncCode = ma_phieu_su_co FROM dbo.SU_CO WHERE ma_su_co_id = @MaSuCoId;

        UPDATE dbo.SU_CO
        SET ky_thuat_vien_id = @KyThuatVienId,
            trang_thai = N'Assigned',
            ngay_phan_cong = SYSUTCDATETIME(),
            muc_do_uu_tien = ISNULL(@MucDoUuTien, muc_do_uu_tien)
        WHERE ma_su_co_id = @MaSuCoId;

        INSERT INTO dbo.LICH_SU_XU_LY (ma_su_co_id, nguoi_thuc_hien_id, trang_thai_cu, trang_thai_moi, noi_dung_ghi_chu, thoi_gian_cap_nhat)
        VALUES (@MaSuCoId, @AdminUserId, N'Pending', N'Assigned', N'Ban Quản lý CSVC đã duyệt và phân công kỹ thuật viên phụ trách', SYSUTCDATETIME());

        INSERT INTO dbo.THONG_BAO (nguoi_nhan_id, tieu_de, noi_dung_thong_bao, ma_su_co_id, da_doc, ngay_gui)
        VALUES (@KyThuatVienId, N'Bạn vừa được giao nhiệm vụ mới', N'Vui lòng tiếp nhận sự cố [' + @IncCode + N']', @MaSuCoId, 0, SYSUTCDATETIME());

        COMMIT TRANSACTION;
        PRINT N'-> Đã phân công thành công cho Kỹ thuật viên!';
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

-- THỦ TỤC 3: CẬP NHẬT TIẾN ĐỘ XỬ LÝ
CREATE PROCEDURE dbo.sp_CapNhatTienDoSuCo
    @MaSuCoId INT,
    @TechnicianUserId INT,
    @TrangThaiMoi NVARCHAR(50), -- InProgress, Resolved
    @NoiDungGhiChu NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRANSACTION;
    BEGIN TRY
        DECLARE @OldStatus NVARCHAR(50);
        DECLARE @RepUserId INT;
        DECLARE @IncCode NVARCHAR(100);

        SELECT @OldStatus = trang_thai, @RepUserId = nguoi_bao_cao_id, @IncCode = ma_phieu_su_co
        FROM dbo.SU_CO WHERE ma_su_co_id = @MaSuCoId;

        IF @TrangThaiMoi = N'Resolved'
        BEGIN
            UPDATE dbo.SU_CO
            SET trang_thai = @TrangThaiMoi, ngay_hoan_thanh = SYSUTCDATETIME()
            WHERE ma_su_co_id = @MaSuCoId;
        END
        ELSE
        BEGIN
            UPDATE dbo.SU_CO
            SET trang_thai = @TrangThaiMoi
            WHERE ma_su_co_id = @MaSuCoId;
        END

        INSERT INTO dbo.LICH_SU_XU_LY (ma_su_co_id, nguoi_thuc_hien_id, trang_thai_cu, trang_thai_moi, noi_dung_ghi_chu, thoi_gian_cap_nhat)
        VALUES (@MaSuCoId, @TechnicianUserId, @OldStatus, @TrangThaiMoi, @NoiDungGhiChu, SYSUTCDATETIME());

        DECLARE @NotifMsg NVARCHAR(MAX) = CASE 
            WHEN @TrangThaiMoi = N'InProgress' THEN N'Kỹ thuật viên đã bắt đầu xử lý sự cố [' + @IncCode + N']'
            WHEN @TrangThaiMoi = N'Resolved' THEN N'Sự cố [' + @IncCode + N'] đã được khắc phục xong. Vui lòng đánh giá nghiệm thu!'
            ELSE N'Tiến độ sự cố [' + @IncCode + N'] vừa được cập nhật'
        END;

        INSERT INTO dbo.THONG_BAO (nguoi_nhan_id, tieu_de, noi_dung_thong_bao, ma_su_co_id, da_doc, ngay_gui)
        VALUES (@RepUserId, N'Cập nhật tiến độ sự cố', @NotifMsg, @MaSuCoId, 0, SYSUTCDATETIME());

        COMMIT TRANSACTION;
        PRINT N'-> Đã cập nhật trạng thái sự cố sang: ' + @TrangThaiMoi;
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        THROW;
    END CATCH
END;
GO

PRINT N'-> Đã tạo thành công 3 Stored Procedures nghiệp vụ.';
GO

-- =========================================================================================
-- 7. CÁC TRUY VẤN KIỂM TRA & BÁO CÁO TỔNG HỢP (TEST QUERIES)
-- =========================================================================================
PRINT N'';
PRINT N'=========================================================================================';
PRINT N'                        KẾT QUẢ KIỂM TRA DỮ LIỆU & BÁO CÁO TỔNG HỢP                      ';
PRINT N'=========================================================================================';

-- TRUY VẤN 1: BẢNG TỔNG HỢP HIỆN TRẠNG CƠ SỞ VẬT CHẤT CÁC PHÒNG KHU A VÀ KHU B
PRINT N'--- BÁO CÁO 1: BẢNG TỔNG HỢP HIỆN TRẠNG TRANG THIẾT BỊ PHÒNG HỌC KHU A VÀ B ---';
SELECT 
    [Mã Dãy], 
    [Mã Phòng], 
    [Mã QR Định Danh], 
    [Loại Phòng], 
    [Số Bàn Sinh Viên (14-18)], 
    [Số Bàn Giáo Viên (1)], 
    [Số Máy Lạnh (2)], 
    [Hệ Thống Quạt (2 Trần / 4 Điện)], 
    [Số Tivi (1)], 
    [Cổng HDMI (1)], 
    [Số Bảng Viết (1)]
FROM dbo.v_BangTongHopCoSoVatChat_KhuA_B
ORDER BY [Mã Dãy], [Mã Phòng];

-- TRUY VẤN 2: THỐNG KÊ TỔNG THỂ TÀI SẢN TRANG THIẾT BỊ THEO TỪNG DÃY NHÀ
PRINT N'--- BÁO CÁO 2: TỔNG HỢP SỐ LƯỢNG THIẾT BỊ THEO DÃY NHÀ ---';
SELECT 
    d.ten_day_nha AS [Tên Dãy Nhà],
    COUNT(p.ma_phong_hoc) AS [Tổng Số Phòng],
    SUM(p.so_ban_sinh_vien) AS [Tổng Số Bàn Sinh Viên],
    SUM(p.so_ban_giao_vien) AS [Tổng Số Bàn Giáo Viên],
    SUM(p.so_may_lanh) AS [Tổng Số Máy Lạnh],
    SUM(p.so_tivi) AS [Tổng Số Tivi Trình Chiếu],
    SUM(p.so_cong_hdmi) AS [Tổng Số Cổng HDMI],
    SUM(p.so_bang_viet) AS [Tổng Số Bảng Viết]
FROM dbo.DAY_NHA d
INNER JOIN dbo.PHONG_HOC p ON d.ma_day_nha = p.ma_day_nha
WHERE d.ma_toa IN (N'B3', N'A4')
GROUP BY d.ten_day_nha;

-- TRUY VẤN 3: DANH SÁCH CHI TIẾT CÁC SỰ CỐ ĐANG THEO DÕI
PRINT N'--- BÁO CÁO 3: DANH SÁCH SỰ CỐ & TIẾN ĐỘ XỬ LÝ HIỆN TẠI ---';
SELECT 
    [Mã Sự Cố], 
    [Tiêu Đề], 
    [Danh Mục], 
    [Phòng], 
    [Vị Trí Cụ Thể], 
    [Mức Ưu Tiên], 
    [Trạng Thái], 
    [Người Báo Cáo], 
    [Kỹ Thuật Viên Phụ Trách], 
    [Thời Gian Gửi]
FROM dbo.v_DanhSachSuCoChiTiet;

PRINT N'';
PRINT N'>>> HOÀN THÀNH TẠO VÀ NẠP CƠ SỞ DỮ LIỆU [TVU_Facility_DB] TIẾNG VIỆT THÀNH CÔNG RỰC RỠ! <<<';
GO
