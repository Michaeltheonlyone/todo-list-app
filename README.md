# 📱 Todo List App

<div align="center">
  <h3>Gestionnaire de tâches avec système de sessions Pomodoro</h3>
  <p><strong>Application Flutter avec backend PHP/MySQL</strong></p>
</div>

## 🎯 Description
Application mobile pour la gestion de tâches avec système de sessions de travail. Développée avec Flutter pour le frontend et PHP/MySQL pour le backend.

## ✨ Fonctionnalités

### ✅ Tâches 
- Création, lecture, modification, suppression (CRUD)
- Priorités (Faible, Moyenne, Haute, Urgente)
- Statuts (En attente, En cours, Terminée, Annulée)
- Dates limites avec indicateurs de retard
- Tags et catégories

### ✅ Sessions de Travail 
- Timer Pomodoro intégré (25min par défaut)
- Association sessions ↔ tâches
- Historique des sessions
- **Fonctionnalité clé :** Une tâche ne peut être marquée comme terminée qu'après une session complétée

### ✅ Interface Utilisateur
- Écran détaillé des tâches
- Timer visuel avec contrôles
- Badges de priorité et statut
- Design Material Design

## 👥 Équipe de Développement

| Membre | Rôle | Contributions |
|--------|------|--------------|
| **Michael** | Architecture & Modèles | • Structure du projet Flutter<br>• Modèles Task et WorkSession<br>• Conception base de données<br>• Debug et corrections<br>• Assistance intégration sessions |
| **Freddy** | Interface Utilisateur | • Design des écrans principaux<br>• Liste des tâches<br>• Ajout/Modification tâches<br>• Widgets réutilisables |
| **Joris** | State Management & API | • Service API initial<br>• Configuration Riverpod<br>• Providers et état global<br>• Connexion UI ↔ API |
| **Nadège** | Sessions & Timer | • Concept sessions Pomodoro<br>• Logique timer sessions<br>• Design fonctionnalité sessions<br>• Assistance implémentation |
| **Stéphane** | Documentation & Assets | • README et documentation<br>• Icône application<br>• Support visuel<br>• Splash Screen (en cours) |

## 🏗️ Structure Technique

### **Base de Données (MySQL)**
Table tasks:
id, title, description, due_date, priority, status,
tags, completed_at, created_at

Table sessions:
id, task_id, start_time, end_time, duration_minutes,
type, status, notes

text

### **Backend (PHP)**
- API REST avec endpoints pour tâches et sessions
- Connexion MySQL sécurisée
- Format JSON pour communication

### **Frontend (Flutter)**
- Architecture: Models → Services → Screens → Widgets
- State Management: Riverpod
- Services API pour communication backend

## 🚀 Installation

### **Prérequis**
- Flutter SDK 3.9.2+
- XAMPP (Apache, MySQL, PHP)
- Android Studio / VS Code

### **Configuration**

# 1. Cloner le projet
git clone https://github.com/Michaeltheonlyone/todo-list-app.git
cd todo-list-app/todo_list_app

# 2. Installer dépendances
flutter pub get

# 3. Configurer backend
# - Placer le dossier backend dans C:\xampp\htdocs\
# - Importer la base de données via phpMyAdmin

# 4. Lancer l'application
flutter run
📁 Structure du Projet
text
todo_list_app/
├── lib/
│   ├── models/           # Task.dart, WorkSession.dart
│   ├── services/         # ApiService.dart
│   ├── screens/          # Écrans de l'application
│   ├── widgets/          # Composants réutilisables
│   └── main.dart         # Point d'entrée
├── backend/              # API PHP
│   ├── endpoints/        # tasks.php, sessions.php
│   └── config/db.php     # Configuration DB
└── assets/               # Images et ressources
🔗 Points d'API
Tâches
GET /tasks.php - Liste toutes les tâches

POST /tasks.php - Crée une tâche

PUT /tasks.php - Met à jour une tâche

DELETE /tasks.php?id=X - Supprime une tâche

Sessions
GET /sessions.php?taskId=X - Sessions d'une tâche

POST /sessions.php - Démarre une session

PUT /sessions.php - Met à jour/termine une session

🔧 Fonctionnement
Créer une tâche dans l'application

Démarrer une session depuis l'écran détail de la tâche

Travailler pendant le temps défini (timer Pomodoro)

Session terminée → enregistrée en base de données

Bouton "Marquer comme terminée" apparaît

Cliquer pour terminer → Tâche marquée comme complétée

🎯 Règle Métier Implémentée
"Une tâche ne peut être marquée comme terminée qu'après avoir complété au moins une session de travail."

Cette règle garantit que:

Les utilisateurs consacrent du temps réel à chaque tâche

L'historique du travail est traçable

La productivité est mesurable

📝 Prochaines Étapes
Implémentation du Splash Screen

Statistiques de productivité

Notifications et rappels

Export des données

📄 License
Projet académique - Développement collaboratif

<div align="center"> <p>Développé avec ❤️ par l'équipe de projet</p> </div> ```
