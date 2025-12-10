# 📱 Todo List App

<div align="center">
  <img src="assets/images/logo.png" width="150">
  <h3>Gestionnaire de tâches avec sessions Pomodoro</h3>
</div>

## 🎯 Description
Application mobile développée avec Flutter pour la gestion de tâches avec système de sessions de travail Pomodoro intégré.

## ✨ Fonctionnalités
### ✅ Implémentées
- **Splash Screen** - Écran d'accueil personnalisé
- **Icône d'application** - Logo professionnel
- **Interface principale** - Liste des tâches
- **Thème Material Design 3** - Design moderne

### 🔄 En développement
- Timer Pomodoro (start/stop/pause)
- Statistiques de productivité
- Synchronisation avec base de données

## 🚀 Installation

### Prérequis
- Flutter SDK 3.9.2+
- Dart SDK 3.9.2+
- Android Studio / Xcode (pour émulateurs)

### Étapes
```bash
# 1. Cloner le projet
git clone https://github.com/[username]/todo-list-app.git
cd todo-list-app

# 2. Installer les dépendances
flutter pub get

# 3. Générer le splash screen
dart run flutter_native_splash:create

# 4. Générer les icônes
dart run flutter_launcher_icons:main

# 5. Lancer l'application
flutter run

## 👥 Équipe de développement
| Membre | Rôle | Tâches principales |
|--------|------|-------------------|
| **Stéphane** | Membre occasionnel | - Splash Screen<br>- Icône d'application<br>- Documentation README<br>- Captures d'écran |
| **Joris** | Logique & State Management | - Choix du state management (Provider/Riverpod/GetX…)<br>Connexion UI ↔ Base de données<br>|
| **Nadège** | Sessions de travail & Statistiques | - Timer de session (start/stop/pause)<br>Associer une session à une tâche<br>Pages statistiques (temps passé, nombre de sessions)
| **Michael** | Designer UI | - Organisation du projet + structure Flutter<br>Création des modèles (Tâche, Session) <br>-Base de données mysql <br>-Repositories (CRUD) |
| **Freddy** | Interface | Design de l’application<br>-Écrans principaux :<br>Liste des tâches<br>Ajouter/Modifier une tâche<br>Détails d’une tâche<br>Widgets réutilisables |
