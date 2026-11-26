<?php

$publicPath = getcwd();

$uri = urldecode(
    parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH) ?? ''
);

// Xử lý preflight CORS OPTIONS
if (isset($_SERVER['REQUEST_METHOD']) && $_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    header('Access-Control-Allow-Origin: *');
    header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS');
    header('Access-Control-Allow-Headers: Origin, Content-Type, Accept, Authorization, X-Requested-With');
    header('Access-Control-Max-Age: 86400');
    exit(0);
}

// Phục vụ file tĩnh trong /storage với đầy đủ CORS header cho Flutter Web và Android emulator
if (str_starts_with($uri, '/storage/')) {
    $storageFile = dirname($publicPath) . '/storage/app/public' . substr($uri, 8);
    if (file_exists($storageFile) && !is_dir($storageFile)) {
        header('Access-Control-Allow-Origin: *');
        header('Access-Control-Allow-Methods: GET, HEAD, OPTIONS');
        header('Access-Control-Allow-Headers: *');
        $mime = mime_content_type($storageFile) ?: 'application/octet-stream';
        header('Content-Type: ' . $mime);
        header('Content-Length: ' . filesize($storageFile));
        if ($_SERVER['REQUEST_METHOD'] !== 'HEAD') {
            readfile($storageFile);
        }
        exit;
    }
}

// Giữ lại các file tĩnh thông thường trong public/
if ($uri !== '/' && file_exists($publicPath.$uri)) {
    return false;
}

require_once $publicPath.'/index.php';
