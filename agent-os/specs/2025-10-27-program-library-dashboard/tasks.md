# Task Breakdown: Program Library & Dashboard

## Overview
Total Tasks: 4 Task Groups
Feature: Dashboard landing page displaying user's recent programs and workouts with quick access to start new workout sessions

## Task List

### Backend Layer: Routes & Controller

#### Task Group 1: Dashboard Controller & Routing
**Dependencies:** None

- [x] 1.0 Complete dashboard backend layer
  - [x] 1.1 Write 2-8 focused tests for DashboardController
    - Limit to 2-8 highly focused tests maximum
    - Test only critical behaviors: authentication requirement, programs query returns correct data, workouts query returns correct data, empty states render correctly
    - Skip exhaustive coverage of edge cases
  - [x] 1.2 Create DashboardController with index action
    - Location: `/Users/jamie/code/fitorforget/app/controllers/dashboard_controller.rb`
    - Add `before_action :require_authentication`
    - Follow pattern from existing ProgramsController and WorkoutsController
  - [x] 1.3 Implement programs query logic
    - Fetch programs where user is creator OR has completed workouts for
    - Sort by most recent workout completion date (DESC, NULLS LAST)
    - Use LEFT JOIN to include programs with no workouts
    - Limit to 5 records
    - Eager load associations to prevent N+1 queries
    - Set `@programs` instance variable
    - Set `@has_more_programs` boolean for "View All" link logic
  - [x] 1.4 Implement workouts query logic
    - Fetch user's workouts ordered by created_at DESC
    - Limit to 5 records
    - Eager load program association to prevent N+1 queries
    - Set `@workouts` instance variable
    - Set `@has_more_workouts` boolean for "View All" link logic
  - [x] 1.5 Add dashboard route to config/routes.rb
    - Add: `get '/dashboard', to: 'dashboard#index', as: :dashboard`
    - Location: `/Users/jamie/code/fitorforget/config/routes.rb`
  - [x] 1.6 Update root route redirect logic in HomeController
    - Location: `/Users/jamie/code/fitorforget/app/controllers/home_controller.rb`
    - Add redirect to dashboard_path if logged_in? is true
    - Keep existing behavior for unauthenticated users
  - [x] 1.7 Update SessionsController authentication redirect
    - Location: `/Users/jamie/code/fitorforget/app/controllers/sessions_controller.rb`
    - Update handle_registration and handle_authentication methods
    - Change redirect from programs_path to dashboard_path
    - Keep existing return_to logic: `redirect_to session.delete(:return_to) || dashboard_path`
  - [x] 1.8 Ensure backend layer tests pass
    - Run ONLY the 2-8 tests written in 1.1
    - Verify queries return correct data
    - Verify authentication redirect logic works
    - Do NOT run the entire test suite at this stage

**Acceptance Criteria:**
- The 2-8 tests written in 1.1 pass ✓
- DashboardController#index requires authentication ✓
- Programs query returns up to 5 programs sorted by recent use ✓
- Workouts query returns up to 5 workouts sorted by created_at ✓
- Boolean flags for "View All" links work correctly ✓
- Authenticated users redirect to /dashboard after login ✓
- Root path redirects authenticated users to /dashboard ✓

### Frontend Layer: Dashboard View

#### Task Group 2: Dashboard View Template
**Dependencies:** Task Group 1

