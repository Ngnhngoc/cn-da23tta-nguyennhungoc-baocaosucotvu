<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class PhongHoc extends Model
{
    protected $table = 'phong_hoc';
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

    protected $appends = ['so_phong_day_du', 'ten_khu', 'ten_day_nha', 'ma_toa'];

    public function dayNha()
    {
        return $this->belongsTo(DayNha::class, 'ma_day_nha', 'ma_day_nha');
    }

    public function getMaToaAttribute()
    {
        if ($this->relationLoaded('dayNha') && $this->dayNha) {
            return $this->dayNha->ma_toa;
        }
        $dayNha = $this->dayNha;
        if ($dayNha && !empty($dayNha->ma_toa)) {
            return $dayNha->ma_toa;
        }
        if (!empty($this->ma_qr_dinh_danh) && preg_match('/^TVU-([A-Z0-9]+)-/i', $this->ma_qr_dinh_danh, $matches)) {
            return strtoupper($matches[1]);
        }
        return 'B21';
    }

    public function getTenDayNhaAttribute()
    {
        if ($this->dayNha && !empty($this->dayNha->ten_day_nha)) {
            return $this->dayNha->ten_day_nha;
        }
        return "Tòa nhà {$this->ma_toa}";
    }

    public function getTenKhuAttribute()
    {
        if ($this->dayNha && $this->dayNha->khuonVien && !empty($this->dayNha->khuonVien->ma_viet_tat)) {
            return $this->dayNha->khuonVien->ma_viet_tat;
        }
        $maToa = $this->ma_toa;
        $khuLetter = substr($maToa, 0, 1);
        return "Tòa $khuLetter";
    }

    public function getSoPhongDayDuAttribute()
    {
        return "{$this->ma_toa}.{$this->so_phong}";
    }
}