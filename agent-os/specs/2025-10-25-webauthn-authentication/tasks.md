# Task Breakdown: WebAuthn Passwordless Authentication

## Overview
Total Task Groups: 5
Estimated Complexity: Large (L)

This breakdown implements passwordless authentication using WebAuthn biometrics, enabling users to create accounts, own programs, and track exercise sessions. The implementation follows a strategic bottom-up approach: foundation setup, database layer, backend logic, frontend UI, and finally strategic test coverage.

## Task List

### Foundation Layer

#### Task Group 1: Rails Setup & Dependencies
**Dependencies:** None

- [x] 1.0 Complete Rails foundation setup
  - [x] 1.1 Add webauthn gem to Gemfile
    - Add `gem "webauthn"` to Gemfile
    - Run `bundle install`
    - Version: Use latest stable release
  - [x] 1.2 Configure session store for indefinite sessions
    - Generate sessions migration: `rails generate session_migration`
    - Run migration to create sessions table
    - Create `/config/initializers/session_store.rb`
    - Configure: `Rails.application.config.session_store :active_record_store`
    - No expiry timeout - sessions persist indefinitely
  - [x] 1.3 Configure WebAuthn gem settings
    - Create `/config/initializers/webauthn.rb`
    - Set origin based on environment (localhost for dev, production domain)
    - Set relying party name (e.g., "Fit or Forget")
    - Configure credential options (timeout, user verification)
  - [x] 1.4 Enable secure session cookies
    - In session_store.rb, set `secure: true` for production
    - Set `httponly: true` to prevent XSS attacks
    - Set `same_site: :lax` for CSRF protection
  - [x] 1.5 Create mise.toml for dependency management
    - Create `mise.toml` in project root
    - Specify Ruby version (e.g., `ruby = "3.3.0"` or latest)
    - Specify Node.js version (e.g., `node = "20"` or latest LTS)
    - Reference: https://mise.jdx.dev
    - Ensure versions align with Rails 8 requirements

**Acceptance Criteria:**
- webauthn gem installed and available
- Sessions table created in database
- Session store configured for database-backed, indefinite sessions
- WebAuthn initializer properly configured for development and production
- Session cookies secured with appropriate flags
- mise.toml created with Ruby and Node.js versions specified

---

### Database Layer

#### Task Group 2: User & Credential Models
**Dependencies:** Task Group 1

- [ ] 2.0 Complete database schema and models
  - [ ] 2.1 Write 2-8 focused tests for User model
    - Limit to 2-8 highly focused tests maximum
    - Test critical behaviors only:
      - Email presence validation
      - Email uniqueness validation
      - Email format validation (contains @)
      - webauthn_id generation on create
      - has_many credentials association
    - Skip exhaustive edge case testing
  - [ ] 2.2 Create User model and migration
    - Generate: `rails generate model User email:string webauthn_id:string`
    - Migration fields:
      - `email` (string, not null, unique, indexed)
      - `webauthn_id` (string, not null, unique)
      - `created_at`, `updated_at` (timestamps)
    - Add database constraints in migration:
      - `add_index :users, :email, unique: true`
      - `add_null_constraint :users, :email`
      - `add_null_constraint :users, :webauthn_id`
  - [ ] 2.3 Implement User model validations
    - Validate email presence
    - Validate email uniqueness (case-insensitive)
    - Validate email format (basic: must contain @)
    - Generate webauthn_id before_create using SecureRandom.hex
  - [ ] 2.4 Write 2-8 focused tests for Credential model
    - Limit to 2-8 highly focused tests maximum
    - Test critical behaviors only:
      - Required field validations (external_id, public_key, user_id)
      - external_id uniqueness validation
      - belongs_to user association
      - Default sign_count value
    - Skip exhaustive edge case testing
  - [ ] 2.5 Create Credential model and migration
    - Generate: `rails generate model Credential user:references external_id:string public_key:text sign_count:integer`
    - Migration fields:
      - `user_id` (foreign key, indexed, not null)
      - `external_id` (string, not null, unique, indexed)
      - `public_key` (text, not null)
      - `sign_count` (integer, default: 0, not null)
      - `nickname` (string, nullable) - for future use
      - `created_at`, `updated_at` (timestamps)
    - Add database constraints:
      - `add_index :credentials, :external_id, unique: true`
      - `add_foreign_key :credentials, :users, on_delete: :cascade`
  - [ ] 2.6 Implement Credential model validations and associations
    - Validate presence of: external_id, public_key, user_id
    - Validate uniqueness of external_id
    - belongs_to :user (required: true)
    - Set default sign_count: 0
  - [ ] 2.7 Set up User-Credential association
    - Add `has_many :credentials, dependent: :destroy` to User model
    - Verify association works in both directions
  - [ ] 2.8 Run migrations and verify database schema
    - Execute: `rails db:migrate`
    - Verify tables created: users, credentials, sessions
    - Verify indexes and constraints applied correctly
  - [ ] 2.9 Ensure database layer tests pass
    - Run ONLY the tests written in 2.1 and 2.4 (6-16 tests maximum)
    - Verify all validations work correctly
    - Verify associations function properly
    - Do NOT run entire test suite at this stage

