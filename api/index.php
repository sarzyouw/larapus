<?php
// Mengarahkan ke file autoload Laravel 5.3
require __DIR__ . '/../bootstrap/autoload.php';
// Mengarahkan ke bootstrap app
$app = require_once __DIR__ . '/../bootstrap/app.php';

$kernel = $app->make(Illuminate\Contracts\Http\Kernel::class);
$response = $kernel->handle(
    $request = Illuminate\Http\Request::capture()
);
$response->send();
$kernel->terminate($request, $response);