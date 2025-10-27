# Task Breakdown: Session Start & Exercise Progression (Workout Tracking)

## Overview
Total Tasks: 37 sub-tasks organized into 5 task groups

This feature enables authenticated users to start workout sessions from programs, progress through exercises sequentially with clear visual progress indicators, and track completion state with pause/resume capability.

## Task List

### Task Group 1: Database Layer & Workout Model

**Dependencies:** None

**Assigned to:** database-engineer

- [x] 1.0 Complete database layer and Workout model
  - [x] 1.1 Write 2-8 focused tests for Workout model functionality
    - Limit to 2-8 highly focused tests maximum
    - Test only critical model behaviors:
      - Exercise unrolling logic (repeat_count expansion)
      - Finding current incomplete exercise
      - Marking exercise complete and auto-advancing
      - Completion detection when all exercises done
      - Skip functionality
    - Skip exhaustive coverage of all methods and edge cases
  - [x] 1.2 Create migration for workouts table
    - Add columns: id (primary key), user_id (foreign key, not null, indexed), program_id (foreign key, nullable, indexed), exercises_data (text for JSON), program_title (string), started_at (datetime, nullable), completed_at (datetime, nullable), created_at, updated_at
    - Foreign keys with on_delete: cascade for user_id, nullify for program_id (workouts persist as snapshots)
    - Index on user_id and program_id for query performance
    - Follow patterns from: existing migrations in db/migrate/
  - [x] 1.3 Create Workout model with associations
    - belongs_to :user
    - belongs_to :program, optional: true
    - Validations: presence of user_id, program_title
    - Follow patterns from: /Users/jamie/code/fitorforget/app/models/program.rb
  - [x] 1.4 Implement JSON serialization for exercises_data
    - Use Rails serialize with JSON coder for exercises_data column
    - Store exercise instances as array of hashes
    - Each exercise hash contains: id (UUID), name, description, video_url, position, repeat_instance, repeat_total, completed (boolean), skipped (boolean)
  - [x] 1.5 Implement exercise unrolling logic
    - Create initialize_from_program(program) class method
    - Iterate through program.exercises.order(:position)
    - For each exercise, create repeat_count instances
    - Generate unique UUID for each instance
    - Set repeat_instance (1, 2, 3...) and repeat_total
    - Initialize completed=false, skipped=false
    - Maintain proper position ordering
  - [x] 1.6 Add state query methods
    - complete? - returns true if all exercises completed or skipped
    - in_progress? - returns true if started_at present and not complete?
    - completion_stats - returns hash with completed_count, skipped_count, total_count
  - [x] 1.7 Add exercise navigation methods
    - current_exercise - returns first exercise where completed=false and skipped=false
    - next_exercise - returns exercise after current_exercise
    - find_exercise(exercise_id) - returns exercise instance by UUID
  - [x] 1.8 Add exercise action methods
    - mark_exercise_complete(exercise_id) - sets completed=true, sets started_at if nil, saves
    - skip_exercise(exercise_id) - sets skipped=true, sets started_at if nil, saves
    - Set completed_at timestamp when last exercise is completed/skipped
  - [x] 1.9 Ensure database layer tests pass
    - Run ONLY the 2-8 tests written in 1.1
    - Verify migrations run successfully
    - Verify exercise unrolling expands repeat_count correctly
    - Do NOT run the entire test suite at this stage

**Acceptance Criteria:**
- The 2-8 tests written in 1.1 pass ✓
- Migration creates workouts table with proper indexes and foreign keys ✓
- Workout model has working associations to User and Program ✓
- Exercise unrolling correctly expands repeat_count into individual instances ✓
- State methods accurately reflect workout completion status ✓
- Action methods properly update exercise state and timestamps ✓

---

### Task Group 2: Workouts Controller & Routes

**Dependencies:** Task Group 1

**Assigned to:** api-engineer

