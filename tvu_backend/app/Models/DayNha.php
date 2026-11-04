<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class DayNha extends Model
{
    protected $table = 'day_nha';
    protected $primaryKey = 'ma_day_nha';
    public $timestamps = false;

    protected $fillable = [
        'ma_khuon_vien',
        'ten_day_nha',
        'ma_toa',
        'tong_so_tang',
    ];

    public function khuonVien()
    {
        return $this->belongsTo(KhuonVien::class, 'ma_khuon_vien', 'ma_khuon_vien');
    }

    public function phongHocs()
    {
        return $this->hasMany(PhongHoc::class, 'ma_day_nha', 'ma_day_nha');
    }
}
