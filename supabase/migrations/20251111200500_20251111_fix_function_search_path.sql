/*
  # Fix Function Search Path Security Issue

  1. Security Fix
    - Recreate `public.set_updated_at()` function with immutable search_path
    - Prevents privilege escalation attacks via search_path manipulation
    - Sets search_path to empty string (only uses fully qualified names)
  
  2. Changes
    - Drop existing trigger first
    - Drop existing function
    - Recreate function with SECURITY DEFINER and immutable search_path
*/

-- Drop trigger first
DROP TRIGGER IF EXISTS trg_set_updated_at ON public.dcf_leads;

-- Drop existing function
DROP FUNCTION IF EXISTS public.set_updated_at();

-- Recreate function with immutable search_path
CREATE OR REPLACE FUNCTION public.set_updated_at()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = ''
AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$;

-- Recreate trigger
CREATE TRIGGER trg_set_updated_at
  BEFORE UPDATE ON public.dcf_leads
  FOR EACH ROW
  EXECUTE PROCEDURE public.set_updated_at();