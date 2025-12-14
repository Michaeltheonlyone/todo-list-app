<?php
// backend/migrate.php

require_once 'config/db.php';

echo "Début de la migration...\n";

$database = new Database();
$db = $database->getConnection();

try {
    $sql = file_get_contents('auth_update.sql');
    $sql .= file_get_contents('notifications.sql');
    
    // Split SQL by semicolon mostly works for simple scripts
    // or just run exec if the driver allows multiple statements.
    // PDO allows multiple statements in one exec() call usually.
    
    $driver = $db->getAttribute(PDO::ATTR_DRIVER_NAME);
    echo "Driver detected: $driver\n";

    $db->exec($sql);
    echo "Migration réussie ! Table 'users' créée et 'tasks' mise à jour.\n";

} catch (PDOException $e) {
    echo "Erreur lors de la migration : " . $e->getMessage() . "\n";
    // Check if it's "duplicate column" which is fine (means already ran)
    if (strpos($e->getMessage(), 'Duplicate column name') !== false) {
        echo "Note: La colonne existe déjà, tout va bien.\n";
    }
}
?>
