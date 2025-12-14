<?php

// Function to load .env file
function loadEnv($path) {
    if (!file_exists($path)) {
        return;
    }
    $lines = file($path, FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
    foreach ($lines as $line) {
        if (strpos(trim($line), '#') === 0) continue;
        list($name, $value) = explode('=', $line, 2);
        $_SERVER[trim($name)] = trim($value);
    }
}

// Try to load .env from root (../../.env from here)
loadEnv(__DIR__ . '/../../.env');

// Defaults (XAMPP/MySQL defaults if no .env)
$type = $_SERVER['DB_CONNECTION'] ?? 'mysql';
$host = $_SERVER['DB_HOST'] ?? 'localhost';
$db_name = $_SERVER['DB_DATABASE'] ?? 'todo_app';
$username = $_SERVER['DB_USERNAME'] ?? 'root';
$password = $_SERVER['DB_PASSWORD'] ?? '';

try {
    if ($type === 'pgsql') {
        // PostgreSQL DSN
        $dsn = "pgsql:host=$host;dbname=$db_name";
    } else {
        // MySQL DSN (XAMPP Default)
        $dsn = "mysql:host=$host;dbname=$db_name;charset=utf8mb4";
    }

    $pdo = new PDO($dsn, $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
    if ($type === 'pgsql') {
        $pdo->exec("SET NAMES 'UTF8'");
    }

} catch (PDOException $e) {
    die(json_encode(["error" => "Connection failed: " . $e->getMessage()]));
}