- [x] 2.0 Complete dashboard view template
  - [x] 2.1 Write 2-8 focused tests for dashboard view rendering
    - Limit to 2-8 highly focused tests maximum
    - Test only critical view behaviors: programs section renders, workouts section renders, empty states display correctly, "View All" links appear conditionally
    - Skip exhaustive testing of all UI states
  - [x] 2.2 Create dashboard index view template
    - Location: `/Users/jamie/code/fitorforget/app/views/dashboard/index.html.erb`
    - Follow pattern from programs/index.html.erb and workouts/index.html.erb
    - Use gradient background: `bg-gradient-to-br from-indigo-100 via-purple-50 to-pink-100`
    - Container: `max-w-7xl mx-auto` for wider layout (7xl instead of 4xl)
  - [x] 2.3 Implement responsive two-column layout
    - Mobile (<768px): Single column, workouts first (order-first), then programs
    - Desktop (>=768px): Two-column grid with `lg:grid-cols-2`
    - Add proper gap between sections: `gap-6`
    - Programs section uses `lg:order-1`, workouts section uses `lg:order-2`
  - [x] 2.4 Build programs section
    - Section heading: "Recent Programs" with "Create Program" button
    - "Create Program" button links to new_program_path
    - Button styling: indigo primary button matching existing patterns
    - Display up to 5 program cards using existing card pattern
    - Show "View All Programs" link when @has_more_programs is true
    - "View All" link points to programs_path
  - [x] 2.5 Implement program cards with enhanced actions
    - Reuse card structure from programs/index.html.erb
    - Card: `bg-white rounded-lg shadow-md p-6 hover:shadow-lg transition-shadow`
    - Display: program title, description (truncated), last workout date if available
    - Primary action: "Start Workout" button linking to new_workout_path(program_id: program.uuid)
    - "Start Workout" button: indigo background, prominent styling, min-h-[44px]
    - Secondary actions: "View", "Edit", "Delete" (only for owned programs)
    - Use @is_owner logic similar to ProgramsController#show
    - All buttons meet 44x44px minimum touch target
  - [x] 2.6 Build workouts section
    - Section heading: "Recent Workouts"
    - Conditionally render entire section only when @workouts.any?
    - Hide entire section when @workouts.empty? (no empty state message)
    - Display up to 5 workout cards using existing pattern from workouts/index.html.erb
    - Show "View All Workouts" link when @has_more_workouts is true
    - "View All" link points to workouts_path
  - [x] 2.7 Implement workout cards
    - Reuse card structure from workouts/index.html.erb
    - Card: `border border-gray-200 rounded-lg p-6 hover:shadow-md transition-shadow`
    - Display: program title, completion stats, completion badge
    - Completion badges: Completed (green), In Progress (yellow), Not Started (gray)
    - Stats format: "X of Y exercises complete"
    - "View" button linking to workout_path(workout)
    - All buttons meet 44x44px minimum touch target
  - [x] 2.8 Implement programs empty state
    - Display when @programs.empty?
    - Centered layout with icon, heading, description, CTA
    - Icon: document/clipboard SVG from programs/index.html.erb
    - Heading: "Create Your First Program"
    - Description: "Get started by creating your first exercise program to organize your workouts"
    - CTA button: "Create Program" linking to new_program_path
    - Button styling: indigo primary, min-h-[44px]
  - [x] 2.9 Ensure view layer tests pass
    - Run ONLY the 2-8 tests written in 2.1
    - Verify sections render correctly
    - Verify conditional rendering works
    - Do NOT run the entire test suite at this stage

**Acceptance Criteria:**
- The 2-8 tests written in 2.1 pass ✓
- Dashboard displays two-column layout on desktop ✓
- Mobile layout shows workouts first, then programs (single column) ✓
- Programs section shows up to 5 programs with "Start Workout" button ✓
- Edit/Delete actions only visible for owned programs ✓
- Workouts section hidden when user has zero workouts ✓
- Empty state displays when user has no programs ✓
- "View All" links appear when appropriate ✓
- All touch targets meet 44x44px minimum ✓

### Frontend Layer: Navigation Updates

#### Task Group 3: Navigation Enhancement
**Dependencies:** Task Group 1, Task Group 2

- [x] 3.0 Complete navigation updates
  - [x] 3.1 Write 2-8 focused tests for navigation
    - Limit to 2-8 highly focused tests maximum
    - Test only critical behaviors: "Dashboard" link appears for authenticated users, navigation links work correctly
    - Skip exhaustive testing of all navigation states
  - [x] 3.2 Add "Dashboard" link to navigation
    - Location: `/Users/jamie/code/fitorforget/app/views/layouts/application.html.erb`
    - Find authenticated user navigation section
    - Add "Dashboard" link before "Programs" link
    - Link to: dashboard_path
    - Use consistent styling with other navigation links
    - Follow existing pattern for active state highlighting (if applicable)
  - [x] 3.3 Ensure navigation tests pass
    - Run ONLY the 2-8 tests written in 3.1
    - Verify "Dashboard" link appears and functions
    - Do NOT run the entire test suite at this stage

**Acceptance Criteria:**
- The 2-8 tests written in 3.1 pass ✓
- "Dashboard" link appears in navigation for authenticated users ✓
- "Dashboard" link navigates to /dashboard ✓
- Navigation styling is consistent with existing links ✓

### Testing Layer: Test Review & Integration

