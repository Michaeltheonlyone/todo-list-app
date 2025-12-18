# 📱 TaskFlow - Votre Compagnon de Productivité Ultime

**TaskFlow** est bien plus qu'une simple liste de tâches. C'est une application mobile complète conçue pour booster votre productivité en combinant une gestion efficace des tâches avec la méthode Pomodoro éprouvée.

Développé avec **Flutter** pour une expérience fluide et native, et propulsé par un backend **PHP** performant.

![Bannière de l'App (Optionnel)](assets/images/banner.png)

## ✨ Fonctionnalités Clés

### 🎯 Gestion de Tâches Avancée
- **Organisation Quotidienne** : Vue claire de vos tâches "Aujourd'hui" pour rester focalisé.
- **Détails Complets** : Ajoutez des descriptions, dates d'échéance et priorités.
- **Statuts Dynamiques** : Suivez la progression de chaque tâche.

### ⏱️ Méthode Pomodoro Intégrée
- **Timer de Focus** : Lancez des sessions de travail directement depuis vos tâches.
- **Synchronisation** : Chaque session Pomodoro est liée à une tâche spécifique pour un suivi précis du temps passé.
- **Pauses Automatiques** : Gestion intelligente des pauses courtes et longues.

### 📊 Statistiques & Suivi (À venir)
- Visualisez votre productivité.
- Historique des sessions et tâches complétées.

### 🔔 Notifications Intelligentes
- Rappels pour ne jamais oublier une échéance.
- Alertes de fin de session Pomodoro.

### 🔐 Espace Utilisateur Sécurisé
- Inscription et Connexion sécurisées.
- Synchronisation des données dans le cloud.

---

## 🛠️ Stack Technique

Ce projet utilise des technologies modernes pour garantir performance et maintenabilité :

**Frontend (Mobile)**
- **Framework** : [Flutter](https://flutter.dev/) (SDK ^3.9.2)
- **Langage** : Dart
- **State Management** : [Riverpod](https://riverpod.dev/) (v2.4.9)
- **Design** : Material 3
- **Réseau** : HTTP
- **Stockage Local** : SharedPreferences

**Backend (API)**
- **Langage** : PHP (Vanilla 8.2+)
- **Base de Données** : MySQL / MariaDB
- **Communication** : API REST JSON

---

## 🚀 Installation et Configuration

Suivez ces étapes pour lancer le projet localement.

### Pré-requis
- Flutter SDK installé et configuré.
- Serveur local (XAMPP, WAMP, ou Docker) avec PHP et MySQL.
- Un éditeur de code (VS Code ou Android Studio).

### 1️⃣ Configuration du Backend

1.  Clonez ce dépôt.
2.  Déplacez le dossier `backend` dans la racine de votre serveur web (ex: `htdocs` ou `www`).
3.  Démarrez votre serveur MySQL.
4.  Créez une base de données nommée `todo_app`.
5.  Importez le fichier `backend/todo_app.sql` dans cette base de données (via phpMyAdmin ou CLI).
6.  Vérifiez le fichier `backend/config/db.php` pour ajuster les identifiants si nécessaire (user/password).

Pour lancer le serveur PHP intégré (développement seulement) :
```bash
cd backend
php -S 0.0.0.0:8000
```
### 2️⃣ Configuration du Frontend (Flutter)

1.  Ouvrez un terminal dans le dossier racine du projet.
2.  Installez les dépendances :
    ```bash
    flutter pub get
    ```
3.  Configurez l'URL de l'API :
    - Ouvrez `lib/services/api_service.dart`.
    - Modifiez `baseUrl` pour correspondre à l'adresse IP de votre machine (ex: `http://192.168.1.XX:8000/backend` ou `http://10.0.2.2:8000` pour l'émulateur Android).

4.  Lancez l'application :
    ```bash
    flutter run
    ```

---

## 📂 Structure du Projet

```
todo-list-app/
├── backend/            # API PHP et Scripts SQL
│   ├── config/         # Connexion BDD
│   ├── endpoints/      # Routes de l'API (auth, tasks, sessions...)
│   └── todo_app.sql    # Structure de la base de données
├── lib/
│   ├── main.dart       # Point d'entrée de l'application
│   ├── models/         # Modèles de données (Task, User...)
│   ├── providers/      # Gestion d'état (Riverpod)
│   ├── screens/        # Écrans de l'interface (UI)
│   ├── services/       # Communication avec l'API
│   └── widgets/        # Composants réutilisables
└── pubspec.yaml        # Dépendances Flutter
```

---

### 🖥️ Environnement de Développement

Cette application est conçue pour être multi-plateforme. Notre équipe de 5 développeurs travaille sur des environnements variés (Windows/XAMPP, Linux, MacOS). Les fichiers de configuration sont donc détaillés pour assurer une compatibilité maximale, notamment avec **XAMPP** et **MySQL** sur Windows.

---

## 🤝 Contribution

Les contributions sont les bienvenues ! Si vous souhaitez améliorer cette application, n'hésitez pas à ouvrir une Issue ou une Pull Request.

---

*Développé avec ❤️ par notre équipe de 5 passionnés*
