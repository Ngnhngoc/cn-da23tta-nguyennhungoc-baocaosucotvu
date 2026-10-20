<?php

namespace App\Models;

use Illuminate\Foundation\Auth\User as Authenticatable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    use HasApiTokens;

    // Trỏ đúng bảng NGUOI_DUNG trong database tvu_suco
    protected $table = 'NGUOI_DUNG';
    protected $primaryKey = 'ma_nguoi_dung';
    public $timestamps = false; // Bảng dùng cột ngay_tao riêng

    protected $fillable = [
        'ten_dang_nhap',
        'ho_va_ten',
        'email_tvu',
        'so_dien_thoai',
        'mat_khau_ma_hoa',
        'vai_tro',
        'lop_hoac_don_vi',
        'ngay_tao',
        'dang_hoat_dong',
    ];

    protected $hidden = [
        'mat_khau_ma_hoa',
    ];

    // Báo cho Laravel biết cột lưu mật khẩu là mat_khau_ma_hoa (thay vì password)
    public function getAuthPassword()
    {
        return $this->mat_khau_ma_hoa;
    }
}