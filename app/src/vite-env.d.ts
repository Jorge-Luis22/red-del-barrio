/// <reference types="vite/client" />

interface ImportMetaEnv {
  readonly VITE_SUPABASE_URL?: string;
  readonly VITE_SUPABASE_ANON_KEY?: string;
  readonly VITE_MATRIX_HOMESERVER?: string;
  readonly VITE_MATRIX_TOKEN?: string;
  readonly VITE_APP_MODE?: string;
  readonly VITE_CONTACT_EMAIL?: string;
  readonly VITE_DEFAULT_ZONE?: string;
  readonly VITE_DEFAULT_LAT?: string;
  readonly VITE_DEFAULT_LNG?: string;
}

interface ImportMeta {
  readonly env: ImportMetaEnv;
}
