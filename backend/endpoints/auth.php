<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type, Accept");
header("Content-Type: application/json");

if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}

require_once("../config/db.php");

$input = json_decode(file_get_contents("php://input"), true);
$action = $input['action'] ?? '';

if ($action == 'register') {
    $username = $input['username'] ?? '';
    $email = $input['email'] ?? '';
    $password = $input['password'] ?? '';

    // Check if user exists
    $stmt = $pdo->prepare("SELECT id FROM users WHERE email = ?");
    $stmt->execute([$email]);
    if ($stmt->fetch()) {
        http_response_code(409);
        echo json_encode(['error' => 'Email already exists']);
        exit();
    }

    $hash = password_hash($password, PASSWORD_DEFAULT);
    
    $stmt = $pdo->prepare("INSERT INTO users (username, email, password) VALUES (?, ?, ?)");
    if ($stmt->execute([$username, $email, $hash])) {
        // Retrieve new user ID
        $newUserId = $pdo->lastInsertId();

        // Create Welcome Notification
        $notifStmt = $pdo->prepare("INSERT INTO notifications (user_id, title, message) VALUES (?, ?, ?)");
        $notifStmt->execute([
            $newUserId,
            "Bienvenue !",
            "Bienvenue sur TaskFlow, $username ! Organisez vos tâches dès maintenant."
        ]);

        http_response_code(201);
        echo json_encode(['message' => 'User created']);
    } else {
        http_response_code(500);
        echo json_encode(['error' => 'Creation failed']);
    }
} 
elseif ($action == 'login') {
    $email = $input['email'] ?? '';
    $password = $input['password'] ?? '';

    $stmt = $pdo->prepare("SELECT id, username, password FROM users WHERE email = ?");
    $stmt->execute([$email]);
    $user = $stmt->fetch(PDO::FETCH_ASSOC);

    if ($user && password_verify($password, $user['password'])) {
        echo json_encode([
            'user_id' => $user['id'],
            'username' => $user['username']
        ]);
    } else {
        http_response_code(401);
        echo json_encode(['error' => 'Invalid credentials']);
    }
} elseif ($action == 'update_profile') {
    $userId = $input['user_id'] ?? '';
    $username = $input['username'] ?? '';
    $password = $input['password'] ?? '';

    if (empty($userId) || empty($username)) {
        http_response_code(400);
        echo json_encode(['error' => 'Missing data']);
        exit();
    }

    $sql = "UPDATE users SET username = ?";
    $params = [$username];

    if (!empty($password)) {
        $sql .= ", password = ?";
        $params[] = password_hash($password, PASSWORD_DEFAULT);
    }

    $sql .= " WHERE id = ?";
    $params[] = $userId;

    $stmt = $pdo->prepare($sql);
    if ($stmt->execute($params)) {
        echo json_encode(['message' => 'Profile updated']);
    } else {
        http_response_code(500);
        echo json_encode(['error' => 'Update failed']);
    }
} else {
    http_response_code(400);
    echo json_encode(['error' => 'Invalid action']);
}