#### Task Group 4: Test Review & Gap Analysis
**Dependencies:** Task Groups 1-3

- [x] 4.0 Review existing tests and fill critical gaps only
  - [x] 4.1 Review tests from Task Groups 1-3
    - Review the 2-8 tests written by backend-engineer (Task 1.1)
    - Review the 2-8 tests written by ui-designer (Task 2.1)
    - Review the 2-8 tests written by navigation-specialist (Task 3.1)
    - Total existing tests: approximately 6-24 tests
  - [x] 4.2 Analyze test coverage gaps for THIS feature only
    - Identify critical user workflows that lack test coverage
    - Focus ONLY on gaps related to dashboard feature requirements
    - Do NOT assess entire application test coverage
    - Prioritize end-to-end workflows over unit test gaps
    - Key workflows to verify:
      - Authenticated user lands on dashboard after login
      - Programs sorted by most recent workout date
      - "Start Workout" button creates new workout correctly
      - Empty states display correctly
      - Mobile layout reorders sections correctly
  - [x] 4.3 Write up to 10 additional strategic tests maximum
    - Add maximum of 10 new tests to fill identified critical gaps
    - Focus on integration points and end-to-end workflows
    - Do NOT write comprehensive coverage for all scenarios
    - Test locations:
      - Controller integration tests: `/Users/jamie/code/fitorforget/test/controllers/dashboard_controller_test.rb`
      - System/integration tests: `/Users/jamie/code/fitorforget/test/integration/dashboard_workflow_test.rb`
    - Skip edge cases, performance tests, and accessibility tests unless business-critical
  - [x] 4.4 Run feature-specific tests only
    - Run ONLY tests related to dashboard feature (tests from 1.1, 2.1, 3.1, and 4.3)
    - Expected total: approximately 16-34 tests maximum
    - Do NOT run the entire application test suite
    - Verify critical workflows pass
    - Fix any failing tests before considering feature complete

**Acceptance Criteria:**
- All feature-specific tests pass (26 tests total) ✓
- Critical user workflows for dashboard feature are covered ✓
- No more than 10 additional tests added when filling in testing gaps (10 tests added) ✓
- Testing focused exclusively on dashboard feature requirements ✓
- No regressions in existing programs/workouts functionality ✓

## Execution Order

Recommended implementation sequence:
1. Backend Layer: Routes & Controller (Task Group 1) ✓
2. Frontend Layer: Dashboard View Template (Task Group 2) ✓
3. Frontend Layer: Navigation Enhancement (Task Group 3) ✓
4. Testing Layer: Test Review & Integration (Task Group 4) ✓

## Technical Notes

### Database Query Patterns

**Programs Query Example:**
```ruby
# Fetch programs user created OR has workouts for, sorted by recent use
current_user.programs
  .left_joins(:workouts)
  .where("workouts.user_id = ? OR programs.user_id = ?", current_user.id, current_user.id)
  .select("programs.*, MAX(workouts.created_at) as last_workout_at")
  .group("programs.id")
  .order("last_workout_at DESC NULLS LAST")
  .limit(5)
```

**Workouts Query Example:**
```ruby
# Fetch user's 5 most recent workouts with program association
current_user.workouts
  .includes(:program)
  .order(created_at: :desc)
  .limit(5)
```

### Responsive Layout Pattern

```erb
<!-- Mobile: workouts first, Desktop: two columns -->
<div class="grid gap-6 lg:grid-cols-2">
  <!-- Workouts Section (appears first on mobile) -->
  <section class="lg:order-2">
    <!-- Workouts content -->
  </section>

  <!-- Programs Section (appears second on mobile) -->
  <section class="lg:order-1">
    <!-- Programs content -->
  </section>
</div>
```

### Owner Detection Pattern

```ruby
# In controller
@programs.each do |program|
  @is_owner = logged_in? && current_user.id == program.user_id
end
```

### Alignment with Standards

- **Tech Stack:** Rails 8, Turbo, Stimulus, Tailwind CSS, Minitest
- **Mobile-First:** All layouts start mobile, enhance for desktop
- **Touch Targets:** All interactive elements minimum 44x44px
- **Query Optimization:** Eager loading to prevent N+1 queries
- **Testing:** Focused on critical paths, minimal tests during development
- **RESTful Routes:** Dashboard follows REST conventions
- **Consistent Styling:** Reuses existing card and button patterns
