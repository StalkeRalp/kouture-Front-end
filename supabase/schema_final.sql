-- ============================================================================
-- KOUTURE — SCHÉMA FINAL RAFFINÉ ET COMPLET
-- Fusion du schéma utilisateur et des fonctionnalités métier (Avis, Notifs, Panier)
-- convention : snake_case (aligné avec les modèles Flutter)
-- ============================================================================

-- ===========================================================================
-- ÉTAPE 0 : NETTOYAGE COMPLET
-- ===========================================================================
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
DROP FUNCTION IF EXISTS public.handle_new_user();

DROP TABLE IF EXISTS public.notifications  CASCADE;
DROP TABLE IF EXISTS public.cart_items     CASCADE;
DROP TABLE IF EXISTS public.reviews        CASCADE;
DROP TABLE IF EXISTS public.order_logs     CASCADE;
DROP TABLE IF EXISTS public.messages       CASCADE;
DROP TABLE IF EXISTS public.order_items    CASCADE;
DROP TABLE IF EXISTS public.orders         CASCADE;
DROP TABLE IF EXISTS public.appointments   CASCADE;
DROP TABLE IF EXISTS public.products       CASCADE;
DROP TABLE IF EXISTS public.categories     CASCADE;
DROP TABLE IF EXISTS public.profiles       CASCADE;

-- ===========================================================================
-- ÉTAPE 1 : TABLES DE RÉFÉRENCE (Catégories)
-- ===========================================================================
CREATE TABLE public.categories (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name        TEXT NOT NULL UNIQUE,
  icon_name   TEXT,
  image_url   TEXT,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE public.categories ENABLE ROW LEVEL SECURITY;
CREATE POLICY "categories_read_public" ON public.categories FOR SELECT USING (true);

-- ===========================================================================
-- ÉTAPE 2 : TABLE profiles (Clients & Couturiers)
-- ===========================================================================
CREATE TABLE public.profiles (
  id                    UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  name                  TEXT NOT NULL DEFAULT '',
  email                 TEXT NOT NULL UNIQUE,
  role                  TEXT NOT NULL DEFAULT 'client' CHECK (role IN ('client', 'tailor')),

  -- Profil général
  profile_image         TEXT,
  bio                   TEXT,
  phone_number          TEXT,
  is_verified           BOOLEAN NOT NULL DEFAULT FALSE,

  -- Données métier
  measurements          JSONB,                     -- Mensurations du client
  favorites             UUID[] DEFAULT '{}',       -- Liste d'IDs produits favoris
  favorite_tailors      UUID[] DEFAULT '{}',       -- Liste d'IDs couturiers favoris
  fcm_tokens            TEXT[] DEFAULT '{}',       -- Pour push notifications

  -- Parrainage
  referred_by_tailor_id UUID REFERENCES public.profiles(id) ON DELETE SET NULL,
  referred_by_code      TEXT,

  -- Données spécifiques couturier
  tailor_code           TEXT UNIQUE,
  shop_name             TEXT,
  shop_address          TEXT,
  experience            TEXT,
  specialties           TEXT[],                    -- ["Costumes", "Robes"]
  city                  TEXT,
  availability          JSONB,

  created_at            TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at            TIMESTAMPTZ
);

ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
CREATE INDEX idx_profiles_role ON public.profiles(role);

CREATE POLICY "profiles_select_public" ON public.profiles FOR SELECT USING (true);
CREATE POLICY "profiles_update_self"   ON public.profiles FOR UPDATE USING (auth.uid() = id);

-- ===========================================================================
-- ÉTAPE 3 : TABLE products
-- ===========================================================================
CREATE TABLE public.products (
  id                    UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  tailor_id             UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  category_id           UUID REFERENCES public.categories(id) ON DELETE SET NULL,

  name                  TEXT NOT NULL DEFAULT '',
  description           TEXT NOT NULL DEFAULT '',
  price                 NUMERIC(12, 2) NOT NULL DEFAULT 0,
  currency              TEXT DEFAULT 'XAF',
  image_urls            TEXT[] DEFAULT '{}',
  type                  TEXT NOT NULL DEFAULT 'readyToWear' CHECK (type IN ('custom', 'readyToWear')),
  gender                TEXT NOT NULL DEFAULT 'unisex' CHECK (gender IN ('male', 'female', 'unisex')),
  confection_time       TEXT,

  -- Options
  sizes                 TEXT[],
  colors                TEXT[],                    -- Codes HEX
  fabrics               TEXT[],
  is_available          BOOLEAN NOT NULL DEFAULT TRUE,
  is_customizable       BOOLEAN NOT NULL DEFAULT TRUE,
  requires_measurements BOOLEAN NOT NULL DEFAULT FALSE,
  is_featured           BOOLEAN NOT NULL DEFAULT FALSE,

  created_at            TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at            TIMESTAMPTZ
);

ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;
CREATE POLICY "products_select_public" ON public.products FOR SELECT USING (true);
CREATE POLICY "products_write_tailor" ON public.products FOR ALL USING (auth.uid() = tailor_id);

-- ===========================================================================
-- ÉTAPE 4 : SYSTEME D'AVIS (Reviews) - AJOUTÉ
-- ===========================================================================
CREATE TABLE public.reviews (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  product_id  UUID NOT NULL REFERENCES public.products(id) ON DELETE CASCADE,
  user_id     UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  rating      INTEGER NOT NULL CHECK (rating >= 1 AND rating <= 5),
  comment     TEXT,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE public.reviews ENABLE ROW LEVEL SECURITY;
CREATE POLICY "reviews_read_public" ON public.reviews FOR SELECT USING (true);
CREATE POLICY "reviews_write_auth"   ON public.reviews FOR INSERT WITH CHECK (auth.role() = 'authenticated');

-- ===========================================================================
-- ÉTAPE 5 : RENDEZ-VOUS ET COMMANDES
-- ===========================================================================
CREATE TABLE public.appointments (
  id                    UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_id             UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  tailor_id             UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  client_name           TEXT, -- Dénormalisé pour streams
  tailor_name           TEXT,
  product_id            UUID REFERENCES public.products(id) ON DELETE SET NULL,
  date_time             TIMESTAMPTZ NOT NULL,
  status                TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'confirmed', 'completed', 'cancelled')),
  type                  TEXT DEFAULT 'consultation',
  notes                 TEXT,
  created_at            TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE public.orders (
  id                      UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  client_id               UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  tailor_id               UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  product_id              UUID REFERENCES public.products(id) ON DELETE SET NULL,
  product_name            TEXT,
  status                  TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'confirmed', 'inProgress', 'fitting', 'completed', 'cancelled', 'rejected')),
  price                   NUMERIC(12, 2) NOT NULL,
  payment_status          TEXT DEFAULT 'pending',
  delivery_address        TEXT,
  created_at              TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE public.appointments ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.orders ENABLE ROW LEVEL SECURITY;