- [x] 2.0 Complete workouts controller and API routes
  - [x] 2.1 Write 2-8 focused tests for controller actions
    - Limit to 2-8 highly focused tests maximum
    - Test only critical controller behaviors:
      - Authentication requirement (redirect if not authenticated)
      - Successful workout creation from program
      - Show action displays current exercise
      - Update action marks exercise complete and redirects
      - Authorization (users can only access own workouts)
    - Skip exhaustive testing of all actions and scenarios
  - [x] 2.2 Add routes for workouts
    - Add to config/routes.rb: resources :workouts, except: [:edit]
    - Add member routes for custom actions: patch :mark_complete, patch :skip
    - Follow RESTful conventions per standards
  - [x] 2.3 Create WorkoutsController with authentication
    - Inherit from ApplicationController
    - Add before_action :require_authentication for all actions
    - Follow patterns from: /Users/jamie/code/fitorforget/app/controllers/application_controller.rb
  - [x] 2.4 Implement index action
    - Load current_user.workouts.includes(:program).order(updated_at: :desc)
    - Display list of user's workouts with program names
    - Show completion status and progress
  - [x] 2.5 Implement new action (preview screen)
    - Find program by params[:program_id]
    - Create temporary workout instance (don't save yet) via Workout.new.initialize_from_program(program)
    - Display all exercise instances in preview list
    - Show total count and repeat indicators
  - [x] 2.6 Implement create action
    - Find program by params[:program_id]
    - Create workout: current_user.workouts.create via initialize_from_program
    - Redirect to workout_path(workout) or new_workout_path for preview
    - Handle errors with flash messages
  - [x] 2.7 Implement show action (progression view)
    - Find workout via current_user.workouts.find(params[:id]) for authorization
    - Get current_exercise or detect completion
    - If complete: render completion partial
    - If in progress: render single exercise view
    - Set started_at timestamp if first view
  - [x] 2.8 Implement mark_complete action
    - Find workout via current_user.workouts
    - Call workout.mark_exercise_complete(params[:exercise_id])
    - Redirect to workout_path (show next exercise or completion)
  - [x] 2.9 Implement skip action
    - Find workout via current_user.workouts
    - Call workout.skip_exercise(params[:exercise_id])
    - Redirect to workout_path (show next exercise or completion)
  - [x] 2.10 Implement destroy action
    - Find workout via current_user.workouts
    - Delete workout with confirmation
    - Redirect to workouts_path with success message
  - [x] 2.11 Ensure controller tests pass
    - Run ONLY the 2-8 tests written in 2.1
    - Verify authentication enforcement
    - Verify critical CRUD operations work
    - Do NOT run the entire test suite at this stage

**Acceptance Criteria:**
- The 2-8 tests written in 2.1 pass ✓
- Routes follow RESTful conventions ✓
- All actions require authentication ✓
- Association-based queries enforce authorization (current_user.workouts) ✓
- Create action properly snapshots and unrolls exercises ✓
- Show action displays current exercise or completion state ✓
- Mark complete and skip actions update state and redirect correctly ✓

---

### Task Group 3: Workout Views & UI Components

**Dependencies:** Task Group 2

**Assigned to:** ui-designer

- [x] 3.0 Complete workout views and UI components
  - [ ] 3.1 Write 2-8 focused tests for UI components and views
    - Limit to 2-8 highly focused tests maximum
    - Test only critical view behaviors:
      - Preview page renders all exercise instances
      - Progression page displays current exercise with video
      - Progress indicator shows correct position
      - Completion screen displays when workout done
      - Buttons are properly sized for mobile (44x44px)
    - Skip exhaustive testing of all view states and interactions
  - [x] 3.2 Create workouts index view (app/views/workouts/index.html.erb)
    - Layout: List of user's workouts with program names
    - Show status badges (In Progress, Completed)
    - Display progress: "X of Y exercises complete"
    - Link to resume or view each workout
    - Match design patterns from: /Users/jamie/code/fitorforget/app/views/programs/show.html.erb
    - Use Tailwind classes: bg-white rounded-lg shadow-md p-6
  - [x] 3.3 Create workout preview view (app/views/workouts/new.html.erb)
    - Display program name and description
    - List all exercise instances with repeat indicators (e.g., "Push-ups - Set 1 of 3")
    - Show total count: "8 exercises in this workout"
    - Large "Begin Workout" button (min-h-[44px] min-w-[44px])
    - Cancel/back button
    - Use gradient background: bg-gradient-to-br from-indigo-100 via-purple-50 to-pink-100
  - [x] 3.4 Create workout progression view (app/views/workouts/show.html.erb)
    - Conditional rendering: if complete? show completion partial, else show current exercise
    - Progress indicator at top: "Exercise X of Y"
    - Progress bar component (see 3.7)
    - Exercise card with white background, rounded corners, shadow
    - Exercise name as h2 heading
    - Formatted description (Markdown rendering if needed)
    - Video embed with responsive aspect ratio container
    - Large "Mark Complete" button (bg-indigo-600 hover:bg-indigo-700, min 44x44px)
    - "Skip" button (secondary styling, min 44x44px)
    - Mobile-first layout with full-width buttons on small screens
  - [x] 3.5 Create completion partial (app/views/workouts/_completion.html.erb)
    - Confetti animation trigger (see 3.8)
    - "Workout Complete!" heading with celebration emoji
    - Summary text: "You completed X of Y exercises" (show skipped count if any)
    - Display completed_at timestamp
    - "View Your Workouts" button linking to workouts_path
    - "Browse Programs" button linking to programs_path
  - [x] 3.6 Add "Start Workout" button to program show page
    - Edit: /Users/jamie/code/fitorforget/app/views/programs/show.html.erb
    - Add prominent "Start Workout" button below program description
    - If authenticated: link_to new_workout_path(program_id: @program.uuid)
    - If not authenticated: link_to with authentication prompt message
    - Style as primary CTA: large, green background, 44x44px minimum
  - [ ] 3.7 Create progress bar Stimulus controller
    - New file: app/javascript/controllers/progress_bar_controller.js
    - Calculate current position from data attributes
    - Update progress bar width percentage
    - Display "Exercise X of Y" text
    - Smooth transitions with CSS
  - [ ] 3.8 Create confetti Stimulus controller
    - New file: app/javascript/controllers/confetti_controller.js
    - Trigger confetti animation on completion screen load
    - Use canvas-based confetti or CSS animation
    - Auto-clean up after animation completes
    - Keep lightweight for mobile performance
  - [x] 3.9 Apply responsive styles
    - Mobile: 320px - 768px (full-width buttons, stacked layout)
    - Tablet: 768px - 1024px (moderate margins)
    - Desktop: 1024px+ (centered content, max-width containers)
    - All interactive elements minimum 44x44px touch targets
    - Follow patterns from existing views
  - [x] 3.10 Implement video embed component
    - Responsive aspect ratio container (16:9 or 4:3)
    - Tap-to-play controls (no autoplay)
    - Handle missing video_url gracefully
    - Mobile-optimized player controls
    - Consider using video_tag or iframe for YouTube embeds
  - [ ] 3.11 Ensure view tests pass
    - Run ONLY the 2-8 tests written in 3.1
    - Verify critical view rendering works
    - Verify mobile touch targets meet 44x44px minimum
    - Do NOT run the entire test suite at this stage

**Acceptance Criteria:**
- The 2-8 tests written in 3.1 pass (PENDING - tests not yet written)
- All views render correctly with proper data ✓
- Preview page lists all exercise instances before starting ✓
- Progression page shows one exercise at a time ✓
- Progress indicators accurately display position ✓
- Completion screen shows celebration and summary ✓
- All buttons meet 44x44px minimum for mobile ✓
- Video embeds are responsive and tap-to-play ✓
- Design matches existing Wombat Workouts patterns ✓

---

### Task Group 4: Integration & Program Connection

**Dependencies:** Task Groups 1-3

**Assigned to:** api-engineer

- [x] 4.0 Complete integration with programs
  - [ ] 4.1 Write 2-8 focused integration tests
    - Limit to 2-8 highly focused tests maximum
    - Test only critical integration behaviors:
      - Complete flow: view program -> start workout -> preview -> progress -> complete
      - Authentication redirect flow for unauthenticated users
      - Resume workout from workouts index
      - Multiple workouts from same program
    - Skip exhaustive testing of all integration scenarios
  - [x] 4.2 Add workout association to Program model
    - Edit: /Users/jamie/code/fitorforget/app/models/program.rb
    - Add: has_many :workouts, dependent: :nullify (workouts persist as snapshots)
  - [x] 4.3 Add workout association to User model
    - Edit: /Users/jamie/code/fitorforget/app/models/user.rb
    - Add: has_many :workouts, dependent: :destroy
  - [ ] 4.4 Implement authentication redirect with return path
    - In WorkoutsController, use store_location before redirecting to sign-in
    - After authentication, redirect back to workout creation
    - Follow patterns from: /Users/jamie/code/fitorforget/app/controllers/application_controller.rb
  - [ ] 4.5 Add workout count and status to programs index/show
    - Optional: Display "X people have completed this workout" on program show page
    - Show user's own workout history for this program if authenticated
  - [ ] 4.6 Test complete user journey
    - Manual test: Browse program as unauthenticated user
    - Click "Start Workout", redirected to sign-in
    - Sign in, redirected back to workout preview
    - View all exercises in preview
    - Begin workout, progress through exercises
    - Mark some complete, skip others
    - Navigate away and resume
    - Complete workout, see celebration
  - [ ] 4.7 Ensure integration tests pass
    - Run ONLY the 2-8 tests written in 4.1
    - Verify end-to-end workflows function correctly
    - Do NOT run the entire test suite at this stage

**Acceptance Criteria:**
- The 2-8 tests written in 4.1 pass (PENDING - tests not yet written)
- Program and User models have workout associations ✓
- Authentication redirect preserves return path to workout (PENDING)
- Complete user journey works from program browse to workout completion (NEEDS MANUAL TESTING)
- Users can resume interrupted workouts ✓
- Multiple workouts can be created from same program ✓

---

### Task Group 5: Strategic Test Coverage & Polish

**Dependencies:** Task Groups 1-4

**Assigned to:** test-engineer

- [ ] 5.0 Review existing tests and fill critical gaps only
  - [ ] 5.1 Review tests from Task Groups 1-4
    - Review the 2-8 tests written by database-engineer (Task 1.1)
    - Review the 2-8 tests written by api-engineer (Tasks 2.1 and 4.1)
    - Review the 2-8 tests written by ui-designer (Task 3.1)
    - Total existing tests: approximately 8-32 tests
  - [ ] 5.2 Analyze test coverage gaps for workout tracking feature only
    - Identify critical user workflows that lack test coverage
    - Focus ONLY on gaps related to workout tracking feature
    - Do NOT assess entire application test coverage
    - Prioritize end-to-end workflows over unit test gaps
    - Key areas to evaluate:
      - Edge case: Exercise with repeat_count=0 or nil
      - Edge case: Workout with no exercises
      - Error handling: Invalid exercise_id in mark_complete/skip
      - State transitions: Marking already-completed exercise
      - Authorization: User trying to access another user's workout
      - Concurrent updates: Race conditions in completion state
  - [ ] 5.3 Write up to 10 additional strategic tests maximum
    - Add maximum of 10 new tests to fill identified critical gaps
    - Focus on integration points and edge cases that could break user experience
    - Do NOT write comprehensive coverage for all scenarios
    - Skip performance tests, accessibility tests, and minor edge cases
    - Prioritize tests for:
      - Authorization boundaries
      - State transition edge cases
      - Error handling for invalid operations
      - Resume functionality after navigation
  - [ ] 5.4 Run feature-specific tests only
    - Run ONLY tests related to workout tracking feature (tests from 1.1, 2.1, 3.1, 4.1, and 5.3)
    - Expected total: approximately 18-42 tests maximum
    - Do NOT run the entire application test suite
    - Verify all critical workflows pass
    - Fix any failures found
  - [ ] 5.5 Polish and refinements
    - Review UI for mobile usability issues
    - Verify all touch targets meet 44x44px minimum
    - Check video embed responsiveness on actual mobile devices
    - Ensure confetti animation performs well on mobile
    - Verify loading states and error messages are user-friendly
    - Check accessibility: keyboard navigation, screen reader labels
  - [ ] 5.6 Documentation updates
    - Update README if needed with workout tracking feature overview
    - Document JSON structure for exercises_data in code comments
    - Add inline documentation for complex unrolling logic
    - Document Stimulus controllers with usage examples

**Acceptance Criteria:**
- All feature-specific tests pass (approximately 18-42 tests total)
- Critical user workflows for workout tracking are covered
- No more than 10 additional tests added when filling in testing gaps
- Testing focused exclusively on workout tracking feature
- UI is polished and mobile-friendly
- All touch targets meet accessibility standards
- Feature is ready for production deployment

---

## Execution Order

Recommended implementation sequence:

1. **Task Group 1: Database Layer & Workout Model** - Foundation with database schema, model, and exercise unrolling logic ✓
2. **Task Group 2: Workouts Controller & Routes** - API endpoints and business logic for workout operations ✓
3. **Task Group 3: Workout Views & UI Components** - User interface for preview, progression, and completion ✓ (except Stimulus controllers and view tests)
4. **Task Group 4: Integration & Program Connection** - Connect workouts to programs and complete user journey (PARTIAL - associations done, needs integration tests and manual testing)
5. **Task Group 5: Strategic Test Coverage & Polish** - Fill test gaps and polish for production (NOT STARTED)

## Key Technical Decisions

### JSON Column for Exercise Storage
- Using JSON column (exercises_data) instead of separate WorkoutExercise model
- Rationale: Workout is a snapshot; no need for relational queries on exercise instances
- Each exercise instance is independent and only queried as part of parent workout
- Simpler schema, easier to snapshot, sufficient for use case

### Exercise Unrolling Strategy
- Expand repeat_count at workout creation time, not at runtime
- Each repeat becomes separate exercise instance with position, repeat_instance, repeat_total
- Allows independent completion tracking per instance
- Maintains proper ordering: Ex1-Set1, Ex1-Set2, Ex1-Set3, Ex2-Set1...

### Authentication Flow
- Workouts require authentication (can't be anonymous)
- Use store_location and redirect to preserve user intent
- Association-based authorization (current_user.workouts) throughout

### State Management
- Track completion state in JSON (completed, skipped booleans)
- Use timestamps: started_at (first exercise viewed), completed_at (all done)
- Current exercise = first where completed=false and skipped=false
- Auto-advance after marking complete or skip

### Mobile-First Design
- All interactive elements 44x44px minimum touch targets
- Large buttons, clear typography, prominent progress indicators
- Responsive video embeds with tap-to-play
- Test on actual mobile devices for validation

## Testing Strategy

### Minimal Test-Driven Approach
- Each task group (1-4) writes 2-8 focused tests for critical behaviors only
- Tests run after completion of task group, not entire suite
- Task Group 5 adds maximum 10 strategic tests to fill critical gaps
- Total expected: 18-42 tests for entire feature
- Focus on user workflows, not exhaustive coverage

### Test Categories
- **Model tests:** Exercise unrolling, state methods, action methods
- **Controller tests:** Authentication, authorization, CRUD operations
- **View tests:** Rendering, mobile sizing, progress indicators
- **Integration tests:** Complete user journey from program to workout completion

### Out of Scope for Testing Phase
- Performance testing under load
- Comprehensive accessibility audit (basic checks only)
- All edge cases and validation scenarios
- Cross-browser compatibility testing
- Internationalization testing

## References

### Existing Code Patterns
- Program model: /Users/jamie/code/fitorforget/app/models/program.rb
- Exercise model: /Users/jamie/code/fitorforget/app/models/exercise.rb
- User model: /Users/jamie/code/fitorforget/app/models/user.rb
- ApplicationController: /Users/jamie/code/fitorforget/app/controllers/application_controller.rb
- ProgramsController: /Users/jamie/code/fitorforget/app/controllers/programs_controller.rb
- Program show view: /Users/jamie/code/fitorforget/app/views/programs/show.html.erb

### Standards Compliance
- RESTful API conventions per: agent-os/standards/backend/api.md
- Model validations per: agent-os/standards/backend/models.md
- Migration best practices per: agent-os/standards/backend/migrations.md
- Test coverage strategy per: agent-os/standards/testing/test-writing.md
- Component design per: agent-os/standards/frontend/components.md
- Tech stack alignment: Rails 8, Postgres, Turbo/Stimulus, Tailwind CSS
