# Specification: Program Library & Dashboard

## Goal
Create a unified dashboard that serves as the landing page after authentication, displaying the user's most recent programs and workouts with quick access to start new workout sessions.

## User Stories
- As a user, I want to see my most recent programs and workouts when I log in so that I can quickly continue my fitness routine
- As a user, I want to start a new workout from any program card so that I can begin exercising with minimal clicks
- As a program creator, I want to edit and delete my programs from the dashboard so that I can manage my content efficiently
- As a user, I want to see which programs I've recently used so that I can prioritize my active training programs
- As a user, I want the workouts section to appear first on mobile so that I can quickly track my recent activity

## Core Requirements
- Dashboard displays 5 most recent programs (created or followed) and 5 most recent workouts
- Each program card includes "Start Workout" button for immediate access
- Programs sorted by most recently used (based on latest workout completion)
- Workouts sorted by most recently created
- Edit/Delete actions available on user's own programs
- "View All" links when more than 5 items exist
- Empty state with "Create Program" CTA when no programs exist
- Hide entire workouts section when user has zero workouts
- Dashboard becomes default landing page after authentication
- Mobile-first responsive layout with workouts displayed first on mobile devices

## Visual Design
No visual mockups provided. Follow existing design patterns from:
- Programs index page: `/Users/jamie/code/fitorforget/app/views/programs/index.html.erb`
- Workouts index page: `/Users/jamie/code/fitorforget/app/views/workouts/index.html.erb`
- Consistent gradient background: `from-indigo-100 via-purple-50 to-pink-100`
- Card-based layout with hover shadows
- Indigo color scheme for primary actions
- 44x44px minimum touch targets for mobile

### Responsive Breakpoints
- **Mobile (<768px)**: Single column, workouts first, then programs
- **Desktop (>=768px)**: Two-column grid (`lg:grid-cols-2`), programs left, workouts right
- All cards full-width within their column
- Adequate spacing between sections and cards

## Reusable Components

### Existing Code to Leverage

**Models:**
- `User` model with associations: `has_many :programs` and `has_many :workouts`
- `Program` model with `belongs_to :user` and `has_many :workouts`
- `Workout` model with timestamps and program association
- Existing methods: `workout.complete?`, `workout.completion_stats`, `workout.program_title`

**Controllers:**
- `ProgramsController#index` pattern for querying user's programs
- `WorkoutsController#index` pattern for querying user's workouts
- `ApplicationController` authentication helpers: `current_user`, `logged_in?`, `require_authentication`
- Authentication redirect logic in `SessionsController` for post-login routing

**Views:**
- Program card styling from `programs/index.html.erb`:
  - Card structure with `bg-white rounded-lg shadow-md p-6 hover:shadow-lg`
  - Action buttons with proper spacing and styling
  - Empty state pattern with icon, heading, and CTA button
- Workout card styling from `workouts/index.html.erb`:
  - Completion badge patterns (Completed, In Progress, Not Started)
  - Stats display format: "X of Y exercises complete"
  - Border and hover effects
- Navigation from `layouts/application.html.erb`:
  - Fixed top navigation bar with proper z-index
  - Authenticated user display and logout button
  - Flash message handling

**Routes:**
- Existing routes: `/programs`, `/workouts`, `/workouts/new?program_id=:uuid`
- Authentication routes: `/signin`, `/signup`
- Root route pattern to be updated

**Styling Patterns:**
- Tailwind utility classes for responsive design
- Gradient backgrounds for page containers
- Button styles: indigo for primary, gray for secondary, red for delete
- Min-height classes for touch targets: `min-h-[44px]`
- Transition effects: `transition-colors`, `transition-shadow`

### New Components Required

**DashboardController:**
- New controller needed because existing controllers serve different purposes
- `ProgramsController` focuses on full CRUD operations for programs
- `WorkoutsController` focuses on workout session management
- Dashboard needs aggregated view with custom query logic for "recently used" programs
- Cannot reuse existing controllers without breaking their single-responsibility design

**Dashboard View:**
- New view template needed to combine programs and workouts in two-column layout
- Existing index views are single-purpose and don't support side-by-side sections
- Requires responsive layout that reorders sections on mobile (workouts first)
- Different card styling requirements (e.g., "Start Workout" button prominence)

**Query Logic:**
- "Most recently used" programs requires JOIN with workouts table to find latest workout date
- Must combine user's created programs with programs they've followed (implicit via workouts)
- Cannot reuse simple `current_user.programs.order(created_at: :desc)` pattern
- Need efficient query to prevent N+1 problems when loading program cards with workout metadata

## Technical Approach

### Database Queries

