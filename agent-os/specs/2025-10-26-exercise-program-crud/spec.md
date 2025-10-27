# Specification: Exercise Program CRUD

## Goal

Enable authenticated users to create, view, edit, and delete their personal exercise programs with title and description fields. Each program receives a UUID for future sharing capabilities.

## User Stories

- As a logged-in user, I want to create exercise programs with a title and description so that I can organize my workouts
- As a logged-in user, I want to view all my programs in a list so that I can see what programs I've created
- As a logged-in user, I want to view individual program details so that I can review the program information
- As a logged-in user, I want to edit my programs so that I can update titles and descriptions as needed
- As a logged-in user, I want to delete programs I no longer need with a confirmation step to prevent accidental deletions
- As a new user with no programs, I want to see an encouraging call-to-action so that I understand how to get started

## Core Requirements

### Program Management
- Create new programs with title and description
- View complete list of user's programs at `/programs`
- View individual program details at `/programs/:id`
- Edit existing program title and description
- Delete programs with Turbo Frame modal confirmation
- Programs automatically receive unique UUID on creation

### Data Model
- Program belongs to User (required association)
- Title: required, maximum 200 characters
- Description: optional, text field
- UUID: auto-generated via `before_create` callback using `SecureRandom.uuid`
- Timestamps: created_at and updated_at (Rails default)

### User Interface
- Mobile-first responsive design using Tailwind CSS
- Empty state with "Create Your First Program" CTA when user has no programs
- Flash messages for success/error feedback using Rails conventions (`:notice`, `:alert`)
- Seamless navigation using Turbo Frames
- Delete confirmation modal using Turbo Frames

### Authorization
- CRITICAL: All queries MUST use `current_user.programs` association pattern
- Users can only access their own programs
- Automatic 404 if user attempts to access another user's program

## Visual Design

No mockups provided. Follow existing application patterns:
- Consistent Tailwind styling matching authentication pages
- Gradient backgrounds similar to signin/signup pages
- Rounded cards with shadows for content containers
- Indigo color scheme (indigo-600 for primary actions)
- Form fields with rounded-lg borders and proper focus states
- Mobile-responsive layouts using max-w containers

## Reusable Components

### Existing Code to Leverage

**User Model Pattern:**
- File: `/Users/jamie/code/fitorforget/app/models/user.rb`
- Pattern: `before_create` callback with `SecureRandom.hex(16)` for webauthn_id generation
- Pattern: Model-level validations for presence, uniqueness, and format
- Reuse: Similar callback pattern for UUID generation in Program model

**Controller Authorization Pattern:**
- File: `/Users/jamie/code/fitorforget/app/controllers/application_controller.rb`
- Pattern: `current_user` helper method and `require_authentication` before_action
- Pattern: Session-based authentication with `session[:user_id]`
- Reuse: Use `require_authentication` before_action in ProgramsController
- Reuse: Access current user via `current_user` helper

**Migration Pattern:**
- Files: `/Users/jamie/code/fitorforget/db/migrate/20251026114301_create_users.rb` and `20251026114329_create_credentials.rb`
- Pattern: Foreign key constraints with `foreign_key: { on_delete: :cascade }`
- Pattern: NOT NULL constraints on required fields
- Pattern: Unique indexes on identifier columns
- Pattern: Standard index on foreign keys
- Reuse: Apply same patterns to programs migration

**Flash Message Styling:**
- File: `/Users/jamie/code/fitorforget/app/views/layouts/application.html.erb`
- Pattern: Green background (bg-green-50) with green border for success notices
- Pattern: Red background (bg-red-50) with red border for error alerts
- Pattern: SVG icons with flex layout
- Reuse: Existing flash message display in application layout (no changes needed)

**Turbo Frame Pattern:**
- File: `/Users/jamie/code/fitorforget/app/views/sessions/new_signin.html.erb`
- Pattern: `turbo_frame_tag` wrapping dynamic content for seamless updates
- Pattern: Form with `form_with` helper submitting to controller actions
- Pattern: Controller renders `turbo_stream.replace` for frame updates
- Reuse: Similar pattern for delete confirmation modal

**Form Styling Pattern:**
- File: `/Users/jamie/code/fitorforget/app/views/sessions/new_signin.html.erb`
- Pattern: `rounded-lg` inputs with `border-gray-300`
- Pattern: Full width fields with `w-full`
- Pattern: Focus states with `focus:ring-indigo-500 focus:border-indigo-500`
- Pattern: Large touch targets with `py-3 px-4`
- Pattern: Indigo submit buttons with hover states
- Reuse: Apply identical styling to program forms

**Navigation Bar:**
- File: `/Users/jamie/code/fitorforget/app/views/layouts/application.html.erb`
- Pattern: Fixed top navigation with white background and shadow
- Pattern: "Wombat Workouts" logo link to root path
- Pattern: User email display and logout button
- Consideration: Add "Programs" navigation link in future enhancement

### New Components Required

**Program Model:**
- Why: No existing model for user-owned content resources
- Purpose: Define program structure, validations, and UUID generation
- Associations: belongs_to :user

**ProgramsController:**
- Why: No existing CRUD controller pattern in codebase
- Purpose: Handle all CRUD operations with association-based authorization
- Actions: index, show, new, create, edit, update, destroy

**Programs Routes:**
- Why: Need RESTful routes for program resources
- Pattern: `resources :programs` in routes.rb

