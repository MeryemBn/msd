# MSD Mobile Application

Application mobile Flutter pour le projet MSD.

##  Installation & Configuration

### 1. Prérequis
- Flutter SDK (version ^3.10.8)
- Dart SDK
- Un émulateur Android/iOS ou un appareil physique

### 2. Installation des dépendances
```bash
flutter pub get
```

### 3. Configuration du Backend
L'application communique avec un serveur local par défaut. Vous pouvez modifier l'adresse IP dans le fichier :
`lib/core/network/api_client.dart`
```dart
static const String baseUrl = 'http://192.168.1.3:8080';
```

---

##  Personnalisation (Icônes & Splash)

### 1. Générer les icônes de l'application
Pour mettre à jour les icônes (Android/iOS) après avoir modifié le fichier source :
```bash
flutter pub run flutter_launcher_icons:main
```

### 2. Générer l'écran de démarrage (Splash Screen)
Pour mettre à jour le Splash Screen natif :
```bash
flutter pub run flutter_native_splash:create
```

---

##  Structure du Projet (Clean Architecture)

- `lib/app/` : Configuration globale (thème, routeur).
- `lib/core/` : Client API, constantes, thèmes partagés.
- `lib/features/` : Modules par fonctionnalité (auth, home, etc.).
- `lib/shared/` : Widgets réutilisables, assets (images/logos).

---

##  Authentification
Le module d'authentification utilise **Riverpod** pour la gestion d'état et **Flutter Secure Storage** pour la persistance des tokens JWT.