**Acceptance Criteria:**
- The 6-16 tests written in 2.1 and 2.4 pass
- Users table created with email, webauthn_id, timestamps
- Credentials table created with proper foreign key to users
- All database constraints enforced (not null, unique, indexes)
- User model validates email format, presence, uniqueness
- User model generates webauthn_id on creation
- Credential model validates required fields and uniqueness
- has_many/belongs_to associations work correctly
- Migrations run successfully without errors

---

### Backend Layer

#### Task Group 3: Authentication Controllers & Routes
**Dependencies:** Task Group 2

- [ ] 3.0 Complete backend authentication logic
  - [ ] 3.1 Write 2-8 focused tests for SessionsController
    - Limit to 2-8 highly focused tests maximum
    - Test critical controller actions only:
      - GET /auth renders auth form
      - POST /auth/check returns registration challenge for new email
      - POST /auth/check returns authentication challenge for existing email
      - POST /auth/verify creates session on valid credential
      - DELETE /logout clears session and redirects
    - Skip exhaustive scenarios and edge cases
  - [ ] 3.2 Configure authentication routes
    - Add to `config/routes.rb`:
      - `get '/auth', to: 'sessions#new', as: :auth`
      - `post '/auth/check', to: 'sessions#check', as: :auth_check`
      - `post '/auth/verify', to: 'sessions#verify', as: :auth_verify`
      - `delete '/logout', to: 'sessions#destroy', as: :logout`
    - Follow RESTful conventions
    - Use named routes for clarity
  - [ ] 3.3 Create SessionsController with new action
    - Generate: `rails generate controller Sessions`
    - Implement `new` action:
      - Render unified auth form
      - Wrap in Turbo Frame: `turbo_frame_tag "auth_flow"`
      - Simple form with email input only
  - [ ] 3.4 Implement SessionsController#check action
    - Accept email parameter
    - Validate email format (basic @ check)
    - Check if User.exists?(email: params[:email])
    - If new email (user not found):
      - Generate WebAuthn registration challenge using webauthn gem
      - Prepare registration options with user email and webauthn_id
      - Respond with Turbo Frame containing registration UI + challenge data
    - If existing email (user found):
      - Fetch user's credentials
      - Generate WebAuthn authentication challenge
      - Respond with Turbo Frame containing authentication UI + challenge data
    - Use data attributes to pass challenge to Stimulus controller
  - [ ] 3.5 Implement SessionsController#verify action
    - Handle WebAuthn credential response from client
    - For registration flow:
      - Verify WebAuthn credential using webauthn gem
      - Create new User record with email
      - Create new Credential record with external_id, public_key, sign_count
      - Create session: `session[:user_id] = user.id`
      - Regenerate session ID for security
      - Redirect to return_to path or root
    - For authentication flow:
      - Find user by email
      - Find matching credential by external_id
      - Verify WebAuthn assertion using webauthn gem
      - Update credential sign_count
      - Create session: `session[:user_id] = user.id`
      - Regenerate session ID for security
      - Redirect to return_to path or root
    - Handle verification failures with clear error messages
  - [ ] 3.6 Implement SessionsController#destroy action
    - Clear session: `reset_session`
    - Set flash message: "You have been logged out"
    - Redirect to root_path
  - [ ] 3.7 Add authentication helpers to ApplicationController
    - Create helper_method: `current_user`
      - Memoize: `@current_user ||= User.find_by(id: session[:user_id])`
      - Return nil if session[:user_id] not present
    - Create helper_method: `logged_in?`
      - Return: `current_user.present?`
    - Create before_action: `require_authentication`
      - Redirect to auth_path unless logged_in?
      - Store return_to in session before redirect
      - Set flash alert: "Please sign in to continue"
  - [ ] 3.8 Implement return_to redirect logic
    - In require_authentication: `session[:return_to] = request.fullpath`
    - In verify action after successful auth:
      - `redirect_to session.delete(:return_to) || root_path`
    - Clear return_to after use to prevent stale redirects
  - [ ] 3.9 Ensure backend layer tests pass
    - Run ONLY the tests written in 3.1 (2-8 tests maximum)
    - Verify critical controller flows work
    - Verify session creation and destruction
    - Do NOT run entire test suite at this stage

