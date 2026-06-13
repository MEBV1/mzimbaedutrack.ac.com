// Helper script to set up Supabase credentials in localStorage
// Run this in your browser's developer tools console
const setupCredentials = () => {
  const config = {
    VITE_SUPABASE_URL: "https://wvsnmgzisrhneoeuwrtn.supabase.co",
    VITE_SUPABASE_ANON_KEY: "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Ind2c25tZ3ppc3JobmVvZXV3cnRuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODEyODAzMTksImV4cCI6MjA5Njg1NjMxOX0.OficIVapN0PgSrTFevM5O55sTR9YLNXz-nRvTjVltwM"
  };
  
  Object.entries(config).forEach(([key, value]) => {
    localStorage.setItem(key, value);
    console.log(`✅ Set ${key} in localStorage`);
  });
  
  console.log("\n✅ Credentials set up! Refresh the page to apply changes.");
};

console.log("📋 To set up Supabase credentials, run: setupCredentials()");
