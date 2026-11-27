<?php

use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| Web Routes
|--------------------------------------------------------------------------
|
| Here is where you can register web routes for your application. These
| routes are loaded by the RouteServiceProvider and all of them will
| be assigned to the "web" middleware group. Make something great!
|
*/

use App\Http\Controllers\AdminController;

Route::get('/', function () {
    return redirect('/admin');
});

Route::get('/admin', [AdminController::class, 'index'])->name('admin.dashboard');
Route::post('/admin/incidents/{id}/status', [AdminController::class, 'updateStatus'])->name('admin.incidents.status');
Route::post('/admin/rooms', [AdminController::class, 'addRoom'])->name('admin.rooms.store');
Route::post('/admin/rooms/{id}/equipments', [AdminController::class, 'updateRoomEquipments'])->name('admin.rooms.equipments');
Route::post('/admin/rooms/{id}/toggle-status', [AdminController::class, 'toggleRoomStatus'])->name('admin.rooms.toggle');
Route::post('/admin/users', [AdminController::class, 'addUser'])->name('admin.users.store');
Route::get('/admin/rooms/{id}/print', [AdminController::class, 'printRoomQr'])->name('admin.rooms.print');
Route::get('/admin/reports/equipment-print', [AdminController::class, 'printEquipmentReport'])->name('admin.reports.equipment');

// Phục vụ file tĩnh kèm CORS header cho Flutter Web & Mobile
Route::get('/storage/{path}', function ($path) {
    $fullPath = storage_path('app/public/' . $path);
    if (!file_exists($fullPath)) {
        abort(404);
    }
    $mimeType = mime_content_type($fullPath) ?: 'application/octet-stream';
    return response()->file($fullPath, [
        'Content-Type' => $mimeType,
        'Access-Control-Allow-Origin' => '*',
        'Access-Control-Allow-Methods' => 'GET, HEAD, OPTIONS',
        'Access-Control-Allow-Headers' => '*',
    ]);
})->where('path', '.*');