**Acceptance Criteria:**
- The 2-8 tests written in 3.1 pass
- Routes configured for auth, check, verify, logout
- SessionsController#new renders unified auth form
- SessionsController#check distinguishes new vs existing users
- SessionsController#check generates appropriate WebAuthn challenges
- SessionsController#verify creates sessions on successful credential verification
- SessionsController#destroy clears sessions properly
- current_user and logged_in? helpers work correctly
- require_authentication before_action redirects unauthenticated users
- return_to logic redirects users back to intended destination

---

### Frontend Layer

#### Task Group 4: Authentication UI & WebAuthn Integration
**Dependencies:** Task Group 3

- [ ] 4.0 Complete frontend authentication interface
  - [ ] 4.1 Write 2-8 focused tests for Stimulus WebAuthn controller
    - Limit to 2-8 highly focused tests maximum
    - Test critical JavaScript behaviors only:
      - WebAuthn browser API availability detection
      - Registration credential creation triggered
      - Authentication credential retrieval triggered
      - Error handling displays user-friendly messages
    - Use JavaScript testing framework (if available) or manual testing
    - Skip exhaustive interaction testing
  - [ ] 4.2 Create unified auth form view
    - Create `app/views/sessions/new.html.erb`
    - Wrap entire form in: `turbo_frame_tag "auth_flow"`
    - Single email input field:
      - Type: email
      - Required: true
      - Autofocus: true
      - Placeholder: "Enter your email"
      - Large touch target (min 44px height)
    - Submit button: "Continue" or "Sign In / Sign Up"
    - Clear, simple layout using Tailwind CSS
    - Mobile-first responsive design
  - [ ] 4.3 Create Turbo Frame partials for WebAuthn flows
    - Create `app/views/sessions/_register.html.erb`:
      - Wrap in: `turbo_frame_tag "auth_flow"`
      - Display message: "Create your account using biometrics"
      - Hidden fields with WebAuthn challenge data (data attributes)
      - Stimulus controller target: `data-controller="webauthn"`
      - Action: `data-action="turbo:frame-load->webauthn#register"`
      - Loading indicator while WebAuthn prompt active
    - Create `app/views/sessions/_authenticate.html.erb`:
      - Wrap in: `turbo_frame_tag "auth_flow"`
      - Display message: "Sign in with your biometric"
      - Hidden fields with WebAuthn challenge data (data attributes)
      - Stimulus controller target: `data-controller="webauthn"`
      - Action: `data-action="turbo:frame-load->webauthn#authenticate"`
      - Loading indicator while WebAuthn prompt active
  - [ ] 4.4 Generate Stimulus WebAuthn controller
    - Create: `app/javascript/controllers/webauthn_controller.js`
    - Import Stimulus controller base
    - Define targets: challenge, credential, form
  - [ ] 4.5 Implement WebAuthn registration in Stimulus controller
    - Method: `register()`
    - Check browser support: `if (!window.PublicKeyCredential)`
      - Display error: "Your browser doesn't support biometric authentication"
      - Suggest modern browsers
      - Return early
    - Parse challenge data from data attributes
    - Convert base64-encoded challenge to ArrayBuffer
    - Call: `navigator.credentials.create({ publicKey: options })`
    - Handle success:
      - Extract credential ID and response
      - Convert ArrayBuffer to base64
      - Submit to backend via form or fetch to auth_verify_path
    - Handle errors:
      - User cancelled: "Registration cancelled. Please try again."
      - Generic error: "Unable to register credential. Please try again."
      - Display errors in UI
  - [ ] 4.6 Implement WebAuthn authentication in Stimulus controller
    - Method: `authenticate()`
    - Check browser support (same as registration)
    - Parse challenge data from data attributes
    - Convert base64 challenge and credential IDs to ArrayBuffer
    - Call: `navigator.credentials.get({ publicKey: options })`
    - Handle success:
      - Extract credential response
      - Convert ArrayBuffer to base64
      - Submit to backend via form or fetch to auth_verify_path
    - Handle errors:
      - User cancelled: "Sign in cancelled."
      - Credential not recognized: "Unable to verify your identity."
      - Timeout: "Authentication timed out. Please try again."
      - Display errors in UI
  - [ ] 4.7 Style authentication UI with Tailwind CSS
    - Mobile-first responsive layout
    - Center form on screen (max-width: ~400px)
    - Large, clear typography (min 16px to prevent mobile zoom)
    - High-contrast colors for readability
    - Clear visual hierarchy
    - Touch-friendly buttons (min 44x44px)
    - Loading states with spinners or animations
    - Error states with red text and icons
    - Success states with brief confirmation
  - [ ] 4.8 Add logout link to navigation
    - Add to main layout (`app/views/layouts/application.html.erb`)
    - Show only when `logged_in?`
    - Link to: `logout_path, method: :delete`
    - Confirm before logout (optional)
    - Mobile-friendly placement
  - [ ] 4.9 Implement error display for auth failures
    - Create error partial: `app/views/sessions/_error.html.erb`
    - Display flash messages for:
      - Invalid email format
      - WebAuthn verification failures
      - Network errors
    - Style with Tailwind alert classes
    - Auto-dismiss after few seconds (optional)
  - [ ] 4.10 Ensure frontend layer tests pass
    - Run ONLY the tests written in 4.1 (2-8 tests maximum)
    - Manually test WebAuthn flows on actual devices:
      - iOS Safari with Face ID/Touch ID
      - Android Chrome with fingerprint
      - Desktop Chrome with Windows Hello
    - Verify Turbo Frame updates work without page refresh
    - Do NOT run entire test suite at this stage

