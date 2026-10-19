# HỆ THỐNG BÁO CÁO & THEO DÕI SỰ CỐ CƠ SỞ VẬT CHẤT - ĐẠI HỌC TRÀ VINH (TVU)

Đề tài Chuyên ngành: **Xây dựng hệ thống quản lý, báo cáo và theo dõi sự cố cơ sở vật chất tích hợp mã QR Code tại Trường Đại học Trà Vinh**.

---

## 📌 1. TỔNG QUAN DỰ ÁN

Hệ thống cho phép Sinh viên, Giảng viên nhanh chóng quét mã QR dán tại cửa phòng học Khu A và Khu B để báo cáo sự cố (máy lạnh chảy nước, quạt trần kêu to, cổng HDMI hỏng, bàn ghế lung lay...). Ban Quản lý CSVC tiếp nhận, phân loại và phân công Kỹ thuật viên (Tổ Điện lạnh, Tổ CNTT) xử lý theo thời gian thực.

### Công nghệ sử dụng:
- **Backend API**: ASP.NET Core (.NET 9.0) - Kiến trúc RESTful API, Entity Framework Core ánh xạ 10 bảng Tiếng Việt, xác thực JWT Bearer, thư viện QRCoder, tài liệu tự động Swagger UI.
- **Cơ sở dữ liệu**: Hỗ trợ 2 hệ quản trị CSDL chuẩn hóa 100% Tiếng Việt:
  - **Microsoft SQL Server (SSMS)**: File `TVU_Facility_DB_SSMS.sql` (hỗ trợ Stored Procedures, Views, Ràng buộc kiểm tra, Unicode tiếng Việt `Vietnamese_CI_AS`).
  - **MySQL 8.0 / Laragon**: File `database/TVU_Facility_DB_MySQL.sql` (chuẩn UTF8MB4, khóa ngoại Cascade/Set Null).
  - **SAP/Sybase PowerDesigner**: File `TVU_Facility_DB_PowerDesigner_TiengViet.sql` xuất mô hình CDM Merise trực quan.
- **Mobile Client**: Flutter (Dart) - Quét mã QR (`mobile_scanner`), chụp ảnh hiện trường, theo dõi dòng thời gian (Timeline) và đánh giá nghiệm thu 1-5 sao.
- **Web Admin**: Bảng điều khiển quản lý phòng học, duyệt sự cố, xuất mã QR tem phòng.

---

## 🗄️ 2. MÔ HÌNH DỮ LIỆU CHUẨN HÓA 100% TIẾNG VIỆT (10 BẢNG)

Toàn bộ hệ thống được xây dựng và đồng bộ chặt chẽ dựa trên 10 bảng tiếng Việt:

1. **`KHUON_VIEN`**: Quản lý các cơ sở ĐH Trà Vinh (Khu 1 - 126 Nguyễn Thiện Thành, Khu 2 Hòa Thuận,...).
2. **`DAY_NHA`**: Dãy nhà / Giảng đường (Dãy B3 - Khoa KT&CN, Dãy A4 - Giảng đường lý thuyết, Tòa A1 Hiệu bộ,...).
3. **`PHONG_HOC`**: Phòng học & Hiện trạng trang thiết bị Khu A & Khu B:
   - **02 máy lạnh** treo tường.
   - **02 quạt trần** (hoặc **04 quạt điện** tùy phòng).
   - **01 Tivi trình chiếu** màn hình lớn.
   - **01 cổng & dây cáp HDMI** tại bục giảng.
   - **01 bảng mica trắng**.
   - **14 – 18 bàn học sinh viên** + **01 bàn giáo viên**.
   - Mã QR Code định danh duy nhất (`TVU-B31.101`, `TVU-A42.103`,...).
4. **`LOAI_SU_CO`**: Danh mục 6 nhóm sự cố (Điện & Chiếu sáng, Máy lạnh & Quạt, Tivi & HDMI & CNTT, Bàn ghế & Bảng giảng dạy, Cấp thoát nước, Vệ sinh môi trường).
5. **`NGUOI_DUNG`**: 4 nhóm tác nhân (Sinh viên, Giảng viên, Kỹ thuật viên, Quản lý CSVC).
6. **`SU_CO`**: Phiếu tiếp nhận sự cố trung tâm (Mã phiếu, Tiêu đề, Mô tả, Mức độ ưu tiên, Trạng thái).
7. **`HINH_ANH_SU_CO`**: Lưu ảnh chụp hiện trường lúc báo và ảnh đối chứng nghiệm thu sau sửa chữa.
8. **`LICH_SU_XU_LY`**: Dòng thời gian tiến trình (Ai đã chuyển trạng thái, lúc mấy giờ, ghi chú vật tư thay thế).
9. **`DANH_GIA_NGHIEM_THU`**: Khảo sát mức độ hài lòng (1 - 5 sao và nhận xét của người báo cáo).
10. **`THONG_BAO`**: Tin nhắn thông báo biến động tiến độ thời gian thực gửi đến người dùng.

