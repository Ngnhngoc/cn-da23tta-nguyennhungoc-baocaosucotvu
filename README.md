# cn-da23tta-nguyennhungoc-baocaosucotvu
# Đồ Án Chuyên Ngành: Hệ Thống Báo Cáo Sự Cố Cơ Sở Vật Chất TVU

## 1. Thông Tin Sinh Viên Thực Hiện
* **Họ và tên:** Nguyễn Như Ngọc
* **Lớp:** DA23TTA
* **Trường:** Đại học Trà Vinh (TVU)
* **Khoa:** Kỹ thuật và Công nghệ

---

## 2. Cấu Trúc Dự Án
```text
cn-da23tta-nguyennhungoc-baocaosucotvu/
├── tvu_backend/          # Máy chủ API Laravel 10 (PHP 8.x, Sanctum, Eloquent ORM)
├── tvu_mobile/           # Ứng dụng di động & Web Flutter (Dart, Material 3, QR Scanner)
├── database_backup/      # Bản sao lưu Cơ sở dữ liệu MySQL (tvu_suco_latest.sql)
├── run_system.bat        # File tự động kích hoạt toàn bộ hệ thống (1 Click)
├── stop_system.bat       # File tắt sạch toàn bộ hệ thống & giải phóng cổng (1 Click)
└── README.md             # Tài liệu hướng dẫn sử dụng và vận hành
```

---

## 3. HƯỚNG DẪN KHỞI ĐỘNG HỆ THỐNG

### 🔹 CÁCH 1: Chạy Siêu Tốc 1-Click bằng Terminal trong VS Code (Khuyên dùng)

1. **Khởi động Database:**
   * Mở phần mềm **Laragon** trên máy tính -> Bấm nút **Start All** (để bật MySQL port 3306).
2. **Mở Terminal trong VS Code:**
   * Nhấn tổ hợp phím: **`Ctrl + ~`** (hoặc vào menu: **Terminal** -> **New Terminal**).
3. **Chạy file tự động:**
   * Gõ lệnh sau và nhấn `Enter`:
     ```powershell
     .\run_system.bat
     ```
   * Hệ thống sẽ tự động bật 2 cửa sổ chạy song song:
     * Cửa sổ 1: **Backend Laravel** trên cổng `8000` (API & Web Admin).
     * Cửa sổ 2: **Frontend Flutter** trên cổng `8088` (chế độ Release siêu nhẹ cho cả điện thoại).

---

### 🔹 CÁCH 2: Chạy trực tiếp từ Thư mục Windows (Không cần mở VS Code)

1. Nhấn phím **`Windows + E`** mở File Explorer.
2. Truy cập vào thư mục: `C:\laragon\www\cn-da23tta-nguyennhungoc-baocaosucotvu`.
3. Nhấp đúp chuột (Double-click) vào file:  
   👉 **`run_system.bat`**
4. Giữ nguyên 2 cửa sổ màu đen chạy ngầm trên thanh Taskbar (không bấm nút X tắt đi).

---

### 🔹 CÁCH 3: Chạy thủ công từng Terminal (Dành cho Lập trình viên)

* **Terminal 1 (Backend Laravel):**
  ```bash
  cd tvu_backend
  php artisan serve --host=0.0.0.0 --port=8000
  ```
* **Terminal 2 (Frontend Flutter):**
  ```bash
  cd tvu_mobile
  flutter run -d web-server --web-hostname=0.0.0.0 --web-port=8088 --release
  ```

---

## 4. HƯỚNG DẪN TRUY CẬP VÀ TRẢI NGHIỆM

### 💻 4.1. Truy cập trên MÁY TÍNH
* **Giao diện Ứng Dụng (Sinh viên / Giảng viên / KTV):**  
  👉 [http://localhost:8088](http://localhost:8088)
* **Trang Web Quản Trị Nhanh (Admin Dashboard):**  
  👉 [http://localhost:8000/admin](http://localhost:8000/admin)

### 📱 4.2. Truy cập trên ĐIỆN THOẠI (iPhone / Android)
1. **Kết nối cùng mạng:**  
   * Kết nối điện thoại và máy tính vào **cùng một mạng Wi-Fi** (hoặc điện thoại bật **Điểm truy cập cá nhân 5G Hotspot** cho máy tính kết nối).
2. **Lấy địa chỉ IP máy tính:**  
   * Khi chạy `run_system.bat`, màn hình sẽ tự động hiển thị địa chỉ IP của máy tính (ví dụ: `172.20.10.2` hoặc `192.168.x.x`).
3. **Mở trình duyệt điện thoại (Safari / Chrome):**  
   * Truy cập ứng dụng: `http://<IP-MÁY-TÍNH>:8088`  
     *(Ví dụ: `http://172.20.10.2:8088` hoặc `http://192.168.1.52:8088`)*
   * Truy cập trang Admin: `http://<IP-MÁY-TÍNH>:8000/admin`

---

## 5. TÀI KHOẢN MẪU ĐỂ KIỂM THỬ HỆ THỐNG

| Vai Trò | Tên Đăng Nhập / Mã Số | Mật Khẩu | Họ và Tên | Chức Năng Chính |
| :--- | :--- | :--- | :--- | :--- |
| **Quản trị viên** | `admin` | `123456` | Ban Quản Lý CSVC TVU | Thống kê, duyệt & phân công KTV, quản lý phòng & tạo QR |
| **Kỹ thuật viên** | `ktv001` | `123456` | KTV. Lê Hoàng Nam | Nhận việc được giao, đổi trạng thái, chụp ảnh nghiệm thu |
| **Giảng viên** | `gv001` | `123456` | ThS. Trần Văn Hùng | Quét mã QR phòng, gửi sự cố kèm tối đa 5 ảnh, xem timeline |
| **Sinh viên** | `110123030` | `123456` | Nguyễn Như Ngọc | Báo cáo sự cố phòng học, theo dõi tiến độ xử lý |

---

## 6. HƯỚNG DẪN TẮT HỆ THỐNG AN TOÀN

Khi kết thúc phiên làm việc hoặc muốn giải phóng cổng mạng:
1. Double-click vào file:  
   👉 **`stop_system.bat`** (hoặc gõ `.\stop_system.bat` trong Terminal).
2. Hệ thống sẽ tự động dọn dẹp và giải phóng hoàn toàn cổng `8000` và `8088`.

---

## 7. CÁC LƯU Ý KỸ THUẬT QUAN TRỌNG

1. **Lỗi "Không thể kết nối đến máy chủ: connection timeout 10s":**  
   * Nguyên nhân: Do máy chủ Backend Laravel (`:8000`) hoặc CSDL MySQL (`:3306`) chưa được bật.
   * Khắc phục: Bật Laragon (Start All) và chạy lại file `run_system.bat`.
2. **Lỗi Safari trên iPhone bị quay vòng vô tận:**  
   * Đã được tối ưu bằng chế độ `--release` trong `run_system.bat`. Chế độ này loại bỏ kết nối debug WebSocket, giúp điện thoại nạp ứng dụng mượt mà trong 1-2 giây.
3. **Cơ chế tự nhận diện địa chỉ máy chủ (Auto Host Detection):**  
   * File `api_service.dart` đã được cấu hình tự động nhận diện địa chỉ máy chủ theo trình duyệt đang truy cập (`localhost`, IP Wi-Fi hay Hotspot), không cần phải chỉnh sửa IP thủ công trong code mỗi khi đổi mạng.
