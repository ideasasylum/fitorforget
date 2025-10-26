# Task Breakdown: Exercise Management within Programs

## Overview
Total Tasks: 24 sub-tasks across 5 task groups

## Task List

### Foundation Layer

#### Task Group 1: ActionText Setup
**Dependencies:** None

- [x] 1.0 Complete ActionText foundation setup
  - [x] 1.1 Install ActionText and Active Storage
    - Run `rails action_text:install` to generate migrations and initializers
    - Run `rails active_storage:install` for attachment storage
    - Review generated migrations for SQLite compatibility
  - [x] 1.2 Run ActionText migrations
    - Run `rails db:migrate` to create action_text_rich_texts and active_storage tables
    - Verify schema.rb includes new tables with proper indexes
  - [x] 1.3 Configure Active Storage for development
    - Verify config/storage.yml includes local disk storage configuration
    - Ensure config/environments/development.rb uses local storage
    - No changes needed if defaults are already configured

**Acceptance Criteria:**
- ActionText and Active Storage migrations successfully applied
- active_storage_blobs, active_storage_attachments, and action_text_rich_texts tables exist in schema
- Application starts without errors related to ActionText/Active Storage

### Database Layer

#### Task Group 2: Exercise Model and Migration
**Dependencies:** Task Group 1

- [x] 2.0 Complete Exercise database layer
  - [x] 2.1 Write 2-8 focused tests for Exercise model
    - Test exercise creation with valid attributes (name, repeat_count, position)
    - Test belongs_to program association
    - Test presence validation for name and repeat_count
    - Test numericality validation for repeat_count (positive integer)
    - Test URL format validation for video_url when present
    - Test ActionText rich_text :description association
    - Limit to 6-8 critical tests maximum
  - [x] 2.2 Create exercises migration
    - Generate migration: `rails g migration CreateExercises`
    - Add columns: name:string (NOT NULL), repeat_count:integer (NOT NULL), video_url:string, position:integer (NOT NULL), program_id:integer (NOT NULL)
    - Add timestamps (created_at, updated_at)
    - Add foreign key to programs with on_delete: :cascade
    - Add index on program_id
    - Add composite index on [program_id, position] for ordering queries
    - Follow pattern from programs migration in schema.rb
  - [x] 2.3 Create Exercise model with validations
    - Create app/models/exercise.rb
    - Add belongs_to :program association
    - Add has_rich_text :description for ActionText integration
    - Validate presence of name, repeat_count, position, and program
    - Validate numericality of repeat_count (only_integer: true, greater_than: 0)
    - Validate URL format for video_url when present (allow_blank: true)
    - Follow validation patterns from app/models/program.rb
  - [x] 2.4 Add exercises association to Program model
    - Open app/models/program.rb
    - Add has_many :exercises, dependent: :destroy association
    - Add has_many :exercises, -> { order(position: :asc) } for ordered retrieval
  - [x] 2.5 Run database migration
    - Run `rails db:migrate` to create exercises table
    - Verify schema.rb includes exercises table with all fields and indexes
  - [x] 2.6 Ensure Exercise model tests pass
    - Run exercise model tests: `rails test test/models/exercise_test.rb`
    - Verify all 6-8 tests pass
    - Do NOT run the entire test suite at this stage

**Acceptance Criteria:**
- The 6-8 tests written in 2.1 pass
- exercises table exists with proper columns, indexes, and foreign key constraint
- Exercise model validates all required fields correctly
- Program has_many :exercises association works
- ActionText description field is accessible on Exercise model

### Backend Layer

#### Task Group 3: Exercises Controller and Routes
**Dependencies:** Task Group 2

- [x] 3.0 Complete exercises backend API
  - [x] 3.1 Write 2-8 focused tests for ExercisesController
    - Test POST create action adds exercise to authorized program
    - Test PATCH update action modifies exercise in authorized program
    - Test DELETE destroy action removes exercise from authorized program
    - Test PATCH move action updates exercise position
    - Test authorization prevents access to exercises in other users' programs
    - Test Turbo Stream responses for create/update/destroy actions
    - Limit to 6-8 critical tests maximum
  - [x] 3.2 Configure nested routes for exercises
    - Open config/routes.rb
    - Nest exercises resources under programs using shallow nesting
    - Add custom member route for move action: `patch :move, on: :member`
    - Routes should be: POST /programs/:program_uuid/exercises, PATCH /exercises/:id, DELETE /exercises/:id, PATCH /exercises/:id/move
    - Follow nested routing pattern matching RESTful conventions
  - [x] 3.3 Create ExercisesController
    - Generate controller: `rails g controller Exercises`
    - Add before_action :require_authentication (from ApplicationController)
    - Add before_action :set_program_and_authorize, only: [:create]
    - Add before_action :set_exercise_and_authorize, only: [:update, :destroy, :move]
    - Implement create action with Turbo Stream response
    - Implement update action with Turbo Stream response
    - Implement destroy action with Turbo Stream response
    - Implement move action for position updates
    - Follow authorization pattern from app/controllers/programs_controller.rb
  - [x] 3.4 Implement authorization methods
    - Add private method set_program_and_authorize to load program by UUID and verify ownership
    - Use current_user.programs.find_by!(uuid: params[:program_id]) pattern
    - Add private method set_exercise_and_authorize to load exercise and verify program ownership
    - Return appropriate error or redirect if authorization fails
  - [x] 3.5 Implement strong parameters
    - Add private method exercise_params
    - Permit: :name, :repeat_count, :video_url, :description, :position
    - Follow pattern from programs_controller.rb
  - [x] 3.6 Ensure ExercisesController tests pass
    - Run controller tests: `rails test test/controllers/exercises_controller_test.rb`
    - Verify all 6-8 tests pass
    - Do NOT run the entire test suite at this stage

