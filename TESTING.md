# Testing Guide

This document provides comprehensive information about testing in Wombat Workouts.

## Test Suite Overview

The application uses Rails' built-in Minitest framework with three types of tests:

1. **Unit Tests** - Model validations, methods, and business logic
2. **Integration Tests** - Controller actions and request flows
3. **System Tests** - End-to-end browser tests with Playwright

## System Tests

System tests provide the highest level of confidence by testing the application exactly as users experience it, including JavaScript interactions, Turbo functionality, and responsive design.

### Technology Stack

- **Test Framework**: Rails System Tests (built on Minitest)
- **Browser Automation**: Capybara with Playwright driver
- **Browser**: Chromium (headless in CI, headed for local debugging)
- **Driver**: capybara-playwright-driver gem

### Test Files

All system tests are located in `test/system/`:

```
test/system/
├── program_creation_test.rb     # Creating workout programs
├── exercise_addition_test.rb    # Adding exercises to programs
├── workout_start_test.rb        # Starting workout sessions
└── workout_completion_test.rb   # Completing workouts
```

### Test Coverage

Each workflow is tested on two viewports to ensure responsive design works correctly:

#### Desktop Viewport: 1280x720
- Standard desktop browser size
- Full navigation and UI elements visible
- Multi-column layouts

#### Mobile Viewport: 375x667 (iPhone SE)
- Mobile-first responsive design
- Touch-optimized controls
- Single-column layouts

**Total Tests**: 8 (4 workflows × 2 viewports)

### Workflow Details

#### 1. Program Creation (`program_creation_test.rb`)

**What it tests:**
- Navigation to program creation form
- Form field validation and submission
- Success message display
- Redirection to program detail page
- Turbo-driven form submission (no full page reload)

**Desktop test**: `test_creating_program_on_desktop`
**Mobile test**: `test_creating_program_on_mobile`

#### 2. Exercise Addition (`exercise_addition_test.rb`)

**What it tests:**
- Adding single exercise to a program
- Adding multiple exercises sequentially
- Exercise list updates via Turbo Frames
- Exercise details display correctly
- Form clearing after successful submission

**Desktop test**: `test_adding_exercises_to_program_on_desktop`
**Mobile test**: `test_adding_exercises_to_program_on_mobile`

#### 3. Workout Start (`workout_start_test.rb`)

**What it tests:**
- Starting a workout from a program
- First exercise displays correctly
- Progress indicators show
- Workout navigation controls present
- Turbo navigation (no full page reload)

**Desktop test**: `test_starting_workout_from_program_on_desktop`
**Mobile test**: `test_starting_workout_from_program_on_mobile`

#### 4. Workout Completion (`workout_completion_test.rb`)

**What it tests:**
- Marking exercises as complete
- Progress indicator updates via Turbo Streams
- Navigation through all exercises
- Workout completion confirmation
- Dashboard displays completed workout
- Completion timestamp recorded

**Desktop test**: `test_completing_workout_and_viewing_dashboard_on_desktop`
**Mobile test**: `test_completing_workout_and_viewing_dashboard_on_mobile`

## Running System Tests

### Prerequisites

Before running system tests, ensure you have:

```bash
# Install Ruby dependencies
bundle install

# Install Node.js dependencies
yarn install

# Install Playwright Chromium browser
yarn run playwright install chromium
```

### Basic Commands

```bash
# Run all system tests
bin/rails test:system

# Run a specific test file
bin/rails test:system test/system/program_creation_test.rb

# Run a specific test method
bin/rails test:system test/system/program_creation_test.rb -n test_creating_program_on_desktop

# Run all tests (unit, integration, and system)
bin/rails test:all
```

### Debugging Tests

#### Headed Mode (Visible Browser)

Watch tests execute in a real browser window:

```bash
PLAYWRIGHT_HEADLESS=false bin/rails test:system
```

This is extremely helpful for:
- Understanding what the test is doing
- Identifying why a test is failing
- Developing new tests

#### Screenshots

Capybara automatically saves screenshots when tests fail:

```bash
# View all screenshots
open tmp/screenshots/

# Screenshots are named with test name and timestamp
# Example: failures_test_creating_program_on_desktop_2024-10-28-12-34-56.png
```

You can also manually capture screenshots in tests:

```ruby
# In a test method
save_and_open_screenshot
```

#### Test Logs

```bash
# Watch test logs in real-time
tail -f log/test.log

# View full test output
bin/rails test:system TESTOPTS="-v"
```

#### Interactive Debugging

Add breakpoints in tests:

```ruby
# In a test method
binding.break  # Opens a debugger session
```

#### Increase Wait Time

If tests fail due to slow page loads:

```ruby
# In test/application_system_test_case.rb
Capybara.default_max_wait_time = 10  # Default is 2 seconds
```

### Test Performance

Expected execution times:

- **Single test**: 5-10 seconds
- **Single test file** (2 tests): 15-20 seconds
- **All system tests** (8 tests): 60-90 seconds
- **CI environment**: 2-5 minutes (including setup)

Playwright is significantly faster than Selenium, providing quick feedback during development.

## Test Data Strategy

### Database Isolation

- Each test runs in a database transaction
- Changes are automatically rolled back after each test
- No manual cleanup required
- Tests are completely isolated from each other

### Test Data Creation

Tests create their own data using ActiveRecord:

```ruby
# Create a user for testing
user = User.create!(
  email: "test@example.com",
  webauthn_id: SecureRandom.hex(16)
)

# Create a program
program = Program.create!(
  title: "Test Program #{Time.current.to_i}",
  description: "Test description",
  user: user
)

# Create exercises
program.exercises.create!(
  name: "Push-ups",
  repeat_count: 3,
  position: 1
)
```

### Unique Identifiers

Use timestamps to ensure unique names:

```ruby
title = "Test Program #{Time.current.to_i}"
# Results in: "Test Program 1698505234"
```

### No Shared Fixtures

- Tests don't rely on shared fixtures
- Each test is self-contained
- No dependencies between tests
- Tests can run in any order

## Authentication in Tests

System tests bypass WebAuthn authentication using the `sign_in_as(user)` helper:

```ruby
test "example test" do
  user = User.create!(email: "test@example.com", webauthn_id: SecureRandom.hex(16))
  sign_in_as(user)

  visit dashboard_path
  # User is now authenticated
end
```

The helper:
1. Creates a session in the database
2. Sets the session cookie in the browser
3. Works seamlessly with Capybara and Playwright

This approach:
- Speeds up tests (no WebAuthn ceremony)
- Simplifies test setup
- Focuses tests on core workflows
- Matches the pattern used in integration tests

## Continuous Integration

### GitHub Actions Workflow

System tests run automatically on every pull request and push to main branch.

**Workflow file**: `.github/workflows/ci.yml`

**Test job includes:**
1. Checkout code
2. Set up Ruby and install gems
3. Set up Node.js and install dependencies
4. Prepare test database
5. Cache Playwright browsers
6. Install Playwright (if not cached)
7. Run system tests
8. Upload screenshots on failure

### CI Configuration Details

#### Playwright Browser Caching

The CI workflow caches Playwright browsers to improve performance:

```yaml
- name: Cache Playwright Chromium browser
  uses: actions/cache@v4
  with:
    path: ~/.cache/ms-playwright
    key: playwright-browsers-${{ runner.os }}-${{ hashFiles('yarn.lock') }}
```

**Cache behavior:**
- **Cache hit**: Browser installation skipped, only deps installed (~20 seconds)
- **Cache miss**: Full browser installation (~60 seconds)
- **Cache invalidation**: When `yarn.lock` changes

#### Test Execution

```yaml
- name: Run system tests
  run: bin/rails test:system
  env:
    RAILS_ENV: test
    CI: true
  timeout-minutes: 10
```

**Environment variables:**
- `RAILS_ENV=test`: Use test database
- `CI=true`: Triggers headless mode in driver configuration

**Timeout**: Tests must complete within 10 minutes (generous buffer)

#### Screenshot Upload

```yaml
- name: Upload system test screenshots
  if: failure()
  uses: actions/upload-artifact@v4
  with:
    name: system-test-screenshots
    path: tmp/screenshots/
    retention-days: 7
```

**Artifact details:**
- Only uploaded on test failure
- Retained for 7 days
- Available in GitHub Actions UI

### Viewing CI Test Results

#### Successful Run

✅ All tests pass - No action needed

#### Failed Run

1. Click on the failed workflow in GitHub Actions
2. Click on the "test" job
3. Review the test output in the "Run system tests" step
4. Download the "system-test-screenshots" artifact
5. Extract and view screenshots to see what failed

### Expected CI Performance

With proper caching:

| Metric | Time |
|--------|------|
| Setup (checkout, Ruby, Node.js) | ~30 seconds |
| Browser cache hit | ~20 seconds |
| Browser cache miss | ~60 seconds |
| Test execution (8 tests) | ~2-3 minutes |
| **Total (cache hit)** | ~3-4 minutes |
| **Total (cache miss)** | ~4-5 minutes |

### CI Best Practices

1. **Don't commit failing tests** - Ensure tests pass locally before pushing
2. **Monitor CI times** - Tests should complete in under 5 minutes
3. **Check artifacts** - Download screenshots when investigating failures
4. **No flaky tests** - All tests should pass consistently
5. **Keep browsers updated** - Update Playwright version periodically

## Writing New System Tests

### Test Structure

