# Spec Requirements: Program Library & Dashboard

## Initial Description

Build user dashboard displaying all programs they've created (with edit/delete actions) and programs they've followed (with quick access to start new session). Implement basic filtering and sorting by recent activity.

This is the dashboard/home page feature where:
- Users see all their created programs
- Can edit/delete programs
- Can start workouts from programs
- Basic filtering and sorting
- Quick access to recent activity
- Mobile-first design

## Requirements Discussion

### First Round Questions

**Q1: What should the dashboard show?**
**Answer:** Show both programs and workouts. Most recent 5 of each.

**Q2: What should be the root path after login?**
**Answer:** After login, users land on `/dashboard`.

**Q3: What actions should be available on program cards?**
**Answer:** Add "Start Workout" button to each program card.

**Q4: Should the dashboard show all programs or only followed programs?**
**Answer:** Only show programs they have created or followed (have completed workouts for).

**Q5: How should programs and workouts be laid out?**
**Answer:** Separate cards for programs and workouts, side-by-side on desktop. On mobile, workouts come first.

**Q6: How should programs and workouts be sorted?**
**Answer:** Workouts sorted by most recently created first. Programs sorted by most recently used first.

**Q7: What quick actions should be available?**
**Answer:** "Create Program" button. Each program has "Start Workout" button.

**Q8: What should happen when there are no programs or workouts?**
**Answer:** Empty state with CTA for programs list. Hide workouts card if there are none.

**Q9: Should mobile show all items or be limited?**
**Answer:** Limited to 5 items with "View All" link to separate pages (/programs and /workouts).

**Q10: Should we include any summary statistics?**
**Answer:** Just program and workout lists for now (no summary stats).

### Existing Code to Reference

**Similar Features Identified:**
- Feature: Programs Index - Path: `/programs` (existing index page)
- Feature: Workouts Index - Path: `/workouts` (existing index page)
- Models: Program and Workout models already exist
- Authentication: WebAuthn authentication is already implemented

No specific component paths provided, but these existing pages should be referenced for styling patterns and data access patterns.

### Follow-up Questions

None needed. Requirements are clear and comprehensive.

## Visual Assets

### Files Provided:
No visual assets provided.

### Visual Insights:
No visual assets to analyze.

## Requirements Summary

### Functional Requirements

**Dashboard Page:**
- New route at `/dashboard` that becomes the landing page after user authentication
- Displays two primary sections: Programs and Workouts
- Each section shows the 5 most recent items
- Authenticated users only (requires WebAuthn login)

**Programs Section:**
- Display programs the user has created OR followed (has completed at least one workout for)
- Sort by "most recently used" (last session completion date)
- Each program card includes:
  - Program title
  - Program description (if available)
  - "Start Workout" button (primary action)
  - Edit/Delete actions (for programs the user created)
- "Create Program" button at the top of the section
- Empty state with CTA when user has no programs
- "View All" link to `/programs` when more than 5 programs exist

**Workouts Section:**
- Display user's completed workout sessions
- Sort by "most recently created" (session creation timestamp, descending)
- Each workout card includes:
  - Program name the workout was for
  - Date/time of completion
  - Number of exercises completed (if available)
- Hide entire workouts card if user has zero completed workouts
- "View All" link to `/workouts` when more than 5 workouts exist

**Navigation:**
- Update authentication flow to redirect to `/dashboard` after successful login
- Dashboard should be accessible via navigation menu
- Maintain existing routes for `/programs` and `/workouts` as full-page views

**User Actions:**
- Click "Start Workout" on any program card to begin a new session
- Click "Create Program" to create a new program
- Click "Edit" on owned programs to modify them
- Click "Delete" on owned programs to remove them
- Click "View All" links to see complete lists

### Layout & Responsive Design

**Desktop Layout (≥768px):**
- Two-column grid layout
- Programs section on the left
- Workouts section on the right
- Equal width columns with gap between
- Both sections visible simultaneously

**Mobile Layout (<768px):**
- Single column, stacked layout
- Workouts section appears FIRST (at top)
- Programs section appears SECOND (below workouts)
- Full-width cards
- Mobile-first approach with touch-friendly targets (44x44px minimum)

**Card Design:**
- Large, clear typography for readability on mobile
- Adequate spacing between interactive elements
- Prominent primary actions (Start Workout, Create Program)
- Secondary actions (Edit/Delete) visually de-emphasized but accessible
- Consistent with existing program/workout card designs on index pages

### Data Logic & Queries

**Programs Query:**
- Filter: Programs where user is creator OR programs where user has at least one completed session
- Sort: By most recent session completion date (descending)
- Limit: 5 items
- Include: Program title, description, creator status, last session date

**Workouts Query:**
- Filter: Sessions where user is the completer
- Sort: By created_at timestamp (descending)
- Limit: 5 items
- Include: Associated program name, completion timestamp, exercise count

**"Most Recently Used" for Programs:**
- Define as: The date/time of the user's most recent completed session for that program
- Programs with no sessions should appear last
- Programs user created but never completed a session for should still appear (at the end)

