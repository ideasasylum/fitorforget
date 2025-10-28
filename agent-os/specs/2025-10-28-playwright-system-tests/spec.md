# Specification: Rails System Tests with Playwright Driver

## Goal
Add comprehensive end-to-end testing using Rails System Tests with Playwright driver to validate JavaScript interactions, Turbo functionality, and complete user workflows that cannot be adequately tested with Rails integration tests alone.

## User Stories
- As a developer, I want automated system tests that validate Turbo Frame and Stream updates work correctly in a real browser
- As a developer, I want confidence that critical user workflows (program creation, exercise addition, workout completion) function properly with all JavaScript enabled
- As a developer, I want tests that run in CI to catch regressions in frontend interactions before deployment
- As a team, we want tests that validate mobile and desktop viewport experiences

## Core Requirements
- Rails System Tests covering 4 core workflows using Capybara DSL
- Playwright as the Capybara driver (replacing Selenium)
- Authentication using existing `sign_in_as` helper (no WebAuthn testing)
- Tests run against Rails test database with fresh data per test
- Desktop and mobile viewport testing for responsive design validation
- Chromium-only browser testing (sufficient for CI/CD)
- Integration with existing GitHub Actions CI workflow
- Tests validate Turbo Frame/Stream updates without page reloads

## Visual Design
No visual assets provided. Tests will validate functionality of existing UI.

## Reusable Components

### Existing Code to Leverage
- **Session Helper Pattern**: `/Users/jamie/code/fitorforget/test/test_helper.rb` contains `sign_in_as(user)` helper - can be reused directly in system tests
- **Session Store Configuration**: `/Users/jamie/code/fitorforget/config/initializers/session_store.rb` uses ActiveRecord session store
- **Test Database Setup**: Existing Rails test environment with SQLite database
- **CI Configuration**: `.github/workflows/ci.yml` can be extended to include system tests
- **Controllers**: Programs, Exercises, Workouts, Dashboard controllers with Turbo Frame/Stream responses already implemented
- **Models**: User, Program, Exercise, Workout models with established associations and validations
- **Integration Test Patterns**: Existing integration tests in `/Users/jamie/code/fitorforget/test/integration/` demonstrate expected user flows

### New Components Required
- **capybara-playwright-driver gem**: New dependency for Playwright integration with Capybara
- **Playwright Node Package**: Matching version of Playwright CLI
- **ApplicationSystemTestCase Configuration**: Update `test/application_system_test_case.rb` to register Playwright driver
- **System Test Files**: Four new test files in `test/system/` for core workflows
- **package.json**: For managing Playwright Node.js dependency (if not already present)
- **CI Playwright Setup**: GitHub Actions steps to cache and install Playwright browsers

## Technical Approach

### Project Setup
1. Add `capybara-playwright-driver` gem to Gemfile (test group)
2. Install matching Playwright Node package version using gem's version constant
3. Run `yarn run playwright install` to download browser binaries
4. Configure custom Capybara driver in `ApplicationSystemTestCase`
5. Create system test files in `test/system/`

### Gem and Dependency Installation
```ruby
# Gemfile
group :test do
  gem "capybara"
  gem "capybara-playwright-driver"
end
```

```bash
# Install matching Playwright CLI version
export PLAYWRIGHT_CLI_VERSION=$(bundle exec ruby -e 'require "playwright"; puts Playwright::COMPATIBLE_PLAYWRIGHT_VERSION.strip')
yarn add -D "playwright@$PLAYWRIGHT_CLI_VERSION"
yarn run playwright install chromium
```

### Capybara Driver Configuration
Update `test/application_system_test_case.rb`:

```ruby
require "test_helper"

Capybara.register_driver :wombat_playwright do |app|
  Capybara::Playwright::Driver.new(app,
    browser_type: ENV["PLAYWRIGHT_BROWSER"]&.to_sym || :chromium,
    headless: (false unless ENV["CI"] || ENV["PLAYWRIGHT_HEADLESS"]))
end

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :wombat_playwright
end
```

### Authentication Strategy
**Approach**: Use existing `sign_in_as(user)` helper from `test/test_helper.rb`

**Implementation**:
- System tests inherit from `ApplicationSystemTestCase` which has access to `sign_in_as`
- Each test calls `sign_in_as(users(:default))` or creates a user and signs in
- No need for cookie injection or session manipulation
- Works seamlessly with Capybara's session management

