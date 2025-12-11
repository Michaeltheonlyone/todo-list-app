<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Accept");
header("Content-Type: application/json");

if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}
require_once("../config/db.php");

header("Content-Type: application/json");
$method = $_SERVER["REQUEST_METHOD"];

// GET all tasks
if ($method == "GET") {
    $stmt = $pdo->query("SELECT 
        id, 
        title, 
        COALESCE(description, '') as description,
        due_date as dueDate,
        COALESCE(priority, 1) as priority,
        COALESCE(status, 0) as status,
        created_at as createdAt,
        completed_at as completedAt,
        COALESCE(tags, '') as tags
    FROM tasks");
    
    $tasks = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    // Format for Dart
    foreach ($tasks as &$task) {
        $task['dueDate'] = $task['dueDate'] ? date('c', strtotime($task['dueDate'])) : null;
        $task['createdAt'] = date('c', strtotime($task['createdAt']));
        $task['completedAt'] = $task['completedAt'] ? date('c', strtotime($task['completedAt'])) : null;
        $task['tags'] = $task['tags'] ? explode(',', $task['tags']) : [];
        $task['priority'] = (int)$task['priority'];
        $task['status'] = (int)$task['status'];
    }
    
    echo json_encode($tasks);
    exit;
}

// POST create task
if ($method == "POST") {
    $input = json_decode(file_get_contents("php://input"), true);
    
    $stmt = $pdo->prepare("INSERT INTO tasks 
        (title, description, due_date, priority, status, tags) 
        VALUES (?, ?, ?, ?, ?, ?)");
    
    $stmt->execute([
        $input['title'] ?? '',
        $input['description'] ?? '',
        !empty($input['dueDate']) ? date('Y-m-d H:i:s', strtotime($input['dueDate'])) : null,
        $input['priority'] ?? 1,
        $input['status'] ?? 0,
        !empty($input['tags']) ? implode(',', $input['tags']) : ''
    ]);
    
    $id = $pdo->lastInsertId();
    $stmt = $pdo->prepare("SELECT * FROM tasks WHERE id=?");
    $stmt->execute([$id]);
    
    $task = $stmt->fetch(PDO::FETCH_ASSOC);
    
    // Format response properly
    $task['dueDate'] = $task['due_date'] ? date('c', strtotime($task['due_date'])) : null;
    $task['createdAt'] = date('c', strtotime($task['created_at']));
    $task['completedAt'] = $task['completed_at'] ? date('c', strtotime($task['completed_at'])) : null;
    $task['tags'] = $task['tags'] ? explode(',', $task['tags']) : [];
    $task['priority'] = (int)$task['priority'];
    $task['status'] = (int)$task['status'];
    unset($task['due_date'], $task['created_at'], $task['completed_at']);
    
    echo json_encode($task);
    exit;
}

// PUT update task
if ($method == "PUT") {
    $input = json_decode(file_get_contents("php://input"), true);
    
    $stmt = $pdo->prepare("UPDATE tasks SET 
        title=?, 
        description=?, 
        due_date=?, 
        priority=?, 
        status=?, 
        completed_at=?,
        tags=?
        WHERE id=?");
    
    $stmt->execute([
        $input['title'] ?? '',
        $input['description'] ?? '',
        !empty($input['dueDate']) ? date('Y-m-d H:i:s', strtotime($input['dueDate'])) : null,
        $input['priority'] ?? 1,
        $input['status'] ?? 0,
        $input['status'] == 2 ? date('Y-m-d H:i:s') : null,
        !empty($input['tags']) ? implode(',', $input['tags']) : '',
        $input['id']
    ]);
    
    echo json_encode(["message" => "Task updated", "id" => $input['id']]);
    exit;
}

// DELETE task
if ($method == "DELETE") {
    $id = $_GET["id"];
    
    $stmt = $pdo->prepare("DELETE FROM tasks WHERE id=?");
    $stmt->execute([$id]);
    
    echo json_encode(["message" => "Task deleted"]);
    exit;
}