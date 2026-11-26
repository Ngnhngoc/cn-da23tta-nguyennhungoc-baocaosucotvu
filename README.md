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
├── apk_output/              # Thư mục chứa file APK thành phẩm để cài vào LDPlayer
│   └── TVU_Facility.apk     # Bản phát hành (Release) đã tối ưu hóa
├── tvu_backend/             # Máy chủ RESTful API (Laravel 10, MySQL, Sanctum) & Web Admin
├── tvu_mobile/              # Mã nguồn ứng dụng Flutter (Hỗ trợ Android APK & Web)
├── database_backup/         # Bản sao lưu Cơ sở dữ liệu (tvu_suco_latest.sql)
└── scripts/                 # Các công cụ hỗ trợ
    ├── backup_database.bat  # Sao lưu dữ liệu MySQL
    ├── restore_database.bat # Khôi phục dữ liệu MySQL
    └── run_web_frontend.bat # Chạy giao diện Web Frontend (:8088)
```

---

## 2. LUỒNG HOẠT ĐỘNG TOÀN HỆ THỐNG (WORKFLOW)

Hệ thống hoạt động theo mô hình Client - Server kết nối đồng bộ qua **RESTful API** và lưu trữ dữ liệu tập trung tại **CSDL MySQL (`tvu_suco`)**.

### 🔹 2.1. Vòng Đời Trạng Thái Sự Cố (Incident State Machine)
```text
[Báo Cáo Mới] ──► [Chờ Tiếp Nhận] ──(Admin phân công)──► [Đang Xử Lý] ──(KTV hoàn tất)──► [Hoàn Thành]
```

### 🔹 2.2. Luồng Nghiệp Vụ Giữa 3 Vai Trò
1. **Giảng viên / Sinh viên (Người báo cáo):**
   * Quét mã QR phòng học (hoặc chọn nhanh phòng mẫu). Hệ thống tự động truy vấn API lấy danh mục thiết bị (máy lạnh, quạt, TV...) của phòng đó.
   * Chọn loại sự cố (Điện, Máy chiếu, Bàn ghế...), nhập mô tả chi tiết, đính kèm 1–5 ảnh hiện trường rồi bấm **Gửi báo cáo**.
   * Hệ thống tự động sinh mã phiếu duy nhất dạng `SC-YYYYMMDD-XXX` và lưu vào hệ thống ở trạng thái `Chờ tiếp nhận`.
2. **Quản trị viên (Admin - Ban Quản lý CSVC):**
   * Mở Web Admin (`http://localhost:8000/admin`) hoặc App Mobile Admin.
   * Xem thống kê tổng quan (Tổng số phiếu, Chờ duyệt, Đang sửa, Hoàn tất).
   * Kiểm tra thông tin hiện trường và chọn Kỹ thuật viên phụ trách $\rightarrow$ Phiếu tự động đổi sang `Đang xử lý`.
3. **Kỹ thuật viên (KTV - Đội ngũ sửa chữa):**
   * Đăng nhập ứng dụng, xem danh sách phiếu sự cố được Admin phân công cho riêng mình.
   * Đến trực tiếp phòng học xử lý sự cố.
   * Sau khi sửa chữa xong, chụp ảnh bằng chứng nghiệm thu (1–5 ảnh) và cập nhật trạng thái phiếu thành `Hoàn thành`.
   * Lịch sử thao tác (Audit Trail) được tự động ghi lại từng phút trong bảng `lich_su_xu_ly`.

---

## 3. CƠ CHẾ KẾT NỐI ĐỒNG BỘ GIỮA MÁY ẢO LDPLAYER VÀ WEB ADMIN

* **Cùng chung một Cơ sở dữ liệu:** Cả ứng dụng APK trên máy ảo LDPlayer và trang Web Admin trên trình duyệt máy tính đều kết nối chung vào Backend Laravel port `8000` và chung Database MySQL `tvu_suco`.
* **Kịch bản Demo trực quan:**
  1. Mở song song màn hình **LDPlayer** (chạy App) và màn hình **Chrome** (chạy Web Admin `http://localhost:8000/admin`).
  2. Trên LDPlayer, gửi một phiếu báo cáo sự cố mới.
  3. Ngay lập tức quay sang Web Admin bấm F5 tải lại $\rightarrow$ Phiếu sự cố vừa gửi từ máy ảo sẽ **lập tức xuất hiện trên đầu danh sách của Web Admin**.
  4. Admin trên Web phân công KTV $\rightarrow$ Trên LDPlayer đăng nhập tài khoản KTV sẽ thấy công việc vừa được giao ngay lập tức.

---

## 4. HƯỚNG DẪN KHỞI ĐỘNG VÀ VẬN HÀNH HỆ THỐNG

### 🔹 Bước 1: Khởi động Backend Laravel & MySQL
1. Mở phần mềm **Laragon** -> Nhấn nút **Start All** (đảm bảo MySQL port 3306 hoạt động).
2. Nhấp đúp chuột (Double-click) vào file:  
   👉 **`1_start_backend.bat`**  
   *(Cửa sổ dòng lệnh Backend sẽ mở ra và thông báo máy chủ đang chạy tại `http://0.0.0.0:8000`).*