### Test Environment Management
- Use Rails test database (SQLite configured for test environment)
- Database transactions handle cleanup automatically per Rails convention
- Each test creates its own test data or uses fixtures
- Rails handles server startup automatically for system tests

### Viewport Configuration
- **Desktop**: 1280x720 (standard desktop browser size)
- **Mobile**: 375x667 (iPhone SE dimensions)
- Set viewport using Capybara's `resize_window_to` method
- Each core workflow should have separate tests for desktop and mobile viewports

### Test Structure and Organization
Organize tests by workflow in `test/system/`:
- `program_creation_test.rb` - Program creation workflow
- `exercise_addition_test.rb` - Exercise addition to program
- `workout_start_test.rb` - Starting workout from program
- `workout_completion_test.rb` - Completing workout and viewing dashboard

Each test file should:
- Inherit from `ApplicationSystemTestCase`
- Use Capybara DSL (`visit`, `click_on`, `fill_in`, `assert_text`, etc.)
- Create fresh test data in setup or test body
- Use `sign_in_as` helper for authentication
- Test both desktop and mobile viewports (separate test methods)

## Core Workflow Specifications

### 1. Program Creation Flow
**Test File**: `test/system/program_creation_test.rb`

**Test Methods**:
- `test_creating_program_on_desktop`
- `test_creating_program_on_mobile`

**Test Steps**:
1. Sign in user with `sign_in_as`
2. Set viewport size (desktop or mobile)
3. Visit programs index (`/programs`)
4. Click "New Program" link/button
5. Fill form fields:
   - Title: "Test Program #{Time.current.to_i}"
   - Description: "Test description"
6. Click submit button
7. Assert redirected to program show page
8. Assert page contains program title
9. Assert success message visible

**Turbo Validation**:
- Use Capybara's default waiting behavior (handles Turbo automatically)
- Assert content appears without explicit wait for page reload

### 2. Exercise Addition Flow
**Test File**: `test/system/exercise_addition_test.rb`

**Test Methods**:
- `test_adding_exercises_to_program_on_desktop`
- `test_adding_exercises_to_program_on_mobile`

**Test Setup**:
- Sign in user
- Create program in setup or test body
- Visit program show page

**Test Steps**:
1. Set viewport size
2. Click "Add Exercise" button
3. Wait for Turbo Frame to load form (Capybara waits automatically)
4. Fill exercise form:
   - Name: "Test Exercise #{Time.current.to_i}"
   - Repeat Count: 3
   - Description: "Test exercise description"
5. Submit form
6. Assert exercise appears in program's exercise list
7. Assert exercise displays correct name and repeat count
8. Add second exercise to verify multiple additions work
9. Assert both exercises visible in correct order

**Turbo Validation**:
- Capybara automatically waits for Turbo Frame/Stream updates
- Assert new content appears without page navigation

### 3. Workout Start Flow
**Test File**: `test/system/workout_start_test.rb`

**Test Methods**:
- `test_starting_workout_from_program_on_desktop`
- `test_starting_workout_from_program_on_mobile`

**Test Setup**:
- Sign in user
- Create program with 3 exercises
- Visit program show page

**Test Steps**:
1. Set viewport size
2. Click "Start Workout" button
3. Assert navigated to workout page
4. Assert first exercise displayed
5. Assert workout shows progress indicator
6. Assert exercise details visible (name, description, repeat count)
7. Assert navigation controls present

**Turbo Validation**:
- Verify smooth navigation via Turbo
- Assert content loads without full page reload

### 4. Workout Completion Flow
**Test File**: `test/system/workout_completion_test.rb`

**Test Methods**:
- `test_completing_workout_and_viewing_dashboard_on_desktop`
- `test_completing_workout_and_viewing_dashboard_on_mobile`

**Test Setup**:
- Sign in user
- Create program with 3 exercises
- Start workout (via UI or direct creation)

**Test Steps**:
1. Set viewport size
2. Verify first exercise displayed
3. Click "Complete" button for exercise 1
4. Assert second exercise appears
5. Assert progress indicator updates
6. Complete exercise 2
7. Complete exercise 3 (final exercise)
8. Assert completion message or redirect to dashboard
9. Visit dashboard if not auto-redirected
10. Assert completed workout appears in recent workouts
11. Assert workout shows completed status with timestamp

