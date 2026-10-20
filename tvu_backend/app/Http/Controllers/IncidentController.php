<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\PhongHoc;
use App\Models\SuCo;

class IncidentController extends Controller
{
    // API Quét mã QR: Nhận chuỗi QR -> Trả về dữ liệu phòng và số lượng thiết bị
    public function getRoomInfo($qr_code)
    {
        $room = PhongHoc::where('ma_qr_dinh_danh', $qr_code)->first();

        if (!$room) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Không tìm thấy phòng học tương ứng với mã QR này.'
            ], 404);
        }

        return response()->json([
            'status' => 'success',
            'data'   => $room
        ], 200);
    }

    // API Tạo mới báo cáo sự cố từ Mobile
    public function store(Request $request)
    {
        $request->validate([
            'ma_phong_hoc'     => 'required|integer',
            'ma_loai_su_co'    => 'required|integer',
            'mo_ta_hu_hong'    => 'required|string',
            'vi_tri_trong_phong' => 'nullable|string',
        ]);

        // Tạo mã phiếu tự động: SC-NămThángNgày-SốNgẫuNhiên
        $maPhieu = 'SC-' . date('Ymd') . '-' . rand(100, 999);

        $suCo = SuCo::create([
            'ma_phieu_su_co'     => $maPhieu,
            'tieu_de'            => 'Sự cố tại phòng #' . $request->ma_phong_hoc,
            'mo_ta_hu_hong'      => $request->mo_ta_hu_hong,
            'ma_phong_hoc'       => $request->ma_phong_hoc,
            'ma_loai_su_co'      => $request->ma_loai_su_co,
            'vi_tri_trong_phong' => $request->vi_tri_trong_phong,
            'muc_do_uu_tien'     => 'Bình thường',
            'trang_thai'         => 'Chờ tiếp nhận',
            'nguoi_bao_cao_id'   => $request->user()->ma_nguoi_dung, // Lấy từ Token đang đăng nhập
            'ngay_gui_bao_cao'   => now(),
        ]);

        return response()->json([
            'status'  => 'success',
            'message' => 'Gửi báo cáo sự cố thành công!',
            'data'    => $suCo
        ], 201);
    }

    // API Lấy danh sách phiếu sự cố do chính người dùng gửi
    public function myIncidents(Request $request)
    {
        $userId = $request->user()->ma_nguoi_dung;

        $incidents = SuCo::with('phongHoc')
            ->where('nguoi_bao_cao_id', $userId)
            ->orderBy('ngay_gui_bao_cao', 'desc')
            ->get();

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

        $suCo->trang_thai = $request->input('trang_thai'); // VD: Đang xử lý, Hoàn thành
        if ($request->input('trang_thai') == 'Hoàn thành') {
            $suCo->ngay_hoan_thanh = now();
        }
        $suCo->save();

        return response()->json([
            'status'  => 'success',
            'message' => 'Cập nhật trạng thái thành công!',
            'data'    => $suCo
        ], 200);
    }
}