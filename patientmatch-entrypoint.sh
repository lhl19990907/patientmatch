#!/bin/sh
set -eu
SUPABASE_URL="${NEXT_PUBLIC_SUPABASE_URL:-${SUPABASE_URL:-}}"
ANON_KEY="${NEXT_PUBLIC_SUPABASE_ANON_KEY:-${SUPABASE_ANON_KEY:-}}"
cat > /app/public/runtime-config.js <<JS
window.__PATIENTMATCH_CONFIG__ = {
  supabaseUrl: "${SUPABASE_URL}",
  supabaseAnonKey: "${ANON_KEY}"
};
JS
exec "$@"