```ruby
require "application_system_test_case"

class MyNewFeatureTest < ApplicationSystemTestCase
  test "my feature on desktop" do
    # 1. Set up test data
    user = User.create!(email: "test@example.com", webauthn_id: SecureRandom.hex(16))

    # 2. Authenticate
    sign_in_as(user)

    # 3. Set viewport
    page.current_window.resize_to(1280, 720)

    # 4. Execute user actions
    visit some_path
    fill_in "Title", with: "My Title"
    click_button "Submit"

    # 5. Assert expected outcomes
    assert_text "Success!"
    assert_current_path some_other_path
  end

  test "my feature on mobile" do
    # Same as desktop but with mobile viewport
    page.current_window.resize_to(375, 667)
    # ... rest of test
  end
end
```

### Best Practices

#### Use Semantic Selectors

Prefer Capybara's semantic methods:

```ruby
# Good - Uses label text
fill_in "Email", with: "test@example.com"
click_button "Submit"
click_link "Sign Out"

# Avoid - Brittle CSS selectors
find(".email-input").set("test@example.com")
find("#submit-btn").click
```

#### Trust Capybara's Waiting

Capybara automatically waits for elements:

```ruby
# Good - Capybara waits for element
click_button "Submit"
assert_text "Success!"

# Avoid - Manual waits
click_button "Submit"
sleep 1
assert_text "Success!"
```

#### Test User Behavior, Not Implementation

```ruby
# Good - Tests what user sees
click_button "Add Exercise"
fill_in "Exercise Name", with: "Push-ups"
click_button "Save"
assert_text "Push-ups"

# Avoid - Testing implementation details
assert_selector "turbo-frame#exercise-form"
assert_selector ".exercise-list > .exercise-item"
```

#### Create Test Data Efficiently

```ruby
# Good - Direct database creation
program = Program.create!(title: "Test", user: user)

# Avoid - Clicking through UI to create test data
visit programs_path
click_link "New Program"
fill_in "Title", with: "Test"
click_button "Create"
```

#### Use Descriptive Test Names

```ruby
# Good
test "completing all exercises marks workout as done and shows on dashboard"

# Avoid
test "test_workout"
```

## Troubleshooting

### Common Issues

#### Browser Not Found

**Error**: `Executable doesn't exist at /path/to/chromium`

**Solution**: Install Playwright browser:
```bash
yarn run playwright install chromium
```

#### Database Locked

**Error**: `SQLite3::BusyException: database is locked`

**Solution**: Ensure no other Rails processes are running:
```bash
pkill -f rails
```

#### Element Not Found

**Error**: `Unable to find button "Submit"`

**Solutions**:
1. Check the button text matches exactly (case-sensitive)
2. Verify element is visible on the page
3. Wait for Turbo Frame/Stream to load
4. Run in headed mode to see the page: `PLAYWRIGHT_HEADLESS=false bin/rails test:system`

#### Test Timeout

**Error**: `Test exceeded 30 seconds`

**Solutions**:
1. Check for infinite loops or missing elements
2. Increase Capybara wait time
3. Verify page loads correctly in headed mode

#### Flaky Tests

**Symptoms**: Tests pass sometimes, fail sometimes

**Common causes**:
1. Race conditions - Use Capybara's waiting methods
2. Shared state - Ensure tests are isolated
3. Time-dependent logic - Freeze time in tests
4. Animations - Wait for animation completion

**Solutions**:
```ruby
# Wait for specific state
assert_text "Expected text"  # Capybara waits automatically

# Disable animations in test environment (CSS)
# app/assets/stylesheets/application.css
# In test environment, animations are instant
```

### Getting Help

If you're stuck:

1. Run test in headed mode to see what's happening
2. Add `save_and_open_screenshot` to capture the page
3. Check `log/test.log` for errors
4. Use `binding.break` to pause and inspect
5. Review this guide and spec files in `agent-os/specs/2025-10-28-playwright-system-tests/`

## Additional Resources

- [Capybara Documentation](https://rubydoc.info/github/teamcapybara/capybara)
- [Playwright Documentation](https://playwright.dev)
- [capybara-playwright-driver](https://github.com/YusukeIwaki/capybara-playwright-driver)
- [Rails Testing Guide](https://guides.rubyonrails.org/testing.html)

## Maintenance

### Updating Playwright

When updating the `capybara-playwright-driver` gem:

```bash
# 1. Update gem
bundle update capybara-playwright-driver

# 2. Get new Playwright version
export PLAYWRIGHT_CLI_VERSION=$(bundle exec ruby -e 'require "playwright"; puts Playwright::COMPATIBLE_PLAYWRIGHT_VERSION.strip')

# 3. Update package.json
yarn add -D "playwright@$PLAYWRIGHT_CLI_VERSION"

# 4. Install new browser
yarn run playwright install chromium

# 5. Commit both Gemfile.lock and yarn.lock
```

### Reviewing Test Health

Periodically check:
- [ ] All tests pass locally
- [ ] All tests pass in CI
- [ ] Tests complete in under 5 minutes
- [ ] No flaky tests (run multiple times)
- [ ] Screenshots are helpful for debugging
- [ ] Test coverage remains relevant to user workflows
