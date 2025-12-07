<?php
require_once("../config/db.php");

// Indique que la réponse sera en JSON
header("Content-Type: application/json");

// Récupère la méthode HTTP
$method = $_SERVER["REQUEST_METHOD"];

// ----- GET: récupérer toutes les tâches -----
if ($method == "GET") {
    $stmt = $pdo->query("SELECT * FROM tasks");
    echo json_encode($stmt->fetchAll(PDO::FETCH_ASSOC));
    exit;
}

// ----- POST: créer une nouvelle tâche -----
if ($method == "POST") {
    $data = json_decode(file_get_contents("php://input"), true);

    $stmt = $pdo->prepare("INSERT INTO tasks (title) VALUES (?)");
    $stmt->execute([$data["title"]]);

    echo json_encode(["message" => "Tâche créée"]);
    exit;
}

// ----- PUT: mettre à jour une tâche -----
if ($method == "PUT") {
    $data = json_decode(file_get_contents("php://input"), true);

    $stmt = $pdo->prepare("UPDATE tasks SET title=?, completed=? WHERE id=?");
    $stmt->execute([
        $data["title"],
        $data["completed"],
        $data["id"]
    ]);

    echo json_encode(["message" => "Tâche mise à jour"]);
    exit;
}

// ----- DELETE: supprimer une tâche -----
if ($method == "DELETE") {
    $id = $_GET["id"];

    $stmt = $pdo->prepare("DELETE FROM tasks WHERE id=?");
    $stmt->execute([$id]);

    echo json_encode(["message" => "Tâche supprimée"]);
    exit;
}