**Program Views:**
- Why: No existing view patterns for user-owned resource management
- Templates needed: index, show, new, edit, _form partial
- Modal needed: Delete confirmation Turbo Frame

**Program Migration:**
- Why: New database table required
- Fields: title, description, uuid, user_id, timestamps

## Technical Approach

### Database Schema

Create migration with:
- Table name: `programs`
- Fields:
  - `title` (string, null: false)
  - `description` (text, null: true)
  - `uuid` (string, null: false)
  - `user_id` (bigint, null: false, foreign key)
  - `created_at`, `updated_at` (timestamps)
- Indexes:
  - Unique index on `uuid`
  - Standard index on `user_id` (foreign key)
- Foreign key constraint: `user_id` references users with `on_delete: :cascade`

### Model Implementation

Program model with:
- Association: `belongs_to :user`
- Validations:
  - Title: presence true, length maximum 200
  - User: presence true (validates association exists)
- Callback: `before_create :generate_uuid`
- Private method: `generate_uuid` using `SecureRandom.uuid`

### Controller Implementation

ProgramsController with:
- Before action: `before_action :require_authentication` (all actions)
- Before action: `before_action :set_program, only: [:show, :edit, :update, :destroy]`
- Authorization: ALL queries through `current_user.programs` association
- Actions:
  - Index: `@programs = current_user.programs.order(created_at: :desc)`
  - Show: Uses `@program` from before_action
  - New: `@program = current_user.programs.build`
  - Create: `@program = current_user.programs.build(program_params)`
  - Edit: Uses `@program` from before_action
  - Update: Uses `@program` from before_action with `@program.update(program_params)`
  - Destroy: Uses `@program` from before_action with `@program.destroy`
- Flash messages: Use `:notice` for success, `:alert` for errors
- Private method: `set_program` calls `@program = current_user.programs.find(params[:id])`
- Private method: `program_params` permits title and description only

### Routes Configuration

Add to routes.rb:
```ruby
resources :programs
```

This creates RESTful routes at `/programs` path.

### View Implementation

**Index View:**
- Check if `@programs.any?` to show list or empty state
- Empty state: Card with "Create Your First Program" heading and CTA button
- Programs list: Cards showing title, truncated description, view/edit/delete links
- "New Program" button prominently displayed

**Show View:**
- Display program title as heading
- Display full description
- Action buttons: Edit and Delete
- Delete button opens Turbo Frame modal

**Form Partial:**
- Shared by new and edit views
- Title field: text input, required, maxlength 200
- Description field: textarea, optional, rows 6
- Submit button: "Create Program" or "Update Program" based on context
- Display validation errors inline with Tailwind error styling

**Delete Confirmation Modal:**
- Turbo Frame implementation
- Display program title in confirmation message
- Cancel and Confirm Delete buttons
- Styled as modal overlay with backdrop

### Authorization Strategy

CRITICAL - Use association-based authorization exclusively:
- Query pattern: `current_user.programs.find(params[:id])`
- Build pattern: `current_user.programs.build(params)`
- Scope pattern: `current_user.programs.where(...)`
- Never check: `current_user.id == @program.user_id`
- Never use: Pundit or other authorization gems
- Error handling: Let ActiveRecord raise RecordNotFound, Rails handles 404

### Validation Strategy

Model-level validations:
- Title presence and length enforced by ActiveRecord
- User association presence enforced by ActiveRecord
- UUID uniqueness enforced by database unique index
- Server-side validation only (no client-side validation required initially)

Display validation errors:
- Use Rails form error helpers
- Style with Tailwind red color scheme (text-red-600, border-red-300)
- Show field-specific errors below each input

### Turbo Frame Modal Implementation

Delete confirmation modal:
- Delete link triggers Turbo Frame load of confirmation partial
- Modal partial contains Turbo Frame with matching ID
- Confirmation form submits DELETE request
- Success redirects to index with flash notice
- Uses Stimulus controller for modal open/close animations (optional enhancement)

## Out of Scope

### Excluded from This Feature
- Exercise management (adding exercises to programs)
- Public UUID viewing or sharing UI
- Share buttons or public program pages
- Session tracking or workout logging
- Program templates or cloning functionality
- Dedicated `/dashboard` page (reserved for future)
- Soft delete or archiving (use hard delete)
- Program categories, tags, or labels
- Search or filtering on programs list
- Pagination (not needed for initial implementation)
- Sorting options beyond created_at descending
- Program duplication
- Bulk actions on programs
- Program export/import
- Program statistics or analytics

### Future Enhancements (Not Now)
- UUID-based public viewing for sharing programs
- Navigation menu item for Programs
- Dashboard aggregating programs and other features
- Advanced program organization features

## Success Criteria

### Functional Success
- Users can create programs with title and description
- Users see all their programs at `/programs` in reverse chronological order
- Users can edit any of their programs
- Users can delete programs with confirmation modal
- Users cannot access other users' programs (404 error)
- New users see encouraging empty state with CTA

### Technical Success
- All authorization uses `current_user.programs` association pattern
- UUID automatically generated on program creation
- Database includes proper indexes and foreign key constraints
- Flash messages provide clear feedback for all actions
- Mobile-responsive UI works well on phones and tablets
- Turbo Frames provide seamless user experience without full page reloads

### Code Quality Success
- Follows Rails RESTful conventions
- Adheres to all standards defined in agent-os/standards/
- Migration includes reversible down method
- Controller uses strong parameters
- Views use form helpers and partials appropriately
- Consistent Tailwind styling matching existing pages