**Programs Query:**
```ruby
# Fetch programs where user is creator OR has completed workouts
# Sort by most recent workout completion date, programs without workouts last
# Use LEFT JOIN to include programs with no workouts
# Limit to 5 records for dashboard display
# Eager load associations to prevent N+1 queries

current_user.programs
  .left_joins(:workouts)
  .where(workouts: { user_id: current_user.id })
  .or(Program.where(user_id: current_user.id))
  .select("programs.*, MAX(workouts.created_at) as last_workout_at")
  .group("programs.id")
  .order("last_workout_at DESC NULLS LAST")
  .limit(5)
```

**Workouts Query:**
```ruby
# Fetch user's 5 most recent workouts
# Order by created_at descending
# Eager load program association for displaying program_title

current_user.workouts
  .order(created_at: :desc)
  .limit(5)
```

**Count Queries for "View All" Links:**
```ruby
# Check if user has more than 5 programs
@has_more_programs = [query for programs].count > 5

# Check if user has more than 5 workouts
@has_more_workouts = current_user.workouts.count > 5
```

### Routing Changes

**New Dashboard Route:**
```ruby
get '/dashboard', to: 'dashboard#index', as: :dashboard
```

**Root Route Update:**
```ruby
# Conditionally redirect authenticated users to dashboard
# Unauthenticated users see home page
# Implementation in HomeController to check logged_in? and redirect
root "home#index"
```

**Authentication Redirect:**
```ruby
# Update SessionsController handle_registration and handle_authentication
# Change: redirect_to session.delete(:return_to) || dashboard_path
```

### Navigation Updates

**Add Dashboard Link:**
```erb
<!-- In app/views/layouts/application.html.erb navigation -->
<%= link_to "Dashboard", dashboard_path, class: "..." %>
<%= link_to "Programs", programs_path, class: "..." %>
```

**Update require_authentication:**
- Already redirects to signin with return_to path
- No changes needed - works as-is

### View Structure

**Dashboard Template Outline:**
```erb
<div class="min-h-screen bg-gradient-to-br from-indigo-100 via-purple-50 to-pink-100 py-12 px-4">
  <div class="max-w-7xl mx-auto">
    <h1>Dashboard</h1>

    <!-- Mobile: workouts first, Desktop: two-column grid -->
    <div class="grid gap-6 lg:grid-cols-2">
      <!-- Workouts Section (order-first on mobile) -->
      <section class="lg:order-2">
        <!-- Workouts cards or empty state -->
      </section>

      <!-- Programs Section -->
      <section class="lg:order-1">
        <!-- Programs cards with Start Workout button -->
      </section>
    </div>
  </div>
</div>
```

**Card Enhancements:**
- Reuse existing card markup from programs/index.html.erb
- Add "Start Workout" button as primary action
- Link to: `new_workout_path(program_id: program.uuid)`
- Keep Edit/Delete actions for owned programs
- Add conditional rendering: `if @is_owner` logic similar to programs#show

### Controller Logic

**DashboardController Structure:**
```ruby
class DashboardController < ApplicationController
  before_action :require_authentication

  def index
    # Query programs with workout metadata
    # Query workouts
    # Set instance variables for view
    # Calculate boolean flags for "View All" links
  end
end
```

**HomeController Update:**
```ruby
def index
  # Redirect authenticated users to dashboard
  redirect_to dashboard_path if logged_in?
end
```

### Turbo & Stimulus

- No custom Stimulus controllers needed for initial implementation
- Turbo works out-of-the-box for navigation
- Delete actions use existing `data-turbo-confirm` pattern
- "Start Workout" button uses standard link_to (no JavaScript needed)
- Future enhancement: Add Turbo Frames for partial updates after delete

## Out of Scope
- Summary statistics (total programs, workout streaks, completion rates)
- Filtering by date range or program type
- Search functionality within dashboard
- Pagination or infinite scroll (hard limit of 5 items per section)
- Inline workout completion from dashboard
- Calendar view of workout history
- Social features (sharing, following other users' programs)
- Analytics or insights beyond basic lists
- Customizable dashboard layout or widget preferences
- "Recently viewed" programs separate from "recently used"
- Program templates or duplication from dashboard
- Bulk actions (multi-select programs for delete)

## Success Criteria
- Authenticated users land on `/dashboard` after successful login
- Dashboard loads in under 2 seconds with efficient database queries (no N+1)
- Programs sorted correctly by most recent workout date
- "Start Workout" button creates new workout and redirects to workout page
- Edit/Delete actions work only for programs user created
- Empty state displays when user has no programs
- Workouts section hidden when user has zero workouts
- Mobile layout displays workouts first, then programs (single column)
- Desktop layout displays two columns side-by-side
- All interactive elements meet 44x44px minimum touch target size
- "View All" links appear when user has more than 5 programs or workouts
- Navigation includes working "Dashboard" link
- All existing functionality (programs CRUD, workouts) remains intact
