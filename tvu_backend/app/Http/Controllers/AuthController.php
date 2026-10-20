<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\User;
use Illuminate\Support\Facades\Hash;

class AuthController extends Controller
{
    public function login(Request $request)
    {
        // Nhận email hoặc mã sinh viên và mật khẩu từ Flutter
        $request->validate([
            'username' => 'required',
            'password' => 'required',
        ]);

        // Tìm tài khoản theo ten_dang_nhap hoặc email_tvu
        $user = User::where('ten_dang_nhap', $request->username)
                    ->orWhere('email_tvu', $request->username)
                    ->first();

        // Kiểm tra tồn tại và mật khẩu băm BCrypt
        if (!$user || !Hash::check($request->password, $user->mat_khau_ma_hoa)) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Tài khoản hoặc mật khẩu không chính xác.'
            ], 401);
        }

        // Tạo Sanctum Token cho thiết bị
        $token = $user->createToken('tvu_mobile_token')->plainTextToken;

        return response()->json([
            'status'  => 'success',
            'message' => 'Đăng nhập thành công!',
            'token'   => $token,
            'user'    => [
                'ma_nguoi_dung' => $user->ma_nguoi_dung,
                'ho_va_ten'     => $user->ho_va_ten,
                'vai_tro'       => $user->vai_tro,
                'lop_don_vi'    => $user->lop_hoac_don_vi
            ]
        ], 200);
    }

    public function me(Request $request)
    {
        return response()->json($request->user());
    }

    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();
        return response()->json(['message' => 'Đăng xuất thành công!']);
    }
}