CREATE POLICY "appointments_self" ON public.appointments FOR SELECT USING (auth.uid() = client_id OR auth.uid() = tailor_id);
CREATE POLICY "orders_self"       ON public.orders       FOR SELECT USING (auth.uid() = client_id OR auth.uid() = tailor_id);

-- ===========================================================================
-- ÉTAPE 6 : CHAT ET MESSAGES
-- ===========================================================================
CREATE TABLE public.messages (
  id                UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  order_id          UUID REFERENCES public.orders(id) ON DELETE CASCADE,
  appointment_id    UUID REFERENCES public.appointments(id) ON DELETE CASCADE,
  sender_id         UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  content           TEXT NOT NULL,
  type              TEXT DEFAULT 'text',
  is_read           BOOLEAN DEFAULT FALSE,
  created_at        TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE public.messages ENABLE ROW LEVEL SECURITY;
CREATE POLICY "messages_self" ON public.messages FOR SELECT 
  USING (EXISTS (SELECT 1 FROM orders WHERE id = messages.order_id AND (client_id = auth.uid() OR tailor_id = auth.uid())));

-- ===========================================================================
-- ÉTAPE 7 : NOTIFICATIONS ET PANIER - AJOUTÉ
-- ===========================================================================
CREATE TABLE public.notifications (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  title       TEXT NOT NULL,
  message     TEXT NOT NULL,
  type        TEXT DEFAULT 'info',
  is_read     BOOLEAN DEFAULT FALSE,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE public.cart_items (
  id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id     UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  product_id  UUID NOT NULL REFERENCES public.products(id) ON DELETE CASCADE,
  quantity    INTEGER DEFAULT 1,
  size        TEXT,
  color       TEXT,
  created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

ALTER TABLE public.notifications ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.cart_items ENABLE ROW LEVEL SECURITY;

CREATE POLICY "notifications_self" ON public.notifications FOR ALL USING (auth.uid() = user_id);
CREATE POLICY "cart_self"          ON public.cart_items    FOR ALL USING (auth.uid() = user_id);

-- ===========================================================================
-- ÉTAPE 8 : TRIGGER AUTH AUTOMATIQUE
-- ===========================================================================
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, email, name, role)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'name', 'Utilisateur'),
    COALESCE(NEW.raw_user_meta_data->>'role', 'client')
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ===========================================================================
-- ÉTAPE 9 : STORAGE & REALTIME
-- ===========================================================================
INSERT INTO storage.buckets (id, name, public) VALUES ('kouture_images', 'kouture_images', true) ON CONFLICT (id) DO NOTHING;

DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_publication WHERE pubname = 'supabase_realtime') THEN
    CREATE PUBLICATION supabase_realtime;
  END IF;
  ALTER PUBLICATION supabase_realtime ADD TABLE public.orders, public.messages, public.appointments, public.notifications;
END;
$$;
