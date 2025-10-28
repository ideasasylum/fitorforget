# Task Breakdown: Rails System Tests with Playwright Driver

## Overview
Total Tasks: 4 task groups
Total Tests Expected: 8 system tests (4 workflows x 2 viewports)

## Task List

### Infrastructure Setup

#### Task Group 1: Playwright Driver Configuration
**Dependencies:** None

- [x] 1.0 Complete Playwright driver setup for Rails System Tests
  - [x] 1.1 Add capybara-playwright-driver gem to Gemfile
    - Add to test group in Gemfile
    - Run `bundle install`
    - Verify gem installation
  - [x] 1.2 Install Playwright CLI and browser binaries
    - Check if package.json exists, create if needed
    - Install Playwright CLI matching gem version:
      ```bash
      export PLAYWRIGHT_CLI_VERSION=$(bundle exec ruby -e 'require "playwright"; puts Playwright::COMPATIBLE_PLAYWRIGHT_VERSION.strip')
      yarn add -D "playwright@$PLAYWRIGHT_CLI_VERSION"
      ```
    - Install Chromium browser: `yarn run playwright install chromium`
    - Verify installation
  - [x] 1.3 Configure Capybara Playwright driver
    - Check if `test/application_system_test_case.rb` exists
    - If not, create it inheriting from ActionDispatch::SystemTestCase
    - Register custom Playwright driver named `:wombat_playwright`
    - Driver configuration:
      - browser_type: chromium (or from ENV["PLAYWRIGHT_BROWSER"])
      - headless: false for local, true for CI (use ENV["CI"] || ENV["PLAYWRIGHT_HEADLESS"])
    - Set `driven_by :wombat_playwright` in ApplicationSystemTestCase
  - [x] 1.4 Verify setup with minimal test
    - Create test/system/.gitkeep or minimal test file
    - Run `bin/rails test:system` to verify:
      - Driver loads correctly
      - Browser launches
      - Rails test server starts automatically
      - No configuration errors
    - Delete minimal test file if created

**Acceptance Criteria:**
- capybara-playwright-driver gem installed and available
- Playwright CLI and Chromium browser installed
- ApplicationSystemTestCase configured with :wombat_playwright driver
- `bin/rails test:system` runs without errors
- Browser launches in headed mode locally, headless in CI

### Core Workflow Tests - Part 1

#### Task Group 2: Program Creation and Exercise Addition Tests
**Dependencies:** Task Group 1

- [x] 2.0 Complete program and exercise workflow tests
  - [x] 2.1 Create program_creation_test.rb
    - File: test/system/program_creation_test.rb
    - Class: ProgramCreationTest < ApplicationSystemTestCase
    - Test: `test_creating_program_on_desktop`
      1. Create user and sign in with `sign_in_as(user)`
      2. Set viewport: `page.current_window.resize_to(1280, 720)`
      3. Visit `/programs`
      4. Click "Create Program" link (use `click_link`)
      5. Fill form:
         - `fill_in "Title", with: "Test Program #{Time.current.to_i}"`
         - `fill_in "Description", with: "Test description"`
      6. Click submit button with `click_button "Create Program"`
      7. Assert page contains program title (waits for redirect)
      8. Assert success message visible
      9. Assert redirected to program show page (check URL pattern)
    - Test: `test_creating_program_on_mobile`
      - Same steps as desktop but set viewport: `page.current_window.resize_to(375, 667)`
    - Both tests should validate Turbo behavior (content updates without full reload)
  - [x] 2.2 Create exercise_addition_test.rb
    - File: test/system/exercise_addition_test.rb
    - Class: ExerciseAdditionTest < ApplicationSystemTestCase
    - Setup (in-test):
      - Create user and sign in
      - Create program: `program = Program.create!(title: "Test Program", user: user)`
    - Test: `test_adding_exercises_to_program_on_desktop`
      1. Set viewport: `page.current_window.resize_to(1280, 720)`
      2. Visit program show page: `visit program_path(program)`
      3. Click "Add Exercise" link using `click_link "Add Exercise"`
      4. Wait for Turbo Frame (Capybara waits automatically)
      5. Fill exercise form:
         - Name: `fill_in "Exercise Name", with: "Test Exercise 1 #{Time.current.to_i}"`
         - Repeat Count: `fill_in "Repeat Count", with: 3`
         - Description: Skipped (uses OverType editor)
      6. Click submit button using `click_button "Add Exercise"`
      7. Assert exercise appears: `assert_text "Test Exercise 1"`
      8. Assert repeat count visible
      9. Add second exercise:
         - Click "Add Exercise" link again using `click_link "Add Exercise"`
         - Fill form with "Test Exercise 2"
         - Submit using `click_button "Add Exercise"`
      10. Assert both exercises visible in order
    - Test: `test_adding_exercises_to_program_on_mobile`
      - Same steps as desktop but set viewport: `page.current_window.resize_to(375, 667)`
    - Tests validate Turbo Frame/Stream updates (no page reload)
  - [x] 2.3 Run and verify Task Group 2 tests
    - Run: `bin/rails test:system test/system/program_creation_test.rb`
    - Run: `bin/rails test:system test/system/exercise_addition_test.rb`
    - Verify 4 total tests pass (2 files x 2 viewports)
    - Check tests complete in under 2 minutes
    - Verify no flaky behavior on re-runs
    - Check screenshots saved to tmp/screenshots/ on any failures

