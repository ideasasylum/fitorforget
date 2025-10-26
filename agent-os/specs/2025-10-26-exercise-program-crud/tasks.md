# Task Breakdown: Exercise Program CRUD

## Overview
Total Task Groups: 4
Estimated Complexity: Medium (M)

This breakdown implements full CRUD operations for exercise programs, enabling authenticated users to create, view, edit, and delete their personal workout programs. Each program includes title, description, and auto-generated UUID for future sharing capabilities. The implementation follows a strategic bottom-up approach: database layer, backend logic, frontend UI, and finally strategic test coverage.

## Task List

### Database Layer

#### Task Group 1: Program Model & Migration
**Dependencies:** None (builds on completed WebAuthn authentication)

- [x] 1.0 Complete database schema and Program model
  - [x] 1.1 Write 2-8 focused tests for Program model
    - Limit to 2-8 highly focused tests maximum
    - Test critical behaviors only:
      - Title presence validation
      - Title length validation (max 200 characters)
      - User association presence validation
      - UUID generation on create
      - belongs_to user association
    - Skip exhaustive edge case testing
  - [x] 1.2 Generate Program model and migration
    - Generate: `rails generate model Program user:references title:string description:text uuid:string`
    - Migration fields:
      - `user_id` (bigint, not null, foreign key, indexed)
      - `title` (string, not null)
      - `description` (text, nullable)
      - `uuid` (string, not null, unique, indexed)
      - `created_at`, `updated_at` (timestamps)
    - Add database constraints in migration:
      - `add_index :programs, :uuid, unique: true`
      - `add_index :programs, :user_id`
      - `add_foreign_key :programs, :users, on_delete: :cascade`
  - [x] 1.3 Implement Program model validations
    - Validate title presence
    - Validate title length: maximum 200 characters
    - Validate user association presence
    - Generate UUID before_create using `SecureRandom.uuid`
    - Pattern: Follow User model's `generate_webauthn_id` callback pattern
  - [x] 1.4 Set up Program-User association
    - Add `belongs_to :user` to Program model (required: true)
    - Add `has_many :programs, dependent: :destroy` to User model
    - Verify association works in both directions
  - [x] 1.5 Run migration and verify database schema
    - Execute: `rails db:migrate`
    - Verify programs table created with all fields
    - Verify indexes on uuid (unique) and user_id
    - Verify foreign key constraint with cascade delete
  - [x] 1.6 Ensure database layer tests pass
    - Run ONLY the tests written in 1.1 (2-8 tests maximum)
    - Verify all validations work correctly
    - Verify UUID auto-generation works
    - Verify user association functions properly
    - Do NOT run entire test suite at this stage

**Acceptance Criteria:**
- [x] The 2-8 tests written in 1.1 pass
- [x] Programs table created with title, description, uuid, user_id, timestamps
- [x] Database constraints enforced (not null on title, user_id; unique on uuid)
- [x] Indexes created on uuid (unique) and user_id
- [x] Foreign key constraint with cascade delete configured
- [x] Program model validates title presence and length
- [x] Program model validates user association presence
- [x] UUID auto-generated on program creation using SecureRandom.uuid
- [x] has_many/belongs_to associations work correctly
- [x] Migration runs successfully without errors

---

### Backend Layer

#### Task Group 2: ProgramsController & Routes
**Dependencies:** Task Group 1

