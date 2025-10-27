# Spec Requirements: Session Start & Exercise Progression

## Initial Description

Build session management allowing users to start a program session and progress through exercises sequentially. Implement UI for marking individual exercises as complete during an active session, with clear visual indicators of progress (e.g., 'Exercise 2 of 8').

This is the workout tracking feature where:
- Users can start a workout session from a program
- They progress through exercises one by one
- Mark each exercise as complete
- See visual progress indicators
- Mobile-first UI with large touch targets

## Requirements Discussion

### First Round Questions

**Q1: Model Naming - Should we call this a "Session" or "Workout"?**
**Answer:** Call it "Workout" not "Session" to avoid confusion with authentication sessions.

**Q2: Exercise Snapshot Strategy - Since programs can change over time, should we snapshot the exercises at workout creation time?**
**Answer:** Yes, programs can change, so we need to snapshot exercises at workout creation. The user is leaning toward a JSON column on the workout model to store exercise instances rather than creating a separate WorkoutExercise model.

**Q3: Exercise Repeat Count Unrolling - How should we handle an exercise with repeat_count=3?**
**Answer:** The repeat_count must be unrolled into individual instances. An exercise with 3x becomes 3 separate exercises in the workout. Each exercise instance needs its own completion state.

**Q4: Authentication Requirement - Can unauthenticated users start workouts?**
**Answer:** No. Unauthenticated users must sign in/signup first before starting a workout.

**Q5: Progression Flow - Should the UI auto-advance to the next exercise after marking one complete?**
**Answer:** Yes, auto-advance after marking complete sounds "fab" to the user.

**Q6: State Persistence - Should users be able to pause and resume workouts?**
**Answer:** Users can resume workouts by clicking on an old workout. There's no explicit pause/resume concept - just open a workout and continue where you left off.

**Q7: Progress Indicators - What type of progress visualization do you want?**
**Answer:** A progress bar showing current position in the workout.

**Q8: Completion Celebration - Should there be any special UI when finishing all exercises?**
**Answer:** Yes, show confetti/celebration when the workout is complete.

**Q9: Navigation - Can users navigate away from a workout and return later?**
**Answer:** Yes, users can navigate away and click the workout to return and continue.

**Q10: Skip Option - Should users be able to skip exercises?**
**Answer:** Yes, allow skipping exercises.

**Q11: Multiple Workouts - Can users have multiple in-progress workouts?**
**Answer:** Yes, users can have multiple workouts. "Active" state isn't really useful - workouts can be completed but can always be reopened and edited.

**Q12: Video Playback - Should videos auto-play or play on tap?**
**Answer:** Tap to play (not auto-play).

### Additional User Thoughts

**Workout Preview Before Starting:**
Before beginning a workout, show a preview list of all exercises.

**One Exercise at a Time:**
Once started, show one exercise at a time during workout progression.

**Existing Exercise Model Context:**
The Exercise model already exists for program templates with a repeat_count field. This is different from the individual workout exercise instances concept.

**JSON Column Preference:**
User is leaning toward JSON column approach for storing exercise instances on the Workout model rather than creating a separate WorkoutExercise join model.

### Existing Code to Reference

**Similar Features Identified:**
No similar existing features were identified. This is a new feature introducing workout tracking for the first time.

**Existing Models to Reference:**
- Program model: `/Users/jamie/code/fitorforget/app/models/program.rb`
- Exercise model: `/Users/jamie/code/fitorforget/app/models/exercise.rb`

**Key Existing Structure:**
- Program has_many :exercises (ordered by position)
- Exercise belongs_to :program
- Exercise has: name, repeat_count, position, video_url, description
- Programs use UUID for public routing
- WebAuthn authentication in place

## Visual Assets

### Files Provided:
No visual assets provided.

### Visual Insights:
N/A

## Requirements Summary

### Functional Requirements

**Workout Model & Data Structure:**
- Create a Workout model that belongs_to :user and belongs_to :program
- Store snapshotted exercise data in a JSON column called `exercise_instances`
- Each exercise instance in the JSON array should contain:
  - Original exercise data: name, description, video_url
  - Instance-specific data: completion state (boolean), order position
  - Repeat instance indicator (e.g., "Set 1 of 3" if original exercise had repeat_count=3)
- Workouts can be reopened and modified even after completion
- No explicit "active" status - workouts exist in various states of completion

**Exercise Unrolling Logic:**
- When creating a workout from a program, iterate through program exercises
- For each exercise with repeat_count > 1, create multiple instances
- Example: Exercise with repeat_count=3 becomes 3 separate exercise instances
- Maintain order: Exercise 1 (3x), Exercise 2 (1x) becomes: Ex1-Set1, Ex1-Set2, Ex1-Set3, Ex2-Set1
- Each instance tracks completion independently

**Authentication & Authorization:**
- Require authentication to start a workout
- If unauthenticated user tries to start workout, redirect to sign-in/sign-up
- Workouts belong to the user who created them
- Users can only access their own workouts

**Workout Creation Flow:**
- User views a program (public, no auth required)
- User clicks "Start Workout" button
- If not authenticated: redirect to authentication
- If authenticated: create workout by snapshotting program exercises, redirect to workout preview

**Workout Preview Screen:**
- Show list of ALL exercise instances that will be in the workout
- Display total count (e.g., "8 exercises")
- Show exercise names with repeat indicators (e.g., "Push-ups - Set 1 of 3")
- Include "Begin Workout" button to start progression
- Able to cancel/go back without starting