---

## 👥 3. TÀI KHOẢN MẪU THỬ NGHIỆM HỆ THỐNG

| Vai Trò | Tên Đăng Nhập | Mật Khẩu | Họ và Tên | Đơn Vị / Lớp |
| :--- | :--- | :--- | :--- | :--- |
| **Quản lý CSVC** | `admin_csvc` | `Tvu@123456` | ThS. Nguyễn Văn Quản | Phòng Quản trị Thiết bị & CSVC TVU |
| **Kỹ thuật viên Điện lạnh** | `ktv_dienlanh` | `Tvu@123456` | Trần Kỹ Thuật | Tổ Điện - Điện Lạnh TVU |
| **Kỹ thuật viên CNTT** | `ktv_it` | `Tvu@123456` | Lê Tin Học | Tổ Hỗ trợ Thiết bị CNTT & Lab |
| **Sinh viên** | `110121001` | `Tvu@123456` | Nguyễn Minh Khang | Lớp DA21TT - Khoa KT&CN |
| **Giảng viên** | `gv_lamthanh` | `Tvu@123456` | TS. Lâm Thành | Giảng viên Bộ môn CNTT |

---

## 🚀 4. HƯỚNG DẪN KHỞI CHẠY HỆ THỐNG

### Cách 1: Chạy tự động bằng tệp Batch
Chỉ cần nhấp đúp vào tệp:
👉 `START_PROJECT.bat`

### Cách 2: Chạy Backend thủ công
1. Khởi động MySQL trong Laragon (Cổng mặc định `3306`).
2. Mở Terminal / PowerShell tại thư mục dự án:
   ```bash
   cd backend
   dotnet run
   ```
3. Truy cập Swagger UI kiểm thử API:
   👉 **http://localhost:5209** hoặc **http://localhost:5209/swagger**
4. Xem danh sách Tem in Mã QR các phòng học Khu A & Khu B:
   👉 **http://localhost:5209/qr_stickers.html**

---

## 📄 5. DANH SÁCH TÀI LIỆU & SCRIPT BÁO CÁO

- **Tài liệu Báo cáo đầy đủ**: [BAO_CAO_HIEN_TRANG_USECASE_SPECIFICATION.md](file:///d:/HKI%202627/CN/BCAO/soure/docs/BAO_CAO_HIEN_TRANG_USECASE_SPECIFICATION.md) (Khảo sát hiện trạng CSVC, 4 Tác nhân, Sơ đồ Use Case, Đặc tả FR/NFR, Từ điển dữ liệu 10 bảng).
- **Tài liệu Thiết kế ERD**: [DATABASE_ERD.md](file:///d:/HKI%202627/CN/BCAO/soure/docs/DATABASE_ERD.md) (Lược đồ quan hệ CDM Merise, Thực thể gốc & Thực thể kết hợp, Bản số Cardinality).
- **Trang xem & Tải ảnh Sơ đồ ERD 3000px**: [ERD_POWERDESIGNER_VIEW.html](file:///d:/HKI%202627/CN/BCAO/soure/docs/ERD_POWERDESIGNER_VIEW.html) (Có nút 1-click tải ảnh PNG nét cao để chèn Word).
- **Script SQL cho SQL Server SSMS**: [TVU_Facility_DB_SSMS.sql](file:///d:/HKI%202627/CN/BCAO/soure/TVU_Facility_DB_SSMS.sql).
- **Script SQL cho MySQL / Laragon**: [TVU_Facility_DB_MySQL.sql](file:///d:/HKI%202627/CN/BCAO/soure/database/TVU_Facility_DB_MySQL.sql).
- **Script SQL cho PowerDesigner**: [TVU_Facility_DB_PowerDesigner_TiengViet.sql](file:///d:/HKI%202627/CN/BCAO/soure/TVU_Facility_DB_PowerDesigner_TiengViet.sql).
