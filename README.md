# Wombat Workouts

A Rails application for creating and tracking workout programs.

## System Requirements

- Ruby 3.3+ (see `.ruby-version` for specific version)
- Node.js 18+ (for JavaScript dependencies and Playwright)
- Yarn (package manager)
- SQLite 3

## Getting Started

### Installation

1. Clone the repository
2. Install dependencies:
   ```bash
   bundle install
   yarn install
   ```

3. Set up the database:
   ```bash
   bin/rails db:setup
   ```

4. Install Playwright browser for system tests:
   ```bash
   yarn run playwright install chromium
   ```

### Running the Application

Start the Rails server:
```bash
bin/dev
```

The application will be available at `http://localhost:3000`.

## Testing

The application uses Rails' built-in Minitest framework with system tests powered by Capybara and Playwright.

### Test Suite Structure

- **Integration Tests**: Traditional Rails integration tests in `test/integration/`
- **System Tests**: End-to-end browser tests in `test/system/` using Playwright

### Running Tests

#### Run All Tests
```bash
bin/rails test        # All unit and integration tests
bin/rails test:system # All system tests only
```

#### Run Specific System Tests
```bash
# Run a single test file
bin/rails test:system test/system/program_creation_test.rb

# Run a specific test method
bin/rails test:system test/system/program_creation_test.rb -n test_creating_program_on_desktop
```

### System Tests Setup

The system tests use Playwright with Chromium to test complete user workflows including JavaScript interactions and Turbo functionality.

**Prerequisites:**
- Ruby gems installed (`bundle install`)
- Node.js dependencies installed (`yarn install`)
- Playwright Chromium browser installed (`yarn run playwright install chromium`)

**Test Coverage:**
The system tests validate four core workflows on both desktop (1280x720) and mobile (375x667) viewports:

1. **Program Creation** - Creating a new workout program
2. **Exercise Addition** - Adding exercises to a program
3. **Workout Start** - Starting a workout session from a program
4. **Workout Completion** - Completing exercises and viewing the dashboard

This results in 8 total system tests (4 workflows × 2 viewports).

### Debugging System Tests

#### Run Tests in Headed Mode (Visible Browser)
```bash
PLAYWRIGHT_HEADLESS=false bin/rails test:system
```

This opens a visible browser window so you can watch the tests execute.

#### View Test Screenshots
When system tests fail, Capybara automatically saves screenshots to help debug:

```bash
open tmp/screenshots/
```

Screenshots are named with the test name and timestamp.

#### Check Test Logs
```bash
tail -f log/test.log
```

#### Debugging Tips
- Use `save_and_open_screenshot` in tests to capture the current page state
- Set `PLAYWRIGHT_HEADLESS=false` to watch tests run in real-time
- Increase wait time if needed: Add `Capybara.default_max_wait_time = 10` in test
- Check browser console errors in headed mode

### Continuous Integration

System tests run automatically in GitHub Actions on every pull request and push to main.

**CI Configuration:**
- Tests run in headless Chromium
- Playwright browsers are cached for faster runs
- Screenshots are uploaded as artifacts on test failure
- Tests timeout after 10 minutes

**Viewing Test Failures in CI:**
1. Go to the Actions tab in GitHub
2. Click on the failed workflow run
3. Scroll to the "Upload system test screenshots" artifact
4. Download the artifact to view screenshots from failed tests

**Expected CI Performance:**
- Browser cache hit: ~20 second overhead
- Browser cache miss: ~60 second overhead for browser installation
- Total test execution: <5 minutes for all 8 system tests

### Test Data and Isolation

- Each test creates fresh data using ActiveRecord
- Database transactions ensure automatic cleanup after each test
- Tests do not share state or depend on fixtures
- Authentication uses the `sign_in_as(user)` helper to bypass WebAuthn

## Development

### Code Style

The project uses StandardRB for Ruby code formatting:

```bash
bundle exec standardrb        # Check for style violations
bundle exec standardrb --fix  # Auto-fix violations
```

### Security Scanning

```bash
bin/brakeman      # Rails security vulnerabilities
bin/bundler-audit # Gem security vulnerabilities
bin/importmap audit # JavaScript dependency vulnerabilities
```

## Deployment

[Add deployment instructions here]

## License

[Add license information here]