**Acceptance Criteria:**
- program_creation_test.rb passes on desktop and mobile viewports
- exercise_addition_test.rb passes on desktop and mobile viewports
- 4 tests total passing (2 workflows x 2 viewports)
- Tests validate Turbo Frame/Stream updates work correctly
- Tests use sign_in_as helper for authentication
- All tests complete in under 2 minutes total

### Core Workflow Tests - Part 2

#### Task Group 3: Workout Start and Completion Tests
**Dependencies:** Task Group 2

- [x] 3.0 Complete workout workflow tests
  - [x] 3.1 Create workout_start_test.rb
    - File: test/system/workout_start_test.rb
    - Class: WorkoutStartTest < ApplicationSystemTestCase
    - Setup:
      - Create user and sign in
      - Create program with 3 exercises:
        ```ruby
        @program = Program.create!(title: "Test Program", user: @user)
        3.times do |i|
          @program.exercises.create!(
            name: "Exercise #{i + 1}",
            repeat_count: 3,
            description: "Description #{i + 1}",
            position: i + 1
          )
        end
        ```
    - Test: `test_starting_workout_from_program_on_desktop`
      1. Set viewport: `page.current_window.resize_to(1280, 720)`
      2. Visit program show page: `visit program_path(@program)`
      3. Click "Start Workout" button
      4. Assert navigated to workout page (check URL or page content)
      5. Assert first exercise displayed: `assert_text @program.exercises.first.name`
      6. Assert progress indicator visible (e.g., "1 of 3" or progress bar)
      7. Assert exercise description displayed
      8. Assert repeat count displayed
      9. Assert navigation controls present (Complete button, etc.)
    - Test: `test_starting_workout_from_program_on_mobile`
      - Same steps as desktop but set viewport: `page.current_window.resize_to(375, 667)`
    - Tests validate Turbo navigation during workout start
  - [x] 3.2 Create workout_completion_test.rb
    - File: test/system/workout_completion_test.rb
    - Class: WorkoutCompletionTest < ApplicationSystemTestCase
    - Setup:
      - Create user and sign in
      - Create program with 3 exercises (as in 3.1)
      - Start workout via UI (click "Start Workout") or create workout record directly
    - Test: `test_completing_workout_and_viewing_dashboard_on_desktop`
      1. Set viewport: `page.current_window.resize_to(1280, 720)`
      2. Visit active workout page (if not already there from setup)
      3. Verify first exercise displayed
      4. Click "Complete" button for exercise 1
      5. Assert second exercise appears
      6. Assert progress updates (e.g., "2 of 3")
      7. Click "Complete" for exercise 2
      8. Assert third exercise appears
      9. Assert progress updates (e.g., "3 of 3")
      10. Click "Complete" for exercise 3
      11. Assert completion message or redirect to dashboard
      12. Visit `/dashboard` if not auto-redirected
      13. Assert completed workout visible in recent workouts
      14. Assert workout shows completed status
      15. Assert completion timestamp visible
    - Test: `test_completing_workout_and_viewing_dashboard_on_mobile`
      - Same steps as desktop but set viewport: `page.current_window.resize_to(375, 667)`
    - Tests validate Turbo Stream updates during exercise completion
  - [x] 3.3 Run and verify Task Group 3 tests
    - Run: `bin/rails test:system test/system/workout_start_test.rb`
    - Run: `bin/rails test:system test/system/workout_completion_test.rb`
    - Verify 4 total tests pass (2 files x 2 viewports)
    - Check tests complete in under 2 minutes
    - Verify Turbo behaviors work correctly
    - Check for any flaky behavior

