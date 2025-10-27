# Specification: Session Start & Exercise Progression (Workout Tracking)

## Goal
Enable authenticated users to start workout sessions from programs, progress through exercises sequentially with clear visual progress indicators, and track completion state with the ability to pause and resume workouts.

## User Stories
- As a program viewer, I want to start a workout from any program so that I can track my exercise progress
- As an unauthenticated user, I want to be prompted to sign in when starting a workout so that my progress is saved
- As a workout participant, I want to see all exercises before starting so that I know what to expect
- As a workout participant, I want to view one exercise at a time with video and description so that I can focus on proper form
- As a workout participant, I want to mark exercises complete or skip them so that I can progress through the workout
- As a workout participant, I want to see my progress (e.g., "Exercise 3 of 8") so that I know how far along I am
- As a workout participant, I want to pause and resume workouts so that I can continue later where I left off
- As a workout participant, I want to see a celebration when I complete a workout so that I feel accomplished

## Core Requirements

### Workout Model
- Belongs to user and program with foreign keys
- Stores snapshotted exercise data in JSON column `exercises_data` (array of exercise instances)
- Each exercise instance contains: name, description, video_url, position, repeat_instance, repeat_total, completed (boolean), skipped (boolean)
- Includes timestamps: created_at, updated_at, started_at (when first exercise viewed), completed_at (when all exercises done)
- Unrolls exercises on creation: exercise with repeat_count=3 becomes 3 separate instances
- Provides methods: complete?, in_progress?, current_exercise, next_exercise, mark_exercise_complete, skip_exercise

### Authentication Flow
- Require authentication before creating workouts
- Redirect unauthenticated users to sign-in with return path
- Association-based authorization (current_user.workouts only)

### Workout Creation Flow
1. User views program page (public, no auth required)
2. User clicks "Start Workout" button
3. If not authenticated: redirect to sign-in with return path
4. If authenticated: create workout by snapshotting and unrolling exercises, redirect to preview

### Workout Preview Screen
- Display all exercise instances in the workout
- Show total count (e.g., "8 exercises")
- Show exercise names with repeat indicators (e.g., "Push-ups - Set 1 of 3")
- Include "Begin Workout" button to start progression
- Allow cancellation/navigation back

### Workout Progression Interface
- Display one exercise at a time
- Show exercise name, description (formatted markdown), and video embed
- Progress indicator: "Exercise X of Y" text and/or progress bar component
- Large "Mark Complete" button (min-w-[44px] min-h-[44px])
- "Skip" button option
- Video tap-to-play (no autoplay)

### Exercise Completion Actions
- "Mark Complete": sets completed=true, auto-advances to next incomplete exercise
- "Skip": sets skipped=true, auto-advances to next incomplete exercise
- Auto-advance navigates immediately to next exercise or completion screen
- Track started_at timestamp when first exercise is viewed

### Workout Completion Screen
- Shown when all exercises are completed or skipped
- Display confetti animation
- Show summary: "Workout Complete! You completed X of Y exercises"
- Set completed_at timestamp
- Provide navigation back to programs or workout history

### State Persistence & Resume
- Users can navigate away at any time (state persists)
- Clicking on workout reopens at current position (first incomplete exercise)
- Can navigate back to view previously completed exercises
- Can reopen completed workouts to view or redo

### Multiple Workouts
- Users can create unlimited workouts from same or different programs
- Each workout has independent completion state
- No restrictions on in-progress workouts

## Visual Design
No mockups provided. Follow existing Wombat Workouts design patterns:
- Gradient background: `bg-gradient-to-br from-indigo-100 via-purple-50 to-pink-100`
- White cards with rounded corners: `bg-white rounded-lg shadow-md`
- Large mobile-friendly buttons: `min-w-[44px] min-h-[44px]`
- Indigo primary color: `bg-indigo-600 hover:bg-indigo-700`
- Responsive video embeds with aspect ratio containers

## Reusable Components

### Existing Code to Leverage
**Models:**
- Program model (`/Users/jamie/code/fitorforget/app/models/program.rb`): UUID routing pattern, belongs_to user, has_many exercises
- Exercise model (`/Users/jamie/code/fitorforget/app/models/exercise.rb`): Source data structure with name, repeat_count, position, video_url, description
- User model (`/Users/jamie/code/fitorforget/app/models/user.rb`): WebAuthn authentication, has_many associations

**Controllers:**
- ApplicationController (`/Users/jamie/code/fitorforget/app/controllers/application_controller.rb`): require_authentication method, current_user helper, return_to path handling
- ProgramsController (`/Users/jamie/code/fitorforget/app/controllers/programs_controller.rb`): Public show action pattern, association-based queries, UUID params

