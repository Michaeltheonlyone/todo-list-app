# 📱 Todo List App with Session-Based Completion

<div align="center">
  <img src="assets/images/logo.png" width="150">
  <h3>Gestionnaire de tâches avec système de sessions Pomodoro</h3>
  <p><strong>Règle fondamentale :</strong> Une tâche ne peut être marquée comme terminée qu'après avoir complété une session de travail dédiée</p>
</div>

## 🎯 Description
Application mobile Flutter complète avec backend PHP/MySQL pour la gestion de tâches professionnelles. L'application intègre un système innovant où la complétion des tâches est liée à des sessions de travail concentré.

## 🏗️ Architecture Technique

### **Backend (PHP/MySQL)**
- **Serveur :** XAMPP avec Apache
- **Base de données :** MySQL avec deux tables principales
- **API REST :** Endpoints pour tâches et sessions

### **Frontend (Flutter)**
- **Framework :** Flutter 3.9.2+
- **State Management :** Riverpod
- **Structure :** Architecture en couches (Models → Services → Screens → Widgets)

## ✨ Fonctionnalités Principales

### ✅ **Tâches (Tasks)**
- Création, lecture, modification, suppression (CRUD complet)
- Priorités (Faible, Moyenne, Haute, Urgente)
- Statuts (En attente, En cours, Terminée, Annulée)
- Dates limites avec indicateurs de retard
- Système de tags

### ✅ **Sessions de Travail (Work Sessions)**
- Timer Pomodoro (25min par défaut, configurable)
- Types de sessions : Travail, Pause courte, Pause longue
- Statuts : Planifiée, Active, En pause, Terminée, Annulée
- **Règle métier :** Session requise pour terminer une tâche
- Historique complet des sessions par tâche

### ✅ **Interface Utilisateur**
- Écran détaillé des tâches avec toutes les informations
- Interface de timer intégrée
- Badges visuels pour priorités et statuts
- Design responsive avec Material Design 3

## 🗄️ Structure de la Base de Données

### **Table `tasks`**
```sql
id, title, description, due_date, priority, status, 
tags, completed_at, created_at
Table sessions
sql
id, task_id, start_time, end_time, duration_minutes,
type, status, notes
🚀 Installation & Configuration
Prérequis
Flutter SDK 3.9.2+

Dart SDK 3.9.2+

XAMPP (Apache, MySQL, PHP)

Android Studio / Xcode

Configuration Backend
Importer database.sql dans phpMyAdmin

Placer le dossier backend dans C:\xampp\htdocs\

Vérifier la connexion dans backend/config/db.php

Configuration Flutter
bash
# Cloner le projet
git clone https://github.com/Michaeltheonlyone/todo-list-app.git
cd todo-list-app/todo_list_app

# Installer les dépendances
flutter pub get

# Configurer l'URL de l'API (selon la plateforme)
# Pour émulateur Android : http://10.0.2.2/backend/endpoints
# Pour appareil physique : http://192.168.1.X/backend/endpoints
# Modifier dans lib/services/api_service.dart

# Lancer l'application
flutter run
🔧 Fonctionnement Clé : Sessions → Tâches Complètes
Workflow Utilisateur
Créer une tâche → Statut "En attente"

Démarrer une session → Timer de 25min (configurable)

Compléter la session → Session enregistrée dans la BD

Bouton "Marquer comme terminée" apparaît

Cliquer pour terminer → Tâche passe à "Terminée"

Contraintes Métier
❌ Impossible de terminer une tâche sans session

✅ Session complétée → Bouton de complétion activé

✅ Historique vérifiable dans la base de données

👥 Contributions de l'Équipe
Membre	Rôle Principal	Contributions Clés
Michael	Architecte Principal	• Conception complète de la base de données
• Modèles Flutter (Task, WorkSession)
• Structure du projet Flutter
• Service API complet (CRUD)
• Intégration backend-frontend
• Fonctionnalité sessions → tâches
Stéphane	Documentation & Assets	• README initial
• Icône d'application
• Support documentation
Joris	State Management	• Configuration Riverpod
• Providers pour l'état global
Nadège	Sessions & Statistiques	• Concept des sessions Pomodoro
• Design des statistiques
Freddy	Interface Utilisateur	• Design des écrans principaux
• Widgets réutilisables
🎯 Points Techniques Réalisés par Michael
1. Modèles de Données
dart
// Task.dart - Modèle complet avec validations
class Task {
  String? id, title, description;
  TaskPriority priority;
  TaskStatus status;
  DateTime? dueDate, completedAt;
  List<String>? tags;
  // + méthodes : isOverdue, copyWith, toMap, fromMap
}

// WorkSession.dart - Système Pomodoro avancé
class WorkSession {
  String? id, taskId;
  DateTime startTime, endTime;
  int durationMinutes;
  SessionType type;
  SessionStatus status;
  // + méthodes : actualDuration, isActive, isCompleted
}
2. Service API Robust
dart
// ApiService.dart - Communication complète
class ApiService {
  // CRUD Tasks: getTasks(), createTask(), updateTask(), deleteTask()
  // CRUD Sessions: getSessions(), createSession(), updateSession()
  // Gestion d'erreurs et connexion backend
}
3. Intégration Backend-Frontend
Synchronisation parfaite entre Flutter ↔ PHP ↔ MySQL

Formatage des dates ISO 8601 pour compatibilité

Gestion des null values et erreurs réseau

📁 Structure du Projet
text
todo_list_app/
├── lib/
│   ├── models/           # Task.dart, WorkSession.dart
│   ├── services/         # ApiService.dart
│   ├── screens/          # TaskDetailScreen.dart, etc.
│   ├── widgets/          # PriorityBadge.dart, StatusBadge.dart
│   └── main.dart
├── backend/              # API PHP complète
│   ├── endpoints/        # tasks.php, sessions.php
│   └── config/db.php     # Connexion MySQL
└── assets/               # Images, fonts
🔗 Endpoints API
Tâches
GET /backend/endpoints/tasks.php - Liste toutes les tâches

POST /backend/endpoints/tasks.php - Crée une nouvelle tâche

PUT /backend/endpoints/tasks.php - Met à jour une tâche

DELETE /backend/endpoints/tasks.php?id=X - Supprime une tâche

Sessions
GET /backend/endpoints/sessions.php?taskId=X - Sessions d'une tâche

POST /backend/endpoints/sessions.php - Démarre une session

PUT /backend/endpoints/sessions.php - Termine/met à jour une session

📊 Règles Métier Implémentées
Validation des sessions : Une tâche nécessite au moins une session complétée

Historique complet : Toutes les sessions sont traçables dans la BD

Intégrité des données : Contraintes foreign key entre tâches et sessions

Expérience utilisateur : Feedback visuel immédiat après chaque action

🚀 Prochaines Étapes (Roadmap)
Statistiques avancées - Temps total par tâche, productivité

Notifications - Rappels pour les sessions et dates limites

Synchronisation cloud - Sauvegarde et multi-appareils

Export de données - PDF/Excel des tâches complétées

📝 License
Projet éducatif développé dans le cadre d'un projet académique.

<div align="center"> <p><em>« Une tâche sans session est un souhait, une session sans fin est un rêve »</em></p> </div> ```
