<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\SuCo;
use App\Models\PhongHoc;
use App\Models\User;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;

class AdminController extends Controller
{
    public function index()
    {
        $totalIncidents = SuCo::count();
        $pendingIncidents = SuCo::where('trang_thai', 'Chờ tiếp nhận')->count();
        $processingIncidents = SuCo::where('trang_thai', 'Đang xử lý')->count();
        $resolvedIncidents = SuCo::where('trang_thai', 'Hoàn thành')->count();

        $incidents = SuCo::with(['phongHoc', 'nguoiBaoCao', 'kyThuatVien'])
            ->orderBy('ngay_gui_bao_cao', 'desc')
            ->get();

        $rooms = PhongHoc::all();
        $users = User::all();
        $incidentTypes = DB::table('loai_su_co')->get();
        $dayNhaList = DB::table('day_nha')->get();

        return view('admin.dashboard', compact(
            'totalIncidents',
            'pendingIncidents',
            'processingIncidents',
            'resolvedIncidents',
            'incidents',
            'rooms',
            'users',
            'incidentTypes',
            'dayNhaList'
        ));
    }

    public function updateStatus(Request $request, $id)
    {
        $suCo = SuCo::findOrFail($id);
        $oldStatus = $suCo->trang_thai;
        $newStatus = $request->input('trang_thai');

        $suCo->trang_thai = $newStatus;
        if ($newStatus == 'Hoàn thành') {
            $suCo->ngay_hoan_thanh = now();
        }
        $suCo->save();

        DB::table('lich_su_xu_ly')->insert([
            'ma_su_co_id'        => $suCo->ma_su_co_id,
            'nguoi_thuc_hien_id' => 1,
            'trang_thai_cu'      => $oldStatus,
            'trang_thai_moi'     => $newStatus,
            'noi_dung_ghi_chu'   => 'Ban quản lý cập nhật trạng thái phiếu.',
            'thoi_gian_cap_nhat' => now(),
        ]);

        if ($request->wantsJson() || $request->is('api/*')) {
            return response()->json(['status' => 'success', 'message' => 'Cập nhật thành công!']);
        }
        return redirect()->back()->with('success', 'Đã cập nhật trạng thái phiếu sự cố thành công!');
    }

    // 0. Quản lý Khu (Khuôn viên)
    public function getCampuses()
    {
        $campuses = \App\Models\KhuonVien::with('dayNhas')->get();
        return response()->json(['status' => 'success', 'data' => $campuses]);
    }

    public function addCampus(Request $request)
    {
        $request->validate([
            'ten_khuon_vien' => 'required|string',
            'ma_viet_tat'    => 'required|string',
        ]);

        $campus = \App\Models\KhuonVien::create([
            'ten_khuon_vien' => $request->input('ten_khuon_vien'),
            'ma_viet_tat'    => $request->input('ma_viet_tat'),
            'dia_chi'        => $request->input('dia_chi', 'Đại học Trà Vinh'),
            'mo_ta'          => $request->input('mo_ta'),
        ]);

        return response()->json([
            'status'  => 'success',
            'message' => "Đã thêm khu: {$campus->ten_khuon_vien} ({$campus->ma_viet_tat}) thành công!",
            'data'    => $campus
        ], 201);
    }

    // 0.1 Quản lý Tòa (Dãy nhà)
    public function getBuildings()
    {
        $buildings = \App\Models\DayNha::with('khuonVien')->get();
        return response()->json(['status' => 'success', 'data' => $buildings]);
    }