**Acceptance Criteria:**
- The 2-8 tests written in 4.1 pass (or manual testing completed)
- Unified auth form renders with email input
- Turbo Frame wraps entire auth flow
- Registration partial displays WebAuthn registration prompt
- Authentication partial displays WebAuthn authentication prompt
- Stimulus controller successfully triggers WebAuthn browser APIs
- Registration flow creates credentials and logs in user
- Authentication flow verifies credentials and logs in user
- Error messages display clearly for failures
- Mobile-first styling with Tailwind CSS
- Logout link appears when user logged in
- No full page refreshes during entire auth flow

---

### Testing & Validation Layer

#### Task Group 5: Strategic Test Coverage & Integration Testing
**Dependencies:** Task Groups 1-4

- [ ] 5.0 Review and fill critical testing gaps
  - [ ] 5.1 Review existing tests from Task Groups 2-4
    - Review tests written for User model (Task 2.1)
    - Review tests written for Credential model (Task 2.4)
    - Review tests written for SessionsController (Task 3.1)
    - Review tests written for WebAuthn Stimulus controller (Task 4.1)
    - Total existing tests: approximately 8-32 tests
  - [ ] 5.2 Analyze test coverage gaps for authentication feature
    - Identify critical end-to-end user workflows lacking coverage:
      - Complete registration flow (email -> WebAuthn -> session creation)
      - Complete login flow (email -> WebAuthn -> session authentication)
      - Multi-device registration (same email, different credentials)
      - Session persistence across requests
      - Logout flow clearing session
      - Authentication requirement enforcement
    - Focus ONLY on integration gaps, not unit test gaps
    - Prioritize user-facing workflows over internal logic
  - [ ] 5.3 Write up to 10 additional integration tests maximum
    - Add maximum of 10 new integration tests to fill gaps
    - Create `test/integration/authentication_flows_test.rb`:
      - Test: Full registration flow creates user, credential, and session
      - Test: Full login flow authenticates existing user
      - Test: Multi-device registration creates multiple credentials
      - Test: Session persists across requests
      - Test: Logout clears session and redirects
      - Test: require_authentication redirects unauthenticated users
      - Test: return_to redirects after successful authentication
    - Focus on end-to-end workflows, not edge cases
    - Mock WebAuthn browser API calls for testing
    - Use Rails integration test helpers (get, post, session, etc.)
  - [ ] 5.4 Add model-level edge case tests if business-critical
    - Add ONLY if critical for data integrity:
      - Test: Email case-insensitivity for uniqueness
      - Test: Credential sign_count increment on authentication
      - Test: User deletion cascades to credentials
    - Maximum 3-5 additional tests
    - Skip if not business-critical
  - [ ] 5.5 Add controller-level edge case tests if business-critical
    - Add ONLY if critical for security:
      - Test: Invalid WebAuthn credential rejected
      - Test: Mismatched credential user rejected
      - Test: Session ID regenerated after authentication
    - Maximum 3-5 additional tests
    - Skip if not business-critical
  - [ ] 5.6 Run feature-specific test suite
    - Run ONLY tests related to authentication feature
    - Expected total: approximately 18-52 tests maximum
    - Execute: `rails test test/models/user_test.rb test/models/credential_test.rb test/controllers/sessions_controller_test.rb test/integration/authentication_flows_test.rb`
    - Verify all critical workflows pass
    - Do NOT run entire application test suite
  - [ ] 5.7 Manual testing on actual devices
    - Test registration on iOS Safari (Face ID/Touch ID)
    - Test login on iOS Safari
    - Test registration on Android Chrome (fingerprint)
    - Test login on Android Chrome
    - Test registration on desktop (Windows Hello/Touch ID)
    - Test session persistence after browser restart
    - Test logout functionality
    - Verify error states display correctly
    - Confirm WebAuthn unsupported browser message works
  - [ ] 5.8 Security validation checklist
    - Verify HTTPS enforced in production
    - Verify session cookies are secure and httponly
    - Verify WebAuthn credentials verified server-side
    - Verify sign_count checked to prevent replay attacks
    - Verify session ID regenerated after authentication
    - Verify authorization checks prevent unauthorized access
    - Verify email validation prevents empty/invalid emails
    - Verify credential uniqueness enforced at database level

