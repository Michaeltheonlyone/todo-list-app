# 🔐 Module : Authentification & Notifications

Ce document détaille les aspects techniques et fonctionnels des modules d'Authentification et de Notifications de **TaskFlow**.

---

## Slide 1 : Architecture Globale
**Titre** : Architecture Client-Serveur
**Contenu** :
*   **Communication** : REST API via HTTP (JSON).
*   **Frontend (Flutter)** :
    *   `AuthService` : Gère l'inscription, la connexion et le stockage local.
    *   `NotificationService` : Récupère les alertes et gère le compteur non-dodu.
*   **Backend (PHP)** :
    *   `auth.php` : Endpoints pour `login` et `register`.
    *   `notifications.php` : Gestion CRUD des notifications.
*   **Base de Données** : Tables relationnelles `users` et `notifications`.

---

## Slide 2 : Authentification - Sécurité
**Titre** : Sécurisation des Données
**Contenu** :
*   **Hashage des Mots de Passe** :
    *   Utilisation de **BCrypt** via `password_hash()` en PHP.
    *   Jamais de stockage en clair.
*   **Vérification** :
    *   Fonction `password_verify()` lors du login.
    *   Protection contre les attaques par force brute (délai naturel de l'algorithme).
*   **Protection SQL** :
    *   Utilisation exclusive de **Requêtes Préparées (PDO)** pour éviter les injections SQL.

---

## Slide 3 : Authentification - Flux Utilisateur
**Titre** : Parcours d'Inscription & Connexion
**Contenu** :
1.  **Inscription** :
    *   L'utilisateur envoie `username`, `email`, `password`.
    *   Le serveur vérifie l'unicité de l'email.
    *   Création du compte + **Notification de Bienvenue automatique**.
2.  **Connexion** :
    *   Vérification des identifiants.
    *   Le serveur renvoie un `user_id`.
3.  **Persistance** :
    *   Stockage du `user_id` dans **SharedPreferences** sur le mobile pour garder la session active.

---

## Slide 4 : Module de Notifications
**Titre** : Système de Notifications
**Contenu** :
*   **Type** : Notifications in-app persistantes (stockées en base de données).
*   **Structure de Données** :
    *   `title`, `message`, `is_read`, `created_at`.
    *   Liées à un utilisateur via clé étrangère (`user_id`).
*   **Mécanisme** :
    *   L'application interroge régulièrement l'API (`GET /notifications.php`).
    *   Affichage en temps quasi-réel des nouvelles alertes.

---

## Slide 5 : Intégration UI (Interface)
**Titre** : Expérience Utilisateur
**Contenu** :
*   **Badge de Notification** :
    *   Pastille rouge sur l'icône de cloche indiquant le nombre de messages non lus.
    *   Mise à jour dynamique via `NotificationService.getUnreadCount()`.
*   **Liste Interactive** :
    *   Vue détaillée des alertes.
    *   Marquage comme "lu" automatique au clic ou via un bouton "Tout marquer comme lu".
    *   Feedback visuel immédiat (disparition du badge).

---

## Slide 6 : Cas d'Usage Implémentés
**Titre** : Exemples Concrets
**Contenu** :
*   🎉 **Bienvenue** : Générée automatiquement à l'inscription.
*   ⏰ **Rappels** : Alertes pour les tâches arrivant à échéance (Backend logic).
*   🍅 **Pomodoro** : Notification de fin de session de travail ou de pause.
*   ⚠️ **Alertes Système** : Messages administratifs ou erreurs critiques.

---

## Slide 7 : Conclusion Technique
**Titre** : Points Forts
**Contenu** :
*   **Robustesse** : Séparation claire Front/Back.
*   **Sécurité** : Standards industriels respectés (BCrypt, PDO).
*   **Scalabilité** : Le système de notification est prêt pour évoluer vers du Push (Firebase) si nécessaire.