    public function addBuilding(Request $request)
    {
        $request->validate([
            'ma_toa'        => 'required|string',
            'ma_khuon_vien' => 'required',
        ]);

        $maToa = strtoupper(trim($request->input('ma_toa')));
        $tenDayNha = $request->input('ten_day_nha');
        if (empty($tenDayNha)) {
            $tenDayNha = "Tòa nhà {$maToa}";
        }

        // Kiểm tra xem đã có tòa với mã này chưa
        $existing = \App\Models\DayNha::where('ma_toa', $maToa)->first();
        if ($existing) {
            $existing->ma_khuon_vien = (int)$request->input('ma_khuon_vien');
            $existing->ten_day_nha = $tenDayNha;
            $existing->tong_so_tang = (int)$request->input('tong_so_tang', 4);
            $existing->save();
            $existing->load('khuonVien');
            return response()->json([
                'status'  => 'success',
                'message' => "Đã cập nhật Tòa: {$existing->ten_day_nha} ({$existing->ma_toa})!",
                'data'    => $existing
            ], 200);
        }

        $building = \App\Models\DayNha::create([
            'ma_khuon_vien' => (int)$request->input('ma_khuon_vien'),
            'ten_day_nha'   => $tenDayNha,
            'ma_toa'        => $maToa,
            'tong_so_tang'  => (int)$request->input('tong_so_tang', 4),
        ]);

        $building->load('khuonVien');

        return response()->json([
            'status'  => 'success',
            'message' => "Đã thêm tòa: {$building->ten_day_nha} ({$building->ma_toa}) thành công!",
            'data'    => $building
        ], 201);
    }

    // 1. Thêm phòng học mới & Tự động tạo mã QR kèm thiết bị
    public function addRoom(Request $request)
    {
        $rawRoom = trim($request->input('so_phong'));
        $maDayNha = $request->input('ma_day_nha');
        $maToa = 'B21';
        $soPhongOnly = $rawRoom;

        // Nếu đã chọn dãy nhà cụ thể
        if ($maDayNha) {
            $dayNha = \App\Models\DayNha::find($maDayNha);
            if ($dayNha) {
                $maToa = $dayNha->ma_toa;
            }
        }

        // Tách số phòng nếu nhập kèm tiền tố (VD: B21.101 -> B21 và 101)
        $cleanInput = str_replace('TVU-', '', $rawRoom);
        if (str_contains($cleanInput, '.')) {
            $parts = explode('.', $cleanInput);
            if (!$maDayNha) {
                $maToa = strtoupper(trim($parts[0]));
            }
            $soPhongOnly = trim($parts[1]);
        } elseif (str_contains($cleanInput, '-')) {
            $parts = explode('-', $cleanInput);
            if (!$maDayNha) {
                $maToa = strtoupper(trim($parts[0]));
            }
            $soPhongOnly = trim($parts[1]);
        }

        // Nếu chưa có dãy nhà, tìm hoặc tạo tự động
        if (!$maDayNha) {
            $dayNha = \App\Models\DayNha::firstOrCreate(
                ['ma_toa' => $maToa],
                [
                    'ma_khuon_vien' => (int)$request->input('ma_khuon_vien', 1),
                    'ten_day_nha'   => "Tòa nhà {$maToa}",
                    'tong_so_tang'  => 4
                ]
            );
            $maDayNha = $dayNha->ma_day_nha;
        }

        // Tự động suy ra tầng số từ ký tự đầu tiên của số phòng (VD: 101 -> tầng 1, 201 -> tầng 2)
        $tangSo = $request->input('tang_so');
        if (!$tangSo && strlen($soPhongOnly) >= 3) {
            $tangSo = (int) substr($soPhongOnly, 0, 1);
        }
        $tangSo = $tangSo ?: 1;

        // Tạo mã QR chuẩn: TVU-{maToa}-{soPhong} (VD: TVU-B21-101, TVU-D71-102)
        $qrCode = "TVU-{$maToa}-{$soPhongOnly}";

        // Tên phòng hiển thị
        $soPhongFull = "{$maToa}.{$soPhongOnly}";

        // Kiểm tra xem phòng đã tồn tại chưa
        $existingRoom = PhongHoc::where('ma_day_nha', $maDayNha)
            ->where('so_phong', $soPhongOnly)
            ->first();

        if ($existingRoom) {
            $existingRoom->update([
                'loai_phong'      => $request->input('loai_phong', $existingRoom->loai_phong),
                'tang_so'         => $tangSo,
                'ma_qr_dinh_danh' => $qrCode,
                'so_may_lanh'     => (int) $request->input('so_may_lanh', $existingRoom->so_may_lanh),
                'so_quat'         => (int) $request->input('so_quat', $existingRoom->so_quat),
                'loai_quat'       => $request->input('loai_quat', $existingRoom->loai_quat),
                'so_tivi'         => (int) $request->input('so_tivi', $existingRoom->so_tivi),
                'so_cong_hdmi'    => (int) $request->input('so_cong_hdmi', $existingRoom->so_cong_hdmi),
                'so_bang_viet'    => (int) $request->input('so_bang_viet', $existingRoom->so_bang_viet),
                'so_ban_sinh_vien'=> (int) $request->input('so_ban_sinh_vien', $existingRoom->so_ban_sinh_vien),
                'so_ban_giao_vien'=> (int) $request->input('so_ban_giao_vien', $existingRoom->so_ban_giao_vien),
                'dang_su_dung'    => 1,
            ]);
            $existingRoom->load('dayNha.khuonVien');

            return response()->json([
                'status'       => 'success',
                'message'      => "Đã cập nhật Phòng $soPhongFull với Mã QR: $qrCode",
                'data'         => $existingRoom,
                'qr_code'      => $qrCode,
                'qr_image_url' => "https://api.qrserver.com/v1/create-qr-code/?size=300x300&data={$qrCode}",
                'so_phong_full'=> $soPhongFull
            ], 200);
        }

        $room = PhongHoc::create([
            'ma_day_nha'      => $maDayNha,
            'so_phong'        => $soPhongOnly,
            'loai_phong'      => $request->input('loai_phong', 'Lý thuyết'),
            'tang_so'         => $tangSo,
            'ma_qr_dinh_danh' => $qrCode,
            'so_may_lanh'     => (int) $request->input('so_may_lanh', 2),
            'so_quat'         => (int) $request->input('so_quat', 2),
            'loai_quat'       => $request->input('loai_quat', 'Quạt trần'),
            'so_tivi'         => (int) $request->input('so_tivi', 1),
            'so_cong_hdmi'    => (int) $request->input('so_cong_hdmi', 1),
            'so_bang_viet'    => (int) $request->input('so_bang_viet', 1),
            'so_ban_sinh_vien'=> (int) $request->input('so_ban_sinh_vien', 20),
            'so_ban_giao_vien'=> (int) $request->input('so_ban_giao_vien', 1),
            'so_may_tinh'     => (int) $request->input('so_may_tinh', 0),
            'so_ban_phim'     => (int) $request->input('so_ban_phim', 0),
            'so_cpu'          => (int) $request->input('so_cpu', 0),
            'so_chuot'        => (int) $request->input('so_chuot', 0),
            'dang_su_dung'    => 1,
        ]);

        $room->load('dayNha.khuonVien');
        $qrUrl = "https://api.qrserver.com/v1/create-qr-code/?size=300x300&data={$qrCode}";

        if ($request->wantsJson() || $request->is('api/*')) {
            return response()->json([
                'status'       => 'success',
                'message'      => "Đã tạo thành công Phòng $soPhongFull với Mã QR: $qrCode",
                'data'         => $room,
                'qr_code'      => $qrCode,
                'qr_image_url' => $qrUrl,
                'so_phong_full'=> $soPhongFull
            ], 201);
        }

        return redirect()->back()->with('success', "Đã thêm phòng $soPhongFull và tạo mã QR: $qrCode thành công!");
    }

