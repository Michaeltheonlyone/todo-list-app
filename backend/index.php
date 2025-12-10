<?php

$endpoint = $_GET["endpoint"] ?? "";

switch ($endpoint) {
    case "tasks":
        require("endpoints/tasks.php");
        break;

    case "sessions":
        require("endpoints/sessions.php");
        break;

    default:
        echo json_encode(["error" => "Endpoint invalide"]);
        break;
}
