<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>In Mã QR - {{ $room->so_phong_day_du ?? 'Phòng ' . $room->so_phong }}</title>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            margin: 0;
            padding: 30px;
            background: #f1f5f9;
            display: flex;
            flex-direction: column;
            align-items: center;
        }
        .no-print {
            margin-bottom: 24px;
            display: flex;
            gap: 12px;
        }
        .btn-print {
            background: #0D47A1;
            color: white;
            border: none;
            padding: 12px 28px;
            font-size: 15px;
            font-weight: bold;
            border-radius: 8px;
            cursor: pointer;
            box-shadow: 0 2px 8px rgba(13, 71, 161, 0.3);
            display: inline-flex;
            align-items: center;
            gap: 8px;
        }
        .btn-print:hover {
            background: #1565C0;
        }
        .badge-card {
            width: 340px;
            background: white;
            border: 3.5px solid #0D47A1;
            border-radius: 18px;
            padding: 24px;
            text-align: center;
            box-shadow: 0 10px 25px rgba(0,0,0,0.08);
            box-sizing: border-box;
        }
        .header {
            border-bottom: 2px solid #0D47A1;
            padding-bottom: 12px;
            margin-bottom: 16px;
        }
        .header h3 {
            margin: 0;
            color: #0D47A1;
            font-size: 15px;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            font-weight: 800;
        }
        .header p {
            margin: 4px 0 0 0;
            color: #475569;
            font-size: 11px;
            font-weight: bold;
            text-transform: uppercase;
        }
        .qr-img {
            width: 220px;
            height: 220px;
            margin: 0 auto;
            display: block;
            border: 2px solid #e2e8f0;
            border-radius: 10px;
            padding: 6px;
            background: white;
        }
        .qr-code-text {
            font-family: monospace;
            font-size: 18px;
            font-weight: bold;
            color: #0D47A1;
            margin: 12px 0 6px 0;
            letter-spacing: 1.5px;
        }
        .room-title {
            font-size: 22px;
            font-weight: 900;
            color: #0f172a;
            margin: 4px 0 2px 0;
        }
        .room-subtitle {
            font-size: 13.5px;
            color: #334155;
            margin: 0 0 14px 0;
            font-weight: bold;
        }
        .equipment-box {
            background: #f8fafc;
            border: 1px solid #e2e8f0;
            border-radius: 8px;
            padding: 8px 10px;
            margin-bottom: 12px;
            font-size: 11px;
            color: #475569;
            text-align: left;
            line-height: 1.5;
        }
        .footer-note {
            background: #eff6ff;
            border-radius: 8px;
            padding: 8px 12px;
            border: 1px dashed #93c5fd;
        }
        .footer-note p {
            margin: 0;
            font-size: 11.5px;
            color: #1e40af;
            font-weight: bold;
            line-height: 1.4;
        }
        @media print {
            body {
                background: white;
                padding: 0;
            }
            .no-print {
                display: none !important;
            }
            .badge-card {
                box-shadow: none !important;
                page-break-inside: avoid;
                border: 3.5px solid #0D47A1 !important;
                margin: 0 auto;
            }
        }
    </style>
</head>
<body>
    <div class="no-print">
        <button class="btn-print" onclick="window.print()">🖨️ Bấm Vào Đây Để In Bảng Mã QR (Ctrl + P)</button>
    </div>

    <div class="badge-card">
        <div class="header">
            <h3>Trường Đại Học Trà Vinh</h3>
            <p>Ban Quản Lý Cơ Sở Vật Chất</p>
        </div>

        <img class="qr-img" src="https://api.qrserver.com/v1/create-qr-code/?size=300x300&data={{ $room->ma_qr_dinh_danh }}" alt="{{ $room->ma_qr_dinh_danh }}">
        
        <div class="qr-code-text">{{ $room->ma_qr_dinh_danh }}</div>
        <div class="room-title">Phòng {{ $room->so_phong_day_du ?? 'B21.' . $room->so_phong }}</div>
        <div class="room-subtitle">{{ $room->ten_khu ?? 'Tòa B' }} • Tầng {{ $room->tang_so }}</div>

        <div class="equipment-box">
            📦 <strong>Trang bị:</strong> {{ $room->so_may_lanh }} máy lạnh, {{ $room->so_quat }} quạt, {{ $room->so_tivi }} TV/chiếu@if(($room->so_may_tinh ?? 0) > 0), {{ $room->so_may_tinh }} máy tính, {{ $room->so_ban_phim }} phím, {{ $room->so_cpu }} CPU, {{ $room->so_chuot }} chuột @endif
        </div>

        <div class="footer-note">
            <p>📷 Hướng Camera điện thoại vào mã QR để báo cáo sự cố cơ sở vật chất ngay lập tức</p>
        </div>
    </div>
</body>
</html>
