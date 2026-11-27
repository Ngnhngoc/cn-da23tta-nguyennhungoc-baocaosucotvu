<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\IncidentController;

// 1. Tuyến đường công khai (Không cần token)
Route::post('/login', [AuthController::class, 'login'])->name('login');

// 2. Tuyến đường yêu cầu xác thực Bearer Token (Sanctum)
Route::middleware('auth:sanctum')->group(function () {
    // Thông tin người dùng hiện tại, Đổi Avatar, Đổi Mật khẩu & Đăng xuất
    Route::get('/me', [AuthController::class, 'me']);
    Route::post('/profile/avatar', [AuthController::class, 'updateAvatar']);
    Route::post('/profile/change-password', [AuthController::class, 'changePassword']);
    Route::post('/logout', [AuthController::class, 'logout']);

    // Quét mã QR phòng học để lấy thông tin thiết bị
    Route::get('/room/{qr_code}', [IncidentController::class, 'getRoomInfo']);

    // Danh sách phòng học & Danh mục sự cố
    Route::get('/rooms', [IncidentController::class, 'getRooms']);
    Route::get('/incident-types', [IncidentController::class, 'getIncidentTypes']);

    // Báo cáo sự cố mới
    Route::post('/incidents', [IncidentController::class, 'store']);

    // Xem danh sách sự cố cá nhân đã gửi (GV / SV)
    Route::get('/my-incidents', [IncidentController::class, 'myIncidents']);

    // Admin & KTV: Xem toàn bộ sự cố (hoặc theo bộ lọc)
    Route::get('/all-incidents', [IncidentController::class, 'getAllIncidents']);

    // Admin: Danh sách kỹ thuật viên & Phân công
    Route::get('/technicians', [IncidentController::class, 'getTechnicians']);
    Route::post('/incidents/{id}/assign', [IncidentController::class, 'assignTechnician']);

    // Kỹ thuật viên: Cập nhật tiến độ & Nghiệm thu
    Route::post('/incidents/{id}/update-status', [IncidentController::class, 'updateStatus']);

    // Thống kê tổng quan
    Route::get('/stats', [IncidentController::class, 'getStats']);

    // Admin Quản trị: Khu (Khuôn viên), Tòa nhà (Dãy nhà)
    Route::get('/admin/campuses', [\App\Http\Controllers\AdminController::class, 'getCampuses']);
    Route::post('/admin/campuses', [\App\Http\Controllers\AdminController::class, 'addCampus']);
    Route::put('/admin/campuses/{id}', [\App\Http\Controllers\AdminController::class, 'updateCampus']);
    Route::post('/admin/campuses/{id}/toggle-status', [\App\Http\Controllers\AdminController::class, 'toggleCampusStatus']);
    Route::delete('/admin/campuses/{id}', [\App\Http\Controllers\AdminController::class, 'deleteCampus']);

    Route::get('/admin/buildings', [\App\Http\Controllers\AdminController::class, 'getBuildings']);
    Route::post('/admin/buildings', [\App\Http\Controllers\AdminController::class, 'addBuilding']);
    Route::put('/admin/buildings/{id}', [\App\Http\Controllers\AdminController::class, 'updateBuilding']);
    Route::post('/admin/buildings/{id}/toggle-status', [\App\Http\Controllers\AdminController::class, 'toggleBuildingStatus']);
    Route::delete('/admin/buildings/{id}', [\App\Http\Controllers\AdminController::class, 'deleteBuilding']);

    // Admin Quản trị: Thêm phòng & Tạo mã QR, Thêm thiết bị, Xóa phòng, Bật/Tắt ẩn phòng, Thêm người dùng
    Route::post('/admin/rooms', [\App\Http\Controllers\AdminController::class, 'addRoom']);
    Route::delete('/admin/rooms/{id}', [\App\Http\Controllers\AdminController::class, 'deleteRoom']);
    Route::post('/admin/rooms/{id}/equipments', [\App\Http\Controllers\AdminController::class, 'updateRoomEquipments']);
    Route::post('/admin/rooms/{id}/toggle-status', [\App\Http\Controllers\AdminController::class, 'toggleRoomStatus']);
    // Admin Quản trị: Người dùng (Thêm, Xóa, Sửa, Đặt lại mật khẩu, Lấy danh sách)
    Route::get('/admin/users', [\App\Http\Controllers\AdminController::class, 'getUsers']);
    Route::post('/admin/users', [\App\Http\Controllers\AdminController::class, 'addUser']);
    Route::put('/admin/users/{id}', [\App\Http\Controllers\AdminController::class, 'updateUser']);
    Route::post('/admin/users/{id}/reset-password', [\App\Http\Controllers\AdminController::class, 'resetPassword']);
    Route::delete('/admin/users/{id}', [\App\Http\Controllers\AdminController::class, 'deleteUser']);
    Route::get('/admin/reports/equipment-print', [\App\Http\Controllers\AdminController::class, 'printEquipmentReport']);

    // Vòng đời thiết bị, Lịch sử sửa chữa & Bảo trì định kỳ
    Route::get('/rooms/{id}/equipments', [\App\Http\Controllers\EquipmentController::class, 'getRoomEquipments']);
    Route::post('/equipments', [\App\Http\Controllers\EquipmentController::class, 'store']);
    Route::post('/equipments/{id}/maintenance', [\App\Http\Controllers\EquipmentController::class, 'addMaintenance']);
    Route::get('/equipments/maintenance-due', [\App\Http\Controllers\EquipmentController::class, 'getMaintenanceDue']);
});