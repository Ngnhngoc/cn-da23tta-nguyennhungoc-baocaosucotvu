/* =========================================================================================
   HỆ THỐNG BÁO CÁO & THEO DÕI SỰ CỐ CƠ SỞ VẬT CHẤT - ĐẠI HỌC TRÀ VINH (TVU)
   TẬP TIN SQL DDL TIẾNG VIỆT DÀNH RIÊNG CHO POWERDESIGNER
   
   Toàn bộ tên bảng, tên thuộc tính và tên mối quan hệ đều dùng TIẾNG VIỆT rõ ràng,
   chuẩn hóa theo đúng hiện trạng cơ sở vật chất Đại học Trà Vinh (Khu A & B).
   ========================================================================================= */

-- 1. BẢNG KHUÔN VIÊN TRƯỜNG
CREATE TABLE KHUON_VIEN (
    ma_khuon_vien INT NOT NULL,
    ten_khuon_vien NVARCHAR(250) NOT NULL,
    ma_viet_tat NVARCHAR(50) NOT NULL,
    dia_chi NVARCHAR(500) NULL,
    mo_ta NVARCHAR(1000) NULL,
    CONSTRAINT PK_KHUON_VIEN PRIMARY KEY (ma_khuon_vien)
);

-- 2. BẢNG DÃY NHÀ / TÒA NHÀ
CREATE TABLE DAY_NHA (
    ma_day_nha INT NOT NULL,
    ma_khuon_vien INT NOT NULL,
    ten_day_nha NVARCHAR(250) NOT NULL,
    ma_toa NVARCHAR(50) NOT NULL,
    tong_so_tang INT NOT NULL,
    CONSTRAINT PK_DAY_NHA PRIMARY KEY (ma_day_nha)
);

-- 3. BẢNG PHÒNG HỌC & TRANG THIẾT BỊ HIỆN TRẠNG (KHU A & KHU B)
-- Chuẩn trang bị: 2 máy lạnh, 2 quạt trần (hoặc 4 quạt điện), 1 Tivi, 1 HDMI, 1 bảng, 14-18 bàn SV, 1 bàn GV
CREATE TABLE PHONG_HOC (
    ma_phong_hoc INT NOT NULL,
    ma_day_nha INT NOT NULL,
    so_phong NVARCHAR(50) NOT NULL,
    loai_phong NVARCHAR(50) NOT NULL,
    tang_so INT NOT NULL,
    ma_qr_dinh_danh NVARCHAR(100) NOT NULL,
    so_may_lanh INT NOT NULL,
    so_quat INT NOT NULL,
    loai_quat NVARCHAR(50) NOT NULL,
    so_tivi INT NOT NULL,
    so_cong_hdmi INT NOT NULL,
    so_bang_viet INT NOT NULL,
    so_ban_sinh_vien INT NOT NULL,
    so_ban_giao_vien INT NOT NULL,
    mo_ta_hien_trang NVARCHAR(1000) NULL,
    dang_su_dung BIT NOT NULL,
    CONSTRAINT PK_PHONG_HOC PRIMARY KEY (ma_phong_hoc)
);

-- 4. BẢNG DANH MỤC LOẠI SỰ CỐ
CREATE TABLE LOAI_SU_CO (
    ma_loai_su_co INT NOT NULL,
    ten_loai_su_co NVARCHAR(200) NOT NULL,
    bieu_tuong NVARCHAR(100) NOT NULL,
    mo_ta_chi_tiet NVARCHAR(1000) NULL,
    CONSTRAINT PK_LOAI_SU_CO PRIMARY KEY (ma_loai_su_co)
);

-- 5. BẢNG NGƯỜI DÙNG HỆ THỐNG
-- Tác nhân: Sinh viên, Giảng viên, Kỹ thuật viên, Quản lý CSVC
CREATE TABLE NGUOI_DUNG (
    ma_nguoi_dung INT NOT NULL,
    ten_dang_nhap NVARCHAR(100) NOT NULL,
    ho_va_ten NVARCHAR(200) NOT NULL,
    email_tvu NVARCHAR(200) NOT NULL,
    so_dien_thoai NVARCHAR(50) NULL,
    mat_khau_ma_hoa NVARCHAR(500) NOT NULL,
    vai_tro NVARCHAR(50) NOT NULL,
    lop_hoac_don_vi NVARCHAR(200) NULL,
    ngay_tao DATETIME NOT NULL,
    dang_hoat_dong BIT NOT NULL,
    CONSTRAINT PK_NGUOI_DUNG PRIMARY KEY (ma_nguoi_dung)
);

