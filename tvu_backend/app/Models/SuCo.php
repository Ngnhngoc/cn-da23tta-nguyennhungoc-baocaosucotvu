<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class SuCo extends Model
{
    protected $table = 'SU_CO';
    protected $primaryKey = 'ma_su_co_id';
    public $timestamps = false;

    protected $fillable = [
        'ma_phieu_su_co',
        'tieu_de',
        'mo_ta_hu_hong',
        'ma_phong_hoc',
        'ma_loai_su_co',
        'vi_tri_trong_phong',
        'muc_do_uu_tien',
        'trang_thai',
        'nguoi_bao_cao_id',
        'ky_thuat_vien_id',
        'ngay_gui_bao_cao',
        'ngay_phan_cong',
        'ngay_hoan_thanh',
        'ngay_dong_phieu',
    ];

    // Liên kết với phòng học
    public function phongHoc()
    {
        return $this->belongsTo(PhongHoc::class, 'ma_phong_hoc', 'ma_phong_hoc');
    }

    // Liên kết với người gửi báo cáo
    public function nguoiBaoCao()
    {
        return $this->belongsTo(User::class, 'nguoi_bao_cao_id', 'ma_nguoi_dung');
    }
}