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

    public function updateCampus(Request $request, $id)
    {
        $campus = \App\Models\KhuonVien::find($id);
        if (!$campus) {
            return response()->json(['status' => 'error', 'message' => 'Không tìm thấy khu!'], 404);
        }
        $request->validate([
            'ten_khuon_vien' => 'required|string',
            'ma_viet_tat'    => 'required|string',
        ]);
        $campus->ten_khuon_vien = $request->input('ten_khuon_vien');
        $campus->ma_viet_tat    = $request->input('ma_viet_tat');
        if ($request->has('dia_chi')) $campus->dia_chi = $request->input('dia_chi');
        if ($request->has('mo_ta')) $campus->mo_ta = $request->input('mo_ta');
        $campus->save();

        return response()->json([
            'status'  => 'success',
            'message' => "Đã cập nhật khu: {$campus->ten_khuon_vien}!",
            'data'    => $campus
        ], 200);
    }

    public function toggleCampusStatus($id)
    {
        $campus = \App\Models\KhuonVien::find($id);
        if (!$campus) {
            return response()->json(['status' => 'error', 'message' => 'Không tìm thấy khu!'], 404);
        }
        $current = isset($campus->dang_su_dung) ? (bool)$campus->dang_su_dung : true;
        $campus->dang_su_dung = !$current;
        $campus->save();

        // Đồng bộ ẩn/hiện các phòng thuộc khu này nếu cần, hoặc giữ nguyên trạng thái khu
        $statusText = $campus->dang_su_dung ? 'Đang hoạt động' : 'Đã ẩn';
        return response()->json([
            'status'  => 'success',
            'message' => "Đã chuyển khu {$campus->ma_viet_tat} sang trạng thái: {$statusText}!",
            'data'    => $campus
        ], 200);
    }

    public function deleteCampus($id)
    {
        $campus = \App\Models\KhuonVien::find($id);
        if (!$campus) {
            return response()->json(['status' => 'error', 'message' => 'Không tìm thấy khu!'], 404);
        }
        $buildingCount = \App\Models\DayNha::where('ma_khuon_vien', $id)->count();
        if ($buildingCount > 0) {
            return response()->json([
                'status'  => 'error',
                'message' => "Không thể xóa khu này vì đang có {$buildingCount} tòa nhà thuộc khu. Vui lòng xóa hoặc chuyển các tòa nhà trước, hoặc dùng nút Ẩn!"
            ], 422);
        }
        $campus->delete();
        return response()->json([
            'status'  => 'success',
            'message' => "Đã xóa khu {$campus->ten_khuon_vien} thành công!"
        ], 200);
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

    public function updateBuilding(Request $request, $id)
    {
        $building = \App\Models\DayNha::find($id);
        if (!$building) {
            return response()->json(['status' => 'error', 'message' => 'Không tìm thấy tòa nhà!'], 404);
        }
        $request->validate([
            'ma_toa'        => 'required|string',
            'ma_khuon_vien' => 'required',
        ]);
        $maToa = strtoupper(trim($request->input('ma_toa')));
        $building->ma_khuon_vien = (int)$request->input('ma_khuon_vien');
        $building->ma_toa        = $maToa;
        $building->ten_day_nha   = $request->input('ten_day_nha') ?: "Tòa nhà {$maToa}";
        if ($request->has('tong_so_tang')) {
            $building->tong_so_tang = (int)$request->input('tong_so_tang');
        }
        $building->save();
        $building->load('khuonVien');

        return response()->json([
            'status'  => 'success',
            'message' => "Đã cập nhật tòa: {$building->ten_day_nha} ({$building->ma_toa})!",
            'data'    => $building
        ], 200);
    }

    public function toggleBuildingStatus($id)
    {
        $building = \App\Models\DayNha::find($id);
        if (!$building) {
            return response()->json(['status' => 'error', 'message' => 'Không tìm thấy tòa nhà!'], 404);
        }
        $current = isset($building->dang_su_dung) ? (bool)$building->dang_su_dung : true;
        $building->dang_su_dung = !$current;
        $building->save();

        $statusText = $building->dang_su_dung ? 'Đang hoạt động' : 'Đã ẩn';
        return response()->json([
            'status'  => 'success',
            'message' => "Đã chuyển {$building->ten_day_nha} sang trạng thái: {$statusText}!",
            'data'    => $building
        ], 200);
    }

    public function deleteBuilding($id)
    {
        $building = \App\Models\DayNha::find($id);
        if (!$building) {
            return response()->json(['status' => 'error', 'message' => 'Không tìm thấy tòa nhà!'], 404);
        }
        $roomCount = \App\Models\PhongHoc::where('ma_day_nha', $id)->count();
        if ($roomCount > 0) {
            return response()->json([
                'status'  => 'error',
                'message' => "Không thể xóa tòa nhà này vì đang có {$roomCount} phòng học bên trong. Vui lòng xóa các phòng trước hoặc dùng nút Ẩn!"
            ], 422);
        }
        $building->delete();
        return response()->json([
            'status'  => 'success',
            'message' => "Đã xóa tòa {$building->ten_day_nha} thành công!"
        ], 200);
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

    // 3.0 Lấy danh sách toàn bộ người dùng (hỗ trợ lọc vai trò, tìm kiếm)
    public function getUsers(Request $request)
    {
        $query = User::query();

        if ($request->filled('vai_tro') && $request->vai_tro != 'Tất cả') {
            $query->where('vai_tro', $request->vai_tro);
        }

        if ($request->filled('search')) {
            $s = trim($request->search);
            $query->where(function ($q) use ($s) {
                $q->where('ten_dang_nhap', 'like', "%{$s}%")
                  ->orWhere('ho_va_ten', 'like', "%{$s}%")
                  ->orWhere('email_tvu', 'like', "%{$s}%")
                  ->orWhere('so_dien_thoai', 'like', "%{$s}%")
                  ->orWhere('lop_hoac_don_vi', 'like', "%{$s}%");
            });
        }

        $users = $query->orderBy('ma_nguoi_dung', 'desc')->get();

        return response()->json([
            'status' => 'success',
            'data'   => $users
        ], 200);
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

    // 3.1 Cập nhật thông tin tài khoản người dùng
    public function updateUser(Request $request, $id)
    {
        $user = User::findOrFail($id);

        $request->validate([
            'ho_va_ten' => 'required|string',
            'vai_tro'   => 'required|string',
        ]);

        $user->ho_va_ten = $request->input('ho_va_ten');
        $user->vai_tro = $request->input('vai_tro');
        if ($request->has('email_tvu')) {
            $user->email_tvu = $request->input('email_tvu');
        }
        if ($request->has('so_dien_thoai')) {
            $user->so_dien_thoai = $request->input('so_dien_thoai');
        }
        if ($request->has('lop_hoac_don_vi')) {
            $user->lop_hoac_don_vi = $request->input('lop_hoac_don_vi');
        }
        if ($request->has('dang_hoat_dong')) {
            $user->dang_hoat_dong = (int)$request->input('dang_hoat_dong');
        }

        // Nếu admin muốn cập nhật mật khẩu luôn
        if ($request->filled('mat_khau_moi')) {
            $user->mat_khau_ma_hoa = Hash::make($request->input('mat_khau_moi'));
        }

        $user->save();

        return response()->json([
            'status'  => 'success',
            'message' => "Đã cập nhật thông tin tài khoản {$user->ten_dang_nhap} thành công!",
            'data'    => $user
        ], 200);
    }

    // 3.2 Đặt lại mật khẩu tài khoản
    public function resetPassword(Request $request, $id)
    {
        $user = User::findOrFail($id);
        $newPassword = $request->input('mat_khau_moi', '123456');

        $user->mat_khau_ma_hoa = Hash::make($newPassword);
        $user->save();

        return response()->json([
            'status'  => 'success',
            'message' => "Đã đặt lại mật khẩu cho tài khoản {$user->ten_dang_nhap} thành công (Mật khẩu mới: $newPassword)!",
        ], 200);
    }

    // 3.3 Xóa tài khoản người dùng
    public function deleteUser(Request $request, $id)
    {
        $user = User::findOrFail($id);

        // Không cho phép xóa chính mình (admin đang đăng nhập)
        if ($request->user() && $request->user()->ma_nguoi_dung == $user->ma_nguoi_dung) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Không thể xóa tài khoản Quản trị viên đang đăng nhập!'
            ], 400);
        }

        $username = $user->ten_dang_nhap;
        $name = $user->ho_va_ten;
        $user->delete();

        return response()->json([
            'status'  => 'success',
            'message' => "Đã xóa tài khoản $name ($username) khỏi hệ thống!",
        ], 200);
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

    // 6. Xuất bản in & File PDF Báo cáo thiết bị theo Tòa và Khu
    public function printEquipmentReport(Request $request)
    {
        $rooms = PhongHoc::with('dayNha.khuonVien')->get();

        $grouped = [];
        $totals = [
            'total_rooms' => 0,
            'total_pc'    => 0,
            'total_cpu'   => 0,
            'total_kb'    => 0,
            'total_mouse' => 0,
            'total_ac'    => 0,
            'total_fan'   => 0,
            'total_tv'    => 0,
            'total_hdmi'  => 0,
            'total_desk'  => 0,
        ];

        foreach ($rooms as $r) {
            $buildingName = $r->dayNha ? $r->dayNha->ten_day_nha : 'Tòa nhà ' . ($r->ma_toa ?? 'B21');
            $campusName = ($r->dayNha && $r->dayNha->khuonVien) ? $r->dayNha->khuonVien->ma_viet_tat : ($r->ten_khu ?? 'Khu I');
            $key = "{$buildingName} ({$campusName})";

            if (!isset($grouped[$key])) {
                $grouped[$key] = [
                    'building_name' => $buildingName,
                    'campus_name'   => $campusName,
                    'rooms_count'   => 0,
                    'pc'            => 0,
                    'cpu'           => 0,
                    'kb'            => 0,
                    'mouse'         => 0,
                    'ac'            => 0,
                    'fan'           => 0,
                    'tv'            => 0,
                    'hdmi'          => 0,
                    'desk'          => 0,
                ];
            }

            $grouped[$key]['rooms_count']++;
            $grouped[$key]['pc']    += (int)($r->so_may_tinh ?? 0);
            $grouped[$key]['cpu']   += (int)($r->so_cpu ?? 0);
            $grouped[$key]['kb']    += (int)($r->so_ban_phim ?? 0);
            $grouped[$key]['mouse'] += (int)($r->so_chuot ?? 0);
            $grouped[$key]['ac']    += (int)($r->so_may_lanh ?? 0);
            $grouped[$key]['fan']   += (int)($r->so_quat ?? 0);
            $grouped[$key]['tv']    += (int)($r->so_tivi ?? 0);
            $grouped[$key]['hdmi']  += (int)($r->so_cong_hdmi ?? 1);
            $grouped[$key]['desk']  += (int)($r->so_ban_sinh_vien ?? 20);

            $totals['total_rooms']++;
            $totals['total_pc']    += (int)($r->so_may_tinh ?? 0);
            $totals['total_cpu']   += (int)($r->so_cpu ?? 0);
            $totals['total_kb']    += (int)($r->so_ban_phim ?? 0);
            $totals['total_mouse'] += (int)($r->so_chuot ?? 0);
            $totals['total_ac']    += (int)($r->so_may_lanh ?? 0);
            $totals['total_fan']   += (int)($r->so_quat ?? 0);
            $totals['total_tv']    += (int)($r->so_tivi ?? 0);
            $totals['total_hdmi']  += (int)($r->so_cong_hdmi ?? 1);
            $totals['total_desk']  += (int)($r->so_ban_sinh_vien ?? 20);
        }

        return view('admin.report_equipment_print', compact('grouped', 'totals', 'rooms'));
    }
}