**Acceptance Criteria:**
- All feature-specific tests pass (approximately 18-52 tests total)
- No more than 10 integration tests added in Task 5.3
- Critical registration and login workflows covered by integration tests
- Multi-device registration workflow tested
- Session persistence and logout workflows tested
- Manual testing completed on iOS, Android, and desktop devices
- Security validation checklist completed and verified
- Testing focused exclusively on authentication feature requirements

---

## Execution Order

Recommended implementation sequence:

1. **Foundation Layer** (Task Group 1) - Set up Rails environment, gems, sessions, and WebAuthn configuration
2. **Database Layer** (Task Group 2) - Create User and Credential models with validations and associations
3. **Backend Layer** (Task Group 3) - Implement controllers, routes, and authentication helpers
4. **Frontend Layer** (Task Group 4) - Build unified auth UI, Turbo Frames, and Stimulus WebAuthn controller
5. **Testing & Validation Layer** (Task Group 5) - Add strategic integration tests and perform manual device testing

## Implementation Notes

### WebAuthn Flow Summary

**Registration (New User):**
1. User enters email in unified form
2. Form submits to SessionsController#check (Turbo, no page refresh)
3. Backend checks email doesn't exist
4. Backend generates WebAuthn registration challenge
5. Backend responds with Turbo Frame containing registration UI
6. Stimulus controller triggers `navigator.credentials.create()`
7. User approves biometric on device (Face ID/Touch ID/fingerprint)
8. Stimulus controller receives credential response
9. Stimulus submits credential to SessionsController#verify
10. Backend verifies credential and creates User + Credential records
11. Backend creates session and redirects