**Workout Progression Interface:**
- Show ONE exercise at a time
- Display current exercise details: name, description (with formatting), video embed
- Show progress indicator: "Exercise 3 of 8" and/or progress bar
- Large "Mark Complete" button (44x44px minimum touch target)
- "Skip" button option
- Video player with tap-to-play (no autoplay)

**Exercise Completion Actions:**
- "Mark Complete" button: marks current exercise complete, auto-advances to next
- "Skip" button: marks current exercise skipped (still tracked), auto-advances to next
- Auto-advance means: immediately navigate to next incomplete exercise
- If all exercises complete/skipped: show completion celebration

**Workout Completion:**
- When last exercise is marked complete/skipped: show celebration screen
- Display confetti animation
- Show summary: "Workout Complete! You completed X of Y exercises"
- Provide option to view workout history or return to programs

**State Persistence & Resumption:**
- Users can navigate away from workout at any time
- Workout state persists (completed exercises remain marked)
- Clicking on a workout reopens it at current position
- Resume at first incomplete exercise
- Can navigate back to previously completed exercises to view them

**Skip Functionality:**
- "Skip" button available on each exercise
- Skipped exercises are tracked differently from completed
- Skipped count displayed in completion summary
- Can revisit skipped exercises later in same workout session

**Multiple Workouts:**
- Users can create multiple workouts from same or different programs
- Each workout is independent with its own completion state
- No limit on number of workouts
- Workouts can be reopened even after completion (to review or redo)

**Video Integration:**
- Display video embed if video_url present
- Tap to play/pause (no autoplay)
- Videos should be responsive and mobile-friendly
- Use existing video_url from exercise snapshot

### Reusability Opportunities

**Existing Components to Leverage:**
- Program and Exercise models provide the source data structure
- WebAuthn authentication system already handles sign-in/sign-up flow
- Tailwind CSS framework for mobile-first responsive design
- Turbo and Stimulus for interactive UI without full page reloads

**Backend Patterns:**
- Follow existing patterns from Program CRUD operations
- Use existing user authentication and authorization patterns
- Leverage Rails 8 and SQLite JSON support for exercise_instances column

**Frontend Patterns:**
- Reuse mobile-first design patterns (44x44px touch targets)
- Use existing Tailwind CSS utility classes
- Follow existing UUID-based routing pattern for workouts if needed

### Scope Boundaries

**In Scope:**
- Workout model with JSON column for exercise instances
- Exercise unrolling logic (repeat_count expansion)
- Snapshot/copy exercises from program to workout at creation
- Authentication requirement for workout creation
- Workout preview screen showing all exercises
- Workout progression UI (one exercise at a time)
- Mark complete and skip functionality
- Auto-advance to next exercise
- Progress indicators (count and progress bar)
- Completion celebration with confetti
- State persistence for resuming workouts
- Multiple simultaneous workouts per user
- Video tap-to-play functionality
- Mobile-responsive design with large touch targets

**Out of Scope:**
- Editing workout exercises after creation (workout is a snapshot)
- Timers for timed exercises (future feature)
- Rest period timers between exercises
- Workout scheduling or reminders (future feature)
- Sharing workout results
- Social features or workout comparisons
- Exercise substitution during workout
- Workout templates or favorite workouts
- Statistics or analytics beyond basic completion count
- Offline support (future PWA feature)
- Background sync for offline completions

### Technical Considerations

**Database Schema:**
- Workout model with JSON column `exercise_instances` (SQLite has good JSON support)
- Foreign keys: user_id, program_id
- Timestamps: created_at, updated_at
- Consider adding: started_at (when user begins progression), completed_at (when all exercises done)

**JSON Structure for exercise_instances:**
```json
[
  {
    "id": "unique-instance-id",
    "name": "Push-ups",
    "description": "Standard push-ups...",
    "video_url": "https://youtube.com/...",
    "position": 1,
    "repeat_instance": 1,
    "repeat_total": 3,
    "completed": false,
    "skipped": false
  },
  {
    "id": "unique-instance-id",
    "name": "Push-ups",
    "description": "Standard push-ups...",
    "video_url": "https://youtube.com/...",
    "position": 2,
    "repeat_instance": 2,
    "repeat_total": 3,
    "completed": false,
    "skipped": false
  }
]
```

**Turbo/Stimulus Strategy:**
- Use Turbo Frames for updating individual exercise completion without full reload
- Stimulus controller for workout progression logic
- Stimulus controller for confetti animation
- Stimulus controller for progress bar updates
- Stimulus controller for video player controls

**Mobile-First Design:**
- Large touch targets (minimum 44x44px) for all interactive elements
- Clear typography optimized for phone screens
- Progress bar prominent and visible
- Video embeds responsive and mobile-optimized
- Test on actual mobile devices

**Performance Considerations:**
- JSON column queries in SQLite are efficient for reading/writing
- Avoid N+1 queries when loading workout with program data
- Lazy-load video embeds to improve page load time
- Consider pagination if workout has many exercises (though unlikely)

**Authentication Flow:**
- Check authentication before workout creation
- Redirect to sign-in with return-to parameter to resume after auth
- Ensure workout belongs_to user for authorization

**Similar Code Patterns:**
- Follow Program/Exercise relationship patterns
- Use similar controller patterns from Programs and Exercises controllers
- Leverage existing UUID routing if workouts need public sharing (though likely not)
- Follow existing WebAuthn patterns for authentication checks

**Technology Stack Alignment:**
- Rails 8.1 with ActiveRecord
- SQLite with JSON column support
- Turbo and Stimulus for interactivity
- Tailwind CSS for styling
- WebAuthn for authentication
- Minitest for testing
