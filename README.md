# Đồ Án Chuyên Ngành: Hệ Thống Báo Cáo Sự Cố Cơ Sở Vật Chất TVU

* **Họ và tên sinh viên:** Nguyễn Như Ngọc
* **Mã số sinh viên / Lớp:** DA23TTA
* **Trường:** Đại học Trà Vinh (TVU)
* **Khoa:** Kỹ thuật và Công nghệ

---

## 1. Cấu Trúc Dự Án Thống Nhất

```text
cn-da23tta-nguyennhungoc-baocaosucotvu/
├── 1_start_backend.bat      # Bước 1: Khởi động MySQL & Backend Laravel (:8000)
├── 2_build_apk.bat          # Bước 2: Tự động biên dịch & xuất file TVU_Facility.apk
├── 3_stop_system.bat        # Bước 3: Tắt toàn bộ máy chủ & giải phóng cổng 8000, 8088
├── apk_output/              # Thư mục chứa file APK thành phẩm
│   └── TVU_Facility.apk     # Bản phát hành (Release) đã tối ưu hóa
├── tvu_backend/             # Máy chủ RESTful API (Laravel 10, MySQL, Sanctum) & Web Admin
├── tvu_mobile/              # Mã nguồn ứng dụng Flutter (Hỗ trợ Android APK & Flutter Web)
├── database_backup/         # Bản sao lưu Cơ sở dữ liệu (tvu_suco_latest.sql)
└── scripts/                 # Các công cụ hỗ trợ
    ├── backup_database.bat  # Sao lưu dữ liệu MySQL
    ├── restore_database.bat # Khôi phục dữ liệu MySQL
    └── run_web_frontend.bat # Khởi động giao diện Web Frontend (:8088)
```

---

## 2. LUỒNG HOẠT ĐỘNG TOÀN HỆ THỐNG (WORKFLOW)

Hệ thống hoạt động theo mô hình Client - Server kết nối đồng bộ qua **RESTful API** và lưu trữ dữ liệu tập trung tại **CSDL MySQL (`tvu_suco`)**.

### 🔹 2.1. Vòng Đời Trạng Thái Sự Cố (Incident State Machine)
```text
[Báo Cáo Mới] ──► [Chờ Tiếp Nhận] ──(Admin phân công / KTV tiếp nhận)──► [Đang Xử Lý] ──(Nghiệm thu)──► [Hoàn Thành]
```
> **Ràng buộc nghiệp vụ chặt chẽ:** Chỉ những sự cố đã được phân công hoặc được chính Kỹ thuật viên tiếp nhận (ở trạng thái `Đang xử lý`) mới được phép bấm **"Hoàn Tất & Nghiệm Thu"** và tải ảnh minh chứng xử lý.

### 🔹 2.2. Luồng Nghiệp Vụ Giữa Các Vai Trò
1. **Giảng viên / Sinh viên (Người báo cáo):**
   * Quét mã QR phòng học (hoặc chọn nhanh phòng mẫu). Hệ thống tự động truy vấn API lấy danh mục thiết bị của phòng học đó.
   * Chọn loại sự cố, nhập vị trí & mô tả hư hỏng, đính kèm 1–5 ảnh hiện trường rồi bấm **Gửi báo cáo**.
   * Hệ thống tự động sinh mã phiếu duy nhất dạng `SC-YYYYMMDD-XXX` ở trạng thái `Chờ tiếp nhận`.
   * Theo dõi tiến độ xử lý và xem chi tiết KTV phụ trách.
2. **Quản trị viên (Admin - Ban Quản lý CSVC):**
   * Xem dashboard thống kê, lọc sự cố đa chiều theo ngày/tháng, Khuôn viên, Tòa nhà, Số phòng và Trạng thái.
   * Phân công Kỹ thuật viên phụ trách phiếu sự cố.
   * Quản lý phòng học, ẩn/hiện phòng ngưng hoạt động, in mã QR Code phòng học.
   * **Quản lý Khu & Tòa nhà:** Thêm mới, chỉnh sửa thông tin, ẩn/hiện hoặc xóa các khu và tòa nhà.
   * **Vòng đời & Bảo trì thiết bị:** Theo dõi tuổi thọ thiết bị, chu kỳ bảo trì định kỳ, ghi nhận lịch sử bảo dưỡng và sửa chữa.
   * **Quản lý tài khoản:** Thêm mới, sửa thông tin, đổi/cấp lại mật khẩu, xóa tài khoản có lọc theo vai trò.
   * **Xuất báo cáo PDF:** In báo cáo tổng hợp thiết bị theo từng tòa và khu.
3. **Kỹ thuật viên (KTV - Đội ngũ sửa chữa):**
   * Xem sự cố được giao cho mình hoặc danh sách tất cả sự cố chưa phân công.
   * Bấm **Tiếp Nhận** để chuyển sang trạng thái `Đang xử lý`.
   * Sau khi sửa chữa tại hiện trường, bấm **Hoàn Tất & Nghiệm Thu**, tải lên 1–5 ảnh nghiệm thu để hoàn tất phiếu.
   * Mọi lịch sử thao tác được ghi vết tự động (Audit Trail).