**Turbo Validation**:
- Exercise completion updates UI dynamically
- Progress indicators update via Turbo Stream
- Dashboard reflects completion without refresh

## Test Data Strategy
- **Database Transactions**: Rails handles automatic rollback per test
- **Test Isolation**: Each test creates its own users, programs, exercises
- **No Shared State**: Tests should not rely on data from other tests
- **Unique Identifiers**: Use timestamps in test data to ensure uniqueness
- **Creation Pattern**: Use ActiveRecord directly in tests or helper methods

## Browser and Viewport Requirements
- **Browser**: Chromium only (sufficient for CI, simpler setup)
- **Viewports**: Two configurations
  - Desktop: 1280x720 via `resize_window_to(1280, 720)`
  - Mobile: 375x667 via `resize_window_to(375, 667)`
- **Test Coverage**: All 4 core workflows should have tests for both viewports
- **Implementation**: Separate test methods per viewport (8 total test methods)

## CI/CD Integration
**GitHub Actions Workflow** (extend `.github/workflows/ci.yml`):

Add these steps after `yarn install` in existing test job or create new `system_tests` job:

```yaml
- name: Cache Playwright Chromium browser
  id: playwright-cache
  uses: actions/cache@v4
  with:
    path: ~/.cache/ms-playwright
    key: playwright-browsers-${{ runner.os }}-${{ hashFiles('yarn.lock') }}

- name: Install Playwright Chromium browser (with deps)
  if: steps.playwright-cache.outputs.cache-hit != 'true'
  run: yarn run playwright install --with-deps chromium

- name: Install Playwright Chromium browser deps
  if: steps.playwright-cache.outputs.cache-hit == 'true'
  run: yarn run playwright install-deps chromium

- name: Run system tests
  run: bin/rails test:system
  env:
    RAILS_ENV: test
    CI: true
```

## Out of Scope
- Error state testing (validation failures, network errors)
- Cross-browser testing (Safari, Firefox)
- Testing without JavaScript (fallback behaviors)
- WebAuthn authentication flow testing
- Performance or load testing
- Accessibility audits (may be added later)
- Visual regression testing
- Video playback functionality
- Offline/PWA features
- Edge cases beyond core happy paths
- Testing features outside the 4 core workflows

## Success Criteria
- All 4 core workflow tests pass consistently on both desktop and mobile viewports (8 test methods total)
- Tests run successfully in CI environment (GitHub Actions)
- Tests complete in under 5 minutes total
- Authentication works reliably using existing `sign_in_as` helper
- Tests accurately validate Turbo Frame and Stream updates
- No false positives or flaky tests
- Clear error messages when tests fail
- Test output includes screenshots for debugging failures

## Implementation Considerations

### Dependencies and Tools
- capybara-playwright-driver gem (latest stable)
- Playwright CLI version matching gem's `COMPATIBLE_PLAYWRIGHT_VERSION`
- Node.js/Yarn for Playwright installation
- Chromium browser binary

### Selector Strategy
- Prefer semantic Capybara matchers: `click_on`, `fill_in`, `assert_text`
- Use data-testid attributes if more specific selectors needed
- Leverage Rails view helpers to add test attributes during implementation
- Avoid brittle CSS class selectors

### Test Execution Performance
- Rails runs system tests in parallel by default with `parallelize` configuration
- Playwright driver handles browser lifecycle efficiently
- Tests should complete quickly due to fast Playwright execution
- Use headless mode in CI for faster execution

### Debugging and Maintenance
- Run tests in headed mode locally: `PLAYWRIGHT_HEADLESS=false bin/rails test:system`
- Capybara automatically saves screenshots on failure to `tmp/screenshots/`
- Use `save_and_open_screenshot` for debugging
- Use Capybara's `pause` method to inspect state during test development

### Known Gotchas
- **Confirm Dialogs**: Use `accept_confirm { click_on "Delete" }` block syntax, not separate calls
- **Text Node Differences**: Playwright strips empty newlines differently than Selenium
- **Error Output**: Playwright adapter may output non-fatal errors to console

### Alignment with Standards
- Follow existing minitest and Rails conventions
- Inherit from `ApplicationSystemTestCase`
- Use StandardRB formatting
- Maintain consistency with existing test structure
- Focus on core user flows per testing standards
- Document tests clearly with descriptive names
