/**
 * config.js - Centralized Configuration Management
 * Loads environment variables and provides configuration access
 * Supports both browser (via window._env_) and Node.js environments
 */

class ConfigManager {
  constructor() {
    this.config = {};
    this.isInitialized = false;
  }

  /**
   * Initialize configuration from environment variables
   * In production, environment variables are injected at build/deploy time
   * For local development, use .env.local file with a build tool or manual injection
   */
  initialize() {
    if (this.isInitialized) return;

    // Check for window._env_ (set by build process or server)
    const envVars = window._env_ || {};

    // Fallback to direct environment variables if available
    this.config = {
      // Supabase Configuration
      supabaseUrl: envVars.VITE_SUPABASE_URL || localStorage.getItem('supabase_url') || 'https://lmunhmfajpjqdegdhxok.supabase.co',
      supabaseAnonKey: envVars.VITE_SUPABASE_ANON_KEY || localStorage.getItem('supabase_key') || 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxtdW5obWZhanBqcWRlZ2RoeG9rIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODA2NjY0MTgsImV4cCI6MjA5NjI0MjQxOH0.YR3ySoiwEcQ_aAOBykZcRWT_Ht8cO5loJT43DYr-ExI',

      // Application Configuration
      appEnv: envVars.VITE_APP_ENV || 'production',
      appName: envVars.VITE_APP_NAME || 'MzimbaEduTrack',
      appVersion: envVars.VITE_APP_VERSION || '1.0.0',

      // Feature Flags
      enableRealtime: (envVars.VITE_ENABLE_REALTIME || 'true').toLowerCase() === 'true',
      enableOfflineMode: (envVars.VITE_ENABLE_OFFLINE_MODE || 'false').toLowerCase() === 'true',
      enableDebugLogging: (envVars.VITE_ENABLE_DEBUG_LOGGING || 'false').toLowerCase() === 'true',

      // Deployment
      deployUrl: envVars.VITE_DEPLOY_URL || '',
    };

    // Validate critical configuration
    if (!this.config.supabaseUrl || !this.config.supabaseAnonKey) {
      console.warn('⚠️ Supabase configuration incomplete. Please set VITE_SUPABASE_URL and VITE_SUPABASE_ANON_KEY');
    }

    this.isInitialized = true;
  }

  /**
   * Get a configuration value
   */
  get(key, defaultValue = undefined) {
    if (!this.isInitialized) this.initialize();
    return this.config[key] !== undefined ? this.config[key] : defaultValue;
  }

  /**
   * Set a configuration value (for runtime changes)
   */
  set(key, value) {
    this.config[key] = value;
  }

  /**
   * Check if running in development mode
   */
  isDevelopment() {
    return this.get('appEnv') === 'development';
  }

  /**
   * Check if running in production mode
   */
  isProduction() {
    return this.get('appEnv') === 'production';
  }

  /**
   * Log a debug message if debug logging is enabled
   */
  debug(message, data = {}) {
    if (this.get('enableDebugLogging')) {
      console.log(`[${this.get('appName')}] ${message}`, data);
    }
  }

  /**
   * Get Supabase configuration object
   */
  getSupabaseConfig() {
    return {
      url: this.get('supabaseUrl'),
      anonKey: this.get('supabaseAnonKey'),
    };
  }
}

// Create and export singleton instance
const Config = new ConfigManager();

// Initialize on load
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', () => Config.initialize());
} else {
  Config.initialize();
}

window.Config = Config;
