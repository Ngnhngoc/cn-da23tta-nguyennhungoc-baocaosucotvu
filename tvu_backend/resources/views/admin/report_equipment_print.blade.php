<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Báo Cáo Trang Thiết Bị CSVC - Trường Đại Học Trà Vinh</title>
    <style>
        body {
            font-family: 'Times New Roman', Times, serif;
            font-size: 13.5pt;
            line-height: 1.4;
            color: #000;
            margin: 0;
            padding: 20px 40px;
            background: #f8fafc;
        }

        .paper {
            max-width: 960px;
            margin: 0 auto;
            background: #fff;
            padding: 40px 50px;
            box-shadow: 0 4px 15px rgba(0,0,0,0.08);
            border-radius: 4px;
        }

        /* Thanh điều khiển trên cùng (Ẩn khi in / xuất PDF) */
        .no-print {
            max-width: 960px;
            margin: 0 auto 20px auto;
            padding: 14px 20px;
            background: #0D47A1;
            color: white;
            border-radius: 8px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            box-shadow: 0 4px 12px rgba(13, 71, 161, 0.25);
        }

        .no-print-btns {
            display: flex;
            gap: 10px;
        }

        .btn {
            border: none;
            padding: 9px 18px;
            font-size: 14px;
            font-weight: bold;
            border-radius: 6px;
            cursor: pointer;
            display: inline-flex;
            align-items: center;
            gap: 6px;
            font-family: 'Segoe UI', Tahoma, sans-serif;
            text-decoration: none;
        }

        .btn-pdf {
            background: #ef4444;
            color: white;
        }
        .btn-pdf:hover { background: #dc2626; }

        .btn-close {
            background: rgba(255, 255, 255, 0.2);
            color: white;
        }
        .btn-close:hover { background: rgba(255, 255, 255, 0.3); }

        /* Tiêu ngữ & Quốc hiệu */
        .header-table {
            width: 100%;
            border-collapse: collapse;
            margin-bottom: 25px;
        }
        .header-table td {
            vertical-align: top;
            padding: 0;
            font-size: 12.5pt;
        }
        .text-center { text-align: center; }
        .text-left { text-align: left; }
        .text-right { text-align: right; }
        .font-bold { font-weight: bold; }
        .uppercase { text-transform: uppercase; }

        .line-under {
            display: inline-block;
            border-bottom: 1.5px solid #000;
            padding-bottom: 2px;
            margin-top: 2px;
        }

        /* Tiêu đề báo cáo */
        .report-title-box {
            text-align: center;
            margin: 25px 0 20px 0;
        }
        .report-title {
            font-size: 16.5pt;
            font-weight: bold;
            text-transform: uppercase;
            margin: 0 0 6px 0;
            color: #0D47A1;
        }
        .report-subtitle {
            font-size: 12.5pt;
            font-style: italic;
            margin: 0;
            color: #334155;
        }

        /* Bảng dữ liệu */
        .data-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 15px;
            margin-bottom: 20px;
        }
        .data-table th, .data-table td {
            border: 1px solid #000;
            padding: 7px 8px;
            font-size: 11.5pt;
            text-align: center;
        }
        .data-table th {
            background-color: #f1f5f9;
            font-weight: bold;
        }
        .data-table td.align-left {
            text-align: left;
        }
        .data-table tr.total-row {
            background-color: #fef3c7;
            font-weight: bold;
        }

        .section-title {
            font-size: 13pt;
            font-weight: bold;
            text-transform: uppercase;
            margin-top: 25px;
            margin-bottom: 8px;
            color: #0f172a;
        }

        /* Phần chữ ký */
        .signature-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 35px;
            page-break-inside: avoid;
        }
        .signature-table td {
            width: 33.33%;
            text-align: center;
            vertical-align: top;
            font-size: 12pt;
        }
        .sig-title {
            font-weight: bold;
            text-transform: uppercase;
            margin-bottom: 4px;
        }
        .sig-subtitle {
            font-style: italic;
            font-size: 11pt;
            color: #475569;
        }
        .sig-space {
            height: 75px;
        }
        .sig-name {
            font-weight: bold;
        }

        /* Tối ưu hóa khi In / Xuất PDF (A4) */
        @media print {
            body {
                background: white;
                padding: 0;
            }
            .paper {
                box-shadow: none;
                padding: 0;
                max-width: 100%;
            }
            .no-print {
                display: none !important;
            }
            @page {
                size: A4 portrait;
                margin: 15mm 15mm 15mm 15mm;
            }
            .data-table th {
                background-color: #f1f5f9 !important;
                -webkit-print-color-adjust: exact;
                print-color-adjust: exact;
            }
            .data-table tr.total-row {
                background-color: #fef3c7 !important;
                -webkit-print-color-adjust: exact;
                print-color-adjust: exact;
            }
            .report-title {
                color: #000 !important;
            }
        }
    </style>
