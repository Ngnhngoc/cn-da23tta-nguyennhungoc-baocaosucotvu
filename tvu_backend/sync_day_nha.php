<?php
require __DIR__ . '/vendor/autoload.php';
$app = require_once __DIR__ . '/bootstrap/app.php';
$kernel = $app->make(Illuminate\Contracts\Console\Kernel::class);
$kernel->bootstrap();

use App\Models\KhuonVien;
use App\Models\DayNha;
use App\Models\PhongHoc;

// Đảm bảo có ít nhất 1 khuôn viên Khu I
$kv1 = KhuonVien::firstOrCreate(
    ['ma_viet_tat' => 'Khu I'],
    [
        'ten_khuon_vien' => 'Khu I - Trường Đại học Trà Vinh',
        'dia_chi'        => '126 Nguyễn Thiện Thành, Phường 5, TP. Trà Vinh',
        'mo_ta'          => 'Khuôn viên chính ĐH Trà Vinh'
    ]
);

// Tạo các tòa mẫu chuẩn TVU
$b21 = DayNha::firstOrCreate(['ma_toa' => 'B21'], ['ma_khuon_vien' => $kv1->ma_khuon_vien, 'ten_day_nha' => 'Tòa nhà B21', 'tong_so_tang' => 4]);
$b31 = DayNha::firstOrCreate(['ma_toa' => 'B31'], ['ma_khuon_vien' => $kv1->ma_khuon_vien, 'ten_day_nha' => 'Tòa nhà B31', 'tong_so_tang' => 4]);
$d71 = DayNha::firstOrCreate(['ma_toa' => 'D71'], ['ma_khuon_vien' => $kv1->ma_khuon_vien, 'ten_day_nha' => 'Tòa nhà D71', 'tong_so_tang' => 5]);
$a11 = DayNha::firstOrCreate(['ma_toa' => 'A11'], ['ma_khuon_vien' => $kv1->ma_khuon_vien, 'ten_day_nha' => 'Tòa nhà A11', 'tong_so_tang' => 3]);
$c31 = DayNha::firstOrCreate(['ma_toa' => 'C31'], ['ma_khuon_vien' => $kv1->ma_khuon_vien, 'ten_day_nha' => 'Tòa nhà C31', 'tong_so_tang' => 4]);

// Gán chính xác phòng vào từng tòa dựa trên mã QR
PhongHoc::where('ma_qr_dinh_danh', 'like', '%B21%')->update(['ma_day_nha' => $b21->ma_day_nha]);
PhongHoc::where('ma_qr_dinh_danh', 'like', '%B31%')->update(['ma_day_nha' => $b31->ma_day_nha]);
PhongHoc::where('ma_qr_dinh_danh', 'like', '%D71%')->update(['ma_day_nha' => $d71->ma_day_nha]);
PhongHoc::where('ma_qr_dinh_danh', 'like', '%A11%')->update(['ma_day_nha' => $a11->ma_day_nha]);
PhongHoc::where('ma_qr_dinh_danh', 'like', '%C31%')->update(['ma_day_nha' => $c31->ma_day_nha]);

echo "SYNCED_BUILDINGS_SUCCESSFULLY\n";
