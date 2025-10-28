# Spec Requirements: Playwright System Tests

## Initial Description

The application currently lacks integration tests that validate JavaScript and Turbo interactions, making it brittle. We need to create comprehensive system tests using Playwright that cover core user workflows:

1. Creating a program
2. Adding exercises to the program
3. Starting a workout from a program
4. Completing the workout and viewing the dashboard

Key technical challenge: The app uses WebAuthn authentication. We need to determine the best approach for handling authentication during system tests. Options include:
- Providing pre-authenticated session cookies to the browser
- Disabling authentication for system testing
- Other approaches

The webauthn-ruby gem has testing documentation at https://github.com/cedarcode/webauthn-ruby?tab=readme-ov-file#testing-your-integration but this appears focused on unit/integration testing rather than full system tests with a real browser.

## Requirements Discussion

### First Round Questions

**Q1: Authentication Testing Approach**
**Answer:** Bypass WebAuthn for testing (similar to existing integration tests with sign_in_as helper)

**Q2: Test Environment Setup**
**Answer:** Use the existing test database (SQLite for tests)

**Q3: Turbo Frame/Stream Testing Coverage**
**Answer:** Test Turbo forms/interactions. No need to test fallback behaviors when JS isn't available.

**Q4: Stimulus Controller Testing**
**Answer:** Don't include WebAuthn controller in testing (covered by auth bypass)

**Q5: Mobile Viewport Testing**
**Answer:** Test on both mobile and desktop viewports

**Q6: Test Data Strategy**
**Answer:** Fresh data for each test run (clean slate)

**Q7: CI/CD Browser Coverage**
**Answer:** Just Chromium is fine

**Q8: Completion Criteria**
**Answer:** Just the core flows for now (no error states):
- Creating a program
- Adding exercises to the program
- Starting a workout from a program
- Completing the workout and viewing the dashboard

### Existing Code to Reference

**Similar Features Identified:**
- Feature: Integration test authentication helper - Path: `/Users/jamie/code/fitorforget/test/test_helper.rb`
- Authentication bypass pattern: The `sign_in_as(user)` helper method creates a session in the database and sets session cookies, bypassing WebAuthn completely. This same pattern should be adapted for Playwright tests.

### Follow-up Questions

No follow-up questions needed.

## Visual Assets

### Files Provided:
No visual assets provided.

### Visual Insights:
Not applicable.

## Requirements Summary

### Functional Requirements

**Core Test Workflows:**
1. **Program Creation Flow**
   - User navigates to program creation page
   - User fills in program details (title, description)
   - User submits the form
   - System creates program and redirects to program detail page
   - User sees confirmation of successful creation

2. **Exercise Addition Flow**
   - User views their created program
   - User clicks to add new exercise
   - User fills in exercise details (name, repeat count, video URL, description)
   - User submits exercise form
   - System adds exercise to program (using Turbo frames/streams)
   - User sees the new exercise appear in the program's exercise list
   - User can add multiple exercises sequentially

3. **Workout Start Flow**
   - User navigates to a program (via UUID link or program library)
   - User clicks to start a workout session
   - System creates a new session
   - User sees the first exercise in the workout interface
   - User can navigate through exercises

4. **Workout Completion Flow**
   - User marks each exercise as complete during active session
   - System updates progress indicators (using Turbo)
   - User completes all exercises in the session
   - User finishes the session
   - System records session completion with timestamp
   - User is redirected to dashboard
   - User sees the completed session in their history

**JavaScript and Turbo Interactions to Validate:**
- Turbo Frame updates when adding exercises to programs
- Turbo Stream updates when marking exercises complete
- Exercise progression UI updates (Stimulus controllers)
- Form submissions with Turbo (no full page reloads)
- Dynamic content updates without page refresh

**Authentication Handling:**
- Bypass WebAuthn authentication entirely during tests
- Use session creation approach similar to existing `sign_in_as` helper
- Create authenticated session before tests run
- Pass session cookie to Playwright browser context

**Viewport Testing:**
- Desktop viewport: 1280x720 or similar standard desktop size
- Mobile viewport: 375x667 (iPhone SE) or similar standard mobile size
- Both viewports should validate the same workflows
- Ensure mobile-first design works correctly on both sizes

**Test Data Management:**
- Fresh database state for each test run
- Clean slate approach: reset database before running Playwright tests
- Create test users, programs, and exercises as needed per test
- No reliance on fixtures or pre-existing data
- Each test should be independent and create its own data

### Reusability Opportunities

**Existing Patterns to Leverage:**
- `sign_in_as(user)` helper from `/Users/jamie/code/fitorforget/test/test_helper.rb` demonstrates the session creation pattern
- Active Record session store usage for authentication bypass
- Rails test database configuration and setup
- Existing minitest setup and conventions

**Code Reuse Strategy:**
- Create similar authentication helper for Playwright that generates session cookies
- Reuse Rails test database for Playwright tests (run against same test environment)
- Leverage existing test fixtures if needed for seed data

### Scope Boundaries

**In Scope:**
- Playwright test setup and configuration
- Authentication bypass mechanism using session cookies
- Four core user workflow tests (program creation, exercise addition, workout start, workout completion)
- Testing on both mobile and desktop viewports
- Validation of Turbo Frame and Turbo Stream interactions
- Integration with existing Rails test environment and database
- CI/CD setup for running Playwright tests in Chromium

**Out of Scope:**
- Error state testing (e.g., validation failures, network errors)
- Cross-browser testing (Safari, Firefox) - Chromium only
- Testing without JavaScript enabled (fallback behaviors)
- WebAuthn controller or authentication flow testing
- Performance testing or load testing
- Accessibility testing (may be added later)
- Visual regression testing
- Testing of edge cases or error conditions
- Testing of features beyond the four core workflows
- Video playback testing within exercises
- Offline/PWA functionality testing

### Technical Considerations

**Playwright Setup:**
- Install Playwright as npm/yarn dependency
- Configure Playwright to run against Rails test server
- Set up test scripts in package.json
- Configure Playwright for Chromium browser only
- Define viewport configurations for mobile and desktop

**Rails Integration:**
- Playwright tests should start Rails test server automatically
- Use `RAILS_ENV=test` to ensure test database is used
- Tests should run against `http://localhost:3000` or similar test server URL
- May need to handle server startup/shutdown in test setup

**Authentication Bypass Implementation:**
- Create a helper endpoint or script to generate authenticated session cookies
- Store session in `ActiveRecord::SessionStore::Session` table (same as existing helper)
- Pass session cookie to Playwright browser context before tests
- Ensure session is valid for the duration of test run

**Database Management:**
- Reset test database before Playwright test runs
- Use Rails test database migrations and schema
- Consider using `rails db:test:prepare` or similar command
- May need to handle database transactions or cleanup between tests

**CI/CD Configuration:**
- Add Playwright to GitHub Actions workflow
- Install Playwright browsers in CI environment
- Ensure Rails test environment is properly configured in CI
- Run Playwright tests after unit/integration tests
- Configure test output and reporting

**Technology Constraints:**
- Rails 8.1 with Turbo and Stimulus
- SQLite test database
- WebAuthn authentication (to be bypassed)
- Tailwind CSS for styling
- ActiveRecord session store
- Node.js and yarn for Playwright installation

**Testing Framework Decisions:**
- Use Playwright Test runner (not Jest or other test runners)
- Write tests in JavaScript/TypeScript
- Use Playwright's built-in assertions
- Organize tests by workflow (one test file per core flow)
- Follow Playwright best practices for selectors and assertions
