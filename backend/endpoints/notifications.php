<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, PUT, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Accept");
header("Content-Type: application/json");

if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}

require_once("../config/db.php");

$method = $_SERVER["REQUEST_METHOD"];

// GET unread notifications
if ($method == "GET") {
    $user_id = $_GET['user_id'] ?? 0;

    // --- AUTO-GENERATE NOTIFICATIONS FOR OVERDUE TASKS ---
    // 1. Find tasks that are not done (status != 2) AND overdue
    $taskStmt = $pdo->prepare("SELECT id, title, due_date FROM tasks WHERE user_id=? AND status != 2 AND due_date < NOW()");
    $taskStmt->execute([$user_id]);
    $overdueTasks = $taskStmt->fetchAll(PDO::FETCH_ASSOC);

    foreach ($overdueTasks as $task) {
        $notifTitle = "Tâche en retard ⚠️";
        $notifMsg = "Alerte : La tâche '" . $task['title'] . "' est en retard !";
        
        // 2. Check if we already notified this specific warning (simple check by title/message matching)
        // ideally we would link notification to task_id, but text matching works for MVP
        $checkStmt = $pdo->prepare("SELECT id FROM notifications WHERE user_id=? AND message LIKE ?");
        $checkStmt->execute([$user_id, $notifMsg]);
        
        if (!$checkStmt->fetch()) {
             // 3. Insert Notification
             $ins = $pdo->prepare("INSERT INTO notifications (user_id, title, message) VALUES (?, ?, ?)");
             $ins->execute([$user_id, $notifTitle, $notifMsg]);
        }
    }
    // -----------------------------------------------------

    $stmt = $pdo->prepare("SELECT * FROM notifications WHERE user_id = ? ORDER BY created_at DESC");
    $stmt->execute([$user_id]);
    $notifications = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo json_encode($notifications);
    exit;
}

// PUT mark as read
if ($method == "PUT") {
    $input = json_decode(file_get_contents("php://input"), true);
    $id = $input['id'] ?? 0;
    
    $stmt = $pdo->prepare("UPDATE notifications SET is_read = TRUE WHERE id = ?");
    $stmt->execute([$id]);
    
    echo json_encode(["message" => "Marked as read"]);
    exit;
}