-- 6. BẢNG BÁO CÁO SỰ CỐ
CREATE TABLE SU_CO (
    ma_su_co_id INT NOT NULL,
    ma_phieu_su_co NVARCHAR(100) NOT NULL,
    tieu_de NVARCHAR(300) NOT NULL,
    mo_ta_hu_hong NVARCHAR(2000) NOT NULL,
    ma_phong_hoc INT NOT NULL,
    ma_loai_su_co INT NOT NULL,
    vi_tri_trong_phong NVARCHAR(250) NULL,
    muc_do_uu_tien NVARCHAR(50) NOT NULL,
    trang_thai NVARCHAR(50) NOT NULL,
    nguoi_bao_cao_id INT NOT NULL,
    ky_thuat_vien_id INT NULL,
    ngay_gui_bao_cao DATETIME NOT NULL,
    ngay_phan_cong DATETIME NULL,
    ngay_hoan_thanh DATETIME NULL,
    ngay_dong_phieu DATETIME NULL,
    CONSTRAINT PK_SU_CO PRIMARY KEY (ma_su_co_id)
);

-- 7. BẢNG HÌNH ẢNH SỰ CỐ
CREATE TABLE HINH_ANH_SU_CO (
    ma_hinh_anh INT NOT NULL,
    ma_su_co_id INT NOT NULL,
    duong_dan_anh NVARCHAR(500) NOT NULL,
    loai_hinh_anh NVARCHAR(50) NOT NULL,
    ngay_chup_anh DATETIME NOT NULL,
    nguoi_chup_id INT NOT NULL,
    CONSTRAINT PK_HINH_ANH_SU_CO PRIMARY KEY (ma_hinh_anh)
);

-- 8. BẢNG LỊCH SỬ TIẾN TRÌNH XỬ LÝ (TIMELINE)
CREATE TABLE LICH_SU_XU_LY (
    ma_lich_su INT NOT NULL,
    ma_su_co_id INT NOT NULL,
    nguoi_thuc_hien_id INT NOT NULL,
    trang_thai_cu NVARCHAR(50) NULL,
    trang_thai_moi NVARCHAR(50) NOT NULL,
    noi_dung_ghi_chu NVARCHAR(2000) NOT NULL,
    thoi_gian_cap_nhat DATETIME NOT NULL,
    CONSTRAINT PK_LICH_SU_XU_LY PRIMARY KEY (ma_lich_su)
);

-- 9. BẢNG ĐÁNH GIÁ NGHIỆM THU
CREATE TABLE DANH_GIA_NGHIEM_THU (
    ma_danh_gia INT NOT NULL,
    ma_su_co_id INT NOT NULL,
    nguoi_danh_gia_id INT NOT NULL,
    so_sao_hai_long INT NOT NULL,
    y_kien_phan_hoi NVARCHAR(2000) NULL,
    ngay_danh_gia DATETIME NOT NULL,
    CONSTRAINT PK_DANH_GIA_NGHIEM_THU PRIMARY KEY (ma_danh_gia)
);

-- 10. BẢNG THÔNG BÁO HỆ THỐNG
CREATE TABLE THONG_BAO (
    ma_thong_bao INT NOT NULL,
    nguoi_nhan_id INT NOT NULL,
    tieu_de NVARCHAR(250) NOT NULL,
    noi_dung_thong_bao NVARCHAR(2000) NOT NULL,
    ma_su_co_id INT NULL,
    da_doc BIT NOT NULL,
    ngay_gui DATETIME NOT NULL,
    CONSTRAINT PK_THONG_BAO PRIMARY KEY (ma_thong_bao)
);

/* =========================================================================================
   CÁC MỐI QUAN HỆ (RELATIONSHIPS) ĐƯỢC ĐẶT TÊN BẰNG TIẾNG VIỆT
   Để PowerDesigner tự động sinh tên viên thuốc hình elip bằng Tiếng Việt
   ========================================================================================= */

