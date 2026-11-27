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

        $base = $request->getSchemeAndHttpHost();
        $avatarUrl = $user->avatar
            ? (str_starts_with($user->avatar, 'http') ? $user->avatar : $base . '/' . ltrim($user->avatar, '/'))
            : null;

        return response()->json([
            'status'  => 'success',
            'message' => 'Đăng nhập thành công!',
            'token'   => $token,
            'user'    => [
                'ma_nguoi_dung' => $user->ma_nguoi_dung,
                'ho_va_ten'     => $user->ho_va_ten,
                'vai_tro'       => $user->vai_tro,
                'lop_don_vi'    => $user->lop_hoac_don_vi,
                'email_tvu'     => $user->email_tvu,
                'so_dien_thoai' => $user->so_dien_thoai,
                'avatar'        => $avatarUrl,
            ]
        ], 200);
    }

    public function me(Request $request)
    {
        $user = $request->user();
        $base = $request->getSchemeAndHttpHost();
        $user->avatar = $user->avatar
            ? (str_starts_with($user->avatar, 'http') ? $user->avatar : $base . '/' . ltrim($user->avatar, '/'))
            : null;
        return response()->json($user);
    }

    public function updateAvatar(Request $request)
    {
        $request->validate([
            'avatar' => 'required|image|mimes:jpeg,png,jpg,gif,webp|max:5120',
        ]);

        $user = $request->user();
        $file = $request->file('avatar');
        $dir = public_path('uploads/avatars');
        if (!file_exists($dir)) {
            mkdir($dir, 0777, true);
        }

        $filename = 'avatar_' . $user->ma_nguoi_dung . '_' . time() . '.' . $file->getClientOriginalExtension();
        $file->move($dir, $filename);

        $relativePath = 'uploads/avatars/' . $filename;
        $user->avatar = $relativePath;
        $user->save();

        $fullUrl = $request->getSchemeAndHttpHost() . '/' . $relativePath;

        return response()->json([
            'status'  => 'success',
            'message' => 'Cập nhật ảnh đại diện thành công!',
            'avatar'  => $fullUrl,
        ], 200);
    }

    public function changePassword(Request $request)
    {
        $request->validate([
            'old_password' => 'required|string',
            'new_password' => 'required|string|min:6',
        ]);

        $user = $request->user();
        if (!Hash::check($request->old_password, $user->mat_khau_ma_hoa)) {
            return response()->json([
                'status'  => 'error',
                'message' => 'Mật khẩu hiện tại không chính xác!'
            ], 422);
        }

        $user->mat_khau_ma_hoa = Hash::make($request->new_password);
        $user->save();

        return response()->json([
            'status'  => 'success',
            'message' => 'Đổi mật khẩu thành công!'
        ], 200);
    }

    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();
        return response()->json(['message' => 'Đăng xuất thành công!']);
    }
}