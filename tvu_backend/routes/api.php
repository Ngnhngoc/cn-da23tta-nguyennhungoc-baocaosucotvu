<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\IncidentController;

// 1. Tuyến đường công khai (Không cần token)
Route::post('/login', [AuthController::class, 'login']);

// 2. Tuyến đường yêu cầu xác thực Bearer Token (Sanctum)
Route::middleware('auth:sanctum')->group(function () {
    // Thông tin người dùng hiện tại & Đăng xuất
    Route::get('/me', [AuthController::class, 'me']);
    Route::post('/logout', [AuthController::class, 'logout']);

    // Quét mã QR phòng học để lấy thông tin thiết bị
    Route::get('/room/{qr_code}', [IncidentController::class, 'getRoomInfo']);

    // Báo cáo sự cố mới
    Route::post('/incidents', [IncidentController::class, 'store']);

    // Xem danh sách sự cố cá nhân đã gửi
    Route::get('/my-incidents', [IncidentController::class, 'myIncidents']);

    // Kỹ thuật viên cập nhật tiến độ (InProgress / Resolved)
    Route::post('/incidents/{id}/update-status', [IncidentController::class, 'updateStatus']);
});