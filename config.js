/**
 * MzimbaEduTrack Configuration System
 * Centralized configuration management
 */

const Config = {
    _config: null,

    getSupabaseConfig() {
        if (this._config) {
            return this._config;
        }

        // Try window._env_ first (Cloudflare Pages injection)
        let url = '';
        let anonKey = '';

        if (typeof window !== 'undefined' && window._env_) {
            url = window._env_.VITE_SUPABASE_URL || '';
            anonKey = window._env_.VITE_SUPABASE_ANON_KEY || '';
        }

        // Fallback to localStorage for development
        if (!url || !anonKey) {
            url = localStorage.getItem('VITE_SUPABASE_URL') || '';
            anonKey = localStorage.getItem('VITE_SUPABASE_ANON_KEY') || '';
        }

        // Final fallback: hardcoded new credentials for local dev
        if (!url || !anonKey) {
            url = 'https://wvsnmgzisrhneoeuwrtn.supabase.co';
            anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Ind2c25tZ3ppc3JobmVvZXV3cnRuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODEyODAzMTksImV4cCI6MjA5Njg1NjMxOX0.OficIVapN0PgSrTFevM5O55sTR9YLNXz-nRvTjVltwM';
        }

        this._config = {
            url,
            anonKey,
            enableRealtime: true,
            enableDebug: false
        };

        return this._config;
    },

    setConfig(key, value) {
        if (typeof window !== 'undefined') {
            localStorage.setItem(key, value);
            this._config = null; // Clear cache
        }
    },

    isDevelopment() {
        return window.location.hostname === 'localhost' || 
               window.location.hostname === '127.0.0.1';
    }
};

window.Config = Config;