**Acceptance Criteria:**
- workout_start_test.rb passes on desktop and mobile viewports
- workout_completion_test.rb passes on desktop and mobile viewports
- 4 tests total passing (2 workflows x 2 viewports)
- Tests validate workout session creation and progression
- Tests validate Turbo Stream updates during exercise completion
- Tests verify dashboard displays completed workouts correctly
- All tests complete in under 2 minutes total

### CI/CD Integration

#### Task Group 4: GitHub Actions Configuration
**Dependencies:** Task Groups 1-3

- [x] 4.0 Complete CI/CD integration
  - [x] 4.1 Update CI workflow with Playwright setup
    - File: .github/workflows/ci.yml
    - Created new test job with complete CI pipeline
    - Added steps after `yarn install`:
      1. Cache Playwright browsers:
         ```yaml
         - name: Cache Playwright Chromium browser
           id: playwright-cache
           uses: actions/cache@v4
           with:
             path: ~/.cache/ms-playwright
             key: playwright-browsers-${{ runner.os }}-${{ hashFiles('yarn.lock') }}
         ```
      2. Install Playwright with deps (if cache miss):
         ```yaml
         - name: Install Playwright Chromium browser (with deps)
           if: steps.playwright-cache.outputs.cache-hit != 'true'
           run: yarn run playwright install --with-deps chromium
         ```
      3. Install Playwright deps only (if cache hit):
         ```yaml
         - name: Install Playwright Chromium browser deps
           if: steps.playwright-cache.outputs.cache-hit == 'true'
           run: yarn run playwright install-deps chromium
         ```
  - [x] 4.2 Add system test execution step
    - Added step to run system tests:
      ```yaml
      - name: Run system tests
        run: bin/rails test:system
        env:
          RAILS_ENV: test
          CI: true
        timeout-minutes: 10
      ```
    - Step runs after Playwright installation
    - Timeout set to 10 minutes
  - [x] 4.3 Configure test artifacts upload
    - Added step to upload screenshots on failure:
      ```yaml
      - name: Upload system test screenshots
        if: failure()
        uses: actions/upload-artifact@v4
        with:
          name: system-test-screenshots
          path: tmp/screenshots/
          retention-days: 7
          if-no-files-found: ignore
      ```
  - [x] 4.4 Update documentation
    - Updated README.md with comprehensive testing section:
      - Prerequisites: Ruby, Node.js, Yarn
      - Setup: `bundle install && yarn install && yarn run playwright install chromium`
      - Run all system tests: `bin/rails test:system`
      - Run specific test: `bin/rails test:system test/system/program_creation_test.rb`
      - Debug tests (headed mode): `PLAYWRIGHT_HEADLESS=false bin/rails test:system`
      - View screenshots: `open tmp/screenshots/`
    - Created TESTING.md with detailed testing guide covering:
      - Test suite overview
      - System test coverage and workflows
      - Running and debugging system tests
      - Test data strategy and authentication
      - CI/CD integration details
      - Writing new tests best practices
      - Troubleshooting common issues
  - [x] 4.5 Verify CI pipeline (Manual verification required)
    - Note: Cannot automatically push to GitHub or trigger CI from this environment
    - Manual verification steps to perform:
      1. Push changes to feature branch
      2. Create pull request or trigger CI manually
      3. Verify all 8 system tests pass in CI (4 workflows x 2 viewports)
      4. Check tests complete in under 5 minutes
      5. Verify Playwright browsers cache correctly (check cache hit on subsequent runs)
      6. Test artifact upload by forcing a failure (optional)
      7. Verify no flaky tests in CI

