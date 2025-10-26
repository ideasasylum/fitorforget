# WebAuthn Configuration
# https://github.com/cedarcode/webauthn-ruby

WebAuthn.configure do |config|
  # Set the allowed origins based on the environment
  # In development: https://local.fitorforget.com:3000 (SSL required for WebAuthn)
  # In production: Use the actual production domain (HTTPS required)
  config.allowed_origins = if Rails.env.development?
    ["https://local.fitorforget.com:3000"]
  elsif Rails.env.test?
    ["https://local.fitorforget.com:3000"]
  else
    # In production, this should be set via environment variable
    # Example: https://fitorforget.com
    [ENV.fetch("WEBAUTHN_ORIGIN") { "https://example.com" }]
  end

  # Set the Relying Party name (displayed to users during WebAuthn prompts)
  config.rp_name = "Fit or Forget"

  # Credential options configuration
  config.credential_options_timeout = 120_000 # 120 seconds for users to complete biometric auth

  # User verification requirement
  # Options: "required", "preferred", "discouraged"
  # "preferred" is recommended - uses biometrics if available, falls back if not
  # This ensures the best UX while maintaining security
  # config.verify_attestation_statement = Rails.env.production?
end
