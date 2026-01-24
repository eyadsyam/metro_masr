-- Metro Masr - Supabase Database Setup
-- Run these SQL commands in your Supabase SQL Editor

-- ============================================
-- 1. Create profiles table
-- ============================================
CREATE TABLE IF NOT EXISTS public.profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT,
  full_name TEXT,
  avatar_url TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- 2. Create saved_routes table
-- ============================================
CREATE TABLE IF NOT EXISTS public.saved_routes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  from_station TEXT NOT NULL,
  to_station TEXT NOT NULL,
  path TEXT[] NOT NULL,
  total_stations INTEGER NOT NULL,
  price NUMERIC(10, 2) NOT NULL,
  estimated_time INTEGER NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ============================================
-- 3. Create indexes for better performance
-- ============================================
CREATE INDEX IF NOT EXISTS idx_profiles_email ON public.profiles(email);
CREATE INDEX IF NOT EXISTS idx_saved_routes_user_id ON public.saved_routes(user_id);
CREATE INDEX IF NOT EXISTS idx_saved_routes_created_at ON public.saved_routes(created_at DESC);

-- ============================================
-- 4. Enable Row Level Security (RLS)
-- ============================================
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.saved_routes ENABLE ROW LEVEL SECURITY;

-- ============================================
-- 5. Create RLS Policies for profiles table
-- ============================================

-- Allow users to view their own profile
CREATE POLICY "Users can view own profile"
  ON public.profiles
  FOR SELECT
  USING (auth.uid() = id);

-- Allow users to insert their own profile
CREATE POLICY "Users can insert own profile"
  ON public.profiles
  FOR INSERT
  WITH CHECK (auth.uid() = id);

-- Allow users to update their own profile
CREATE POLICY "Users can update own profile"
  ON public.profiles
  FOR UPDATE
  USING (auth.uid() = id)
  WITH CHECK (auth.uid() = id);

-- ============================================
-- 6. Create RLS Policies for saved_routes table
-- ============================================

-- Allow users to view their own routes
CREATE POLICY "Users can view own routes"
  ON public.saved_routes
  FOR SELECT
  USING (auth.uid() = user_id);

-- Allow users to insert their own routes
CREATE POLICY "Users can insert own routes"
  ON public.saved_routes
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Allow users to delete their own routes
CREATE POLICY "Users can delete own routes"
  ON public.saved_routes
  FOR DELETE
  USING (auth.uid() = user_id);

-- ============================================
-- 7. Create function to automatically update updated_at
-- ============================================
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- 8. Create trigger for profiles table
-- ============================================
DROP TRIGGER IF EXISTS set_updated_at ON public.profiles;
CREATE TRIGGER set_updated_at
  BEFORE UPDATE ON public.profiles
  FOR EACH ROW
  EXECUTE FUNCTION public.handle_updated_at();

-- ============================================
-- 9. Grant necessary permissions
-- ============================================
GRANT USAGE ON SCHEMA public TO anon, authenticated;
GRANT ALL ON public.profiles TO authenticated;
GRANT ALL ON public.saved_routes TO authenticated;
GRANT SELECT ON public.profiles TO anon;

-- ============================================
-- VERIFICATION QUERIES
-- ============================================

-- Check if tables exist
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
  AND table_name IN ('profiles', 'saved_routes');

-- Check RLS is enabled
SELECT tablename, rowsecurity 
FROM pg_tables 
WHERE schemaname = 'public' 
  AND tablename IN ('profiles', 'saved_routes');

-- Check policies
SELECT schemaname, tablename, policyname, permissive, roles, cmd
FROM pg_policies
WHERE tablename IN ('profiles', 'saved_routes');

-- ============================================
-- NOTES
-- ============================================
-- 1. Run this script in Supabase SQL Editor
-- 2. Make sure you're connected to your project
-- 3. Enable Google OAuth in Authentication > Providers
-- 4. Add your Google Client ID and Secret
-- 5. Configure authorized redirect URIs
