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
Route::post('/admin/users', [AdminController::class, 'addUser'])->name('admin.users.store');
Route::get('/admin/rooms/{id}/print', [AdminController::class, 'printRoomQr'])->name('admin.rooms.print');