**"View All" Link Logic:**
- Show "View All Programs" link when user has >5 programs (created or followed)
- Show "View All Workouts" link when user has >5 completed sessions
- Links navigate to existing `/programs` and `/workouts` pages

### Empty States

**Programs Section Empty State:**
- Display when user has created zero programs AND followed zero programs
- Message: "No programs yet. Create your first program to get started."
- Primary CTA button: "Create Program" (links to new program form)
- Should be visually distinct but not overwhelming

**Workouts Section Empty State:**
- DO NOT display an empty state message
- HIDE the entire workouts card/section if user has zero completed sessions
- This prevents visual clutter when users are just getting started

### Reusability Opportunities

**Existing Components to Investigate:**
- Program card component from `/programs` index page
- Workout card component from `/workouts` index page
- Empty state patterns (if any exist in current app)
- Navigation components for "View All" links
- Button styles for "Create Program" and "Start Workout"
- Authentication redirect logic in sessions controller

**Backend Patterns to Reference:**
- Program model query scopes
- Workout/Session model query scopes
- User association methods for programs and sessions
- Existing controller actions for program CRUD operations

**Styling Patterns:**
- Tailwind CSS classes used in existing program/workout views
- Grid/flex layouts from existing index pages
- Card styling from existing components
- Responsive breakpoint usage throughout app
- Touch target sizing (44x44px minimum per standards)

### Scope Boundaries

**In Scope:**
- Dashboard page at `/dashboard` route
- Programs section with 5 most recent programs (created or followed)
- Workouts section with 5 most recent completed sessions
- "Start Workout" action on each program card
- "Create Program" CTA button
- Edit/Delete actions on owned programs
- "View All" links to existing index pages
- Empty state for programs section
- Conditional rendering (hide workouts section when empty)
- Responsive layout (mobile-first, workouts-first on mobile)
- Authentication redirect to dashboard
- Sorting logic (programs by recent use, workouts by recent creation)

**Out of Scope:**
- Summary statistics (total programs, total workouts, streaks, etc.)
- Filtering functionality (by date range, program type, etc.)
- Search functionality
- Pagination within dashboard (5-item limit is hard limit)
- Workout session details/drill-down from dashboard
- Inline workout completion tracking
- Program templates or program duplication
- Social features (sharing, following other users)
- Calendar view of workout history
- Analytics or insights beyond basic lists
- Customizable dashboard layout or widget preferences

**Future Enhancements Mentioned:**
- None explicitly mentioned, but potential future features could include:
  - Summary statistics at top of dashboard
  - Configurable number of items shown
  - Dashboard customization options
  - Quick filters (e.g., "My Programs" vs "Followed Programs")

### Technical Considerations

**Routing:**
- Add `get '/dashboard', to: 'dashboard#index'` route
- Create new `DashboardController` with `index` action
- Update authentication success redirect to `/dashboard` path
- Maintain existing `/programs` and `/workouts` routes unchanged

**Authentication:**
- Dashboard requires authenticated user (before_action authenticate_user)
- Unauthenticated users redirected to login
- After successful WebAuthn authentication, redirect to `/dashboard` instead of current landing page

**Database Queries:**
- Programs: `current_user.programs` (created) UNION programs with `current_user.sessions.program_id`
- Sort programs by `sessions.completed_at DESC NULLS LAST`
- Workouts: `current_user.sessions.order(created_at: :desc).limit(5)`
- Consider N+1 query prevention with includes/joins for associated programs

**Performance:**
- Limit queries to 5 items each (no pagination needed)
- Eager load associations to prevent N+1 queries
- Consider caching user's dashboard data (future optimization)
- SQLite-optimized queries (app uses SQLite, not Postgres)

**Turbo & Stimulus:**
- Use Turbo Frames if partial updates needed (e.g., after deleting a program)
- Stimulus controller may be needed for "Start Workout" action if it requires confirmation
- Leverage Turbo for navigation (should work with existing setup)

**Mobile-First CSS:**
- Use Tailwind responsive prefixes (e.g., `md:grid-cols-2` for desktop two-column)
- Default to single-column stacked layout
- Ensure 44x44px minimum touch targets for all buttons
- Test on actual mobile devices per standards

**Integration Points:**
- Existing Program model and controller
- Existing Workout/Session model and controller
- WebAuthn authentication flow and session management
- Existing navigation component/partial
- Tailwind CSS configuration and design system

**Technology Stack Compliance:**
- Rails 8 conventions and patterns
- Turbo and Stimulus for interactivity
- Tailwind CSS for styling
- Minitest for testing
- SQLite database with ActiveRecord ORM
- WebAuthn for authentication

**Existing System Constraints:**
- All programs are public (per product mission context)
- Workouts/sessions belong to users (private)
- Users can follow programs by completing sessions for them
- No explicit "follow" action - implicit via session completion
- Mobile-first design philosophy throughout application