-- 1. Dãy nhà [thuoc_ve] Khuôn viên (1 - N)
ALTER TABLE DAY_NHA ADD CONSTRAINT thuoc_ve
    FOREIGN KEY (ma_khuon_vien) REFERENCES KHUON_VIEN (ma_khuon_vien);

-- 2. Dãy nhà [chua_phong] Phòng học (1 - N)
ALTER TABLE PHONG_HOC ADD CONSTRAINT chua_phong
    FOREIGN KEY (ma_day_nha) REFERENCES DAY_NHA (ma_day_nha);

-- 3. Sự cố [xay_ra_tai] Phòng học (1 - N)
ALTER TABLE SU_CO ADD CONSTRAINT xay_ra_tai
    FOREIGN KEY (ma_phong_hoc) REFERENCES PHONG_HOC (ma_phong_hoc);

-- 4. Sự cố [thuoc_loai] Danh mục sự cố (1 - N)
ALTER TABLE SU_CO ADD CONSTRAINT thuoc_loai
    FOREIGN KEY (ma_loai_su_co) REFERENCES LOAI_SU_CO (ma_loai_su_co);

-- 5. Người dùng [bao_cao] Sự cố (1 - N)
ALTER TABLE SU_CO ADD CONSTRAINT bao_cao
    FOREIGN KEY (nguoi_bao_cao_id) REFERENCES NGUOI_DUNG (ma_nguoi_dung);

-- 6. Quản lý [phan_cong_cho] Kỹ thuật viên (0..1 - N)
ALTER TABLE SU_CO ADD CONSTRAINT phan_cong_cho
    FOREIGN KEY (ky_thuat_vien_id) REFERENCES NGUOI_DUNG (ma_nguoi_dung);

-- 7. Sự cố [co_hinh_anh] Hình ảnh minh chứng (1 - N)
ALTER TABLE HINH_ANH_SU_CO ADD CONSTRAINT co_hinh_anh
    FOREIGN KEY (ma_su_co_id) REFERENCES SU_CO (ma_su_co_id);

-- 8. Người dùng [chup_anh] Minh chứng (1 - N)
ALTER TABLE HINH_ANH_SU_CO ADD CONSTRAINT chup_anh
    FOREIGN KEY (nguoi_chup_id) REFERENCES NGUOI_DUNG (ma_nguoi_dung);

-- 9. Sự cố [co_lich_su] Tiến trình xử lý (1 - N)
ALTER TABLE LICH_SU_XU_LY ADD CONSTRAINT co_lich_su
    FOREIGN KEY (ma_su_co_id) REFERENCES SU_CO (ma_su_co_id);

-- 10. Người dùng [cap_nhat] Lịch sử xử lý (1 - N)
ALTER TABLE LICH_SU_XU_LY ADD CONSTRAINT cap_nhat
    FOREIGN KEY (nguoi_thuc_hien_id) REFERENCES NGUOI_DUNG (ma_nguoi_dung);

-- 11. Sự cố [duoc_nghiem_thu] Đánh giá chất lượng (1 - 0..1)
ALTER TABLE DANH_GIA_NGHIEM_THU ADD CONSTRAINT duoc_nghiem_thu
    FOREIGN KEY (ma_su_co_id) REFERENCES SU_CO (ma_su_co_id);

-- 12. Người dùng [danh_gia] Nghiệm thu (1 - N)
ALTER TABLE DANH_GIA_NGHIEM_THU ADD CONSTRAINT danh_gia
    FOREIGN KEY (nguoi_danh_gia_id) REFERENCES NGUOI_DUNG (ma_nguoi_dung);

-- 13. Người dùng [nhan_thong_bao] Tin nhắn hệ thống (1 - N)
ALTER TABLE THONG_BAO ADD CONSTRAINT nhan_thong_bao
    FOREIGN KEY (nguoi_nhan_id) REFERENCES NGUOI_DUNG (ma_nguoi_dung);

-- 14. Sự cố [kich_hoat] Thông báo (0..1 - N)
ALTER TABLE THONG_BAO ADD CONSTRAINT lien_quan_su_co
    FOREIGN KEY (ma_su_co_id) REFERENCES SU_CO (ma_su_co_id);
