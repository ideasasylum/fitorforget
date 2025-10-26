class SessionsController < ApplicationController
  # Task 3.3: Render unified auth form
  def new
    # Render the unified auth form wrapped in a Turbo Frame
  end

  # Task 3.4: Check if user exists and return appropriate WebAuthn challenge
  def check
    email = params[:email]&.downcase&.strip

    # Basic email validation
    unless email.present? && email.include?("@")
      render turbo_stream: turbo_stream.replace(
        "auth_flow",
        partial: "sessions/error",
        locals: { message: "Please enter a valid email address" }
      )
      return
    end

    user = User.find_by(email: email)

    if user
      # Existing user - generate authentication challenge
      generate_authentication_challenge(user)
    else
      # New user - generate registration challenge
      generate_registration_challenge(email)
    end
  end

  # Task 3.5: Verify WebAuthn credential and create session
  def verify
    begin
      email = params[:email]&.downcase&.strip
      credential_response = params[:credential_response]
      flow_type = params[:flow_type] # "registration" or "authentication"

      if flow_type == "registration"
        handle_registration(email, credential_response)
      else
        handle_authentication(email, credential_response)
      end
    rescue => e
      Rails.logger.error "WebAuthn verification failed: #{e.message}"
      redirect_to auth_path, alert: "Authentication failed. Please try again."
    end
  end

  # Task 3.6: Clear session and redirect
  def destroy
    reset_session
    redirect_to root_path, notice: "You have been logged out"
  end

  private

  def generate_registration_challenge(email)
    # Generate a temporary webauthn_id for the challenge
    webauthn_id = SecureRandom.hex(16)

    # Generate WebAuthn registration options using correct method name
    options = WebAuthn::Credential.options_for_create(
      user: {
        id: webauthn_id,
        name: email,
        display_name: email
      },
      exclude: []
    )

    # Store challenge and email in session for verification
    session[:webauthn_challenge] = options.challenge
    session[:pending_email] = email
    session[:pending_webauthn_id] = webauthn_id

    render turbo_stream: turbo_stream.replace(
      "auth_flow",
      partial: "sessions/register",
      locals: {
        email: email,
        options: options.as_json
      }
    )
  end

  def generate_authentication_challenge(user)
    # Get all credentials for this user
    credentials = user.credentials.pluck(:external_id)

    # Generate WebAuthn authentication options
    options = WebAuthn::Credential.options_for_get(
      allow: credentials
    )

    # Store challenge and email in session for verification
    session[:webauthn_challenge] = options.challenge
    session[:pending_email] = user.email

    render turbo_stream: turbo_stream.replace(
      "auth_flow",
      partial: "sessions/authenticate",
      locals: {
        email: user.email,
        options: options.as_json
      }
    )
  end

  def handle_registration(email, credential_response)
    # Verify the credential
    webauthn_credential = WebAuthn::Credential.from_create(credential_response)

    # Verify against stored challenge
    webauthn_credential.verify(session[:webauthn_challenge])

    # Create user with the stored webauthn_id
    user = User.create!(
      email: email,
      webauthn_id: session[:pending_webauthn_id]
    )

    # Store the credential
    user.credentials.create!(
      external_id: webauthn_credential.id,
      public_key: webauthn_credential.public_key,
      sign_count: webauthn_credential.sign_count
    )

    # Create session
    create_user_session(user)

    # Clear temporary session data
    session.delete(:webauthn_challenge)
    session.delete(:pending_email)
    session.delete(:pending_webauthn_id)

    # Task 3.8: Redirect to return_to path or root
    redirect_to session.delete(:return_to) || root_path, notice: "Welcome! Your account has been created."
  end

  def handle_authentication(email, credential_response)
    # Find user
    user = User.find_by(email: email)
    raise "User not found" unless user

    # Verify the credential
    webauthn_credential = WebAuthn::Credential.from_get(credential_response)

    # Find matching credential
    credential = user.credentials.find_by(external_id: webauthn_credential.id)
    raise "Credential not found" unless credential

    # Verify against stored challenge and public key
    webauthn_credential.verify(
      session[:webauthn_challenge],
      public_key: credential.public_key,
      sign_count: credential.sign_count
    )

    # Update sign count
    credential.update!(sign_count: webauthn_credential.sign_count)

    # Create session
    create_user_session(user)

    # Clear temporary session data
    session.delete(:webauthn_challenge)
    session.delete(:pending_email)

    # Task 3.8: Redirect to return_to path or root
    redirect_to session.delete(:return_to) || root_path, notice: "Welcome back!"
  end

  def create_user_session(user)
    # Clear old session data
    reset_session

    # Create new session
    session[:user_id] = user.id

    # Regenerate session ID for security
    request.session_options[:renew] = true
  end
end
