<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Accept");
header("Content-Type: application/json");

if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}

header("Content-Type: application/json");
$method = $_SERVER["REQUEST_METHOD"];

// GET sessions for task
if ($method == "GET") {
    $taskId = $_GET["taskId"] ?? null;
    
    if (!$taskId) {
        echo json_encode([]);
        exit;
    }
    
    $stmt = $pdo->prepare("SELECT 
        id,
        task_id as taskId,
        start_time as startTime,
        end_time as endTime,
        COALESCE(duration_minutes, 25) as durationMinutes,
        COALESCE(type, 0) as type,
        COALESCE(status, 0) as status,
        COALESCE(notes, '') as notes
    FROM sessions WHERE task_id=?");
    
    $stmt->execute([$taskId]);
    $sessions = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    // Format dates for Dart
    foreach ($sessions as &$session) {
        $session['startTime'] = date('c', strtotime($session['startTime']));
        $session['endTime'] = $session['endTime'] ? date('c', strtotime($session['endTime'])) : null;
        $session['durationMinutes'] = (int)$session['durationMinutes'];
        $session['type'] = (int)$session['type'];
        $session['status'] = (int)$session['status'];
    }
    
    echo json_encode($sessions);
    exit;
}

// POST start session
if ($method == "POST") {
    $input = json_decode(file_get_contents("php://input"), true);
    
    if (!isset($input['taskId'])) {
        http_response_code(400);
        echo json_encode(["error" => "taskId required"]);
        exit;
    }
    
    $stmt = $pdo->prepare("INSERT INTO sessions 
        (task_id, start_time, duration_minutes, type, status, notes) 
        VALUES (?, NOW(), ?, ?, ?, ?)");
    
    $stmt->execute([
        $input['taskId'],
        $input['durationMinutes'] ?? 25,
        $input['type'] ?? 0,
        $input['status'] ?? 0,
        $input['notes'] ?? ''
    ]);
    
    $id = $pdo->lastInsertId();
    
    $stmt = $pdo->prepare("SELECT * FROM sessions WHERE id=?");
    $stmt->execute([$id]);
    
    $session = $stmt->fetch(PDO::FETCH_ASSOC);
    
    // Format response properly
    $session['taskId'] = $session['task_id'];
    $session['startTime'] = date('c', strtotime($session['start_time']));
    $session['endTime'] = $session['end_time'] ? date('c', strtotime($session['end_time'])) : null;
    $session['durationMinutes'] = (int)$session['duration_minutes'];
    $session['type'] = (int)$session['type'];
    $session['status'] = (int)$session['status'];
    unset($session['task_id'], $session['start_time'], $session['end_time'], $session['duration_minutes']);
    
    echo json_encode($session);
    exit;
}

// PUT end/update session
if ($method == "PUT") {
    $input = json_decode(file_get_contents("php://input"), true);
    
    if (!isset($input['id'])) {
        http_response_code(400);
        echo json_encode(["error" => "session id required"]);
        exit;
    }
    
    if (isset($input['endTime'])) {
        // End session
        $stmt = $pdo->prepare("UPDATE sessions SET end_time=NOW(), status=? WHERE id=?");
        $stmt->execute([2, $input['id']]);
    } else {
        // Update session
        $stmt = $pdo->prepare("UPDATE sessions SET 
            duration_minutes=?, 
            type=?, 
            status=?, 
            notes=?
            WHERE id=?");
        
        $stmt->execute([
            $input['durationMinutes'] ?? 25,
            $input['type'] ?? 0,
            $input['status'] ?? 0,
            $input['notes'] ?? '',
            $input['id']
        ]);
    }
    
    echo json_encode(["message" => "Session updated", "id" => $input['id']]);
    exit;
}