**Acceptance Criteria:**
- The 6-8 tests written in 3.1 pass
- Exercises routes are properly nested under programs with shallow routing
- ExercisesController enforces authorization through program ownership
- All CRUD actions return appropriate Turbo Stream responses
- Move action successfully updates exercise position

### Frontend Layer

#### Task Group 4: Exercise UI Components and Inline Editing
**Dependencies:** Task Group 3

- [x] 4.0 Complete exercise UI and inline editing
  - [x] 4.1 Write 2-8 focused tests for exercise UI interactions
    - Test exercise list renders all exercises for a program
    - Test inline form displays when "Add Exercise" is clicked
    - Test exercise creation via inline form
    - Test inline edit form displays when edit icon clicked
    - Test exercise update via inline edit form
    - Test exercise deletion with confirmation
    - Limit to 6-8 critical integration tests maximum
  - [x] 4.2 Update program show page to include exercises section
    - Open app/views/programs/show.html.erb
    - Add exercises section after program description
    - Add "Add Exercise" button that displays inline form
    - Wrap exercises list in Turbo Frame for seamless updates
    - Follow Tailwind styling patterns from existing program views
  - [x] 4.3 Create exercise list partial
    - Create app/views/exercises/_exercise.html.erb
    - Display exercise name, repeat_count, video_url (if present), and description
    - Add edit and delete icons positioned next to each exercise
    - Add drag handle for desktop (hidden on mobile with Tailwind md: classes)
    - Add up/down arrow buttons for mobile (visible only on mobile with Tailwind classes)
    - Use Tailwind for styling with minimum 44x44px touch targets
    - Follow error display patterns from app/views/programs/_form.html.erb
  - [x] 4.4 Create inline exercise form partial
    - Create app/views/exercises/_form.html.erb
    - Include fields: name (text_field), repeat_count (number_field with inputmode="numeric" pattern="[0-9]*"), video_url (url_field), description (rich_text_area)
    - Add field-level error display following Program form pattern
    - Add submit and cancel buttons
    - Use Tailwind styling matching programs form
    - Ensure mobile-optimized with large touch targets
  - [x] 4.5 Create Turbo Stream templates
    - Create app/views/exercises/create.turbo_stream.erb for appending new exercise
    - Create app/views/exercises/update.turbo_stream.erb for replacing updated exercise
    - Create app/views/exercises/destroy.turbo_stream.erb for removing deleted exercise
    - Use Turbo Stream actions: append, replace, remove
  - [x] 4.6 Implement drag-and-drop Stimulus controller
    - Create app/javascript/controllers/drag_controller.js
    - Implement HTML5 Drag and Drop API for desktop reordering
    - Add visual feedback during drag (opacity change, placeholder)
    - Send AJAX request to move action on drop
    - Handle success/error responses from server
    - Reference Stimulus controller pattern from webauthn_controller.js
  - [x] 4.7 Implement mobile reorder Stimulus controller
    - Create app/javascript/controllers/reorder_controller.js or add to drag_controller.js
    - Implement up/down button click handlers
    - Send AJAX request to move action with new position
    - Update UI optimistically with server confirmation
    - Handle error cases with rollback
  - [x] 4.8 Apply responsive mobile styling
    - Ensure repeat_count field uses inputmode="numeric" and pattern="[0-9]*"
    - Hide drag handles on mobile breakpoints (< md) using Tailwind
    - Show up/down arrows only on mobile breakpoints
    - Verify all touch targets are minimum 44x44px
    - Test inline forms on mobile viewport sizes
  - [x] 4.9 Ensure exercise UI tests pass
    - Run integration tests: `rails test test/integration/exercises_test.rb`
    - Verify all 6-8 tests pass
    - Manually test in browser: create, edit, reorder, delete exercises
    - Do NOT run the entire test suite at this stage