</head>
<body>

    <!-- THANH ĐIỀU KHIỂN (ẨN KHI IN / XUẤT PDF) -->
    <div class="no-print">
        <div>
            <div style="font-size: 16px; font-weight: bold; display: flex; align-items: center; gap: 8px;">
                <span>📄</span> BÁO CÁO TRANG THIẾT BỊ PHÒNG HỌC TVU
            </div>
            <div style="font-size: 12px; opacity: 0.9; margin-top: 2px;">
                Chọn máy in đích là <b>"Lưu dưới dạng PDF" (Save as PDF)</b> để lưu file PDF về máy tính/điện thoại.
            </div>
        </div>
        <div class="no-print-btns">
            <button class="btn btn-pdf" onclick="window.print()">
                <span>🖨️</span> Xuất File Báo Cáo PDF / In
            </button>
            <button class="btn btn-close" onclick="window.close()">
                ✕ Đóng
            </button>
        </div>
    </div>

    <!-- KHỔ GIẤY BÁO CÁO CHÍNH THỨC -->
    <div class="paper">
        <!-- QUỐC HIỆU & TIÊU NGỮ -->
        <table class="header-table">
            <tr>
                <td style="width: 48%; text-align: center;">
                    <div class="uppercase" style="font-size: 11pt;">ỦY BAN NHÂN DÂN TỈNH TRÀ VINH</div>
                    <div class="font-bold uppercase" style="font-size: 11.5pt;">TRƯỜNG ĐẠI HỌC TRÀ VINH</div>
                    <div class="font-bold uppercase" style="font-size: 11pt;">BAN QUẢN LÝ CƠ SỞ VẬT CHẤT</div>
                    <div class="line-under" style="width: 140px;"></div>
                    <div style="font-size: 10.5pt; margin-top: 5px; font-style: italic;">
                        Số: {{ date('Ymd') }}/BC-BQLCSVC
                    </div>
                </td>
                <td style="width: 52%; text-align: center;">
                    <div class="font-bold uppercase" style="font-size: 11.5pt;">CỘNG HÒA XÃ HỘI CHỦ NGHĨA VIỆT NAM</div>
                    <div class="font-bold" style="font-size: 12pt;">Độc lập - Tự do - Hạnh phúc</div>
                    <div class="line-under" style="width: 180px;"></div>
                    <div style="font-size: 11pt; margin-top: 5px; font-style: italic;">
                        Trà Vinh, ngày {{ date('d') }} tháng {{ date('m') }} năm {{ date('Y') }}
                    </div>
                </td>
            </tr>
        </table>

        <!-- TIÊU ĐỀ BÁO CÁO -->
        <div class="report-title-box">
            <div class="report-title">BÁO CÁO THỐNG KÊ TRANG THIẾT BỊ PHÒNG HỌC</div>
            <div style="font-weight: bold; font-size: 13.5pt; text-transform: uppercase; margin-bottom: 4px;">
                THEO TỪNG TÒA NHÀ VÀ KHUÔN VIÊN
            </div>
            <div class="report-subtitle">
                (Dữ liệu cập nhật thời gian thực từ Hệ thống Giám sát & Quản trị CSVC TVU)
            </div>
        </div>

        <!-- BẢNG 1: BẢNG TỔNG HỢP THEO TÒA & KHU -->
        <div class="section-title">I. Bảng Tổng Hợp Thiết Bị Theo Từng Tòa Nhà & Khuôn Viên:</div>
        <table class="data-table">
            <thead>
                <tr>
                    <th style="width: 35px;">STT</th>
                    <th style="text-align: left;">Tòa Nhà & Khuôn Viên</th>
                    <th style="width: 65px;">Số Phòng</th>
                    <th style="width: 55px;">PC</th>
                    <th style="width: 55px;">CPU</th>
                    <th style="width: 55px;">Phím</th>
                    <th style="width: 55px;">Chuột</th>
                    <th style="width: 60px;">M.Lạnh</th>
                    <th style="width: 55px;">Quạt</th>
                    <th style="width: 55px;">TV/Chiếu</th>
                </tr>
            </thead>
            <tbody>
                @php $index = 1; @endphp
                @foreach($grouped as $key => $item)
                    <tr>
                        <td>{{ $index++ }}</td>
                        <td class="align-left font-bold">{{ $item['building_name'] }} <span style="font-weight: normal; color: #475569;">({{ $item['campus_name'] }})</span></td>
                        <td class="font-bold">{{ $item['rooms_count'] }} phòng</td>
                        <td style="{{ $item['pc'] > 0 ? 'font-weight: bold; color: #0D47A1;' : 'color: #94a3b8;' }}">{{ $item['pc'] > 0 ? $item['pc'] : '-' }}</td>
                        <td style="{{ $item['cpu'] > 0 ? 'font-weight: bold;' : 'color: #94a3b8;' }}">{{ $item['cpu'] > 0 ? $item['cpu'] : '-' }}</td>
                        <td style="{{ $item['kb'] > 0 ? 'font-weight: bold;' : 'color: #94a3b8;' }}">{{ $item['kb'] > 0 ? $item['kb'] : '-' }}</td>
                        <td style="{{ $item['mouse'] > 0 ? 'font-weight: bold;' : 'color: #94a3b8;' }}">{{ $item['mouse'] > 0 ? $item['mouse'] : '-' }}</td>
                        <td class="font-bold">{{ $item['ac'] }}</td>
                        <td class="font-bold">{{ $item['fan'] }}</td>
                        <td class="font-bold">{{ $item['tv'] }}</td>
                    </tr>
                @endforeach
                <!-- DÒNG TỔNG CỘNG TOÀN TRƯỜNG -->
                <tr class="total-row">
                    <td colspan="2" class="align-left uppercase font-bold" style="text-align: center; font-size: 12pt;">
                        TỔNG CỘNG TOÀN TRƯỜNG
                    </td>
                    <td>{{ $totals['total_rooms'] }} phòng</td>
                    <td style="color: #0D47A1; font-size: 12pt;">{{ $totals['total_pc'] }}</td>
                    <td>{{ $totals['total_cpu'] }}</td>
                    <td>{{ $totals['total_kb'] }}</td>
                    <td>{{ $totals['total_mouse'] }}</td>
                    <td>{{ $totals['total_ac'] }}</td>
                    <td>{{ $totals['total_fan'] }}</td>
                    <td>{{ $totals['total_tv'] }}</td>
                </tr>
            </tbody>
        </table>

        <!-- BẢNG 2: DANH MỤC CHI TIẾT TỪNG PHÒNG HỌC -->
        <div class="section-title" style="margin-top: 30px;">II. Danh Mục Chi Tiết Từng Phòng Học & Mã Định Danh QR:</div>
        <table class="data-table">
            <thead>
                <tr>
                    <th style="width: 35px;">STT</th>
                    <th style="width: 80px;">Số Phòng</th>
                    <th style="text-align: left;">Vị Trí & Tòa Nhà</th>
                    <th style="width: 105px;">Loại Phòng</th>
                    <th style="width: 110px;">Mã QR Gán</th>
                    <th>Trang Thiết Bị Bố Trí Thực Tế</th>
                    <th style="width: 90px;">Trạng Thái</th>
                </tr>
            </thead>
            <tbody>
                @php $rIdx = 1; @endphp
                @foreach($rooms as $r)
                    <tr>
                        <td>{{ $rIdx++ }}</td>
                        <td class="font-bold" style="color: #0D47A1;">{{ $r->so_phong_day_du ?? 'Phòng ' . $r->so_phong }}</td>
                        <td class="align-left">
                            {{ $r->dayNha ? $r->dayNha->ten_day_nha : 'Tòa ' . ($r->ma_toa ?? 'B21') }} 
                            ({{ ($r->dayNha && $r->dayNha->khuonVien) ? $r->dayNha->khuonVien->ma_viet_tat : ($r->ten_khu ?? 'Khu I') }})
                            - Tầng {{ $r->tang_so ?? 1 }}
                        </td>
                        <td>{{ $r->loai_phong ?? 'Lý thuyết' }}</td>
                        <td style="font-family: monospace; font-size: 10.5pt; font-weight: bold;">
                            {{ $r->ma_qr_dinh_danh }}
                        </td>
                        <td class="align-left" style="font-size: 10.5pt;">
                            @if(($r->so_may_tinh ?? 0) > 0)
                                <b>{{ $r->so_may_tinh }}</b> Máy tính PC ({{ $r->so_cpu }} CPU, {{ $r->so_ban_phim }} Phím, {{ $r->so_chuot }} Chuột),
                            @endif
                            <b>{{ $r->so_may_lanh ?? 0 }}</b> Máy lạnh, 
                            <b>{{ $r->so_quat ?? 0 }}</b> Quạt, 
                            <b>{{ $r->so_tivi ?? 0 }}</b> TV, 
                            <b>{{ $r->so_ban_sinh_vien ?? 20 }}</b> Bàn SV
                        </td>
                        <td>
                            @if($r->dang_su_dung == 1)
                                <span style="color: #166534; font-weight: bold;">Đang sử dụng</span>
                            @else
                                <span style="color: #dc2626; font-weight: bold;">Tạm ngưng</span>
                            @endif
                        </td>
                    </tr>
                @endforeach
            </tbody>
        </table>

        <!-- GHI CHÚ BÁO CÁO -->
        <div style="font-style: italic; font-size: 11pt; color: #475569; margin-top: 15px;">
            * Ghi chú: Số liệu trang thiết bị được kiểm kê và cập nhật đồng bộ trực tiếp với cơ sở dữ liệu hệ thống báo cáo sự cố qua mã QR của Nhà trường.
        </div>

        <!-- PHẦN CHỮ KÝ PHÊ DUYỆT -->
        <table class="signature-table">
            <tr>
                <td>
                    <div class="sig-title">NGƯỜI LẬP BIỂU</div>
                    <div class="sig-subtitle">(Ký và ghi rõ họ tên)</div>
                    <div class="sig-space"></div>
                    <div class="sig-name">Ban Quản Lý CSVC</div>
                </td>
                <td>
                    <div class="sig-title">TRƯỞNG BAN QLCSVC</div>
                    <div class="sig-subtitle">(Ký, đóng dấu)</div>
                    <div class="sig-space"></div>
                    <div class="sig-name">ThS. Nguyễn Văn A</div>
                </td>
                <td>
                    <div class="sig-title">BAN GIÁM HIỆU</div>
                    <div class="sig-subtitle">(Phê duyệt)</div>
                    <div class="sig-space"></div>
                    <div class="sig-name">HIỆU TRƯỞNG</div>
                </td>
            </tr>
        </table>
    </div>

</body>
</html>
