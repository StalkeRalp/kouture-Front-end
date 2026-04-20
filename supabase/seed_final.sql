-- SEED_FINAL.SQL - DONNÉES DE TEST RAFFINÉES
-- Executez ceci après schema_final.sql

-- 1. SEED CATEGORIES
INSERT INTO public.categories (id, name, icon_name) VALUES
  ('550e8400-e29b-41d4-a716-446655440001', 'Men', 'men'),
  ('550e8400-e29b-41d4-a716-446655440002', 'Women', 'women'),
  ('550e8400-e29b-41d4-a716-446655440003', 'Kids', 'kids'),
  ('550e8400-e29b-41d4-a716-446655440004', 'Accessories', 'accessories'),
  ('550e8400-e29b-41d4-a716-446655440005', 'Suits', 'suits')
ON CONFLICT (name) DO NOTHING;

-- 2. SEED VENDORS (PROFILÉ COMME COUTURIERS)
-- Note: Dans un vrai système, ces profils seraient créés via auth.users
-- Ici on insère directement dans public.profiles pour le test.
INSERT INTO public.profiles (id, email, name, role, shop_name, bio, tailor_code, is_verified) VALUES
  ('550e8400-e29b-41d4-a716-446655440010', 'official@kouture.com', 'Kouture Team', 'tailor', 'Kouture Official', 'Le magasin principal pour la mode africaine premium.', 'CT-001', true),
  ('550e8400-e29b-41d4-a716-446655440011', 'chic@tailor.com', 'Afro-Chic Studio', 'tailor', 'Afro-Chic', 'Sur-mesure et coupes modernes.', 'CT-002', true)
ON CONFLICT (id) DO NOTHING;

-- 3. SEED PRODUCTS
INSERT INTO public.products (id, tailor_id, category_id, name, description, price, image_urls, sizes, colors, tags, is_featured) VALUES
  ('550e8400-e29b-41d4-a716-446655440101', 
   '550e8400-e29b-41d4-a716-446655440010', 
   '550e8400-e29b-41d4-a716-446655440001', 
   'Dashiki Premium', 
   'Un magnifique dashiki fait en wax authentique.', 
   15000, 
   ARRAY['https://images.unsplash.com/photo-1542291026-7eec264c27ff'],
   ARRAY['S', 'M', 'L', 'XL'], 
   ARRAY['#FF0000', '#0000FF'], 
   ARRAY['traditionnel', 'dashiki', 'mariage'], 
   true),
  ('550e8400-e29b-41d4-a716-446655440102', 
   '550e8400-e29b-41d4-a716-446655440010', 
   '550e8400-e29b-41d4-a716-446655440002', 
   'Boubou en Soie', 
   'Élégant boubou en soie pour les grandes occasions.', 
   25000, 
   ARRAY['https://images.unsplash.com/photo-1491553895911-0055eca6402d'],
   ARRAY['M', 'L'], 
   ARRAY['#000000', '#DAA520'], 
   ARRAY['soie', 'élégant', 'femme'], 
   true);
