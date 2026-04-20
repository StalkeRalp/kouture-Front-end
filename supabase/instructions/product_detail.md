# Correspondance Supabase - Détail Produit (`ProductDetailScreen`)

Ce document explique comment migrer l'écran de détail d'un produit vers Supabase.

## 1. Récupérer le Produit et ses Images

### Frontend : `lib/screens/product_detail/product_detail_screen.dart`
**Ancien code :** `MockFirebase().getProductById(id)`

**Nouvelle Requête Supabase (via `ProductService`) :**
```dart
// Utilise le service ProductService
final product = await ProductService().getProductById(productId);
// Les images sont le tableau 'image_urls'
print(product['images']); // [url1, url2, ...]
```

## 2. Gérer les Favoris

### Frontend : `lib/widgets/product_card.dart`
**Ancien code :** `MockFirebase().toggleFavorite(id)`

**Nouvelle Requête Supabase :**
```dart
// Pour ajouter d'un favori
await Supabase.instance.client
  .from('favorites')
  .insert({'user_id': userId, 'product_id': productId});

// Pour supprimer un favori
await Supabase.instance.client
  .from('favorites')
  .delete()
  .match({'user_id': userId, 'product_id': productId});
```

## 3. Récupérer les Avis (Reviews)

### Frontend : `lib/screens/product_detail/product_detail_screen.dart`
**Ancien code :** `MockFirebase().getReviewsByProductId(id)`

**Nouvelle Requête Supabase :**
```dart
final reviews = await Supabase.instance.client
  .from('reviews')
  .select('*, profiles(full_name, avatar_url)')
  .eq('product_id', productId);
```

---

> [!IMPORTANT]
> Assurez-vous d'avoir exécuté `03_rls.sql` pour que les utilisateurs puissent insérer leurs propres avis et favoris en toute sécurité.