    // 1.1 Xóa phòng học
    public function deleteRoom($id)
    {
        $room = PhongHoc::findOrFail($id);
        $roomName = $room->so_phong_day_du;
        $room->delete();

        return response()->json([
            'status'  => 'success',
            'message' => "Đã xóa phòng $roomName thành công!"
        ]);
    }

    // 2. Cập nhật / Thêm trang thiết bị cho phòng học
    public function updateRoomEquipments(Request $request, $id)
    {
        $room = PhongHoc::findOrFail($id);

        $room->so_may_lanh      = $request->input('so_may_lanh', $room->so_may_lanh);
        $room->so_quat          = $request->input('so_quat', $room->so_quat);
        $room->so_tivi          = $request->input('so_tivi', $room->so_tivi);
        $room->so_cong_hdmi     = $request->input('so_cong_hdmi', $room->so_cong_hdmi);
        $room->so_bang_viet     = $request->input('so_bang_viet', $room->so_bang_viet);
        $room->so_ban_sinh_vien = $request->input('so_ban_sinh_vien', $room->so_ban_sinh_vien);
        $room->so_ban_giao_vien = $request->input('so_ban_giao_vien', $room->so_ban_giao_vien);
        $room->so_may_tinh      = $request->input('so_may_tinh', $room->so_may_tinh ?? 0);
        $room->so_ban_phim      = $request->input('so_ban_phim', $room->so_ban_phim ?? 0);
        $room->so_cpu           = $request->input('so_cpu', $room->so_cpu ?? 0);
        $room->so_chuot         = $request->input('so_chuot', $room->so_chuot ?? 0);
        $room->save();

        if ($request->wantsJson() || $request->is('api/*')) {
            return response()->json([
                'status'  => 'success',
                'message' => 'Cập nhật thiết bị phòng thành công!',
                'data'    => $room
            ]);
        }

        return redirect()->back()->with('success', "Đã cập nhật thiết bị phòng {$room->so_phong} thành công!");
    }