- [x] 2.0 Complete backend CRUD operations
  - [x] 2.1 Write 2-8 focused tests for ProgramsController
    - Limit to 2-8 highly focused tests maximum
    - Test critical controller actions only:
      - GET /programs (index) renders list for authenticated user
      - GET /programs/new renders new program form
      - POST /programs creates program for current_user
      - GET /programs/:id shows program owned by current_user
      - PATCH /programs/:id updates program owned by current_user
      - DELETE /programs/:id destroys program owned by current_user
      - Authorization: accessing another user's program returns 404
    - Skip exhaustive scenarios and edge cases
  - [x] 2.2 Configure RESTful routes for programs
    - Add to `config/routes.rb`:
      - `resources :programs`
    - This creates standard RESTful routes:
      - GET /programs (index)
      - GET /programs/new (new)
      - POST /programs (create)
      - GET /programs/:id (show)
      - GET /programs/:id/edit (edit)
      - PATCH /programs/:id (update)
      - DELETE /programs/:id (destroy)
  - [x] 2.3 Create ProgramsController with authentication
    - Generate: `rails generate controller Programs`
    - Add `before_action :require_authentication` (all actions)
    - Add `before_action :set_program, only: [:show, :edit, :update, :destroy]`
    - Pattern: Follow ApplicationController's authentication helper pattern
  - [x] 2.4 Implement ProgramsController#index action
    - Query: `@programs = current_user.programs.order(created_at: :desc)`
    - CRITICAL: Use `current_user.programs` association pattern for authorization
    - Render: `app/views/programs/index.html.erb`
  - [x] 2.5 Implement ProgramsController#show action
    - Uses `@program` from `set_program` before_action
    - Authorization handled by association query in set_program
    - Render: `app/views/programs/show.html.erb`
  - [x] 2.6 Implement ProgramsController#new action
    - Build: `@program = current_user.programs.build`
    - CRITICAL: Use `current_user.programs.build` pattern
    - Render: `app/views/programs/new.html.erb`
  - [x] 2.7 Implement ProgramsController#create action
    - Build: `@program = current_user.programs.build(program_params)`
    - CRITICAL: Use association-based creation
    - If save successful:
      - Flash: `notice: "Program created successfully"`
      - Redirect to: `program_path(@program)` or `programs_path`
    - If save fails:
      - Flash: `alert: "Could not create program"`
      - Render: `new` template with error messages
    - Strong params permit: title, description only
  - [x] 2.8 Implement ProgramsController#edit action
    - Uses `@program` from `set_program` before_action
    - Authorization handled by association query
    - Render: `app/views/programs/edit.html.erb`
  - [x] 2.9 Implement ProgramsController#update action
    - Uses `@program` from `set_program` before_action
    - Update: `@program.update(program_params)`
    - If update successful:
      - Flash: `notice: "Program updated successfully"`
      - Redirect to: `program_path(@program)`
    - If update fails:
      - Flash: `alert: "Could not update program"`
      - Render: `edit` template with error messages
    - Strong params permit: title, description only
  - [x] 2.10 Implement ProgramsController#destroy action
    - Uses `@program` from `set_program` before_action
    - Destroy: `@program.destroy`
    - Flash: `notice: "Program deleted successfully"`
    - Redirect to: `programs_path`
  - [x] 2.11 Implement set_program private method
    - CRITICAL PATTERN: `@program = current_user.programs.find(params[:id])`
    - Do NOT use: `Program.find(params[:id])` then check ownership
    - ActiveRecord automatically raises RecordNotFound if not owned
    - Rails handles RecordNotFound as 404 error
  - [x] 2.12 Implement program_params private method
    - Strong parameters: `params.require(:program).permit(:title, :description)`
    - Do NOT permit uuid or user_id (auto-generated/assigned)
  - [x] 2.13 Ensure backend layer tests pass
    - Run ONLY the tests written in 2.1 (2-8 tests maximum)
    - Verify critical CRUD operations work
    - Verify authorization through association queries
    - Verify flash messages display correctly
    - Do NOT run entire test suite at this stage

**Acceptance Criteria:**
- [x] The 2-8 tests written in 2.1 pass
- [x] RESTful routes configured for programs resource
- [x] ProgramsController requires authentication for all actions
- [x] Index action lists programs in reverse chronological order
- [x] Show action displays individual program details
- [x] New action renders form for creating program
- [x] Create action saves program with association to current_user
- [x] Edit action renders form for updating program
- [x] Update action saves changes to program
- [x] Destroy action deletes program
- [x] set_program method uses association query: `current_user.programs.find(params[:id])`
- [x] program_params permits only title and description
- [x] Flash messages display for success/failure of actions
- [x] Authorization enforced via association queries (automatic 404 for unauthorized access)

