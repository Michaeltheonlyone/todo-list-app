-- Seed Data for TaskFlow (PostgreSQL Compatible)
-- Password for all users is "TaskFlowSecure!2025"

BEGIN;

-- 1. Users
INSERT INTO users (username, email, password, created_at) VALUES
('Jean Dupont', 'jean@example.com', '$2y$12$gH4jxrtv9tvWAR.nBvPK1uZH4pNvzXLkuZVNEGpMJDfQQR2GHxvdO', NOW()),
('Marie Curie', 'marie@example.com', '$2y$12$gH4jxrtv9tvWAR.nBvPK1uZH4pNvzXLkuZVNEGpMJDfQQR2GHxvdO', NOW()),
('Thomas Pesquet', 'thomas@example.com', '$2y$12$gH4jxrtv9tvWAR.nBvPK1uZH4pNvzXLkuZVNEGpMJDfQQR2GHxvdO', NOW()),
('Sophie Martin', 'sophie@example.com', '$2y$12$gH4jxrtv9tvWAR.nBvPK1uZH4pNvzXLkuZVNEGpMJDfQQR2GHxvdO', NOW()),
('Lucas Bernard', 'lucas@example.com', '$2y$12$gH4jxrtv9tvWAR.nBvPK1uZH4pNvzXLkuZVNEGpMJDfQQR2GHxvdO', NOW());

-- 2. Tasks
-- Jean Dupont (5 tâches variées)
INSERT INTO tasks (user_id, title, description, priority, status, due_date, created_at, completed) VALUES
((SELECT id FROM users WHERE email='jean@example.com'), 'Finaliser le rapport annuel', 'Rédiger la section finance et relire l''introduction.', 3, 0, NOW() + INTERVAL '2 days', NOW(), FALSE),
((SELECT id FROM users WHERE email='jean@example.com'), 'Réviser la présentation client', 'Vérifier les chiffres du slide 14.', 2, 0, NOW() + INTERVAL '4 hours', NOW(), FALSE),
((SELECT id FROM users WHERE email='jean@example.com'), 'Faire les courses', 'Lait, Œufs, Pain, Café.', 1, 0, NOW() + INTERVAL '1 day', NOW(), FALSE),
((SELECT id FROM users WHERE email='jean@example.com'), 'Appeler le service technique', 'Concernant le bug du serveur de prod.', 3, 0, NOW() - INTERVAL '1 hour', NOW(), FALSE),
((SELECT id FROM users WHERE email='jean@example.com'), 'Lire un livre', 'Chapitre 3 de "Clean Code".', 1, 1, NOW() - INTERVAL '2 days', NOW(), TRUE);

-- Autres utilisateurs
INSERT INTO tasks (user_id, title, description, priority, status, due_date, created_at, completed) VALUES
((SELECT id FROM users WHERE email='marie@example.com'), 'Préparer la réunion client', 'Slides PowerPoint et démo technique.', 2, 0, NOW() + INTERVAL '1 day', NOW(), FALSE),
((SELECT id FROM users WHERE email='thomas@example.com'), 'Entraînement physique', 'Séance de cardio 45min.', 1, 1, NOW() - INTERVAL '1 day', NOW(), TRUE),
((SELECT id FROM users WHERE email='sophie@example.com'), 'Acheter des fournitures', 'Papier, stylos, café pour le bureau.', 1, 0, NOW() + INTERVAL '5 days', NOW(), FALSE),
((SELECT id FROM users WHERE email='lucas@example.com'), 'Mise à jour du site web', 'Déployer la v2.0 en production.', 3, 0, NOW() + INTERVAL '3 hours', NOW(), FALSE);

-- 3. Sessions (Linked to tasks)
-- Type: 0=Work, 1=Short Break, 2=Long Break
INSERT INTO sessions (task_id, start_time, end_time, duration_minutes, type, status, notes) VALUES
((SELECT id FROM tasks WHERE title='Finaliser le rapport annuel' LIMIT 1), NOW() - INTERVAL '2 hours', NOW() - INTERVAL '1 hour 35 minutes', 25, 0, 1, 'Rédaction efficace section 1'),
((SELECT id FROM tasks WHERE title='Finaliser le rapport annuel' LIMIT 1), NOW() - INTERVAL '1 hour 30 minutes', NOW() - INTERVAL '1 hour 25 minutes', 5, 1, 1, 'Pause café'),
((SELECT id FROM tasks WHERE title='Préparer la réunion client' LIMIT 1), NOW() - INTERVAL '4 hours', NOW() - INTERVAL '3 hours 10 minutes', 50, 0, 1, 'Création des slides'),
((SELECT id FROM tasks WHERE title='Mise à jour du site web' LIMIT 1), NOW() - INTERVAL '30 minutes', NULL, 25, 0, 0, 'Déploiement en cours...'),
((SELECT id FROM tasks WHERE title='Entraînement physique' LIMIT 1), NOW() - INTERVAL '1 day 1 hour', NOW() - INTERVAL '1 day', 60, 0, 1, 'Séance intense');

-- 4. Notifications
INSERT INTO notifications (user_id, title, message, is_read, created_at) VALUES
((SELECT id FROM users WHERE email='jean@example.com'), 'Rappel de tâche', 'Votre rapport est à rendre bientôt !', FALSE, NOW()),
((SELECT id FROM users WHERE email='marie@example.com'), 'Session terminée', 'Bravo ! Vous avez complété 50min de focus.', TRUE, NOW() - INTERVAL '3 hours'),
((SELECT id FROM users WHERE email='thomas@example.com'), 'Tâche complétée', 'Félicitations pour votre entraînement.', TRUE, NOW() - INTERVAL '1 day'),
((SELECT id FROM users WHERE email='sophie@example.com'), 'Bienvenue', 'Bienvenue sur TaskFlow ! Commencez par créer une tâche.', TRUE, NOW() - INTERVAL '1 week'),
((SELECT id FROM users WHERE email='lucas@example.com'), 'Alerte Urgente', 'La mise à jour doit être finie avant midi.', FALSE, NOW());

COMMIT;


--TaskFlowSecure!2025