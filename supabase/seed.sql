-- SEED.SQL - INITIAL DATA
-- Execute this to populate your categories and some test products

-- 1. SEED CATEGORIES
INSERT INTO public.categories (id, name, icon_name) VALUES
  ('550e8400-e29b-41d4-a716-446655440001', 'Men', 'men'),
  ('550e8400-e29b-41d4-a716-446655440002', 'Women', 'women'),
  ('550e8400-e29b-41d4-a716-446655440003', 'Kids', 'kids'),
  ('550e8400-e29b-41d4-a716-446655440004', 'Accessories', 'accessories'),
  ('550e8400-e29b-41d4-a716-446655440005', 'Suits', 'suits')
ON CONFLICT (name) DO NOTHING;

-- 2. SEED VENDORS
INSERT INTO public.vendors (id, name, bio, rating, is_official) VALUES
  ('550e8400-e29b-41d4-a716-446655440010', 'Kouture Official', 'The main store for premium African wear.', 4.8, true),
  ('550e8400-e29b-41d4-a716-446655440011', 'Afro-Chic Studio', 'Bespoke tailoring and modern African cuts.', 4.5, false)
ON CONFLICT (id) DO NOTHING;

-- 3. SEED PRODUCTS
INSERT INTO public.products (id, vendor_id, category_id, name, description, price, sizes, colors, tags, is_featured) VALUES
  ('550e8400-e29b-41d4-a716-446655440101', 
   '550e8400-e29b-41d4-a716-446655440010', 
   '550e8400-e29b-41d4-a716-446655440001', 
   'Dashiki Premium', 
   'A beautiful dashiki made from authentic African wax.', 
   15000, 
   ARRAY['S', 'M', 'L', 'XL'], 
   ARRAY['#FF0000', '#0000FF'], 
   ARRAY['traditional', 'dashiki', 'wedding'], 
   true),
  ('550e8400-e29b-41d4-a716-446655440102', 
   '550e8400-e29b-41d4-a716-446655440010', 
   '550e8400-e29b-41d4-a716-446655440002', 
   'Boubou Silk', 
   'Elegant silk boubou for special occasions.', 
   25000, 
   ARRAY['M', 'L'], 
   ARRAY['#000000', '#DAA520'], 
   ARRAY['silk', 'elegant', 'women'], 
   true);

-- 4. SEED PRODUCT IMAGES
INSERT INTO public.product_images (product_id, url) VALUES
  ('550e8400-e29b-41d4-a716-446655440101', 'https://images.unsplash.com/photo-1542291026-7eec264c27ff'),
  ('550e8400-e29b-41d4-a716-446655440102', 'https://images.unsplash.com/photo-1491553895911-0055eca6402d');