---

## 3. CƠ CHẾ KẾT NỐI ĐỒNG BỘ ĐA NỀN TẢNG (WEB & ANDROID APK)

* **Dùng chung Cơ sở dữ liệu:** Cả ứng dụng Web trên trình duyệt máy tính và ứng dụng APK trên máy ảo LDPlayer / điện thoại Android đều kết nối trực tiếp vào Backend Laravel port `8000` và chung Database MySQL `tvu_suco`.
* **Đồng bộ thời gian thực:** Phiếu sự cố vừa gửi từ điện thoại/LDPlayer sẽ ngay lập tức hiển thị trên giao diện Web khi làm mới trang.

---

## 4. HƯỚNG DẪN KHỞI ĐỘNG VÀ VẬN HÀNH HỆ THỐNG

Bạn có thể chạy và trải nghiệm hệ thống theo **2 cách** dưới đây:

### 🌟 CÁCH 1: Chạy Trực Tiếp Trên Trình Duyệt Web (Nhanh nhất & Đầy đủ tính năng nhất - KHUYẾN NGHỊ)

#### 🔹 Bước 1: Khởi động Backend Laravel & MySQL
1. Mở phần mềm **Laragon** -> Nhấn nút **Start All** (đảm bảo dịch vụ MySQL và Apache/Nginx hoạt động, cổng 3306 mở).
2. Nhấp đúp chuột (Double-click) vào file:  
   👉 **`1_start_backend.bat`**  
   *(Cửa sổ dòng lệnh Backend sẽ mở ra và thông báo máy chủ đang chạy tại `http://0.0.0.0:8000`).*
3. Giữ nguyên cửa sổ đen này thu nhỏ trên thanh Taskbar (không tắt đi).

#### 🔹 Bước 2: Khởi động Giao diện Web Frontend
1. Vào thư mục `scripts`, nhấp đúp chuột vào file:  
   👉 **`scripts\run_web_frontend.bat`**  
   *(Hệ thống sẽ tự động khởi chạy Web Server siêu tốc tại cổng `8088`).*
