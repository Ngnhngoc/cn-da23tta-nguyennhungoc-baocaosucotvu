<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Carbon\Carbon;

class EquipmentController extends Controller
{
    /**
     * Lấy danh sách thiết bị theo phòng kèm vòng đời & lịch sử bảo trì/sửa chữa
     */
    public function getRoomEquipments($roomId)
    {
        $room = DB::table('PHONG_HOC')->where('ma_phong_hoc', $roomId)->first();
        if (!$room) {
            return response()->json(['status' => 'error', 'message' => 'Không tìm thấy phòng học'], 404);
        }

        $equipments = DB::table('THIET_BI')
            ->where('ma_phong_hoc', $roomId)
            ->orderBy('ma_thiet_bi', 'asc')
            ->get();

        $now = Carbon::now();
        $result = [];

        foreach ($equipments as $eq) {
            $history = DB::table('LICH_SU_BAO_TRI')
                ->where('ma_thiet_bi', $eq->ma_thiet_bi)
                ->orderBy('ngay_thuc_hien', 'desc')
                ->get();

            $repairCount = $history->whereIn('loai_hoat_dong', ['Sửa chữa sự cố', 'Thay thế linh kiện'])->count();
            $maintenanceCount = $history->where('loai_hoat_dong', 'Bảo trì định kỳ')->count();

            $dueStatus = 'Bình thường';
            $daysUntilDue = null;
            if ($eq->ngay_bao_tri_tiep_theo) {
                $nextDate = Carbon::parse($eq->ngay_bao_tri_tiep_theo);
                $daysUntilDue = $now->diffInDays($nextDate, false);
                if ($daysUntilDue < 0) {
                    $dueStatus = 'Quá hạn';
                } elseif ($daysUntilDue <= 14) {
                    $dueStatus = 'Sắp đến hạn';
                }
            }

            $ageMonths = $eq->ngay_lap_dat ? Carbon::parse($eq->ngay_lap_dat)->diffInMonths($now) : 0;

            $result[] = [
                'ma_thiet_bi'            => $eq->ma_thiet_bi,
                'ma_phong_hoc'           => $eq->ma_phong_hoc,
                'ma_tai_san'             => $eq->ma_tai_san,
                'ten_thiet_bi'           => $eq->ten_thiet_bi,
                'loai_thiet_bi'          => $eq->loai_thiet_bi,
                'ngay_lap_dat'           => $eq->ngay_lap_dat,
                'han_bao_hanh'           => $eq->han_bao_hanh,
                'chu_ky_bao_tri_thang'   => $eq->chu_ky_bao_tri_thang,
                'ngay_bao_tri_gan_nhat'  => $eq->ngay_bao_tri_gan_nhat,
                'ngay_bao_tri_tiep_theo' => $eq->ngay_bao_tri_tiep_theo,
                'trang_thai'             => $eq->trang_thai,
                'ghi_chu'                => $eq->ghi_chu,
                'tuoi_tho_thang'         => $ageMonths,
                'tinh_trang_bao_tri'     => $dueStatus,
                'so_ngay_con_lai'        => $daysUntilDue,
                'so_lan_sua_chua'        => $repairCount,
                'so_lan_bao_tri'         => $maintenanceCount,
                'lich_su'                => $history,
            ];
        }

        // Lấy thêm các phiếu sự cố đã từng xảy ra tại phòng này để đối chiếu sửa chữa
        $roomIncidents = DB::table('SU_CO')
            ->where('ma_phong_hoc', $roomId)
            ->orderBy('ngay_gui_bao_cao', 'desc')
            ->get(['ma_su_co_id', 'ma_phieu_su_co', 'mo_ta_hu_hong', 'trang_thai', 'ngay_gui_bao_cao', 'ngay_hoan_thanh']);

        return response()->json([
            'status' => 'success',
            'data'   => [
                'equipments' => $result,
                'incidents'  => $roomIncidents,
            ]
        ], 200);
    }

