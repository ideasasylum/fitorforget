# Spec Requirements: User Authentication & Account Management

## Initial Description
Implement WebAuthn passwordless authentication for user sign-up, login, and session management using device biometrics (Face ID, Touch ID, fingerprint). Users can create accounts to own programs and track history.

## Requirements Discussion

### First Round Questions

**Q1:** Registration Flow - What information should we collect during registration?
**Answer:** Just collect email (no display name/username)

**Q2:** Anonymous User Experience - How should anonymous users interact with the app?
**Answer:** Only offer "Create Account" when they try to start a session

**Q3:** Session Duration - How long should authentication sessions last?
**Answer:** Very long-lived sessions (indefinite or very long duration)

**Q4:** WebAuthn Fallback - Should we provide fallback authentication for browsers without WebAuthn support?
**Answer:** No fallback. Don't care about older browsers

**Q5:** User Model Fields - What fields are needed in the User model?
**Answer:** Email, webauthn_id, timestamps - that's enough for MVP

**Q6:** Multiple Device Registration - Can users register multiple devices/credentials?
**Answer:** YES - Users should be able to use multiple devices

**Q7:** Account Recovery - How should users recover accounts if they lose device access?
**Answer:** Defer email recovery (not in this spec)

**Q8:** Login Flow UI - Should login and registration be separate flows?
**Answer:** Single unified flow for both login and registration

**Q9:** Program Ownership - How do user accounts relate to program creation?
**Answer:** Users can only edit their own programs, but all programs are publicly viewable via UUID

**Q10:** Anonymous-to-Authenticated Migration - Should anonymous users be able to migrate their data?
**Answer:** Anonymous users cannot track sessions - they must register first. No migration required.

**Q11:** Mobile-First UI - What are the UI expectations for auth screens?
**Answer:** Very simple, clean layouts

**Q12:** Exclusions - What should NOT be included?
**Answer:** No 2FA, no social logins, nothing that isn't strictly necessary to identify a user

### Follow-up Questions

**Follow-up 1:** Session Duration - What specific session duration should we implement?
**Answer:** Sessions never expire (truly indefinite - only expire on explicit logout)

**Follow-up 2:** Unified Auth Flow Logic - How should the unified auth flow work technically?
**Answer:** Option A - Single form where user enters email, backend checks if exists, shows appropriate WebAuthn prompt (register new credential OR authenticate existing). IMPORTANT: Use Turbo so there's no full page refresh after entering the email.

### Existing Code to Reference
No similar existing features identified for reference.

## Visual Assets

### Files Provided:
No visual assets provided.

### Visual Insights:
No visual assets provided.

## Requirements Summary

### Functional Requirements

#### User Registration
- Collect email address only during registration
- Generate WebAuthn credential using device biometrics
- Store credential in database (credential_id, public_key, sign_count)
- Support multiple credentials per user (has_many relationship)
- No username or display name required
- No password field needed

#### Authentication Flow
- Single unified form handling both new user registration and existing user login
- User enters email in single form
- Backend checks if email exists without full page refresh (using Turbo)
- If email is new: trigger WebAuthn registration flow
- If email exists: trigger WebAuthn authentication flow
- Present "Create Account" option only when anonymous users attempt to start a session
- No fallback authentication for older browsers
- HTTPS required in production (WebAuthn requirement)

#### Session Management
- Truly indefinite sessions - never expire automatically
- Sessions only expire on explicit user logout
- Persistent authentication across browser sessions
- No forced re-authentication timeframes
- Session should survive browser restarts indefinitely

#### User-Program Relationship
- Users can create and own exercise programs
- Users can only edit/delete their own programs
- All programs remain publicly viewable via UUID (no auth required for viewing)
- Users can track session history for programs they follow

#### Multi-Device Support
- Users can register multiple devices/credentials
- Each device gets its own WebAuthn credential
- User can authenticate from any registered device
- No device limit specified

#### Anonymous User Restrictions
- Anonymous users can view programs via UUID links
- Anonymous users CANNOT start or track sessions
- Must create account before tracking any exercise sessions
- No data migration from anonymous to authenticated state needed

### Reusability Opportunities
No similar existing features identified. This is the first authentication implementation for the application.