3. Giữ nguyên cửa sổ đen này thu nhỏ trên thanh Taskbar (không tắt đi).
   * *Trang Web Quản trị Admin trên máy tính:* 👉 [http://localhost:8000/admin](http://localhost:8000/admin)

---

### 🔹 Bước 2: Xuất file APK (Build APK)
1. Trong thư mục gốc đồ án, nhấp đúp chuột vào file:  
   👉 **`2_build_apk.bat`**
2. File script sẽ tự động:
   * Kiểm tra và nạp các thư viện Flutter (`flutter pub get`).
   * Biên dịch mã nguồn sang file APK bản phát hành tối ưu (`flutter build apk --release`).
   * Tự động sao chép file thành phẩm ra thư mục: **`apk_output\TVU_Facility.apk`**.
   * Tự động mở cửa sổ thư mục `apk_output` lên màn hình máy tính.

---

### 🔹 Bước 3: Cài đặt và Kiểm thử trên Giả lập LDPlayer
1. Mở phần mềm giả lập **LDPlayer** trên máy tính.
2. Từ cửa sổ thư mục `apk_output`, **kéo và thả file `TVU_Facility.apk` vào màn hình LDPlayer**.
3. LDPlayer sẽ tự động cài đặt ứng dụng **TVU Facility** trong vài giây.
4. Mở app **TVU Facility** trên LDPlayer lên để sử dụng:
   * **Cấu hình máy chủ (nếu cần):** Mặc định app tự động kết nối qua IP máy tính của bạn. Nếu cần đổi địa chỉ, bấm biểu tượng **`<->`** (góc trên bên phải màn hình Đăng nhập) và chọn địa chỉ IP máy tính (Ví dụ: `192.168.2.29:8000`) rồi bấm **Lưu**.

---

### 🔹 Bước 4: Tắt hệ thống an toàn
Khi kết thúc phiên làm việc:
* Nhấp đúp chuột vào file: 👉 **`3_stop_system.bat`**  
* Toàn bộ các tiến trình đang chiếm dụng cổng `8000` (và `8088` nếu có) sẽ được giải phóng hoàn toàn.

---

## 5. TÀI KHOẢN MẪU KIỂM THỬ HỆ THỐNG

| Vai Trò | Tên Đăng Nhập | Mật Khẩu | Chức Năng Chính |
| :--- | :--- | :--- | :--- |
| **Quản trị viên (Admin)** | `admin` | `123456` | Xem thống kê, phân công kỹ thuật viên, quản lý phòng & in mã QR |
| **Kỹ thuật viên (KTV)** | `ktv001` | `123456` | Nhận phiếu sự cố được giao, cập nhật tiến độ, tải ảnh nghiệm thu |
| **Giảng viên** | `gv001` | `123456` | Quét QR chọn phòng, gửi báo cáo kèm 1-5 ảnh, theo dõi tiến độ |
| **Sinh viên** | `110123030` | `123456` | Gửi báo cáo sự cố CSVC, xem lịch sử xử lý |

---

## 6. LƯU Ý KỸ THUẬT VỀ TÍNH NĂNG QUÉT CAMERA & CHỤP ẢNH

1. **Quét mã QR trên máy ảo LDPlayer:**  
   * Máy ảo LDPlayer trên Windows không hỗ trợ kết nối trực tiếp với phần cứng Webcam laptop.
   * Vì vậy, hệ thống đã trang bị sẵn **Cơ chế chọn nhanh phòng học (QR Fallback)** ngay dưới khung quét (nút `B21.102`, `D71.102`...). Bấm nút này sẽ kích hoạt cùng luồng API bóc tách dữ liệu giống hệt như camera vừa quét trúng mã QR thật.
2. **Quét mã QR bằng Webcam thật trên Laptop (Bản Web):**  
   * Mở trình duyệt Chrome trên máy tính vào [http://localhost:8088](http://localhost:8088) (chạy qua file `scripts\run_web_frontend.bat`).
   * Bấm **Quét QR** $\rightarrow$ Trình duyệt hỏi quyền Camera $\rightarrow$ Bấm **Cho phép (Allow)**. Đèn Webcam laptop sẽ bật sáng và quét mã QR giơ trước màn hình.
3. **Quét mã QR trên Điện thoại thật:**  
   * Chép file `apk_output\TVU_Facility.apk` sang điện thoại Android thật và cài đặt. Khi mở quét QR, camera sau của điện thoại sẽ bật sáng quét mã bình thường.
4. **Nút "Mở Camera Chụp Ảnh Hiện Trường":**  
   * Khi chạy trên điện thoại thật: Bật ứng dụng camera chụp ảnh trực tiếp.
   * Khi chạy trên trình duyệt máy tính: Chuẩn bảo mật web Windows sẽ tự động mở hộp thoại chọn tệp ảnh (`File Open`) để tải ảnh từ máy tính lên.