**Views:**
- Program show page (`/Users/jamie/code/fitorforget/app/views/programs/show.html.erb`): Layout patterns, Tailwind styling, mobile-responsive design, authentication CTAs
- Exercise list partial (`/Users/jamie/code/fitorforget/app/views/exercises/_list.html.erb`): Iteration patterns

**Frontend:**
- Turbo Frames for partial page updates
- Stimulus controllers for interactivity
- Tailwind CSS utility classes for styling
- 44x44px touch target pattern established in exercise views

### New Components Required
**Workout Model:**
- New model with JSON column support for exercises_data
- Unrolling logic to expand repeat_count into individual instances
- State management methods (complete?, current_exercise, etc.)
- Cannot reuse Exercise model as instances need independent completion tracking

**WorkoutsController:**
- New RESTful controller with actions: index, new (preview), create, show (current exercise), update (mark complete/skip), destroy
- Cannot reuse ProgramsController as workouts have different authorization and state management

**Workout Views:**
- New preview template to list all exercises before starting
- New show template for single exercise progression view
- New completion template with celebration UI
- Cannot reuse program views as workout flow is fundamentally different

**Progress Bar Stimulus Controller:**
- New controller for visual progress indicator
- Calculates and displays current position in workout
- No existing progress component to reuse

**Confetti Stimulus Controller:**
- New controller for celebration animation on completion
- No existing celebration/animation component

## Technical Approach

### Database Schema
Create `workouts` table with:
- id (primary key)
- user_id (foreign key, not null, indexed, on_delete: cascade)
- program_id (foreign key, not null, indexed, on_delete: cascade)
- exercises_data (text/json column for exercise instances array)
- started_at (datetime, nullable)
- completed_at (datetime, nullable)
- created_at (datetime, not null)
- updated_at (datetime, not null)

### JSON Structure for exercises_data
```json
[
  {
    "id": "uuid-1",
    "name": "Push-ups",
    "description": "Standard push-ups...",
    "video_url": "https://youtube.com/...",
    "position": 1,
    "repeat_instance": 1,
    "repeat_total": 3,
    "completed": false,
    "skipped": false
  }
]
```

### Workout Model Methods
- `initialize_from_program(program)`: Snapshot and unroll exercises from program
- `complete?`: All exercises completed or skipped
- `in_progress?`: Has started_at but not completed_at
- `current_exercise`: First exercise where completed=false and skipped=false
- `next_exercise`: Exercise after current_exercise
- `mark_exercise_complete(exercise_id)`: Set completed=true, set started_at if nil
- `skip_exercise(exercise_id)`: Set skipped=true, set started_at if nil
- `completion_stats`: Returns hash with completed_count, skipped_count, total_count

### Controller Actions
- `index`: List user's workouts ordered by updated_at DESC
- `new`: Preview screen showing workout.exercises_data before starting
- `create`: Initialize workout from program, snapshot exercises, redirect to preview
- `show`: Display current exercise with video, description, action buttons
- `update`: Handle mark_complete or skip actions, set timestamps, redirect to next or completion
- `destroy`: Delete workout with confirmation

### Turbo/Stimulus Integration
- Turbo Frames for exercise transitions without full page reload
- Progress bar Stimulus controller for updating position indicator
- Confetti Stimulus controller triggered on completion screen
- Video player Stimulus controller for tap-to-play controls

### Routing
```ruby
resources :workouts, except: [:edit] do
  member do
    patch :mark_complete
    patch :skip
  end
end
```

### Mobile-First Design Considerations
- All interactive elements minimum 44x44px touch targets
- Large, clear typography for exercise names and descriptions
- Prominent progress bar at top of screen
- Full-width buttons for actions
- Responsive video embeds with proper aspect ratio
- Test on actual mobile devices

## Out of Scope
- Editing workout exercises after creation (snapshot is immutable)
- Timers for timed exercises
- Rest period timers between exercises
- Workout scheduling or calendar reminders
- Sharing workout results or social features
- Exercise substitution during active workout
- Workout templates or favorites
- Detailed analytics beyond basic completion stats
- Offline support (PWA features)
- Background sync for offline completions
- UUID routing for workouts (integer IDs sufficient as workouts are private)
- Deleting individual exercises from workout
- Reordering exercises during workout

## Success Criteria
- Authenticated users can start workouts from any program
- Exercises are properly snapshotted and unrolled (repeat_count expansion works correctly)
- Users can progress through exercises one at a time
- Progress indicators accurately show position in workout
- Mark complete and skip actions work correctly and auto-advance
- Workouts can be paused (navigated away) and resumed from current position
- Completion screen displays with celebration animation
- Multiple workouts can exist simultaneously per user
- All touch targets meet 44x44px minimum for mobile usability
- Videos play on tap, not automatically
- Integration tests cover full workout flow from start to completion
