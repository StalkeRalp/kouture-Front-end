-- 02_STORAGE.SQL - STORAGE CONFIGURATION
-- Execute this to create buckets and set public access

-- 1. CREATE BUCKETS
INSERT INTO storage.buckets (id, name, public) 
VALUES 
  ('product-images', 'product-images', true),
  ('avatars', 'avatars', true),
  ('category-icons', 'category-icons', true)
ON CONFLICT (id) DO NOTHING;

-- 2. STORAGE POLICIES

-- Product Images: Publicly readable, restricted upload
CREATE POLICY "Public Read for Product Images" ON storage.objects
  FOR SELECT USING (bucket_id = 'product-images');

CREATE POLICY "Admin Upload for Product Images" ON storage.objects
  FOR INSERT WITH CHECK (bucket_id = 'product-images' AND auth.role() = 'authenticated');

-- Avatars: Publicly readable, user can only update their own
CREATE POLICY "Public Read for Avatars" ON storage.objects
  FOR SELECT USING (bucket_id = 'avatars');

CREATE POLICY "User Upload own Avatar" ON storage.objects
  FOR INSERT WITH CHECK (bucket_id = 'avatars' AND auth.uid()::text = (storage.foldername(name))[1]);
