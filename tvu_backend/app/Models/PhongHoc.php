<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class PhongHoc extends Model
{
    protected $table = 'PHONG_HOC';
    protected $primaryKey = 'ma_phong_hoc';
    public $timestamps = false;

    protected $fillable = [
        'ma_day_nha',
        'so_phong',
        'loai_phong',
        'tang_so',
        'ma_qr_dinh_danh',
        'so_may_lanh',
        'so_quat',
        'loai_quat',
        'so_tivi',
        'so_cong_hdmi',
        'so_bang_viet',
        'so_ban_sinh_vien',
        'so_ban_giao_vien',
        'mo_ta_hien_trang',
        'dang_su_dung',
    ];
}