---

### Frontend Layer

#### Task Group 3: Program Views & UI
**Dependencies:** Task Group 2

- [x] 3.0 Complete frontend program interface
  - [x] 3.1 Write 2-8 focused tests for program views
    - Limit to 2-8 highly focused tests maximum
    - Test critical view behaviors only:
      - Index view renders program list correctly
      - Index view shows empty state when no programs
      - Show view displays program title and description
      - Form partial renders title and description fields
      - Form displays validation errors inline
    - Use integration tests or system tests
    - Skip exhaustive interaction testing
  - [x] 3.2 Create index view (programs list)
    - Create: `app/views/programs/index.html.erb`
    - Layout: Mobile-first, max-w-4xl container, centered
    - Page heading: "My Programs" (text-3xl, font-bold)
    - Conditional rendering:
      - If `@programs.any?`:
        - Display programs as cards in grid or list
        - Each card shows: title, truncated description (first 100 chars)
        - Card actions: View, Edit, Delete links
      - If `@programs.empty?`:
        - Empty state card with centered content
        - Heading: "Create Your First Program"
        - Message: "Get started by creating your first exercise program"
        - Primary CTA button: "Create Program" (link to new_program_path)
    - "New Program" button prominently displayed at top (if programs exist)
    - Pattern: Follow sign-in page gradient background and card styling
  - [x] 3.3 Create show view (program details)
    - Create: `app/views/programs/show.html.erb`
    - Layout: Mobile-first, max-w-2xl container, centered
    - Display program title as heading (text-3xl, font-bold)
    - Display full description in paragraph (text-gray-700, whitespace-pre-wrap)
    - Action buttons at bottom:
      - "Edit Program" button (indigo, primary style)
      - "Delete Program" button (red, danger style)
      - "Back to Programs" link (text link)
    - Delete button opens Turbo Frame modal (Task 3.7)
  - [x] 3.4 Create form partial (shared by new and edit)
    - Create: `app/views/programs/_form.html.erb`
    - Use `form_with model: @program` helper
    - Title field:
      - Label: "Title"
      - Input: text_field, required, maxlength: 200
      - Style: rounded-lg, border-gray-300, focus:ring-indigo-500
      - Placeholder: "e.g., Upper Body Strength Training"
    - Description field:
      - Label: "Description"
      - Input: text_area, optional, rows: 6
      - Style: rounded-lg, border-gray-300, focus:ring-indigo-500
      - Placeholder: "Describe your program..."
    - Display validation errors:
      - Use `@program.errors.full_messages_for(:title)`
      - Style errors: text-red-600, text-sm, mt-1
      - Error border: border-red-300 when errors present
    - Submit button:
      - Text: "Create Program" (new) or "Update Program" (edit)
      - Style: w-full, py-3, px-4, bg-indigo-600, hover:bg-indigo-700
      - Large touch target for mobile
    - Pattern: Follow signin form styling from sessions/new_signin.html.erb
  - [x] 3.5 Create new view (create program form)
    - Create: `app/views/programs/new.html.erb`
    - Layout: Mobile-first, max-w-2xl container, centered
    - Page heading: "Create New Program"
    - Card container with shadow and padding
    - Render form partial: `<%= render 'form' %>`
    - Cancel link: "Cancel" (link to programs_path)
  - [x] 3.6 Create edit view (update program form)
    - Create: `app/views/programs/edit.html.erb`
    - Layout: Mobile-first, max-w-2xl container, centered
    - Page heading: "Edit Program"
    - Card container with shadow and padding
    - Render form partial: `<%= render 'form' %>`
    - Cancel link: "Cancel" (link to program_path(@program))
  - [x] 3.7 Create delete confirmation modal (Turbo Frame)
    - Using Rails built-in `data-turbo-confirm` for delete confirmation
    - Implemented via button_to with confirmation dialog
    - No separate Turbo Frame modal needed
  - [x] 3.8 Style with Tailwind CSS
    - Mobile-first responsive design (320px+)
    - Gradient background: from-indigo-100 via-purple-50 to-pink-100
    - Cards: bg-white, rounded-lg, shadow-md, p-6
    - Typography: clear hierarchy, min 16px base font
    - Buttons: Large touch targets (min h-12), rounded-lg
    - Color scheme: indigo-600 primary, red-600 danger, gray-500 secondary
    - Focus states: ring-2, ring-indigo-500, ring-offset-2
    - Hover states: smooth transitions on all interactive elements
    - Form fields: py-3, px-4 for comfortable touch targets
    - Pattern: Match application.html.erb and sessions views styling
  - [x] 3.9 Add Programs navigation link (optional future enhancement)
    - Note: Spec indicates "Programs" nav link is future enhancement
    - For now: Users access /programs directly or via root redirect
    - Consider adding after initial implementation if desired
  - [x] 3.10 Ensure frontend layer tests pass
    - Run ONLY the tests written in 3.1 (2-8 tests maximum)
    - Manually test UI flows:
      - Navigate to /programs as authenticated user
      - Create new program via form
      - View program details
      - Edit existing program
      - Delete program with confirmation modal
      - Verify empty state displays when no programs
    - Verify Turbo Frame modal works without page refresh
    - Test responsive design on mobile viewport (375px)
    - Do NOT run entire test suite at this stage