    /**
     * Thêm thiết bị mới vào phòng
     */
    public function store(Request $request)
    {
        $request->validate([
            'ma_phong_hoc'         => 'required|integer',
            'ten_thiet_bi'         => 'required|string|max:150',
            'loai_thiet_bi'        => 'required|string|max:80',
            'chu_ky_bao_tri_thang' => 'nullable|integer|min:1|max:60',
        ]);

        $installDate = $request->input('ngay_lap_dat', Carbon::now()->format('Y-m-d'));
        $cycle = (int) $request->input('chu_ky_bao_tri_thang', 6);
        $nextMaint = Carbon::parse($installDate)->addMonths($cycle)->format('Y-m-d');

        $id = DB::table('THIET_BI')->insertGetId([
            'ma_phong_hoc'           => $request->input('ma_phong_hoc'),
            'ma_tai_san'             => $request->input('ma_tai_san', 'TVU-TB-' . rand(1000, 9999)),
            'ten_thiet_bi'           => $request->input('ten_thiet_bi'),
            'loai_thiet_bi'          => $request->input('loai_thiet_bi'),
            'ngay_lap_dat'           => $installDate,
            'han_bao_hanh'           => $request->input('han_bao_hanh'),
            'chu_ky_bao_tri_thang'   => $cycle,
            'ngay_bao_tri_gan_nhat'  => $installDate,
            'ngay_bao_tri_tiep_theo' => $nextMaint,
            'trang_thai'             => $request->input('trang_thai', 'Hoạt động tốt'),
            'ghi_chu'                => $request->input('ghi_chu'),
            'created_at'             => now(),
            'updated_at'             => now(),
        ]);

        DB::table('LICH_SU_BAO_TRI')->insert([
            'ma_thiet_bi'     => $id,
            'loai_hoat_dong'  => 'Lắp đặt mới',
            'ngay_thuc_hien'  => $installDate . ' ' . Carbon::now()->format('H:i:s'),
            'nguoi_thuc_hien' => $request->user() ? $request->user()->ho_va_ten : 'Quản trị viên',
            'noi_dung'        => 'Lắp đặt thiết bị mới và đưa vào vận hành.',
            'chi_phi'         => 0,
            'ket_qua'         => 'Hoạt động tốt',
            'created_at'      => now(),
            'updated_at'      => now(),
        ]);

        return response()->json([
            'status'  => 'success',
            'message' => 'Đã thêm thiết bị mới và khởi tạo vòng đời thành công!',
        ], 201);
    }

    /**
     * Ghi nhận bảo trì định kỳ hoặc sửa chữa thiết bị
     */
    public function addMaintenance(Request $request, $id)
    {
        $eq = DB::table('THIET_BI')->where('ma_thiet_bi', $id)->first();
        if (!$eq) {
            return response()->json(['status' => 'error', 'message' => 'Không tìm thấy thiết bị'], 404);
        }

        $request->validate([
            'loai_hoat_dong' => 'required|string',
            'noi_dung'       => 'required|string',
        ]);

        $now = Carbon::now();
        $ngayThucHien = $request->input('ngay_thuc_hien', $now->format('Y-m-d H:i:s'));
        $nguoiThucHien = $request->input('nguoi_thuc_hien', $request->user() ? $request->user()->ho_va_ten : 'Kỹ thuật viên');

        DB::table('LICH_SU_BAO_TRI')->insert([
            'ma_thiet_bi'     => $id,
            'loai_hoat_dong'  => $request->input('loai_hoat_dong'),
            'ngay_thuc_hien'  => $ngayThucHien,
            'nguoi_thuc_hien' => $nguoiThucHien,
            'noi_dung'        => $request->input('noi_dung'),
            'chi_phi'         => (float) $request->input('chi_phi', 0),
            'ket_qua'         => $request->input('ket_qua', 'Hoàn thành'),
            'created_at'      => now(),
            'updated_at'      => now(),
        ]);

        $newStatus = $request->input('trang_thai_moi', 'Hoạt động tốt');
        $cycle = (int) ($eq->chu_ky_bao_tri_thang ?? 6);
        $dateOnly = Carbon::parse($ngayThucHien)->format('Y-m-d');
        $nextMaint = Carbon::parse($dateOnly)->addMonths($cycle)->format('Y-m-d');

        DB::table('THIET_BI')->where('ma_thiet_bi', $id)->update([
            'ngay_bao_tri_gan_nhat'  => $dateOnly,
            'ngay_bao_tri_tiep_theo' => $nextMaint,
            'trang_thai'             => $newStatus,
            'updated_at'             => now(),
        ]);

        return response()->json([
            'status'  => 'success',
            'message' => 'Đã ghi nhận lịch sử bảo trì / sửa chữa thành công!',
        ], 200);
    }

    /**
     * Lấy danh sách thiết bị cần bảo trì định kỳ (quá hạn hoặc sắp đến hạn trong 30 ngày)
     */
    public function getMaintenanceDue()
    {
        $limitDate = Carbon::now()->addDays(30)->format('Y-m-d');
        $list = DB::table('THIET_BI')
            ->join('PHONG_HOC', 'THIET_BI.ma_phong_hoc', '=', 'PHONG_HOC.ma_phong_hoc')
            ->whereDate('THIET_BI.ngay_bao_tri_tiep_theo', '<=', $limitDate)
            ->orderBy('THIET_BI.ngay_bao_tri_tiep_theo', 'asc')
            ->select('THIET_BI.*', 'PHONG_HOC.so_phong', 'PHONG_HOC.ma_qr_dinh_danh')
            ->get();

        return response()->json([
            'status' => 'success',
            'data'   => $list,
        ], 200);
    }
}
