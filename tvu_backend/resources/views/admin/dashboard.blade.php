<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Hệ Thống Báo Cáo Sự Cố TVU - Ban Quản Lý</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <style>
        body { font-family: 'Inter', sans-serif; }
    </style>
</head>
<body class="bg-slate-50 text-slate-800">

    <!-- Top Navbar -->
    <header class="bg-blue-900 text-white shadow-md sticky top-0 z-50">
        <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-3.5 flex flex-wrap justify-between items-center gap-4">
            <div class="flex items-center space-x-3">
                <div class="bg-white p-2 rounded-lg text-blue-900 shadow">
                    <i class="fa-solid fa-graduation-cap text-2xl"></i>
                </div>
                <div>
                    <h1 class="text-xl font-bold tracking-tight">ĐẠI HỌC TRÀ VINH (TVU)</h1>
                    <p class="text-xs text-blue-200">Cổng Quản Trị & Xử Lý Sự Cố Cơ Sở Vật Chất</p>
                </div>
            </div>

            <!-- Quick Action Buttons on Header -->
            <div class="flex items-center flex-wrap gap-2">
                <button onclick="document.getElementById('modalAddRoom').classList.remove('hidden')" class="px-3 py-1.5 bg-blue-700 hover:bg-blue-800 text-white rounded-lg text-xs font-semibold shadow flex items-center gap-1.5 transition">
                    <i class="fa-solid fa-plus-circle"></i> Thêm Phòng & Tạo QR
                </button>
                <button onclick="document.getElementById('modalAddUser').classList.remove('hidden')" class="px-3 py-1.5 bg-pink-700 hover:bg-pink-800 text-white rounded-lg text-xs font-semibold shadow flex items-center gap-1.5 transition">
                    <i class="fa-solid fa-user-plus"></i> Thêm GV / SV / KTV
                </button>
                <div class="text-right pl-3 border-l border-blue-800">
                    <p class="text-xs font-semibold">Ban Quản Lý</p>
                    <span class="inline-flex items-center px-2 py-0.5 rounded text-[10px] font-medium bg-emerald-400 text-blue-950 font-bold">Admin</span>
                </div>
                <!-- Nút Đăng Xuất -->
                <button onclick="handleLogout()" class="px-3 py-1.5 bg-red-600 hover:bg-red-700 text-white rounded-lg text-xs font-semibold shadow flex items-center gap-1.5 transition ml-1" title="Đăng xuất khỏi hệ thống">
                    <i class="fa-solid fa-right-from-bracket"></i> Đăng xuất
                </button>
            </div>
        </div>
    </header>

    <main class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        
        @if(session('success'))
            <div class="mb-6 p-4 bg-emerald-50 border-l-4 border-emerald-500 rounded-r-lg shadow-sm flex items-center justify-between">
                <div class="flex items-center space-x-3">
                    <i class="fa-solid fa-circle-check text-emerald-600 text-xl"></i>
                    <p class="text-emerald-800 font-medium">{{ session('success') }}</p>
                </div>
                <button onclick="this.parentElement.remove()" class="text-emerald-500 hover:text-emerald-700">
                    <i class="fa-solid fa-xmark"></i>
                </button>
            </div>
        @endif

        <!-- Stats Overview Cards -->
        <div class="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-5 mb-8">
            <div class="bg-white rounded-xl shadow-sm border border-slate-200 p-5 flex items-center justify-between">
                <div>
                    <p class="text-xs font-semibold text-slate-500 uppercase tracking-wider">Tổng Sự Cố</p>
                    <h3 class="text-3xl font-extrabold text-slate-900 mt-1">{{ $totalIncidents }}</h3>
                    <p class="text-xs text-slate-400 mt-1">Tất cả phiếu đã ghi nhận</p>
                </div>
                <div class="w-12 h-12 bg-blue-50 text-blue-600 rounded-xl flex items-center justify-center text-xl">
                    <i class="fa-solid fa-clipboard-list"></i>
                </div>
            </div>

            <div class="bg-white rounded-xl shadow-sm border border-slate-200 p-5 flex items-center justify-between">
                <div>
                    <p class="text-xs font-semibold text-amber-600 uppercase tracking-wider">Chờ Tiếp Nhận</p>
                    <h3 class="text-3xl font-extrabold text-amber-600 mt-1">{{ $pendingIncidents }}</h3>
                    <p class="text-xs text-slate-400 mt-1">Cần phân công KTV</p>
                </div>
                <div class="w-12 h-12 bg-amber-50 text-amber-600 rounded-xl flex items-center justify-center text-xl">
                    <i class="fa-solid fa-clock-rotate-left"></i>
                </div>
            </div>

            <div class="bg-white rounded-xl shadow-sm border border-slate-200 p-5 flex items-center justify-between">
                <div>
                    <p class="text-xs font-semibold text-blue-600 uppercase tracking-wider">Đang Xử Lý</p>
                    <h3 class="text-3xl font-extrabold text-blue-600 mt-1">{{ $processingIncidents }}</h3>
                    <p class="text-xs text-slate-400 mt-1">KTV đang khắc phục</p>
                </div>
                <div class="w-12 h-12 bg-blue-50 text-blue-600 rounded-xl flex items-center justify-center text-xl">
                    <i class="fa-solid fa-screwdriver-wrench"></i>
                </div>
            </div>

            <div class="bg-white rounded-xl shadow-sm border border-slate-200 p-5 flex items-center justify-between">
                <div>
                    <p class="text-xs font-semibold text-emerald-600 uppercase tracking-wider">Đã Hoàn Thành</p>
                    <h3 class="text-3xl font-extrabold text-emerald-600 mt-1">{{ $resolvedIncidents }}</h3>
                    <p class="text-xs text-slate-400 mt-1">Đã sửa xong & nghiệm thu</p>
                </div>
                <div class="w-12 h-12 bg-emerald-50 text-emerald-600 rounded-xl flex items-center justify-center text-xl">
                    <i class="fa-solid fa-circle-check"></i>
                </div>
            </div>
        </div>

        <!-- Section: Bảng Sự Cố -->
        <div class="bg-white rounded-xl shadow-sm border border-slate-200 overflow-hidden mb-8">
            <div class="px-6 py-4 border-b border-slate-200 bg-slate-50/50 flex justify-between items-center">
                <div>
                    <h2 class="text-lg font-bold text-slate-900">Danh Sách Báo Cáo Sự Cố Từ Mobile / Web</h2>
                    <p class="text-xs text-slate-500">Các báo cáo do sinh viên hoặc giảng viên gửi về hệ thống</p>
                </div>
                <span class="text-xs bg-blue-100 text-blue-800 font-semibold px-2.5 py-1 rounded-full">
                    {{ $incidents->count() }} phiếu
                </span>
            </div>

            <div class="overflow-x-auto">
                <table class="w-full text-left text-sm text-slate-600">
                    <thead class="bg-slate-100 text-slate-700 text-xs uppercase font-semibold">
                        <tr>
                            <th class="px-5 py-3">Mã Phiếu</th>
                            <th class="px-5 py-3">Phòng Học</th>
                            <th class="px-5 py-3">Nội Dung Hư Hỏng</th>
                            <th class="px-5 py-3">Người Báo Cáo</th>
                            <th class="px-5 py-3">KTV Phụ Trách</th>
                            <th class="px-5 py-3">Thời Gian</th>
                            <th class="px-5 py-3">Trạng Thái</th>
                            <th class="px-5 py-3 text-center">Thao Tác</th>
                        </tr>
                    </thead>
                    <tbody class="divide-y divide-slate-200">
                        @forelse($incidents as $ticket)
                        <tr class="hover:bg-slate-50/80 transition-colors">
                            <td class="px-5 py-4 font-mono font-bold text-blue-900 text-xs">
                                {{ $ticket->ma_phieu_su_co }}
                            </td>
                            <td class="px-5 py-4">
                                <span class="font-semibold text-slate-800">
                                    {{ $ticket->phongHoc ? 'Phòng ' . ($ticket->phongHoc->so_phong_day_du ?? 'B21.' . $ticket->phongHoc->so_phong) . ' (' . ($ticket->phongHoc->ten_khu ?? 'Tòa B') . ')' : 'Phòng #' . $ticket->ma_phong_hoc }}
                                </span>
                                @if($ticket->vi_tri_trong_phong)
                                    <p class="text-xs text-slate-400 mt-0.5"><i class="fa-solid fa-location-dot mr-1"></i>{{ $ticket->vi_tri_trong_phong }}</p>
                                @endif
                            </td>
                            <td class="px-5 py-4">
                                <p class="font-medium text-slate-900 max-w-xs">{{ $ticket->mo_ta_hu_hong }}</p>
                            </td>
                            <td class="px-5 py-4">
                                <p class="font-medium text-slate-800">{{ $ticket->nguoiBaoCao ? $ticket->nguoiBaoCao->ho_va_ten : 'Ẩn danh' }}</p>
                                <p class="text-xs text-slate-400">{{ $ticket->nguoiBaoCao ? $ticket->nguoiBaoCao->ten_dang_nhap . ' • ' . $ticket->nguoiBaoCao->vai_tro : '' }}</p>
                            </td>
                            <td class="px-5 py-4">
                                @if($ticket->kyThuatVien)
                                    <span class="text-xs font-semibold text-blue-900"><i class="fa-solid fa-wrench mr-1"></i>{{ $ticket->kyThuatVien->ho_va_ten }}</span>
                                    <p class="text-[11px] text-slate-400">{{ $ticket->kyThuatVien->so_dien_thoai }}</p>
                                @else
                                    <span class="text-xs text-slate-400 italic">Chưa phân công</span>
                                @endif
                            </td>
                            <td class="px-5 py-4 text-xs text-slate-500 whitespace-nowrap">
                                {{ date('d/m/Y H:i', strtotime($ticket->ngay_gui_bao_cao)) }}
                            </td>
                            <td class="px-5 py-4 whitespace-nowrap">
                                @if($ticket->trang_thai == 'Chờ tiếp nhận')
                                    <span class="inline-flex items-center px-2.5 py-1 rounded-full text-xs font-semibold bg-amber-100 text-amber-800">
                                        <i class="fa-regular fa-clock mr-1"></i> Chờ tiếp nhận
                                    </span>
                                @elseif($ticket->trang_thai == 'Đang xử lý')
                                    <span class="inline-flex items-center px-2.5 py-1 rounded-full text-xs font-semibold bg-blue-100 text-blue-800">
                                        <i class="fa-solid fa-wrench mr-1"></i> Đang xử lý
                                    </span>
                                @else
                                    <span class="inline-flex items-center px-2.5 py-1 rounded-full text-xs font-semibold bg-emerald-100 text-emerald-800">
                                        <i class="fa-solid fa-check mr-1"></i> Hoàn thành
                                    </span>
                                @endif
                            </td>
                            <td class="px-5 py-4 text-center whitespace-nowrap">
                                <form action="{{ url('/admin/incidents/' . $ticket->ma_su_co_id . '/status') }}" method="POST" class="inline-flex items-center space-x-1.5">
                                    @csrf
                                    <select name="trang_thai" class="text-xs border border-slate-300 rounded px-2 py-1 bg-white focus:outline-none focus:ring-1 focus:ring-blue-500">
                                        <option value="Chờ tiếp nhận" {{ $ticket->trang_thai == 'Chờ tiếp nhận' ? 'selected' : '' }}>Chờ tiếp nhận</option>
                                        <option value="Đang xử lý" {{ $ticket->trang_thai == 'Đang xử lý' ? 'selected' : '' }}>Đang xử lý</option>
                                        <option value="Hoàn thành" {{ $ticket->trang_thai == 'Hoàn thành' ? 'selected' : '' }}>Hoàn thành</option>
                                    </select>
                                    <button type="submit" class="px-2.5 py-1 bg-blue-700 hover:bg-blue-800 text-white rounded text-xs font-medium transition shadow-sm">
                                        Lưu
                                    </button>
                                </form>
                            </td>
                        </tr>
                        @empty
                        <tr>
                            <td colspan="8" class="px-6 py-10 text-center text-slate-400">
                                <i class="fa-regular fa-folder-open text-4xl mb-2 text-slate-300 block"></i>
                                Chưa có báo cáo sự cố nào trong hệ thống.
                            </td>
                        </tr>
                        @endforelse
                    </tbody>
                </table>
            </div>
        </div>

        <!-- Section: Danh Sách Phòng Học & Mã QR & Cập Nhật Thiết Bị -->
        <div class="bg-white rounded-xl shadow-sm border border-slate-200 p-6 mb-8">
            <div class="flex justify-between items-center mb-6 pb-3 border-b border-slate-200">
                <div>
                    <h3 class="text-lg font-bold text-slate-900 flex items-center">
                        <i class="fa-solid fa-door-open text-blue-600 mr-2"></i> Quản Lý Phòng Học, Thiết Bị & Mã QR Định Danh
                    </h3>
                    <p class="text-xs text-slate-500">Mã QR chính xác được gắn cố định tại từng phòng học TVU</p>
                </div>
                <button onclick="document.getElementById('modalAddRoom').classList.remove('hidden')" class="px-3 py-1.5 bg-blue-600 hover:bg-blue-700 text-white text-xs font-semibold rounded-lg shadow flex items-center gap-1">
                    <i class="fa-solid fa-plus"></i> Thêm Phòng Học Mới
                </button>
            </div>

            <div class="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-5">
                @foreach($rooms as $r)
                <div class="p-4 bg-slate-50 border border-slate-200 rounded-xl flex flex-col justify-between hover:shadow-md transition">
                    <div class="flex items-start space-x-3.5">
                        <div class="bg-white p-1.5 rounded-lg border border-slate-300 shadow-sm shrink-0 text-center">
                            <img src="https://api.qrserver.com/v1/create-qr-code/?size=120x120&data={{ $r->ma_qr_dinh_danh }}" alt="QR {{ $r->so_phong }}" class="w-20 h-20">
                            <a href="https://api.qrserver.com/v1/create-qr-code/?size=350x350&data={{ $r->ma_qr_dinh_danh }}" target="_blank" class="text-[10px] text-blue-600 hover:underline mt-1 block font-semibold">
                                <i class="fa-solid fa-arrow-up-right-from-square"></i> In QR
                            </a>
                        </div>
                        <div class="flex-1">
                            <p class="font-bold text-slate-900 text-base">Phòng {{ $r->so_phong_day_du ?? 'B21.' . $r->so_phong }}</p>
                            <p class="text-xs text-slate-500">Tòa: <span class="font-semibold text-slate-700">{{ $r->ten_khu ?? 'Tòa B' }}</span> • Tầng {{ $r->tang_so }}</p>
                            <div class="mt-2 text-xs text-slate-700 bg-white p-2 rounded border border-slate-200 space-y-0.5">
                                <p><i class="fa-solid fa-snowflake text-cyan-600 w-4"></i> Máy lạnh: <strong>{{ $r->so_may_lanh }}</strong></p>
                                <p><i class="fa-solid fa-fan text-blue-600 w-4"></i> Quạt: <strong>{{ $r->so_quat }}</strong></p>
                                <p><i class="fa-solid fa-tv text-purple-600 w-4"></i> TV / Chiếu: <strong>{{ $r->so_tivi }}</strong></p>
                                @if(($r->so_may_tinh ?? 0) > 0)
                                <p><i class="fa-solid fa-desktop text-indigo-600 w-4"></i> Máy tính: <strong>{{ $r->so_may_tinh }}</strong> • CPU: <strong>{{ $r->so_cpu }}</strong></p>
                                <p><i class="fa-solid fa-keyboard text-slate-600 w-4"></i> Bàn phím: <strong>{{ $r->so_ban_phim }}</strong> • Chuột: <strong>{{ $r->so_chuot }}</strong></p>
                                @endif
                            </div>
                        </div>
                    </div>

                    <div class="mt-3 pt-3 border-t border-slate-200 flex justify-between items-center">
                        <span class="font-mono text-xs font-bold bg-blue-100 text-blue-900 px-2 py-0.5 rounded">
                            {{ $r->ma_qr_dinh_danh }}
                        </span>
                        <button onclick="openEditEquipmentModal({{ $r->ma_phong_hoc }}, '{{ $r->so_phong }}', {{ $r->so_may_lanh }}, {{ $r->so_quat }}, {{ $r->so_tivi }}, {{ $r->so_may_tinh ?? 0 }}, {{ $r->so_ban_phim ?? 0 }}, {{ $r->so_cpu ?? 0 }}, {{ $r->so_chuot ?? 0 }})" class="text-xs text-blue-700 font-semibold hover:underline">
                            <i class="fa-solid fa-pen-to-square"></i> Sửa thiết bị
                        </button>
                    </div>
                </div>
                @endforeach
            </div>
        </div>

    </main>

    <!-- MODAL 1: THÊM PHÒNG & TẠO MÃ QR -->
    <div id="modalAddRoom" class="fixed inset-0 bg-black/50 z-50 flex items-center justify-center p-4 hidden">
        <div class="bg-white rounded-xl shadow-xl max-w-md w-full p-6 relative">
            <h3 class="text-lg font-bold text-slate-900 mb-4 flex items-center">
                <i class="fa-solid fa-door-open text-blue-600 mr-2"></i> Thêm Phòng Học & Tạo Mã QR
            </h3>
            <form action="{{ route('admin.rooms.store') }}" method="POST">
                @csrf
                <div class="space-y-4 text-sm">
                    <div>
                        <label class="block font-semibold mb-1">Số phòng (Nhập dạng B21.101, B21.103, A11.201...) *</label>
                        <input type="text" name="so_phong" required placeholder="B21.101" class="w-full border border-slate-300 rounded-lg p-2.5 focus:ring-1 focus:ring-blue-500 font-semibold text-blue-900">
                        <p class="text-[11px] text-slate-500 mt-1">💡 Hệ thống sẽ tự động tạo Mã QR chuẩn: <strong>TVU-B21-101</strong></p>
                    </div>
                    <div class="grid grid-cols-2 gap-3">
                        <div>
                            <label class="block font-semibold mb-1">Tầng số (Tùy chọn)</label>
                            <input type="number" name="tang_so" placeholder="Tự suy từ số phòng" min="1" max="10" class="w-full border border-slate-300 rounded-lg p-2.5">
                        </div>
                        <div>
                            <label class="block font-semibold mb-1">Loại phòng</label>
                            <select name="loai_phong" class="w-full border border-slate-300 rounded-lg p-2.5 bg-white">
                                <option value="Lý thuyết">Lý thuyết</option>
                                <option value="Thực hành">Thực hành Máy tính</option>
                                <option value="Hội trường">Hội trường</option>
                            </select>
                        </div>
                    </div>
                    <div class="border-t border-slate-200 pt-3">
                        <p class="font-semibold mb-2">Trang thiết bị ban đầu trong phòng:</p>
                        <div class="grid grid-cols-3 gap-2">
                            <div>
                                <label class="text-xs text-slate-600">Số máy lạnh</label>
                                <input type="number" name="so_may_lanh" value="2" class="w-full border border-slate-300 rounded p-1.5 text-center">
                            </div>
                            <div>
                                <label class="text-xs text-slate-600">Số quạt</label>
                                <input type="number" name="so_quat" value="2" class="w-full border border-slate-300 rounded p-1.5 text-center">
                            </div>
                            <div>
                                <label class="text-xs text-slate-600">Số TV / Chiếu</label>
                                <input type="number" name="so_tivi" value="1" class="w-full border border-slate-300 rounded p-1.5 text-center">
                            </div>
                        </div>
                        <div class="grid grid-cols-2 gap-2 mt-2">
                            <div>
                                <label class="text-xs text-slate-600">Cổng HDMI</label>
                                <input type="number" name="so_cong_hdmi" value="1" class="w-full border border-slate-300 rounded p-1.5 text-center">
                            </div>
                            <div>
                                <label class="text-xs text-slate-600">Bảng viết</label>
                                <input type="number" name="so_bang_viet" value="1" class="w-full border border-slate-300 rounded p-1.5 text-center">
                            </div>
                        </div>
                        <div class="p-2 bg-blue-50 rounded border border-blue-200 mt-2 space-y-1">
                            <p class="font-bold text-xs text-blue-900"><i class="fa-solid fa-desktop mr-1"></i> Dành cho Phòng Thực Hành (Tùy chọn):</p>
                            <div class="grid grid-cols-2 gap-2">
                                <div>
                                    <label class="text-xs text-slate-600">Máy tính</label>
                                    <input type="number" name="so_may_tinh" value="0" class="w-full border border-slate-300 rounded p-1 text-center bg-white">
                                </div>
                                <div>
                                    <label class="text-xs text-slate-600">Bàn phím</label>
                                    <input type="number" name="so_ban_phim" value="0" class="w-full border border-slate-300 rounded p-1 text-center bg-white">
                                </div>
                                <div>
                                    <label class="text-xs text-slate-600">Thùng CPU</label>
                                    <input type="number" name="so_cpu" value="0" class="w-full border border-slate-300 rounded p-1 text-center bg-white">
                                </div>
                                <div>
                                    <label class="text-xs text-slate-600">Chuột</label>
                                    <input type="number" name="so_chuot" value="0" class="w-full border border-slate-300 rounded p-1 text-center bg-white">
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                <div class="mt-6 flex justify-end space-x-2">
                    <button type="button" onclick="document.getElementById('modalAddRoom').classList.add('hidden')" class="px-4 py-2 border border-slate-300 rounded-lg text-sm font-semibold hover:bg-slate-100">Hủy</button>
                    <button type="submit" class="px-4 py-2 bg-blue-700 hover:bg-blue-800 text-white rounded-lg text-sm font-semibold shadow">Tạo Phòng & Sinh Mã QR</button>
                </div>
            </form>
        </div>
    </div>

    <!-- MODAL 2: THÊM TÀI KHOẢN (GV, SV, KTV) -->
    <div id="modalAddUser" class="fixed inset-0 bg-black/50 z-50 flex items-center justify-center p-4 hidden">
        <div class="bg-white rounded-xl shadow-xl max-w-md w-full p-6 relative">
            <h3 class="text-lg font-bold text-slate-900 mb-4 flex items-center">
                <i class="fa-solid fa-user-plus text-pink-600 mr-2"></i> Thêm Tài Khoản (GV / SV / KTV)
            </h3>
            <form action="{{ route('admin.users.store') }}" method="POST">
                @csrf
                <div class="space-y-3.5 text-sm">
                    <div>
                        <label class="block font-semibold mb-1">Vai trò tài khoản *</label>
                        <select name="vai_tro" class="w-full border border-slate-300 rounded-lg p-2.5 bg-white font-medium">
                            <option value="Sinh viên">Sinh viên TVU</option>
                            <option value="Giảng viên">Giảng viên TVU</option>
                            <option value="Kỹ thuật viên">Kỹ thuật viên (KTV)</option>
                        </select>
                    </div>
                    <div>
                        <label class="block font-semibold mb-1">Tên đăng nhập (MSSV / Mã GV / Mã KTV) *</label>
                        <input type="text" name="ten_dang_nhap" required placeholder="VD: 110123035 hoặc gv002" class="w-full border border-slate-300 rounded-lg p-2.5">
                    </div>
                    <div>
                        <label class="block font-semibold mb-1">Họ và tên *</label>
                        <input type="text" name="ho_va_ten" required placeholder="Nguyễn Văn A" class="w-full border border-slate-300 rounded-lg p-2.5">
                    </div>
                    <div>
                        <label class="block font-semibold mb-1">Số điện thoại liên hệ</label>
                        <input type="text" name="so_dien_thoai" placeholder="0987654321" class="w-full border border-slate-300 rounded-lg p-2.5">
                    </div>
                    <div>
                        <label class="block font-semibold mb-1">Lớp học hoặc Đơn vị công tác</label>
                        <input type="text" name="lop_hoac_don_vi" value="Khoa CNTT - TVU" class="w-full border border-slate-300 rounded-lg p-2.5">
                    </div>
                    <p class="text-xs text-slate-400">Mật khẩu ban đầu mặc định: <strong>123456</strong></p>
                </div>
                <div class="mt-6 flex justify-end space-x-2">
                    <button type="button" onclick="document.getElementById('modalAddUser').classList.add('hidden')" class="px-4 py-2 border border-slate-300 rounded-lg text-sm font-semibold hover:bg-slate-100">Hủy</button>
                    <button type="submit" class="px-4 py-2 bg-pink-700 hover:bg-pink-800 text-white rounded-lg text-sm font-semibold shadow">Tạo Tài Khoản</button>
                </div>
            </form>
        </div>
    </div>

    <!-- MODAL 3: CẬP NHẬT THIẾT BỊ PHÒNG HỌC -->
    <div id="modalEditEquipment" class="fixed inset-0 bg-black/50 z-50 flex items-center justify-center p-4 hidden">
        <div class="bg-white rounded-xl shadow-xl max-w-sm w-full p-6 relative">
            <h3 class="text-lg font-bold text-slate-900 mb-4 flex items-center">
                <i class="fa-solid fa-screwdriver-wrench text-blue-600 mr-2"></i> Cập Nhật Thiết Bị Phòng <span id="editRoomName" class="ml-1 text-blue-800"></span>
            </h3>
            <form id="formEditEquipment" method="POST">
                @csrf
                <div class="space-y-3 text-sm">
                    <div>
                        <label class="block font-semibold mb-1">Số lượng Máy Lạnh</label>
                        <input type="number" id="editAc" name="so_may_lanh" min="0" class="w-full border border-slate-300 rounded-lg p-2 text-center">
                    </div>
                    <div>
                        <label class="block font-semibold mb-1">Số lượng Quạt</label>
                        <input type="number" id="editFan" name="so_quat" min="0" class="w-full border border-slate-300 rounded-lg p-2 text-center">
                    </div>
                    <div>
                        <label class="block font-semibold mb-1">Số lượng TV / Màn Chiếu</label>
                        <input type="number" id="editTv" name="so_tivi" min="0" class="w-full border border-slate-300 rounded-lg p-2 text-center">
                    </div>
                    <div class="p-3 bg-blue-50 rounded-lg border border-blue-200 mt-2 space-y-2">
                        <p class="font-bold text-xs text-blue-900"><i class="fa-solid fa-desktop mr-1"></i> Thiết bị Thực hành / Tin học</p>
                        <div class="grid grid-cols-2 gap-2">
                            <div>
                                <label class="text-xs text-slate-600">Số Máy tính / Màn</label>
                                <input type="number" id="editPc" name="so_may_tinh" min="0" class="w-full border border-slate-300 rounded p-1.5 text-center bg-white">
                            </div>
                            <div>
                                <label class="text-xs text-slate-600">Số Bàn phím</label>
                                <input type="number" id="editKb" name="so_ban_phim" min="0" class="w-full border border-slate-300 rounded p-1.5 text-center bg-white">
                            </div>
                            <div>
                                <label class="text-xs text-slate-600">Số Thùng CPU</label>
                                <input type="number" id="editCpu" name="so_cpu" min="0" class="w-full border border-slate-300 rounded p-1.5 text-center bg-white">
                            </div>
                            <div>
                                <label class="text-xs text-slate-600">Số Chuột</label>
                                <input type="number" id="editMouse" name="so_chuot" min="0" class="w-full border border-slate-300 rounded p-1.5 text-center bg-white">
                            </div>
                        </div>
                    </div>
                </div>
                <div class="mt-6 flex justify-end space-x-2">
                    <button type="button" onclick="document.getElementById('modalEditEquipment').classList.add('hidden')" class="px-4 py-2 border border-slate-300 rounded-lg text-sm font-semibold hover:bg-slate-100">Hủy</button>
                    <button type="submit" class="px-4 py-2 bg-blue-700 hover:bg-blue-800 text-white rounded-lg text-sm font-semibold shadow">Lưu Thiết Bị</button>
                </div>
            </form>
        </div>
    </div>

    <script>
        function handleLogout() {
            if (confirm('Bạn có chắc chắn muốn đăng xuất khỏi trang Quản trị TVU?')) {
                // Điều hướng về cổng đăng nhập chính của hệ thống (Flutter Web port 8088 hoặc trang chủ)
                window.location.href = 'http://' + window.location.hostname + ':8088';
            }
        }

        function openEditEquipmentModal(roomId, roomName, ac, fan, tv, pc = 0, kb = 0, cpu = 0, mouse = 0) {
            document.getElementById('editRoomName').innerText = roomName;
            document.getElementById('editAc').value = ac;
            document.getElementById('editFan').value = fan;
            document.getElementById('editTv').value = tv;
            document.getElementById('editPc').value = pc;
            document.getElementById('editKb').value = kb;
            document.getElementById('editCpu').value = cpu;
            document.getElementById('editMouse').value = mouse;
            document.getElementById('formEditEquipment').action = '/admin/rooms/' + roomId + '/equipments';
            document.getElementById('modalEditEquipment').classList.remove('hidden');
        }
    </script>

    <footer class="mt-12 py-6 border-t border-slate-200 text-center text-xs text-slate-400">
        Đồ Án Chuyên Ngành DA23TTA - Sinh viên: Nguyễn Như Ngọc - Trường Đại Học Trà Vinh (TVU)
    </footer>

</body>
</html>