**Authentication (Existing User):**
1. User enters email in unified form
2. Form submits to SessionsController#check (Turbo, no page refresh)
3. Backend checks email exists
4. Backend fetches user's credentials and generates authentication challenge
5. Backend responds with Turbo Frame containing authentication UI
6. Stimulus controller triggers `navigator.credentials.get()`
7. User approves biometric on device
8. Stimulus controller receives assertion response
9. Stimulus submits assertion to SessionsController#verify
10. Backend verifies assertion and updates sign_count
11. Backend creates session and redirects

### Key Technical Decisions

- **Database:** SQLite with WAL mode for concurrent read performance
- **Session Store:** Database-backed (ActiveRecord) for indefinite duration
- **Session Expiry:** Never (only explicit logout)
- **Email Validation:** Basic format check (contains @), no verification
- **Multi-Device:** has_many credentials per user
- **Turbo Frames:** Keep auth flow within frame, no full page refreshes
- **WebAuthn Gem:** Server-side credential verification and challenge generation
- **Browser Support:** No fallback for unsupported browsers
- **Mobile-First:** Tailwind CSS with min 44px touch targets, min 16px font size

### Security Considerations

- HTTPS required in production (WebAuthn standard)
- Secure, httponly session cookies
- Session ID regeneration after authentication
- Server-side WebAuthn credential verification
- Sign count verification prevents replay attacks
- Database constraints enforce data integrity
- Credentials dependent: :destroy on user deletion
- Private keys never leave user's device
- Public keys stored in database, not private keys

### Testing Strategy

- **Minimal tests during development:** 2-8 tests per task group
- **Focus on critical workflows:** Registration, login, multi-device
- **Integration over unit:** End-to-end flows more important than isolated units
- **Manual device testing:** iOS Safari, Android Chrome, desktop browsers
- **Strategic gap filling:** Maximum 10 additional tests in testing phase
- **Feature-focused:** Only test authentication feature, not entire app

### Performance Considerations

- Email lookups indexed for fast queries
- Credential external_id indexed for fast authentication
- Session store in database for durability
- Memoize current_user to prevent repeated queries
- No N+1 queries in authentication flow

### Accessibility & UX

- Large touch targets (min 44x44px) for mobile
- Clear typography (min 16px) to prevent mobile zoom
- High-contrast colors for readability
- Loading states during WebAuthn operations
- Clear error messages for failures
- Success confirmations before redirect
- Mobile-first responsive design
- Single-column layout for simplicity

## Success Metrics

### Functional Success
- Users can register accounts using biometric authentication
- Users can log in from registered devices without passwords
- Users can register and authenticate from multiple devices
- Sessions persist indefinitely until explicit logout
- Anonymous users prompted to create accounts when attempting restricted actions
- Authenticated users can create and manage their own programs

### User Experience Goals
- Registration completes in under 30 seconds
- Login completes in under 10 seconds
- Authentication flow feels seamless with no page refreshes
- Error messages are clear and actionable
- Mobile users can complete entire flow comfortably on small screens

### Technical Quality
- All feature-specific tests passing (18-52 tests)
- No N+1 queries in authentication flow
- Code follows Rails conventions and project standards
- Database constraints enforce data integrity
- Sessions secured with proper cookie flags
- WebAuthn credentials verified server-side

### Security Validation
- HTTPS enforced in production
- Sessions cannot be hijacked or tampered with
- User authorization prevents unauthorized program edits
- Replay attack prevention via sign_count verification
- Phishing-resistant authentication (WebAuthn standard)