**Acceptance Criteria:**
- The 6-8 tests written in 4.1 pass
- Exercises display in ordered list on program show page
- Inline add/edit forms work seamlessly with Turbo Frames
- Drag-and-drop reordering works on desktop with visual feedback
- Up/down arrows work on mobile for reordering
- Mobile numeric keyboard appears for repeat_count field
- ActionText editor displays and saves rich text descriptions
- All interactive elements meet 44x44px touch target minimum

### Testing Layer

#### Task Group 5: Strategic Test Coverage & Integration Verification
**Dependencies:** Task Groups 1-4

- [x] 5.0 Review existing tests and fill critical gaps only
  - [x] 5.1 Review tests from Task Groups 2-4
    - Review the 6-8 tests written for Exercise model (Task 2.1)
    - Review the 6-8 tests written for ExercisesController (Task 3.1)
    - Review the 6-8 tests written for exercise UI (Task 4.1)
    - Total existing tests: approximately 18-24 tests
  - [x] 5.2 Analyze test coverage gaps for Exercise Management feature only
    - Identify critical user workflows that lack test coverage
    - Focus on end-to-end scenarios: full exercise lifecycle within a program
    - Check position updates maintain correct ordering after multiple reorders
    - Verify cascade delete when program is deleted removes all exercises
    - Do NOT assess entire application test coverage
    - Prioritize integration scenarios over unit test gaps
  - [x] 5.3 Write up to 10 additional strategic tests maximum if needed
    - Add tests for edge cases in position ordering (e.g., moving first to last, last to first)
    - Add test for cascading delete (deleting program removes all exercises)
    - Add test for concurrent position updates (if relevant)
    - Add test for ActionText attachment handling (if uploading images in descriptions)
    - Do NOT write comprehensive coverage for all scenarios
    - Skip performance tests, accessibility tests unless business-critical
    - Maximum 10 new tests total
  - [x] 5.4 Run complete feature test suite
    - Run all exercise-related tests: `rails test test/models/exercise_test.rb test/controllers/exercises_controller_test.rb test/integration/exercises_test.rb`
    - Expected total: approximately 28-34 tests maximum
    - Verify all tests pass
    - Do NOT run the entire application test suite unless instructed
  - [x] 5.5 Perform manual end-to-end testing
    - Create new program and add 5+ exercises with various content
    - Edit exercise names, repeat counts, video URLs, and descriptions
    - Test drag-and-drop reordering on desktop browser
    - Test mobile reordering using up/down arrows on mobile viewport
    - Verify numeric keyboard appears for repeat_count on mobile
    - Test exercise deletion with confirmation
    - Delete program and verify exercises are cascade deleted
    - Test with 20+ exercises to verify performance

**Acceptance Criteria:**
- All feature-specific tests pass (approximately 28-34 tests total)
- Critical user workflows for exercise management are covered
- No more than 10 additional tests added when filling gaps
- Manual testing confirms all features work smoothly
- Performance is acceptable with 50+ exercises in a program
- Mobile experience is optimized with correct keyboards and touch targets

## Execution Order

Recommended implementation sequence:
1. **Foundation Layer** (Task Group 1) - Set up ActionText and Active Storage
2. **Database Layer** (Task Group 2) - Create Exercise model with associations and validations
3. **Backend Layer** (Task Group 3) - Build ExercisesController with authorization and routes
4. **Frontend Layer** (Task Group 4) - Implement UI components, forms, and Stimulus controllers
5. **Testing Layer** (Task Group 5) - Review coverage and perform integration verification

## Key Technical Decisions

### Authorization Strategy
- All exercise operations are scoped through program ownership
- Use `current_user.programs.find_by!(uuid: params[:program_id])` to verify program access
- Exercise authorization inherits from program authorization

### Position Management
- Position field is an integer starting from 1
- Reordering updates positions of affected exercises
- Position is scoped within each program (two programs can have exercises with position 1)
- Use `-> { order(position: :asc) }` scope for consistent ordering

### Turbo Integration
- Turbo Frames wrap exercise list for seamless inline updates
- Turbo Streams handle create/update/destroy responses
- Stimulus controllers manage drag-and-drop and reordering interactions
- Optimistic UI updates with server confirmation for better UX

### Mobile Optimization
- `inputmode="numeric"` triggers mobile numeric keyboard for repeat_count
- `pattern="[0-9]*"` ensures iOS numeric keyboard
- Drag handles hidden below md breakpoint using Tailwind responsive classes
- Up/down arrows visible only below md breakpoint
- Minimum 44x44px touch targets for all interactive elements

### ActionText Integration
- Exercise description uses ActionText `has_rich_text :description`
- Requires Active Storage for image attachments in rich text
- Trix editor provides mobile-friendly rich text editing
- No additional configuration needed beyond standard ActionText setup

## Notes

- This feature builds directly on the completed Program CRUD feature
- Reuse existing patterns: UUID routing, authorization, form styling, error handling
- Focus on mobile-first design with progressive enhancement for desktop
- Keep tests strategic and focused on critical user workflows
- Ensure cascade delete works properly (deleting program removes exercises)