    // 3. Thêm tài khoản Giảng viên, Sinh viên, Kỹ thuật viên
    public function addUser(Request $request)
    {
        $request->validate([
            'ten_dang_nhap' => 'required|string|unique:nguoi_dung,ten_dang_nhap',
            'ho_va_ten'     => 'required|string',
            'vai_tro'       => 'required|string', // 'Giảng viên', 'Sinh viên', 'Kỹ thuật viên'
        ]);

        $vaiTro = $request->input('vai_tro');
        $username = $request->input('ten_dang_nhap');
        $password = $request->input('mat_khau', '123456');

        // Sinh email TVU mặc định nếu không nhập
        $defaultEmail = strtolower($username) . ($vaiTro == 'Sinh viên' ? '@st.tvu.edu.vn' : '@tvu.edu.vn');
        $email = $request->input('email_tvu', $defaultEmail);

        $user = User::create([
            'ten_dang_nhap'    => $username,
            'ho_va_ten'        => $request->input('ho_va_ten'),
            'email_tvu'        => $email,
            'so_dien_thoai'    => $request->input('so_dien_thoai', '0987654321'),
            'mat_khau_ma_hoa'  => Hash::make($password),
            'vai_tro'          => $vaiTro,
            'lop_hoac_don_vi'  => $request->input('lop_hoac_don_vi', 'Khoa CNTT - TVU'),
            'dang_hoat_dong'   => 1,
            'ngay_tao'         => now(),
        ]);

        if ($request->wantsJson() || $request->is('api/*')) {
            return response()->json([
                'status'  => 'success',
                'message' => "Đã tạo tài khoản $vaiTro: {$user->ho_va_ten} ($username) thành công!",
                'data'    => $user
            ], 201);
        }

        return redirect()->back()->with('success', "Đã thêm tài khoản $vaiTro: {$user->ho_va_ten} thành công!");
    }

    // 4. In bảng mã QR định danh phòng học chính thức
    public function printRoomQr($id)
    {
        $room = PhongHoc::where('ma_phong_hoc', $id)
            ->orWhere('ma_qr_dinh_danh', $id)
            ->firstOrFail();

        return view('admin.print_qr', compact('room'));
    }

    // 5. Bật / Tắt trạng thái hoạt động của phòng (Ẩn phòng không còn sử dụng)
    public function toggleRoomStatus(Request $request, $id)
    {
        $room = PhongHoc::where('ma_phong_hoc', $id)->first();
        if (!$room) {
            return response()->json(['status' => 'error', 'message' => 'Không tìm thấy phòng học!'], 404);
        }

        $newStatus = $request->has('dang_su_dung')
            ? (int)$request->input('dang_su_dung')
            : ($room->dang_su_dung == 1 ? 0 : 1);

        $room->dang_su_dung = $newStatus;
        $room->save();

        $statusText = $newStatus == 1 ? 'Đang sử dụng' : 'Tạm ngưng hoạt động (Đã ẩn)';

        if ($request->wantsJson() || $request->is('api/*')) {
            return response()->json([
                'status'       => 'success',
                'message'      => "Đã chuyển trạng thái phòng {$room->so_phong_day_du} sang: {$statusText}!",
                'dang_su_dung' => $newStatus,
                'data'         => $room,
            ]);
        }

        return redirect()->back()->with('success', "Đã chuyển trạng thái phòng sang: {$statusText}!");
    }
}