2. Mở trình duyệt Web (Google Chrome, Microsoft Edge, Cốc Cốc) và truy cập:  
   👉 **[http://localhost:8088](http://localhost:8088)**
3. Đăng nhập bằng các tài khoản mẫu ở mục 5 để kiểm thử đầy đủ các chức năng.

---

### 📱 CÁCH 2: Chạy Ứng Dụng Android APK (Trên Giả Lập LDPlayer Hoặc Điện Thoại Thật)

#### 🔹 Bước 1: Khởi động Backend Laravel & MySQL
1. Chạy file **`1_start_backend.bat`** như ở Cách 1.

#### 🔹 Bước 2: Xuất file APK (Build APK)
1. Trong thư mục gốc đồ án, nhấp đúp chuột vào file:  
   👉 **`2_build_apk.bat`**
2. Script sẽ tự động nạp dependencies, biên dịch và lưu file thành phẩm tại:  
   👉 **`apk_output\TVU_Facility.apk`**
3. Cửa sổ thư mục `apk_output` sẽ tự động mở lên màn hình.

#### 🔹 Bước 3: Cài đặt và Sử dụng trên LDPlayer
1. Mở phần mềm giả lập **LDPlayer** trên máy tính.
2. Kéo và thả file **`TVU_Facility.apk`** vào cửa sổ LDPlayer để tự động cài đặt.
3. Mở ứng dụng **TVU Facility** lên để đăng nhập và kiểm thử.
   * *Lưu ý cấu hình IP:* Ứng dụng mặc định kết nối qua IP mạng máy tính. Nếu đổi mạng WiFi, bấm vào biểu tượng `<->` ở góc trên màn hình Đăng nhập để chọn lại IP máy tính của bạn.

---

### 🛑 HƯỚNG DẪN TẮT HỆ THỐNG AN TOÀN
Khi kết thúc phiên làm việc:
* Nhấp đúp chuột vào file: 👉 **`3_stop_system.bat`**  
* Toàn bộ các tiến trình đang chiếm dụng cổng `8000` (Backend) và `8088` (Frontend) sẽ được giải phóng hoàn toàn và an toàn.

---

## 5. TÀI KHOẢN MẪU KIỂM THỬ HỆ THỐNG

Tất cả tài khoản đều có mật khẩu mặc định là: **`123456`**

| Vai Trò | Tên Đăng Nhập | Mật Khẩu | Chức Năng Nổi Bật |
| :--- | :--- | :--- | :--- |
| **Quản trị viên (Admin)** | `admin` | `123456` | Xem thống kê, phân công KTV, quản lý người dùng, đổi mật khẩu, quản lý khu/tòa, theo dõi vòng đời thiết bị, xuất PDF báo cáo |
| **Kỹ thuật viên 1** | `ktv001` | `123456` | Xem phiếu được giao, bấm Tiếp nhận, Nghiệm thu sửa chữa kèm ảnh bằng chứng |
| **Kỹ thuật viên 2** | `ktv002` | `123456` | Nhận xử lý các sự cố khác, đối chiếu quyền hạn nghiệm thu |
| **Giảng viên** | `gv001` | `123456` | Quét QR chọn phòng, gửi báo cáo sự cố kèm 1-5 ảnh, theo dõi trạng thái xử lý |
| **Sinh viên** | `110123030` | `123456` | Gửi báo cáo hư hỏng CSVC, xem lịch sử các phiếu cá nhân |

---

## 6. HƯỚNG DẪN SỬ DỤNG CÁC TÍNH NĂNG NÂNG CAO

### 🔹 6.1. Thay Ảnh Đại Diện (Avatar) & Đổi Mật Khẩu Cá Nhân
- Ở góc trên cùng bên phải thanh tiêu đề của **tất cả các màn hình** (Admin, KTV, GV/SV) có biểu tượng **Avatar tròn**.
- Bấm vào Avatar để mở cửa sổ **"Hồ Sơ & Bảo Mật Tài Khoản"**:
  - Bấm vào nút Camera hoặc *"Thay ảnh đại diện"* để tải ảnh mới từ máy tính/điện thoại lên.
  - Form *"Đổi mật khẩu cá nhân"*: Nhập mật khẩu cũ, mật khẩu mới (tối thiểu 6 ký tự) và xác nhận để đổi mật khẩu.

### 🔹 6.2. Theo Dõi Vòng Đời & Bảo Trì Định Kỳ Thiết Bị
- Vào tab **Phòng & Thiết Bị** trên giao diện Admin, mỗi thẻ phòng đều có nút **"Vòng Đời & Bảo Trì"** (màu xanh ngọc).
- Bấm vào để:
  - Xem tuổi thọ thiết bị (tháng), hạn bảo hành, chu kỳ bảo dưỡng định kỳ.
  - Cảnh báo tình trạng bảo trì: *Hoạt động tốt*, *Sắp đến hạn*, *Quá hạn*.
  - Xem timeline toàn bộ các lần bảo trì, sửa chữa, thay thế linh kiện trước đó.
  - Bấm nút **"Ghi nhận Bảo trì / Sửa chữa"** để cập nhật lịch sử bảo dưỡng mới.

### 🔹 6.3. Quản Lý Khuôn Viên & Tòa Nhà (Thêm / Sửa / Xóa / Ẩn & Hiện)
- Tại tab **Phòng & Thiết Bị**, bấm nút **"Quản lý Khu & Tòa"** trên banner đầu trang.
- Hỗ trợ:
  - **Ẩn / Hiện:** Bấm biểu tượng con mắt để ẩn các khu hoặc tòa nhà tạm ngưng sử dụng (quét QR hoặc lọc sẽ tự động ẩn các khu/tòa này).
  - **Sửa:** Chỉnh sửa tên khu, mã viết tắt, địa chỉ, mã tòa, số tầng.
  - **Xóa:** Xóa khu/tòa khi không còn phòng học liên kết.

### 🔹 6.4. Bộ Lọc Đa Tầng Thông Minh (Khu -> Tòa -> Phòng -> Ngày)
- Khi chọn **Khu II**, danh sách chip Tòa nhà bên dưới sẽ **tự động chỉ hiển thị các tòa thuộc Khu II**.
- Thanh tìm kiếm hỗ trợ gõ nhanh số phòng (VD: `102`, `B21.102`), mã phiếu sự cố hoặc tên người báo.

---

## 7. XỬ LÝ LỖI THƯỜNG GẶP (TROUBLESHOOTING)

1. **Lỗi "localhost refused to connect" (Không vào được `localhost:8088` hoặc `8000`):**
   * Nguyên nhân: Do máy chủ web chưa được bật hoặc đã bị tắt.
   * Khắc phục: Chạy lại file `1_start_backend.bat` và `scripts\run_web_frontend.bat`.
2. **Trình duyệt hiển thị giao diện cũ:**
   * Khắc phục: Nhấn tổ hợp phím **`Ctrl + F5`** trên bàn phím (hoặc mở cửa sổ ẩn danh `Ctrl + Shift + N`) để xóa bộ nhớ đệm (cache) của trình duyệt.
3. **Cổng 8000 hoặc 8088 bị báo đang bị chiếm dụng:**
   * Khắc phục: Chạy file `3_stop_system.bat` để tự động giải phóng toàn bộ các cổng này.
4. **Lỗi "Waiting for another flutter command to release the startup lock":**
   * Khắc phục: Xóa tệp `C:\src\flutter\bin\cache\lockfile` và chạy lại.
