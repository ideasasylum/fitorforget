# Specification: WebAuthn Passwordless Authentication

## Goal
Implement passwordless authentication using WebAuthn biometrics (Face ID, Touch ID, fingerprint) enabling users to create accounts, own programs, and track exercise sessions. Authentication uses a single unified flow with indefinite session duration and multi-device credential support.

## User Stories

### Registration Flow
- As a new user viewing a program, when I try to start a session, I'm prompted to create an account
- As a new user, I enter my email address in a single form
- As a new user, the system recognizes my email is new and prompts me to register a biometric credential
- As a new user, I approve the credential registration on my device (Face ID/Touch ID/fingerprint)
- As a new user, my account is created and I'm logged in immediately with an indefinite session

### Login Flow
- As a returning user, I enter my email address in the same unified form
- As a returning user, the system recognizes my email exists and prompts me to authenticate
- As a returning user, I verify my identity using my device biometric
- As a returning user, I'm logged in immediately without any password

### Multi-Device Support
- As a user on a new device, I enter my email and the system prompts me to register this device's credential
- As a user with multiple devices, each device has its own WebAuthn credential stored in the database
- As a user, I can authenticate from any of my registered devices seamlessly

### Session Management
- As a logged-in user, my session persists indefinitely across browser restarts
- As a logged-in user, I can explicitly log out to end my session
- As a logged-in user, I never experience unexpected session timeouts or forced re-authentication

## Core Requirements

### User Registration
- Collect only email address (no username, password, or display name)
- Generate and store WebAuthn credential using device biometrics
- Support multiple credentials per user via has_many relationship
- Email must be unique across all users
- Basic email format validation (contains @)
- No email verification required for MVP

### Authentication Flow
- Single unified form for both registration and login
- User enters email, form submits without full page refresh (Turbo)
- Backend checks if email exists and responds with appropriate WebAuthn challenge
- If new email: present WebAuthn registration flow
- If existing email: present WebAuthn authentication flow
- No fallback authentication for browsers without WebAuthn support
- Display clear error message if WebAuthn not available
- HTTPS required in production (WebAuthn standard requirement)

### Session Management
- Sessions never expire automatically (truly indefinite duration)
- Database-backed sessions for durability across server restarts
- Sessions only end on explicit logout action
- Session persists across browser restarts indefinitely

### Program Ownership
- Authenticated users can create exercise programs
- Users can only edit/delete their own programs
- All programs remain publicly viewable via UUID (no auth required)
- Anonymous users can view programs but cannot create or edit them

### Session Tracking Requirements
- Anonymous users cannot start or track exercise sessions
- Users must be authenticated to start a program session
- Present "Create Account" option when anonymous user attempts to start session
- Redirect to login/registration flow, then return to program to start session

### Multi-Device Credential Storage
- Store multiple WebAuthn credentials per user
- Each device registration creates a new credential record
- User can authenticate from any registered device
- No limit on number of devices per user

## Visual Design

No visual mockups provided. Follow these design principles:

### Mobile-First Layout
- Large, clear form inputs optimized for mobile devices
- Minimum 44x44px touch targets for all interactive elements
- Clean, uncluttered single-column layout
- Clear typography with readable font sizes (minimum 16px to prevent mobile zoom)

### Authentication UI
- Single form with email input field
- Clear call-to-action button ("Continue" or "Sign In/Up")
- Loading state when checking email existence
- Clear messaging when transitioning to WebAuthn prompt
- Error states for WebAuthn failures or unsupported browsers
- Success state with brief confirmation before redirect

### Responsive Breakpoints
- Mobile: default, optimized layout
- Tablet: centered form with comfortable max-width
- Desktop: centered form, not stretched full-width

## Reusable Components

### Existing Code to Leverage
No existing authentication or user management code in codebase. This is the first user-facing feature.

### New Components Required

**Models:**
- User model (new) - manages user accounts and associations
- Credential model (new) - stores WebAuthn credentials with belongs_to relationship

**Controllers:**
- SessionsController (new) - handles authentication flow
- UsersController (new) - handles registration flow
- ApplicationController enhancement - adds current_user helpers and authentication checks

**Stimulus Controllers:**
- webauthn_controller.js (new) - handles WebAuthn JavaScript API calls for both registration and authentication

**Views/Partials:**
- Unified auth form (new) - single form handling both login and registration
- Turbo Frame for auth flow (new) - enables seamless form submission without page refresh

## Technical Approach

### Database Schema

**Users Table:**
```
- id (primary key)
- email (string, not null, unique, indexed)
- webauthn_id (string, not null, unique) - used as WebAuthn user handle
- created_at (timestamp)
- updated_at (timestamp)
```

**Credentials Table:**
```
- id (primary key)
- user_id (foreign key, indexed, not null)
- external_id (string, not null, unique) - credential ID from WebAuthn
- public_key (string, not null) - credential public key
- sign_count (integer, default 0) - counter for replay attack prevention
- nickname (string, nullable) - optional device name (not in MVP)
- created_at (timestamp)
- updated_at (timestamp)
```

