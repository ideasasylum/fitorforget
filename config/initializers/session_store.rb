# Configure database-backed sessions for indefinite duration
Rails.application.config.session_store :active_record_store,
  key: "_fitorforget_session",
  secure: Rails.env.production?, # Secure cookies in production (HTTPS only)
  httponly: true,                # Prevent XSS attacks by making cookie inaccessible to JavaScript
  same_site: :lax                # CSRF protection while allowing navigation from external sites
# No expiry timeout configured - sessions persist indefinitely until explicit logout
