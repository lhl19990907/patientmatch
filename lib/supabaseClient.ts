import { createClient } from "@supabase/supabase-js";

declare global {
  interface Window {
    __PATIENTMATCH_CONFIG__?: {
      supabaseUrl?: string;
      supabaseAnonKey?: string;
    };
  }
}

function resolveSupabaseBrowserConfig() {
  const runtimeConfig =
    typeof window !== "undefined" ? window.__PATIENTMATCH_CONFIG__ : undefined;
  const supabaseUrl =
    runtimeConfig?.supabaseUrl || process.env.NEXT_PUBLIC_SUPABASE_URL || "";
  const supabaseAnonKey =
    runtimeConfig?.supabaseAnonKey || process.env.NEXT_PUBLIC_SUPABASE_ANON_KEY || "";

  if (!supabaseUrl || !supabaseAnonKey) {
    throw new Error("Supabase env not configured");
  }

  return { supabaseUrl, supabaseAnonKey };
}

export function getSupabaseBrowser() {
  const { supabaseUrl, supabaseAnonKey } = resolveSupabaseBrowserConfig();
  return createClient(supabaseUrl, supabaseAnonKey);
}