### Model Relationships and Validations

**User Model:**
- Has many credentials (dependent: destroy)
- Validates email presence, uniqueness, format (basic @ check)
- Generates webauthn_id on create (SecureRandom.hex or similar)
- Method to find or create by email for unified auth flow

**Credential Model:**
- Belongs to user
- Validates presence of external_id, public_key, user_id
- Validates uniqueness of external_id
- Stores sign_count for security verification

### Routes

```ruby
# Authentication routes
get    '/auth',         to: 'sessions#new',     as: :auth
post   '/auth/check',   to: 'sessions#check',   as: :auth_check
post   '/auth/verify',  to: 'sessions#verify',  as: :auth_verify
delete '/logout',       to: 'sessions#destroy', as: :logout

# Registration routes (if separated)
post   '/register',     to: 'users#create',     as: :register
```

### Controller Logic

**SessionsController:**
- `new` - renders unified auth form in Turbo Frame
- `check` - receives email, checks if user exists, responds with Turbo Stream/Frame containing WebAuthn challenge
- `verify` - receives WebAuthn credential response, verifies it, creates session, redirects to appropriate page
- `destroy` - clears session, redirects to root

**UsersController:**
- `create` - handles new user creation with WebAuthn credential
- Validates email, creates user record, stores credential, creates session

### Turbo Frame Implementation

**Flow Architecture:**
1. Render auth form wrapped in `turbo_frame_tag "auth_flow"`
2. User enters email and submits form
3. Form submits to `auth_check` controller action via Turbo
4. Controller checks if email exists, prepares WebAuthn challenge
5. Controller responds by replacing Turbo Frame content with:
   - WebAuthn registration UI (if new email) with registration challenge
   - WebAuthn authentication UI (if existing email) with authentication challenge
6. Stimulus controller receives challenge data and triggers WebAuthn browser API
7. User completes biometric verification on device
8. Stimulus controller sends credential response back to server
9. Backend verifies credential and creates session
10. User redirected to appropriate destination

**Implementation Notes:**
- Use `data-turbo-frame="auth_flow"` on form to keep navigation within frame
- Include WebAuthn challenge data in frame response via data attributes
- Stimulus controller watches for data attribute changes to trigger WebAuthn API
- No full page refreshes throughout entire flow

### Stimulus Controller for WebAuthn

**Responsibilities:**
- Trigger WebAuthn registration: `navigator.credentials.create()`
- Trigger WebAuthn authentication: `navigator.credentials.get()`
- Handle WebAuthn API responses and errors
- Submit credential data back to Rails backend
- Display loading states during WebAuthn operations

**Key Methods:**
- `registerCredential()` - initiates WebAuthn registration flow
- `authenticateCredential()` - initiates WebAuthn authentication flow
- `handleSuccess()` - processes successful credential creation/verification
- `handleError()` - displays user-friendly error messages for WebAuthn failures

### Session Configuration

Configure Rails for indefinite sessions:

```ruby
# config/initializers/session_store.rb
Rails.application.config.session_store :active_record_store
# No session expiry configured - sessions persist indefinitely
```

Create sessions table via migration for durability across server restarts.

### WebAuthn Gem Integration

Use `webauthn` gem for server-side WebAuthn operations:

**Registration Flow:**
1. Generate registration challenge options
2. Send to client via Turbo Frame response
3. Client creates credential via WebAuthn API
4. Backend verifies credential and stores in database

**Authentication Flow:**
1. Fetch user's credentials by email
2. Generate authentication challenge options
3. Send to client via Turbo Frame response
4. Client authenticates via WebAuthn API
5. Backend verifies assertion and creates session

### Authentication Helpers

Add to ApplicationController:

```ruby
helper_method :current_user, :logged_in?

def current_user
  @current_user ||= User.find_by(id: session[:user_id]) if session[:user_id]
end

def logged_in?
  current_user.present?
end

def require_authentication
  redirect_to auth_path, alert: "Please sign in to continue" unless logged_in?
end
```

### Post-Authentication Redirect

After successful authentication:
- If user came from specific program page attempting to start session: redirect back to that program
- Otherwise: redirect to user dashboard or root path
- Store return_to path in session before redirecting to auth

### Logout Implementation

Simple logout flow:
- Clear session data: `session.delete(:user_id)` or `reset_session`
- Display confirmation message
- Redirect to root path
- Include logout link in main navigation when user is logged_in?

## Edge Cases & Error Handling

### Unsupported Browsers
- Check WebAuthn availability: `window.PublicKeyCredential`
- If unavailable: display clear message "Your browser doesn't support biometric authentication. Please use a modern browser."
- No fallback authentication method provided
- Suggest Chrome, Safari, Firefox, Edge