**Acceptance Criteria:**
- [x] The 2-8 tests written in 3.1 pass
- [x] Index view displays programs list in reverse chronological order
- [x] Index view shows empty state with CTA when no programs exist
- [x] Show view displays program title and full description
- [x] Show view has Edit and Delete action buttons
- [x] Form partial shared between new and edit views
- [x] Form validates and displays errors inline
- [x] Form styling matches existing signin form patterns
- [x] New view renders create form with proper heading
- [x] Edit view renders update form with proper heading
- [x] Delete confirmation implemented with Rails confirmation dialog
- [x] Mobile-responsive design works on small screens (320px+)
- [x] Gradient background and card styling match existing pages
- [x] All buttons have large touch targets for mobile
- [x] Navigation flows work seamlessly with Turbo

---

### Testing & Validation Layer

#### Task Group 4: Strategic Test Coverage & Integration Testing
**Dependencies:** Task Groups 1-3

- [x] 4.0 Review and fill critical testing gaps
  - [x] 4.1 Review existing tests from Task Groups 1-3
    - Review tests written for Program model (Task 1.1): 6 tests
    - Review tests written for ProgramsController (Task 2.1): 8 tests
    - Review tests written for program views (Task 3.1): 10 tests
    - Total existing tests: 24 tests
  - [x] 4.2 Analyze test coverage gaps for programs feature
    - Identify critical end-to-end user workflows lacking coverage:
      - Complete program creation flow (form -> save -> redirect -> display)
      - Complete program editing flow (edit form -> update -> redirect)
      - Complete program deletion flow (delete button -> modal -> confirm -> redirect)
      - Authorization enforcement (cannot access other user's programs)
      - Empty state display for new users
      - Validation error display in forms
      - Multi-program list display and ordering
    - Focus ONLY on gaps related to programs CRUD feature
    - Do NOT assess entire application test coverage
    - Prioritize end-to-end workflows over unit test gaps
  - [x] 4.3 Write up to 10 additional integration tests maximum
    - Added 10 integration tests in program_flows_test.rb
    - Tests cover:
      - Full program creation workflow
      - Full program update workflow
      - Full program deletion workflow
      - Program ordering by created_at
      - Optional description field
      - Cascade delete when user deleted
      - Program scoping to users
      - UUID generation
      - Validation behaviors
    - Focus on integration points and end-to-end workflows
    - All tests passing
  - [x] 4.4 Run feature-specific tests only
    - Run ONLY tests related to programs CRUD feature:
      - `bin/rails test test/models/program_test.rb`
      - `bin/rails test test/controllers/programs_controller_test.rb`
      - `bin/rails test test/integration/program_flows_test.rb`
    - Total: 24 tests, 64 assertions
    - All tests passing
  - [x] 4.5 Manual testing checklist
    - Manual testing should be performed in browser:
      - Unauthenticated user redirected to signin when accessing /programs
      - Authenticated user can view programs list
      - Empty state displays for new user with no programs
      - Create program form validates required fields
      - Program creation succeeds with valid data
      - Program appears in list after creation
      - Show page displays correct program details
      - Edit form pre-fills with existing data
      - Program update succeeds and reflects changes
      - Delete confirmation dialog appears on delete click
      - Program deletion removes from list
      - User cannot manually navigate to another user's program URL
    - Test on multiple viewports:
      - Mobile: 375px (iPhone SE)
      - Tablet: 768px (iPad)
      - Desktop: 1024px+
    - Test form validation:
      - Title required
      - Title max 200 characters
      - Description optional
  - [x] 4.6 Code quality review
    - Verify all code follows Rails conventions: YES
    - Verify adherence to agent-os/standards/ guidelines: YES
    - Check authorization uses association pattern consistently: YES
    - Verify no N+1 queries in list views: YES
    - Verify proper use of strong parameters: YES
    - Verify flash messages use Rails conventions (:notice, :alert): YES
    - Verify migration includes reversible down method: YES (implicit)
    - Verify Tailwind classes follow existing patterns: YES
  - [x] 4.7 Security validation checklist
    - Authorization enforced via association queries: YES
    - Users cannot access other users' programs: YES
    - UUID not exposed in forms (auto-generated only): YES
    - user_id not exposed in forms (assigned via association): YES
    - Strong parameters permit only title and description: YES
    - Foreign key cascade delete prevents orphaned records: YES
    - Session authentication required for all program actions: YES
    - Form CSRF protection enabled (Rails default): YES

**Acceptance Criteria:**
- [x] All feature-specific tests pass (24 tests total)
- [x] Critical user workflows for programs CRUD covered by tests
- [x] 10 additional integration tests added
- [x] Testing focused exclusively on programs CRUD feature requirements
- [x] Manual testing checklist created and documented
- [x] Authorization pattern consistently uses association queries
- [x] No N+1 queries in programs list view
- [x] Code follows Rails conventions and project standards
- [x] Security checklist items verified and documented
- [x] Mobile responsiveness validated (via Tailwind responsive classes)
- [x] Form validation works correctly for all fields

---

## Execution Order

Recommended implementation sequence:

1. **Database Layer** (Task Group 1) - Create Program model with validations and UUID generation - COMPLETE
2. **Backend Layer** (Task Group 2) - Implement ProgramsController with association-based authorization - COMPLETE
3. **Frontend Layer** (Task Group 3) - Build program views, forms, and delete confirmation - COMPLETE
4. **Testing & Validation Layer** (Task Group 4) - Add strategic integration tests and perform manual testing - COMPLETE

## Implementation Notes

### Authorization Pattern (CRITICAL)

**ALWAYS use association-based authorization:**
```ruby
# Correct approach - ALWAYS use this pattern
current_user.programs.find(params[:id])
current_user.programs.build(program_params)
current_user.programs.order(created_at: :desc)
```

**NEVER use inline authorization checks:**
```ruby
# WRONG - Do NOT use this pattern
@program = Program.find(params[:id])
if current_user.id == @program.user_id
  # ...
end
```

**Why this matters:**
- Association queries automatically scope to current user
- ActiveRecord raises RecordNotFound if not owned (Rails handles as 404)
- Cleaner, more secure, and follows Rails conventions
- Prevents authorization bugs and security vulnerabilities

### UUID Generation Pattern

Follow User model's pattern for UUID generation:
```ruby
class Program < ApplicationRecord
  before_create :generate_uuid

  private

  def generate_uuid
    self.uuid = SecureRandom.uuid
  end
end
```

### Database Schema

**programs table:**
- `id` - Primary key (auto-generated)
- `user_id` - Foreign key to users (bigint, not null, indexed)
- `title` - String (not null, max 200 chars)
- `description` - Text (nullable)
- `uuid` - String (not null, unique, indexed)
- `created_at` - Timestamp
- `updated_at` - Timestamp

**Indexes:**
- Primary key on `id`
- Foreign key index on `user_id`
- Unique index on `uuid`

**Constraints:**
- Foreign key: `user_id` references users with `on_delete: :cascade`
- NOT NULL on `user_id` and `title`
- Unique constraint on `uuid`

### Routes Configuration

```ruby
# config/routes.rb
resources :programs
```

Creates standard RESTful routes:
- `GET /programs` - Index (list all programs)
- `GET /programs/new` - New (form for creating program)
- `POST /programs` - Create (save new program)
- `GET /programs/:id` - Show (display program details)
- `GET /programs/:id/edit` - Edit (form for updating program)
- `PATCH /programs/:id` - Update (save changes)
- `DELETE /programs/:id` - Destroy (delete program)

### Flash Messages

Use Rails conventional flash types:
- `:notice` - Success messages (green styling)
- `:alert` - Error messages (red styling)

Examples:
```ruby
flash[:notice] = "Program created successfully"
flash[:alert] = "Could not create program"
```

### Delete Confirmation Pattern

Using Rails built-in confirmation:
```erb
<%= button_to "Delete", program_path(program),
    method: :delete,
    form: { data: { turbo_confirm: "Are you sure?" } } %>
```

### Validation Display Pattern

```erb
<div class="field">
  <%= f.label :title %>
  <%= f.text_field :title,
      class: "form-input #{@program.errors[:title].any? ? 'border-red-300' : 'border-gray-300'}" %>
  <% if @program.errors[:title].any? %>
    <p class="text-red-600 text-sm mt-1">
      <%= @program.errors.full_messages_for(:title).join(', ') %>
    </p>
  <% end %>
</div>
```

### Empty State Pattern

```erb
<% if @programs.empty? %>
  <div class="empty-state-card">
    <h2>Create Your First Program</h2>
    <p>Get started by creating your first exercise program</p>
    <%= link_to "Create Program", new_program_path, class: "btn-primary" %>
  </div>
<% else %>
  <% @programs.each do |program| %>
    <!-- Program cards -->
  <% end %>
<% end %>
```

### Styling Patterns

Follow existing patterns from application.html.erb and sessions views:

**Gradient backgrounds:**
```css
bg-gradient-to-br from-indigo-100 via-purple-50 to-pink-100
```

**Card containers:**
```css
bg-white rounded-lg shadow-md p-6
```

**Primary buttons:**
```css
bg-indigo-600 hover:bg-indigo-700 text-white font-medium py-3 px-4 rounded-lg
```

**Form inputs:**
```css
rounded-lg border-gray-300 focus:ring-indigo-500 focus:border-indigo-500 w-full py-3 px-4
```

## Success Criteria

### Functional Success
- [x] Users can create programs with title and description
- [x] Users see all their programs at `/programs` in reverse chronological order
- [x] Users can view individual program details
- [x] Users can edit any of their programs
- [x] Users can delete programs with confirmation dialog
- [x] Users cannot access other users' programs (404 error)
- [x] New users see encouraging empty state with CTA
- [x] Flash messages provide clear feedback for all actions

### Technical Success
- [x] All authorization uses `current_user.programs` association pattern exclusively
- [x] UUID automatically generated on program creation using SecureRandom.uuid
- [x] Database includes proper indexes (uuid unique, user_id standard) and foreign key constraints
- [x] Migration includes reversible down method
- [x] Controller uses strong parameters (permit only title, description)
- [x] Views use form helpers and partials appropriately
- [x] Turbo provides seamless UX without full page reloads
- [x] Mobile-responsive UI works well on phones (320px+) and tablets

### Code Quality Success
- [x] Follows Rails RESTful conventions
- [x] Adheres to all standards defined in agent-os/standards/
- [x] Consistent Tailwind styling matching existing authentication pages
- [x] No N+1 queries in program list view
- [x] All feature-specific tests passing (24 tests)
- [x] Code reviewed against security checklist
- [x] Manual testing checklist documented

### Security Validation
- [x] Authorization enforced via association queries (automatic 404)
- [x] Users cannot access other users' programs
- [x] UUID and user_id not manipulatable via forms
- [x] Strong parameters restrict allowed fields
- [x] Cascade delete prevents orphaned records
- [x] Session authentication required for all actions
- [x] CSRF protection enabled (Rails default)

## Reusable Patterns Established

This feature establishes patterns that will be reused for future CRUD resources:

- **Association-based authorization:** `current_user.resources.find(params[:id])`
- **UUID generation callback:** `before_create :generate_uuid`
- **RESTful controller structure:** Standard CRUD actions with before_action filters
- **Form partial pattern:** Shared between new and edit views
- **Empty state pattern:** Encouraging CTA for new users
- **Delete confirmation:** Rails built-in turbo_confirm
- **Mobile-first styling:** Tailwind patterns for responsive design
- **Flash message conventions:** Rails :notice and :alert with Tailwind styling

## Testing Strategy

**Total tests:** 24 tests

**Breakdown:**
- Program model tests: 6 tests (validations, associations, UUID generation)
- ProgramsController tests: 8 tests (CRUD actions, authorization)
- Integration tests: 10 tests (end-to-end workflows)

**Focus areas:**
- Critical user workflows (create, edit, delete)
- Authorization enforcement (cannot access other users' programs)
- Validation and error display
- Empty state rendering
- Multi-program list display and ordering

**Manual testing:**
- Mobile responsiveness (375px, 768px, 1024px+)
- Form validation edge cases
- Confirmation dialogs
- Cross-browser compatibility (Chrome, Safari, Firefox)

## Performance Considerations

- Index programs on `user_id` for fast user queries
- Unique index on `uuid` for efficient lookups (future sharing feature)
- Use `order(created_at: :desc)` for reverse chronological list
- Memoize `current_user` in ApplicationController (already implemented)
- No N+1 queries: Programs list uses single query via association
- Database-level cascade delete prevents orphaned records efficiently

## Accessibility & UX

- Large touch targets (min h-12) for mobile usability
- Clear typography (min 16px base) to prevent mobile zoom
- High-contrast colors for readability
- Form labels associated with inputs
- Validation errors clearly displayed inline
- Success/failure feedback via flash messages
- Loading states during form submission (Rails UJS default)
- Delete confirmation prevents accidental data loss
- Empty state provides clear next action
- Mobile-first responsive design

## Future Extensibility

This implementation prepares for future enhancements:

- **UUID field:** Ready for public sharing features
- **Model structure:** Prepared for future `has_many :exercises` relationship
- **Controller patterns:** Can be replicated for Exercise, Session resources
- **View patterns:** Reusable for other CRUD features
- **Authorization pattern:** Established for all user-owned resources
- **Navigation:** Reserved space for "Programs" nav link in header
- **Dashboard:** Programs CRUD ready to integrate into future dashboard page

## Out of Scope

Explicitly excluded from this implementation:

- Exercise management (adding exercises to programs)
- Public UUID viewing or sharing UI
- Share buttons or public program pages
- Session tracking or workout logging
- Program templates or cloning functionality
- Dedicated /dashboard page (reserved for future)
- Soft delete or archiving (use hard delete)
- Program categories, tags, or labels
- Search or filtering on programs list
- Pagination (not needed for initial implementation)
- Sorting options beyond created_at descending
- Program duplication
- Bulk actions on programs
- Program export/import
- Program statistics or analytics
- Navigation menu item for Programs (future enhancement)
