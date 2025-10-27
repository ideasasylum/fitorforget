# Specification: Program Duplication / Save to My Programs

## Goal
Enable users to save copies of other users' programs and automatically duplicate programs when starting workouts from programs they don't own, creating independent copies they can modify and track.

## User Stories
- As a user viewing someone else's program, I want to click "Save to My Programs" so that I have my own copy to customize
- As a user starting a workout from someone else's program, I want the system to automatically create my own copy so that I can track progress against my own program
- As a program creator, I want others to be able to save and use my programs without affecting my original

## Core Requirements

### Manual Duplication
- Add "Save to My Programs" button on program show page
- Button visible only when: `logged_in? && @program.user_id != current_user.id`
- Button hidden for anonymous users and program owners
- Clicking button creates deep copy and redirects to user's new copy
- Show success flash message: "Program saved to your library"

### Automatic Silent Duplication
- When user starts workout from non-owned program, silently duplicate it first
- Create workout from the duplicated copy (not original)
- No flash message for automatic duplication
- User unaware duplication occurred - seamless experience

### Deep Copy Behavior
- Copy program attributes: `title` (exact, no prefix), `description`
- Copy all associated exercises with: `name`, `repeat_count`, `description`, `video_url`, `position`
- Generate new `id` and `uuid` for duplicated program
- Set `user_id` to `current_user.id`
- Maintain exercise position order
- No reference to original program (completely independent)
- Allow unlimited duplicates (no deduplication)

## Reusable Components

### Existing Code to Leverage
- **Models**: `Program` and `Exercise` with established associations
  - Program: `has_many :exercises, -> { order(position: :asc) }, dependent: :destroy`
  - Exercise: `belongs_to :program`
- **Controllers**: Authentication patterns from `ApplicationController`
  - `current_user`, `logged_in?`, `require_authentication` helpers
  - Flash message patterns: `notice` for success, `alert` for errors
  - UUID-based program lookup: `Program.find_by!(uuid: params[:id])`
- **Views**: Button styling patterns from program show page
  - Primary button classes: "inline-flex items-center justify-center px-8 py-4 ... bg-green-600 hover:bg-green-700 ... min-h-[44px]"
  - Ownership check pattern: `@is_owner` instance variable
- **Routes**: Member action patterns from existing resources
  - Example: `patch :mark_complete` in workouts
- **Testing**: MiniTest patterns from existing test files
  - Model tests: validation and association testing
  - Integration tests: workflow and controller action testing

### New Components Required
- **Program#duplicate**: Instance method for deep copying
  - Does not exist in current codebase
  - Needed to encapsulate duplication logic at model level
  - Must handle transactional copying of program and all exercises
- **ProgramsController#duplicate**: Controller action for manual duplication
  - New POST route and action required
  - Handles authentication, duplication, flash messages, and redirect
- **WorkoutsController#new and #create modifications**: Ownership check and auto-duplication
  - Existing actions need enhancement to check program ownership
  - If not owned, duplicate first, then use duplicated program
  - Silent operation (no flash message)

## Technical Approach

### Program Model Enhancement
Add `duplicate` instance method that:
- Creates new program instance with copied attributes (title, description)
- Sets `user_id` to provided user (typically `current_user`)
- Wraps duplication in database transaction for atomicity
- Iterates through `self.exercises.order(:position)` to copy each exercise
- Creates new exercise records with copied attributes maintaining position order
- Returns the newly created program instance
- Rolls back transaction if any part fails

### Programs Controller Enhancement
Add `duplicate` action that:
- Requires authentication via `before_action :require_authentication`
- Finds source program: `Program.find_by!(uuid: params[:id])`
- Calls `program.duplicate(current_user.id)` to perform duplication
- Sets success flash message
- Redirects to duplicated program show page: `redirect_to @duplicated_program`
- Handles errors with rescue block and error flash message

Update `before_action` to include duplicate action in authentication requirement.

### Workouts Controller Enhancement
Modify `new` and `create` actions to:
- Find program: `Program.find_by!(uuid: params[:program_id])`
- Check ownership: `if program.user_id != current_user.id`
- If not owned: call `program.duplicate(current_user.id)` and use duplicated program
- If owned: use original program
- Continue with existing workout creation logic
- No flash message for auto-duplication (silent operation)

### View Enhancement
Update `app/views/programs/show.html.erb`:
- Add "Save to My Programs" button after "Start Workout" button
- Conditional rendering: `<% if logged_in? && @program.user_id != current_user.id %>`
- Button uses primary styling (green background, 44x44px minimum)
- Form submits POST to `duplicate_program_path(@program)`
- Include save icon SVG for visual clarity

### Routes Enhancement
Add to `config/routes.rb`:
```ruby
resources :programs do
  member do
    post :duplicate
  end
  # existing nested routes...
end
```

### Database Considerations
- No schema changes required (uses existing tables)
- Duplication creates new records with auto-generated IDs
- UUID generation handled by existing `before_create :generate_uuid` callback
- Transaction ensures atomic duplication (all or nothing)

## Out of Scope
- Return-to redirect after login/signup for anonymous users
- Preventing duplicate saves (users can save same program multiple times)
- "Copy of..." prefix on duplicated program titles
- Tracking original program UUID or attribution
- Analytics on program duplication frequency
- Showing users which programs they've already duplicated
- Program version tracking or syncing updates from original
- Duplicate-click protection (Rails default handling sufficient)

## Success Criteria
- User can click "Save to My Programs" button and receive their own independent copy
- User starting workout from non-owned program automatically receives their own copy without visible indication
- Duplicated program includes all exercises in correct order with all attributes
- User can modify their duplicated program without affecting original
- Flash message confirms successful manual duplication
- Button only appears for authenticated users viewing others' programs
- All duplication operations complete atomically (transaction rollback on failure)
- Integration tests verify both manual and automatic duplication workflows
- Model tests verify deep copy logic with exercises