### WebAuthn Registration Failures
- User cancels biometric prompt: display "Registration cancelled. Please try again."
- Credential already exists: handle gracefully, may indicate user already registered on this device
- Generic errors: "Unable to register credential. Please try again."

### WebAuthn Authentication Failures
- User cancels authentication: display "Sign in cancelled."
- Credential not recognized: "Unable to verify your identity. Try another device or create a new account."
- Timeout: "Authentication timed out. Please try again."

### Email Validation Errors
- Empty email: "Email is required"
- Invalid format: "Please enter a valid email address"
- Display errors inline near email field

### Network Errors
- Timeout during email check: display retry option
- Failed credential verification: "Connection error. Please try again."
- Use Turbo error handling for failed requests

### Session Edge Cases
- Deleted user account: session becomes invalid, clear and redirect to auth
- Concurrent sessions: allow multiple sessions across devices (no session limiting)
- Session store failures: fall back to cookie-based session as temporary measure

## Testing Strategy

### Model Tests
- User validations (email presence, uniqueness, format)
- Credential validations (presence of required fields)
- User-Credential association (has_many/belongs_to)
- webauthn_id generation on user creation

### Controller Tests
- SessionsController#check returns correct Turbo response for new vs existing email
- SessionsController#verify creates session on successful credential verification
- SessionsController#destroy clears session
- Authentication required before accessing protected actions
- Post-authentication redirect flows

### Integration Tests
- Full registration flow: email submission, credential registration, session creation
- Full login flow: email submission, credential authentication, session creation
- Multi-device registration: register multiple credentials for same user
- Session persistence: session survives across requests
- Logout flow: session cleared and user redirected

### JavaScript/Stimulus Tests (Optional for MVP)
- WebAuthn Stimulus controller triggers navigator.credentials APIs
- Error handling displays appropriate messages
- Success handling submits data back to server

### Manual Testing Checklist
- Test on actual mobile devices (iOS Safari, Chrome Android)
- Verify Face ID/Touch ID prompts appear correctly
- Test registration and login on same device
- Test registration on second device with same email
- Verify session persists after browser restart
- Confirm logout clears session
- Test error states (cancel biometric prompt, unsupported browser)

## Security Considerations

### WebAuthn Security Benefits
- Phishing-resistant authentication (credentials bound to origin)
- No password storage or transmission
- Private key never leaves device
- Replay attack prevention via sign_count verification
- Biometric data never leaves user's device

### Session Security
- Database-backed sessions prevent tampering
- Session ID regeneration after authentication to prevent fixation attacks
- Secure and HTTP-only session cookies
- Use HTTPS in production (enforced by WebAuthn standard)

### Credential Storage Security
- Store only public keys in database (private keys remain on device)
- Validate credential data from client before storage
- Verify WebAuthn assertions server-side (never trust client alone)
- Sign count verification prevents credential replay attacks

### Email Privacy
- Email addresses are PII - follow data privacy best practices
- Index email for performance but ensure database security
- No email verification means potential for invalid emails - acceptable for MVP

### Authorization
- Always verify user owns resources before allowing edit/delete
- Public program viewing doesn't require auth (by design)
- Session tracking requires authentication (enforce at controller level)

## Out of Scope

### Explicitly Excluded from This Spec
- Account recovery mechanisms (email-based recovery deferred)
- Email verification during registration
- Password authentication or fallback methods
- Social login integrations (Google, Apple, GitHub, etc.)
- Two-factor authentication (2FA) - WebAuthn is already phishing-resistant
- Username or display name fields
- Anonymous-to-authenticated data migration (anonymous users cannot create data)
- Device management UI (viewing/revoking registered devices)
- Session timeout or automatic expiration
- Remember me functionality (not needed with indefinite sessions)
- Credential nickname management (future enhancement)
- Multiple email addresses per account
- Email change functionality
- Account deletion

### Deferred to Future Specs
- Account recovery flow (likely email-based magic link)
- Email verification and confirmation
- Device management dashboard
- Account settings page
- Profile customization (avatar, display name)
- Privacy settings

## Success Criteria

### Functional Success Metrics
- Users can successfully register accounts using biometric authentication
- Users can log in from registered devices without passwords
- Users can register and authenticate from multiple devices
- Sessions persist indefinitely until explicit logout
- Anonymous users are correctly prompted to create accounts when attempting session tracking
- Authenticated users can create and manage their own programs

### User Experience Goals
- Registration completes in under 30 seconds
- Login completes in under 10 seconds
- Authentication flow feels seamless with no jarring page refreshes
- Error messages are clear and actionable
- Mobile users can complete entire flow comfortably on small screens

### Security Validation
- All WebAuthn credentials verified server-side
- Sessions cannot be hijacked or tampered with
- User authorization checks prevent unauthorized program edits
- HTTPS enforced in production environment

### Technical Quality
- All model validations and tests passing
- Controller tests cover authentication flows
- Integration tests verify end-to-end registration and login
- Code follows Rails conventions and project standards
- No N+1 queries in authentication flow