### Scope Boundaries

**In Scope:**
- WebAuthn passwordless authentication implementation
- User model with email and credential storage
- Registration flow (email + biometric credential creation)
- Login flow (email + biometric authentication)
- Single unified auth UI flow using Turbo (no full page refreshes)
- Multi-device/multi-credential support
- Indefinite session management (only expires on logout)
- Gating session tracking behind authentication
- User ownership of programs
- Basic user profile/account page

**Out of Scope:**
- Account recovery mechanisms (deferred to future spec)
- Email verification during registration
- Password authentication or fallback methods
- Social login integrations (Google, Apple, etc.)
- Two-factor authentication (2FA)
- Username or display name fields
- Anonymous-to-authenticated data migration
- Device management UI (viewing/removing registered devices)
- Session timeout or automatic expiration
- Remember me functionality (not needed with indefinite sessions)

### Technical Considerations

#### Database Schema
- User model fields: `email`, `webauthn_id`, `created_at`, `updated_at`
- Credential model for has_many relationship (to support multiple devices)
- Need credential fields: `credential_id`, `public_key`, `sign_count`, `user_id`
- Email uniqueness constraint required
- Consider adding index on email for lookup performance

#### Development Environment
- Use mise (https://mise.jdx.dev) for managing Ruby and Node.js dependencies
- Create mise.toml file in project root with Ruby and Node.js versions
- Ensures consistent development environment across team members

#### Integration Points
- WebAuthn gem for credential creation and verification
- Rails 8 built-in session management
- Turbo/Stimulus for frontend authentication flow
- Tailwind CSS for mobile-first auth UI
- SQLite database (ActiveRecord)

#### Technical Constraints
- Requires HTTPS in production (WebAuthn standard requirement)
- WebAuthn browser support: ~95% (all modern devices)
- No Postgres - must work with SQLite
- Mobile-first responsive design required
- Large touch targets (44x44px minimum) for mobile interaction

#### Turbo Implementation Approach for Unified Auth Flow

**Flow Architecture:**
1. Single form wrapped in Turbo Frame (e.g., `turbo_frame_tag "auth_flow"`)
2. User enters email and submits
3. Backend controller action:
   - Checks if email exists in database
   - Responds with Turbo Stream or Frame update (no full page refresh)
   - If new email: replace frame content with WebAuthn registration UI + JavaScript to trigger credential creation
   - If existing email: replace frame content with WebAuthn authentication UI + JavaScript to trigger credential authentication
4. WebAuthn JavaScript triggers appropriate browser API
5. Credential data sent back to Rails backend
6. Session created and user redirected

**Technical Implementation Notes:**
- Use `turbo_frame_tag` to wrap the email input form
- Controller responds with `turbo_stream` or partial replacement of frame content
- Stimulus controller handles WebAuthn JavaScript API calls
- Response includes appropriate WebAuthn challenge data from backend
- No full page reloads throughout entire flow
- Leverage Rails 8 Turbo capabilities for seamless UX

**Alternatives Considered:**
- Turbo Streams vs Turbo Frames: Either approach works - Frames are simpler for content replacement, Streams offer more granular control
- Could use data attributes + Stimulus to handle flow client-side, but backend check is more secure

#### Session Duration Implementation
- Rails session configuration: no expiry timeout
- Database-backed sessions recommended for indefinite persistence (not cookie-only)
- Session only destroyed on explicit logout action
- Consider using `Rails.application.config.session_store :active_record_store` for durability

### Additional Clarifications Needed

**OPTIONAL - Email Validation:**
Should we validate email format or just accept any string?
- Basic format validation (contains @)?
- No validation at all?

**OPTIONAL - Post-Authentication Redirect:**
After successful authentication, where should users land?
- Dashboard showing their created programs?
- Back to the program they were viewing (if came from session start)?
- Simple "You're logged in" confirmation?

**OPTIONAL - Logout Mechanism:**
How should users log out?
- Explicit logout button/link?
- Menu item in navigation?
- Account page option?

**OPTIONAL - Account Page:**
What should a basic account/profile page show?
- Just email address and logout button?
- List of created programs?
- Session history?
- Nothing (defer to future spec)?
