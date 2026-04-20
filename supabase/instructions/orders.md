# Correspondance Supabase - Panier & Commandes

Ce document explique comment gérer le cycle de vie d'une commande avec Supabase.

## 1. Ajouter au Panier

### Frontend : `lib/widgets/product_card.dart`
**Ancien code :** `MockFirebase().addToCart(product)`

**Nouvelle Requête Supabase (via `OrderService`) :**
```dart
await OrderService().addToCart(
  productId: product['id'],
  size: 'M', 
  color: '#FF0000',
  quantity: 1
);
```

## 2. Valider la Commande (Checkout)

### Frontend : `lib/screens/order/checkout_screen.dart`
**Ancien code :** `MockFirebase().createOrder(items, total)`

**Nouvelle Requête Supabase :**
Le service `OrderService().checkout(...)` s'occupe de :
1. Insérer l'en-tête de la commande dans `orders`.
2. Insérer les lignes détails dans `order_items`.
3. Vider le panier de l'utilisateur dans `cart_items`.

## 3. Historique des Commandes

### Frontend : `lib/screens/profile/orders_history_screen.dart`
**Ancien code :** `MockFirebase().allOrders`

**Nouvelle Requête Supabase :**
```dart
final myOrders = await OrderService().getMyOrders();
// Cette requête récupère la commande ET tous les articles associés en une seule fois.
```

---

> [!TIP]
> Dans Supabase, utilisez l'extension `Table Editor` pour modifier manuellement les statuts des commandes pendant vos tests (ex: passer de `pending` à `shipped`).
