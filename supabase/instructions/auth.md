# Correspondance Supabase - Authentification (`Login`/`Register`)

Ce document explique comment gérer l'authentification avec Supabase Auth.

## 1. Login (Connexion)

### Frontend : `lib/screens/auth/login_screen.dart`
**Ancien code :** `MockFirebase().signIn(email, password)`

**Nouvelle Requête Supabase (via `AuthService`) :**
```dart
try {
  final response = await AuthService().signIn(email, password);
  // Le nom de l'utilisateur est accessible via response.user.userMetadata['name']
  Navigator.pushReplacementNamed(context, MainNavigationScreen.routeName);
} catch (e) {
  // Gérer l'erreur
}
```

## 2. Register (Inscription)

### Frontend : `lib/screens/auth/register_screen.dart`
**Ancien code :** `MockFirebase().signUp(...)`

**Nouvelle Requête Supabase :**
```dart
await AuthService().signUp(
  email: email, 
  password: password, 
  fullName: fullName
);
// Supabase envoie automatiquement un mail de vérification si configuré.
```

## 3. Profil Utilisateur

### Frontend : `lib/screens/profile/profile_screen.dart`
**Ancien code :** `MockFirebase().currentUser`

**Nouvelle Requête Supabase :**
```dart
final profile = await AuthService().getCurrentProfile();
// Récupère les données de la table 'profiles' liée à l'utilisateur Auth.
```

---

> [!TIP]
> Le déclencheur (`trigger`) SQL dans `01_schema.sql` crée automatiquement une entrée dans la table `profiles` dès qu'un utilisateur s'inscrit via l'Auth de Supabase.
