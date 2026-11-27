<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\PhongHoc;
use App\Models\SuCo;
use Illuminate\Support\Facades\DB;

class IncidentController extends Controller
{
    // API Lấy danh sách loại sự cố
    public function getIncidentTypes()
    {
        $types = DB::table('loai_su_co')->get();
        return response()->json([
            'status' => 'success',
            'data'   => $types
        ], 200);
    }

    // API Lấy danh sách phòng học
    public function getRooms(Request $request)
    {
        $query = PhongHoc::query();
        // Mặc định chỉ lấy phòng đang hoạt động; Nếu truyền all=1 hoặc include_inactive=1 thì lấy toàn bộ
        if (!$request->has('all') && !$request->has('include_inactive')) {
            $query->where('dang_su_dung', 1);
        }
        $rooms = $query->get();
        return response()->json([
            'status' => 'success',
            'data'   => $rooms
        ], 200);
    }

    // API Quét mã QR: Nhận chuỗi QR -> Trả về dữ liệu phòng và số lượng thiết bị
    public function getRoomInfo($qr_code)
    {
        $qr_code = trim($qr_code);
        $room = PhongHoc::where('ma_qr_dinh_danh', $qr_code)->first();

        if (!$room) {
            $clean = preg_replace('/^(TVU-|B21\.|B21-)/i', '', $qr_code);
            $room = PhongHoc::where('so_phong', $clean)
                ->orWhere('so_phong', $qr_code)
                ->orWhere('ma_qr_dinh_danh', 'like', "%{$clean}%")
                ->first();
        }

        if (!$room) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Không tìm thấy phòng học tương ứng với mã QR này.'
            ], 404);
        }

        // Chặn phòng học tạm ngưng hoạt động hoặc đã bị ẩn
        if ($room->dang_su_dung != 1) {
            return response()->json([
                'status'  => 'inactive',
                'message' => "Phòng {$room->so_phong_day_du} hiện đang tạm ngưng hoạt động hoặc không còn sử dụng. Không thể báo cáo sự cố cho phòng này!",
                'data'    => $room,
            ], 403);
        }

        return response()->json([
            'status' => 'success',
            'data'   => $room
        ], 200);
    }

    // API Tạo mới báo cáo sự cố từ Mobile (hỗ trợ tối đa 5 hình ảnh)
    public function store(Request $request)
    {
        $request->validate([
            'ma_phong_hoc'       => 'required|integer',
            'ma_loai_su_co'      => 'required|integer',
            'mo_ta_hu_hong'      => 'required|string',
            'vi_tri_trong_phong' => 'nullable|string',
        ]);

        $room = PhongHoc::find($request->ma_phong_hoc);
        if (!$room) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Không tìm thấy thông tin phòng học!'
            ], 404);
        }

        if ($room->dang_su_dung != 1) {
            return response()->json([
                'status'  => 'inactive',
                'message' => "Phòng {$room->so_phong_day_du} hiện đang tạm ngưng hoạt động hoặc không còn sử dụng. Không thể gửi báo cáo sự cố!",
            ], 403);
        }

        // Tạo mã phiếu tự động: SC-NămThángNgày-SốNgẫuNhiên
        $maPhieu = 'SC-' . date('Ymd') . '-' . rand(100, 999);
        $user = $request->user();

        $suCo = SuCo::create([
            'ma_phieu_su_co'     => $maPhieu,
            'tieu_de'            => 'Sự cố tại phòng #' . $request->ma_phong_hoc,
            'mo_ta_hu_hong'      => $request->mo_ta_hu_hong,
            'ma_phong_hoc'       => $request->ma_phong_hoc,
            'ma_loai_su_co'      => $request->ma_loai_su_co,
            'vi_tri_trong_phong' => $request->vi_tri_trong_phong,
            'muc_do_uu_tien'     => 'Bình thường',
            'trang_thai'         => 'Chờ tiếp nhận',
            'nguoi_bao_cao_id'   => $user->ma_nguoi_dung,
            'ngay_gui_bao_cao'   => now(),
        ]);

        // 1. Thu thập tất cả các file ảnh gửi lên (tối đa 5 ảnh)
        $filesToSave = [];

        // Kiểm tra hinh_anh[] hoặc hinh_anh đơn lẻ
        if ($request->hasFile('hinh_anh')) {
            $files = $request->file('hinh_anh');
            if (is_array($files)) {
                $filesToSave = array_merge($filesToSave, $files);
            } else {
                $filesToSave[] = $files;
            }
        }
        // Kiểm tra hinh_anh_list[]
        if ($request->hasFile('hinh_anh_list')) {
            $files = $request->file('hinh_anh_list');
            if (is_array($files)) {
                $filesToSave = array_merge($filesToSave, $files);
            } else {
                $filesToSave[] = $files;
            }
        }
        // Kiểm tra từng file riêng lẻ hinh_anh_0, hinh_anh_1, ..., hinh_anh_4
        for ($i = 0; $i < 5; $i++) {
            if ($request->hasFile("hinh_anh_$i")) {
                $filesToSave[] = $request->file("hinh_anh_$i");
            }
        }

        // Cắt bớt nếu vượt quá 5 ảnh
        $filesToSave = array_slice($filesToSave, 0, 5);
        $savedImageUrls = [];

        foreach ($filesToSave as $file) {
            if ($file && $file->isValid()) {
                $path = $file->store('incidents', 'public');
                $imageUrl = url('storage/' . $path);
                $savedImageUrls[] = $imageUrl;

                DB::table('hinh_anh_su_co')->insert([
                    'ma_su_co_id'   => $suCo->ma_su_co_id,
                    'duong_dan_anh' => $imageUrl,
                    'loai_hinh_anh' => 'Hiện trường',
                    'nguoi_chup_id' => $user->ma_nguoi_dung,
                    'ngay_chup_anh' => now(),
                ]);
            }
        }

        // 2. Ghi nhật ký vào bảng lich_su_xu_ly
        DB::table('lich_su_xu_ly')->insert([
            'ma_su_co_id'         => $suCo->ma_su_co_id,
            'nguoi_thuc_hien_id'  => $user->ma_nguoi_dung,
            'trang_thai_cu'       => null,
            'trang_thai_moi'      => 'Chờ tiếp nhận',
            'noi_dung_ghi_chu'    => 'Sinh viên gửi báo cáo sự cố mới qua ứng dụng (' . count($savedImageUrls) . ' ảnh).',
            'thoi_gian_cap_nhat'  => now(),
        ]);

        return response()->json([
            'status'  => 'success',
            'message' => 'Gửi báo cáo sự cố thành công!',
            'data'    => $suCo,
            'images'  => $savedImageUrls
        ], 201);
    }

    // API Lấy danh sách phiếu sự cố do chính người dùng gửi
    public function myIncidents(Request $request)
    {
        $userId = $request->user()->ma_nguoi_dung;

        $incidents = SuCo::with(['phongHoc.dayNha.khuonVien', 'kyThuatVien'])
            ->where('nguoi_bao_cao_id', $userId)
            ->orderBy('ngay_gui_bao_cao', 'desc')
            ->get();

        $base = $request->getSchemeAndHttpHost();

        // Gắn kèm danh sách hình ảnh & thông tin KTV
        foreach ($incidents as $item) {
            $images = DB::table('hinh_anh_su_co')
                ->where('ma_su_co_id', $item->ma_su_co_id)
                ->get();
            $formattedImages = [];
            foreach ($images as $img) {
                $formattedImages[] = [
                    'ma_hinh_anh'   => $img->ma_hinh_anh,
                    'duong_dan_anh' => $this->formatImageUrl($img->duong_dan_anh, $base),
                    'loai_hinh_anh' => $img->loai_hinh_anh,
                ];
            }
            $item->hinh_anh_list = $formattedImages;

            $ktv = $item->kyThuatVien;
            $item->ktv_info = $ktv ? [
                'ho_va_ten'     => $ktv->ho_va_ten,
                'so_dien_thoai' => $ktv->so_dien_thoai ?? '0987654321',
                'email_tvu'     => $ktv->email_tvu,
            ] : null;
            $item->ktv_ten = $ktv ? $ktv->ho_va_ten : 'Chưa phân công';

            // Đảm bảo alias phong_hoc luôn trỏ đến phongHoc
            if (!$item->phong_hoc && $item->phongHoc) {
                $item->phong_hoc = $item->phongHoc;
            }

            // Lịch sử xử lý chi tiết (timeline)
            $item->lich_su_list = DB::table('lich_su_xu_ly')
                ->leftJoin('nguoi_dung', 'lich_su_xu_ly.nguoi_thuc_hien_id', '=', 'nguoi_dung.ma_nguoi_dung')
                ->where('ma_su_co_id', $item->ma_su_co_id)
                ->select(
                    'lich_su_xu_ly.*',
                    'nguoi_dung.ho_va_ten as nguoi_thuc_hien_ten',
                    'nguoi_dung.vai_tro as nguoi_thuc_hien_vaitro'
                )
                ->orderBy('thoi_gian_cap_nhat', 'asc')
                ->get();
        }

        return response()->json([
            'status' => 'success',
            'data'   => $incidents
        ], 200);
    }

    // API Cho Kỹ thuật viên đổi trạng thái (Tiếp nhận / Hoàn tất)
    public function updateStatus(Request $request, $id)
    {
        $suCo = SuCo::find($id);

        if (!$suCo) {
            return response()->json(['message' => 'Không tìm thấy phiếu sự cố.'], 404);
        }

        $oldStatus = $suCo->trang_thai;
        $newStatus = $request->input('trang_thai'); // VD: Đang xử lý, Hoàn thành

        $currentUser = $request->user();
        $isKtvOrStaff = $currentUser && in_array($currentUser->vai_tro, ['Kỹ thuật viên', 'Nhân viên']);

        // RÀNG BUỘC NGHIỆP VỤ: Chỉ những sự cố đã được phân công hoặc đã tiếp nhận (Đang xử lý) mới được hoàn tất nghiệm thu
        if ($newStatus == 'Hoàn thành') {
            if ($oldStatus == 'Chờ tiếp nhận') {
                return response()->json([
                    'status'  => 'error',
                    'message' => 'Phiếu sự cố đang ở trạng thái "Chờ tiếp nhận". Vui lòng bấm "Tiếp nhận" trước khi hoàn tất nghiệm thu!'
                ], 422);
            }

            // Nếu người thao tác là KTV: Chỉ KTV được phân công hoặc đã tiếp nhận phiếu này mới được quyền nghiệm thu
            if ($isKtvOrStaff && (!$suCo->ky_thuat_vien_id || $suCo->ky_thuat_vien_id != $currentUser->ma_nguoi_dung)) {
                return response()->json([
                    'status'  => 'error',
                    'message' => 'Chỉ Kỹ thuật viên được phân công hoặc đã tiếp nhận phiếu này mới có quyền hoàn tất & nghiệm thu!'
                ], 403);
            }
        }

        // Khi Kỹ thuật viên tiếp nhận sự cố:
        if ($newStatus == 'Đang xử lý' && $isKtvOrStaff) {
            // Nếu phiếu chưa có ai nhận, tự động gán cho KTV này
            if (!$suCo->ky_thuat_vien_id) {
                $suCo->ky_thuat_vien_id = $currentUser->ma_nguoi_dung;
                $suCo->ngay_phan_cong = now();
            }
        }

        $suCo->trang_thai = $newStatus;
        if ($newStatus == 'Hoàn thành') {
            $suCo->ngay_hoan_thanh = now();
            if ($isKtvOrStaff && !$suCo->ky_thuat_vien_id) {
                $suCo->ky_thuat_vien_id = $currentUser->ma_nguoi_dung;
            }
        }
        $suCo->save();

        // Lưu danh sách ảnh nghiệm thu / bằng chứng sửa chữa (tối đa 5 ảnh)
        $uploadedFiles = [];
        if ($request->hasFile('hinh_anh_nghiem_thu')) {
            $f = $request->file('hinh_anh_nghiem_thu');
            if (is_array($f)) {
                $uploadedFiles = array_merge($uploadedFiles, $f);
            } else {
                $uploadedFiles[] = $f;
            }
        }
        for ($i = 0; $i < 5; $i++) {
            if ($request->hasFile("hinh_anh_nghiem_thu_{$i}")) {
                $uploadedFiles[] = $request->file("hinh_anh_nghiem_thu_{$i}");
            }
        }

        foreach ($uploadedFiles as $index => $file) {
            if ($index >= 5) break;
            $path = $file->store('incidents_resolved', 'public');
            $imageUrl = url('storage/' . $path);

            DB::table('hinh_anh_su_co')->insert([
                'ma_su_co_id'   => $suCo->ma_su_co_id,
                'duong_dan_anh' => $imageUrl,
                'loai_hinh_anh' => 'Nghiệm thu',
                'nguoi_chup_id' => $request->user() ? $request->user()->ma_nguoi_dung : 1,
                'ngay_chup_anh' => now(),
            ]);
        }

        // Ghi lịch sử chuyển trạng thái
        DB::table('lich_su_xu_ly')->insert([
            'ma_su_co_id'         => $suCo->ma_su_co_id,
            'nguoi_thuc_hien_id'  => $request->user()->ma_nguoi_dung,
            'trang_thai_cu'       => $oldStatus,
            'trang_thai_moi'      => $newStatus,
            'noi_dung_ghi_chu'    => $request->input('ghi_chu', 'Cập nhật trạng thái phiếu.'),
            'thoi_gian_cap_nhat'  => now(),
        ]);

        return response()->json([
            'status'  => 'success',
            'message' => 'Cập nhật trạng thái thành công!',
            'data'    => $suCo
        ], 200);
    }

    // API Cho Admin & KTV: Lấy tất cả sự cố
    public function getAllIncidents(Request $request)
    {
        $query = SuCo::with(['phongHoc.dayNha.khuonVien', 'nguoiBaoCao', 'kyThuatVien']);

        // Nếu là KTV lọc các sự cố được giao hoặc chưa phân công
        if ($request->query('assigned_to_me') == 'true') {
            $query->where('ky_thuat_vien_id', $request->user()->ma_nguoi_dung);
        }

        $incidents = $query->orderBy('ngay_gui_bao_cao', 'desc')->get();
        $base = $request->getSchemeAndHttpHost();

        foreach ($incidents as $item) {
            $images = DB::table('hinh_anh_su_co')
                ->where('ma_su_co_id', $item->ma_su_co_id)
                ->get();
            $formattedImages = [];
            foreach ($images as $img) {
                $formattedImages[] = [
                    'ma_hinh_anh'   => $img->ma_hinh_anh,
                    'duong_dan_anh' => $this->formatImageUrl($img->duong_dan_anh, $base),
                    'loai_hinh_anh' => $img->loai_hinh_anh,
                ];
            }
            $item->hinh_anh_list = $formattedImages;

            $ktv = $item->kyThuatVien;
            $item->ktv_info = $ktv ? [
                'ho_va_ten'     => $ktv->ho_va_ten,
                'so_dien_thoai' => $ktv->so_dien_thoai ?? '0987654321',
                'email_tvu'     => $ktv->email_tvu,
            ] : null;
            $item->ktv_ten = $ktv ? $ktv->ho_va_ten : 'Chưa phân công';

            $rep = $item->nguoiBaoCao;
            $item->nguoi_bao_cao_info = $rep ? [
                'ho_va_ten'     => $rep->ho_va_ten,
                'ten_dang_nhap' => $rep->ten_dang_nhap,
                'email_tvu'     => $rep->email_tvu,
                'so_dien_thoai' => $rep->so_dien_thoai ?? 'Chưa cập nhật',
                'lop_don_vi'    => $rep->lop_hoac_don_vi,
                'vai_tro'       => $rep->vai_tro,
            ] : null;

            // Đảm bảo alias phong_hoc luôn trỏ đến phongHoc
            if (!$item->phong_hoc && $item->phongHoc) {
                $item->phong_hoc = $item->phongHoc;
            }
        }

        return response()->json([
            'status' => 'success',
            'data'   => $incidents
        ], 200);
    }

    // API Lấy danh sách nhân viên kỹ thuật
    public function getTechnicians()
    {
        $ktvs = \App\Models\User::whereIn('vai_tro', ['Kỹ thuật viên', 'Nhân viên'])->get([
            'ma_nguoi_dung', 'ho_va_ten', 'email_tvu', 'so_dien_thoai', 'vai_tro'
        ]);

        return response()->json([
            'status' => 'success',
            'data'   => $ktvs
        ], 200);
    }

    // API Admin: Phân công KTV xử lý sự cố
    public function assignTechnician(Request $request, $id)
    {
        $request->validate([
            'ky_thuat_vien_id' => 'required|integer',
        ]);

        $suCo = SuCo::findOrFail($id);
        $suCo->ky_thuat_vien_id = $request->ky_thuat_vien_id;
        $suCo->ngay_phan_cong = now();
        if ($suCo->trang_thai == 'Chờ tiếp nhận') {
            $suCo->trang_thai = 'Đang xử lý';
        }
        $suCo->save();

        $ktvTen = DB::table('NGUOI_DUNG')->where('ma_nguoi_dung', $request->ky_thuat_vien_id)->value('ho_va_ten');

        DB::table('lich_su_xu_ly')->insert([
            'ma_su_co_id'         => $suCo->ma_su_co_id,
            'nguoi_thuc_hien_id'  => $request->user()->ma_nguoi_dung,
            'trang_thai_cu'       => 'Chờ tiếp nhận',
            'trang_thai_moi'      => $suCo->trang_thai,
            'noi_dung_ghi_chu'    => 'Phân công cho KTV: ' . $ktvTen,
            'thoi_gian_cap_nhat'  => now(),
        ]);

        return response()->json([
            'status'  => 'success',
            'message' => 'Phân công kỹ thuật viên thành công!',
            'data'    => $suCo
        ], 200);
    }

    // API Thống kê số lượng ticket
    public function getStats()
    {
        $total = SuCo::count();
        $pending = SuCo::where('trang_thai', 'Chờ tiếp nhận')->count();
        $processing = SuCo::where('trang_thai', 'Đang xử lý')->count();
        $resolved = SuCo::where('trang_thai', 'Hoàn thành')->count();

        return response()->json([
            'status' => 'success',
            'data'   => [
                'total'      => $total,
                'pending'    => $pending,
                'processing' => $processing,
                'resolved'   => $resolved,
            ]
        ], 200);
    }

    protected function formatImageUrl($url, $base)
    {
        if (empty($url)) return '';
        $parsed = parse_url($url);
        $path = $parsed['path'] ?? $url;
        if (!str_starts_with($path, '/')) {
            $path = '/' . $path;
        }
        return rtrim($base, '/') . $path;
    }
}