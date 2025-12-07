<?php
require_once("../config/db.php");

header("Content-Type: application/json");

$method = $_SERVER["REQUEST_METHOD"];

// ----- GET: récupérer toutes les sessions d'une tâche -----
if ($method == "GET") {
    $taskId = $_GET["taskId"];

    $stmt = $pdo->prepare("SELECT * FROM sessions WHERE task_id=?");
    $stmt->execute([$taskId]);

    echo json_encode($stmt->fetchAll(PDO::FETCH_ASSOC));
    exit;
}

// ----- POST: démarrer une session -----
if ($method == "POST") {
    $data = json_decode(file_get_contents("php://input"), true);

    $stmt = $pdo->prepare("INSERT INTO sessions (task_id, start_time) VALUES (?, NOW())");
    $stmt->execute([$data["taskId"]]);

    echo json_encode(["message" => "Session démarrée"]);
    exit;
}

// ----- PUT: terminer une session -----
if ($method == "PUT") {
    $data = json_decode(file_get_contents("php://input"), true);

    $stmt = $pdo->prepare("UPDATE sessions SET end_time=NOW() WHERE id=?");
    $stmt->execute([$data["id"]]);

    echo json_encode(["message" => "Session terminée"]);
    exit;
}
