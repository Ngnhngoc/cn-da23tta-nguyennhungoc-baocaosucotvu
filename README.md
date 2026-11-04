# cn-da23tta-nguyennhungoc-baocaosucotvu
# Đồ Án Chuyên Ngành: Hệ Thống Báo Cáo Sự Cố Cơ Sở Vật Chất TVU

## 1. Thông Tin Sinh Viên
* **Họ và tên:** Nguyễn Như Ngọc
* **Lớp:** DA23TTA
* **Trường:** Đại học Trà Vinh (TVU)

---

## 2. Cấu Trúc Dự Án
* `tvu_backend/`: Mã nguồn máy chủ Laravel API & Cơ sở dữ liệu MySQL.
* `tvu_mobile/`: Mã nguồn giao diện Flutter (Hỗ trợ Web, Android, iOS).
* `run_system.bat`: File chạy tự động toàn bộ hệ thống (1 click).
* `stop_system.bat`: File tắt toàn bộ hệ thống & giải phóng cổng 8000, 8088 (1 click).

---

## 3. HƯỚNG DẪN MỞ & CHẠY HỆ THỐNG TRONG VS CODE

### 🔹 Cách 1: Chạy bằng Terminal trong VS Code (Khuyên dùng khi lập trình)

1. **Khởi động Database:**
   - Mở **Laragon** -> Bấm **Start All** (để khởi động MySQL port 3306).

2. **Mở dự án trong VS Code:**
   - Mở VS Code -> Chọn **File** -> **Open Folder...** -> Chọn thư mục:
     `c:\laragon\www\cn-da23tta-nguyennhungoc-baocaosucotvu`

3. **Mở Terminal 1 (Chạy Backend Laravel):**
   - Vào menu: **Terminal** -> **New Terminal** (phím tắt `Ctrl + ~` hoặc `Ctrl + Shift + \``).
   - Chạy các lệnh sau:
     ```bash
     cd tvu_backend
     php artisan serve --host=0.0.0.0 --port=8000
     ```
   - *Backend sẽ hoạt động tại: `http://localhost:8000`*.

4. **Mở Terminal 2 (Chạy Frontend Flutter):**
   - Tại thanh công cụ Terminal của VS Code, bấm dấu **`+`** (Create New Terminal) để mở thêm 1 tab terminal thứ 2.
   - Chạy các lệnh sau:
     ```bash
     cd tvu_mobile
     flutter run -d chrome
     # Hoặc chạy web server cho cả điện thoại truy cập:
     flutter run -d web-server --web-hostname=0.0.0.0 --web-port=8088
     ```
   - *Frontend sẽ mở trên trình duyệt tại: `http://localhost:8088`*.

---

### 🔹 Cách 2: Chạy siêu nhanh bằng 1 Click (Không cần gõ lệnh)
- Trong thư mục gốc của đồ án, chỉ cần **Double-click vào file:**
  👉 **`run_system.bat`**
- File này sẽ tự động mở 2 cửa sổ chạy song song cả Backend (:8000) và Frontend (:8088).

---

## 4. HƯỚNG DẪN TẮT HỆ THỐNG

### 🔹 Cách 1: Tắt từ Terminal VS Code
- Chuyển vào từng tab Terminal (tab Backend và tab Frontend).
- Nhấn tổ hợp phím **`Ctrl + C`**, sau đó gõ chữ **`y`** rồi nhấn **`Enter`**.

### 🔹 Cách 2: Tắt sạch hoàn toàn bằng 1 Click
- Nếu lỡ đóng VS Code hoặc cổng 8000 / 8088 vẫn đang bị chiếm dụng ngầm:
- Double-click vào file:
  👉 **`stop_system.bat`**
- Toàn bộ tiến trình Backend và Frontend sẽ được tắt sạch và giải phóng cổng ngay lập tức.

---

## 5. LƯU Ý QUAN TRỌNG KHI MANG SANG MÁY TÍNH KHÁC

1. **Cấu hình địa chỉ IP khi đổi mạng Wi-Fi:**
   - Nếu đổi mạng Wi-Fi, kiểm tra IP mới bằng lệnh: `ipconfig` (xem dòng IPv4 Address Wi-Fi, ví dụ `192.168.1.50`).
   - Mở file `tvu_mobile/lib/services/api_service.dart`:
     Cập nhật dòng:
     ```dart
     static const String baseUrl = 'http://<IP-MỚI>:8000/api';
     ```
   - Nếu chỉ dùng trên máy tính cá nhân, có thể dùng:
     ```dart
     static const String baseUrl = 'http://localhost:8000/api';
     ```

2. **Cài đặt thư viện (nếu qua máy mới tinh):**
   - Tại `tvu_backend`: chạy `composer install`
   - Tại `tvu_mobile`: chạy `flutter pub get`
