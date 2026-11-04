<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class KhuonVien extends Model
{
    protected $table = 'khuon_vien';
    protected $primaryKey = 'ma_khuon_vien';
    public $timestamps = false;

    protected $fillable = [
        'ten_khuon_vien',
        'ma_viet_tat',
        'dia_chi',
        'mo_ta',
    ];

    public function dayNhas()
    {
        return $this->hasMany(DayNha::class, 'ma_khuon_vien', 'ma_khuon_vien');
    }
}
