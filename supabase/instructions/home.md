# Correspondance Supabase - Écran Accueil (`HomeScreen`)

Ce document explique comment remplacer les appels à `MockFirebase` par des requêtes Supabase pour l'écran d'accueil.

## 1. Récupérer les Catégories

### Frontend : `lib/screens/home/home_screen.dart`
**Ancien code :** `MockFirebase().getAllCategories()`

**Nouvelle Requête Supabase :**
```dart
final categories = await Supabase.instance.client
  .from('categories')
  .select('*')
  .order('name');
```

## 2. Récupérer les Produits Vedettes (Featured)

### Frontend : `lib/screens/home/home_screen.dart`
**Ancien code :** `MockFirebase().getProducts()` avec filtre `isFeatured`

**Nouvelle Requête Supabase :**
```dart
final featuredProducts = await Supabase.instance.client
  .from('products')
  .select('*')
  .eq('is_featured', true)
  .limit(10);
// Note : Les images sont dans le tableau image_urls
```

## 3. Récupérer les Couturiers Suggérés (Vendors)

### Frontend : `lib/screens/home/home_screen.dart`
**Ancien code :** `MockFirebase().getSuggestedTailors()`

**Nouvelle Requête Supabase :**
```dart
final tailors = await Supabase.instance.client
  .from('profiles')
  .select('*')
  .eq('role', 'tailor')
  .order('is_verified', ascending: false)
  .limit(5);
```

---

> [!TIP]
> Utilisez le service `ProductService` que j'ai généré dans `lib/backend/supabase/product_service.dart` pour encapsuler ces requêtes et garder votre code de UI propre.