**Acceptance Criteria:**
- [x] GitHub Actions workflow includes Playwright browser installation steps
- [x] Playwright browsers cached efficiently (~20 second overhead)
- [x] System test execution step configured with proper environment
- [x] Screenshots upload as artifacts on test failure
- [x] Documentation exists for running tests locally and in CI
- [ ] CI verification (requires manual testing):
  - System tests run successfully in CI environment
  - All 8 system tests pass consistently (4 workflows x 2 viewports)
  - Tests complete in under 5 minutes in CI
  - CI passes consistently without flaky tests

## Execution Order

Recommended implementation sequence:
1. Infrastructure Setup (Task Group 1) - Configure Playwright driver for Rails
2. Core Workflow Tests - Part 1 (Task Group 2) - Program and exercise workflows
3. Core Workflow Tests - Part 2 (Task Group 3) - Workout workflows
4. CI/CD Integration (Task Group 4) - Automate in GitHub Actions

## Implementation Notes

### Test Data Strategy
- Each test creates fresh data using ActiveRecord in setup or test body
- Use unique identifiers (timestamps) to ensure uniqueness: `"Program #{Time.current.to_i}"`
- Rails handles database cleanup automatically via transactions
- Tests should not depend on fixtures or shared state
- Use direct ActiveRecord creation for speed: `Program.create!(...)`

### Selector Strategy
- Prefer semantic Capybara methods: `click_link`, `click_button`, `fill_in`, `assert_text`
- Use label text for form fields: `fill_in "Title", with: "..."`
- Use `click_link` for links and `click_button` for buttons when specificity is needed
- Add data-testid attributes if more specific selectors needed
- Avoid brittle CSS class selectors (Tailwind classes can change)

### Viewport Management
- Set viewport at start of each test using:
  ```ruby
  page.current_window.resize_to(width, height)
  ```
- Desktop: 1280x720
- Mobile: 375x667
- Consider extracting to helper methods for reusability

### Authentication
- Extended `sign_in_as(user)` helper for system tests in test/test_helper.rb
- Helper creates session in database and sets cookie via JavaScript
- Works seamlessly with Capybara and Playwright
- Example:
  ```ruby
  user = User.create!(email: "test@example.com", webauthn_id: SecureRandom.hex(16))
  sign_in_as(user)
  ```

### Debugging Tips
- Run tests in headed mode locally: `PLAYWRIGHT_HEADLESS=false bin/rails test:system`
- Capybara saves screenshots on failure to `tmp/screenshots/`
- Use `save_and_open_screenshot` in tests for debugging
- Use Capybara's `pause` method to stop and inspect: `binding.break` or `page.pause` (if available)
- Check Rails logs: `tail -f log/test.log`
- Increase Capybara's default wait time if needed: `Capybara.default_max_wait_time = 5`

### Performance Considerations
- Tests should run quickly (target: <30 seconds per test)
- Use direct database creation instead of clicking through UI for setup
- Playwright is fast; avoid unnecessary `sleep` calls
- Capybara waits automatically for elements; trust its default behavior
- Total execution time target: under 5 minutes for all 8 tests

### Known Gotchas from capybara-playwright-driver
- **Confirm Dialogs**: Use block syntax: `accept_confirm { click_on "Delete" }`
- **Text Nodes**: Playwright strips empty newlines differently than Selenium
- **Error Output**: Playwright adapter may log non-fatal errors to console
- **Window Resizing**: Use `page.current_window.resize_to(width, height)` format
- **Cookie Setting**: Use JavaScript via `page.execute_script` to set cookies

### Alignment with Project Standards
- Follow minitest and Rails conventions
- Inherit from `ApplicationSystemTestCase`
- Use StandardRB formatting for all Ruby code
- Test naming: `test_description_with_underscores`
- Focus on core user flows (no error states or edge cases for now)
- Keep tests focused and fast
- Document tests with clear, descriptive names and comments where helpful
