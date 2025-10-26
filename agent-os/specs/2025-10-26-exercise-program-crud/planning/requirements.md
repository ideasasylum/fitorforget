# Spec Requirements: Exercise Program CRUD

## Initial Description

Build the core Program model and controller with full CRUD operations. Users can create, edit, view, and delete exercise programs. Each program includes title, description, and UUID generation for sharing.

**Context from Roadmap:**
- This is the second item in the roadmap, building on top of the completed WebAuthn authentication system
- Users are already authenticated via WebAuthn (roadmap item 1 - complete)
- Programs will have a belongs_to :user relationship
- Each program needs: title, description, UUID for sharing
- Full CRUD operations required: Create, Read, Update, Delete

**Existing Stack:**
- Rails 8 application
- Using Tailwind CSS for styling
- Turbo Frames for seamless navigation
- Stimulus for JavaScript interactions
- SQLite database
- Mobile-first responsive design
- WebAuthn authentication already implemented

## Requirements Discussion

### First Round Questions

**Q1: UUID Generation Strategy** - I assume UUIDs should be auto-generated in a `before_create` callback on the Program model. Is that correct, or would you prefer manual generation or a different approach?

**Answer:** Auto-generate in `before_create` callback - approved

**Q2: Program List/Dashboard Location** - I'm thinking the main programs list should live at `/programs` (RESTful route). Should we also create a dedicated `/dashboard` that shows programs along with other summary information, or keep it simple with just `/programs` for now?

**Answer:** `/programs` is good. Reserve `/dashboard` for a future feature

**Q3: Program Ownership & Authorization** - For ensuring users can only access their own programs, should we use association-based queries (e.g., `current_user.programs.find(params[:id])`) or implement a policy-based authorization system like Pundit?

**Answer:** **Strong preference** - Always use association through the user (i.e., `current_user.programs.find(params[:id])`). Do NOT use inline checks like `current_user.id == @program.user_id`. Do NOT use Pundit.

**Q4: Delete Confirmation Pattern** - For program deletion, should we use a Turbo Frame modal confirmation dialog, a simple Rails confirmation dialog, or redirect to a dedicated confirmation page?

**Answer:** Turbo Frame deletion modal

**Q5: Form Styling & Layout** - Should program forms follow a specific layout pattern (single column, two-column, card-based), or should we follow whatever existing form patterns you have in the app?

**Answer:** Don't mind about it right now (follow existing patterns)

**Q6: Validation Rules** - What validation rules should apply to programs?
- Title: required, max length?
- Description: required or optional? Max length?
- UUID: auto-generated, should it be unique and indexed?
- User association: required?

**Answer:**
- Title: required, max 200 characters
- Description: optional, text field
- UUID: auto-generated, unique, indexed
- **Must belong_to :user** (required association)

**Q7: Flash Messages** - Should we use Rails conventional flash messages (`:notice`, `:alert`) with Tailwind-styled alerts, or implement a different notification system?

**Answer:** Perfect - use Rails conventions with Tailwind-styled alerts

**Q8: Empty States** - When a user has no programs yet, should we show an empty state with a call-to-action, or just an empty list?

**Answer:** CTA is good - show prominent "Create Your First Program" call-to-action

**Q9: Scope & Exclusions** - Based on the roadmap, this feature focuses on CRUD operations only. Should we exclude:
- Exercise management (adding exercises to programs)
- Public UUID viewing/sharing UI
- Program templates
- Session tracking or workout logging

**Answer:** Sounds good - exclude exercise management, public UUID viewing, sharing UI, session tracking

**Q10: Existing Code to Reference** - Are there existing features in your codebase with similar patterns we should reference? For example:
- Similar CRUD resources
- Existing Turbo Frame modals
- Form patterns or components to reuse
- Association-based authorization patterns

**Answer:** Not provided

**Q11: Visual Assets Request** - Do you have any design mockups, wireframes, or screenshots that could help guide the development?

**Answer:** None provided

### Existing Code to Reference

No similar existing features identified for reference.

### Follow-up Questions

None required - all requirements clearly defined.

## Visual Assets

### Files Provided:

No visual assets provided.

### Visual Insights:

Not applicable.

## Requirements Summary

### Functional Requirements

**Model: Program**
- Belongs to user (required association)
- Fields:
  - `title`: string, required, max 200 characters
  - `description`: text, optional
  - `uuid`: string, auto-generated via `before_create` callback, unique, indexed
  - `user_id`: integer, required (foreign key)
- UUID generation: Implemented in `before_create` callback using `SecureRandom.uuid`
- Database indexes: UUID must be indexed and unique

**Controller: ProgramsController**
- Full CRUD operations:
  - **Index**: List all programs belonging to current user
  - **Show**: Display individual program details
  - **New**: Render form for new program
  - **Create**: Save new program with validation
  - **Edit**: Render form for editing existing program
  - **Update**: Save changes to existing program
  - **Destroy**: Delete program with Turbo Frame modal confirmation

**Routes**
- Primary route: `/programs` (programs#index)
- RESTful resources for programs
- Note: `/dashboard` reserved for future feature

**Views & UI Components**
- **Index page** (`programs/index.html.erb`):
  - List of user's programs
  - Empty state with "Create Your First Program" CTA when no programs exist
  - Link/button to create new program

- **Show page** (`programs/show.html.erb`):
  - Display program title and description
  - Edit and delete action buttons

- **Form partial** (`programs/_form.html.erb`):
  - Title input field (required, max 200 chars)
  - Description textarea (optional)
  - Form validation with error messages
  - Follow existing form styling patterns in the app

- **New page** (`programs/new.html.erb`):
  - Render form partial for creating program

- **Edit page** (`programs/edit.html.erb`):
  - Render form partial for updating program

- **Delete confirmation modal** (Turbo Frame):
  - Modal dialog for delete confirmation
  - Implemented using Turbo Frames for seamless UX

**Flash Messages**
- Use Rails conventional flash types: `:notice`, `:alert`
- Style with Tailwind CSS for consistency
- Display messages for:
  - Successful program creation
  - Successful program update
  - Successful program deletion
  - Validation errors

**User Actions Enabled**
- Create new exercise programs with title and description
- View list of all their programs at `/programs`
- View individual program details
- Edit existing programs (title and description)
- Delete programs with confirmation modal
- Navigate seamlessly using Turbo Frames

**Data Management**
- Programs are scoped to authenticated users
- Each program has auto-generated UUID for future sharing features
- Programs persist in SQLite database
- Soft delete not required (hard delete via `destroy`)

### Authorization & Security

**CRITICAL AUTHORIZATION PATTERN:**

**DO use association-based authorization:**
```ruby
# Correct approach - ALWAYS use this pattern
current_user.programs.find(params[:id])
current_user.programs.build(program_params)
current_user.programs.where(...)
```

**DO NOT use inline authorization checks:**
```ruby
# WRONG - Do NOT use this pattern
@program = Program.find(params[:id])
if current_user.id == @program.user_id
  # ...
end
```

**DO NOT use Pundit or policy-based authorization:**
- No Pundit policies
- No authorization gems
- Rely solely on Active Record associations

**Implementation Details:**
- All controller actions must query through `current_user.programs`
- This ensures users can only access their own programs
- Active Record will automatically raise `ActiveRecord::RecordNotFound` if program doesn't belong to user
- Handle `ActiveRecord::RecordNotFound` with standard Rails 404 error handling

### Reusability Opportunities

No existing similar features identified. This will establish patterns for:
- Future CRUD resources in the application
- Association-based authorization approach
- Turbo Frame modal patterns
- Form styling and validation patterns

### Scope Boundaries

**In Scope:**
- Program model with CRUD operations
- User association and ownership
- UUID generation for programs
- Basic program list and detail views
- Create, edit, delete functionality
- Form validation and error handling
- Flash messages for user feedback
- Empty state with CTA
- Turbo Frame delete confirmation modal
- RESTful routes and controller actions
- Mobile-responsive UI using Tailwind CSS

**Out of Scope:**
- Exercise management (adding exercises to programs) - Future feature
- Public UUID viewing/sharing functionality - Future feature
- Sharing UI or public program pages - Future feature
- Session tracking or workout logging - Future feature
- Program templates or cloning - Future feature
- Dedicated dashboard page - Reserved for future feature
- Soft delete or archiving - Use hard delete
- Program categories or tags - Not included
- Program search or filtering - Not included
- Pagination - Not needed initially

### Technical Considerations

**Technology Stack:**
- Rails 8 framework
- SQLite database
- Tailwind CSS for styling
- Turbo Frames for seamless navigation and modals
- Stimulus for JavaScript interactions (if needed for modal)
- Mobile-first responsive design approach

**Integration Points:**
- Integrates with existing WebAuthn authentication system
- Uses existing user model and `current_user` helper
- Follows existing Tailwind styling patterns in the app
- Leverages Turbo Frames already in use

**Database Schema:**
- Migration to create `programs` table
- Foreign key constraint on `user_id`
- Unique index on `uuid` column
- Index on `user_id` for query performance

**Validation Strategy:**
- Model-level validations for title (presence, length)
- Model-level validation for user association (presence)
- UUID uniqueness validated at database level via unique index
- Display validation errors inline in forms

**Error Handling:**
- Use `current_user.programs.find(params[:id])` - raises RecordNotFound if not owned
- Let Rails handle 404 errors for unauthorized access attempts
- Display validation errors in forms with Tailwind styling
- Flash messages for success/failure feedback

**Convention Adherence:**
- Follow Rails RESTful conventions
- Standard controller action names (index, show, new, create, edit, update, destroy)
- Follow Rails naming conventions for models, controllers, views
- Use Rails form helpers and conventions
- Adhere to existing coding standards defined in agent-os/standards/

**Mobile Responsiveness:**
- All views must be mobile-first
- Forms should be easy to use on mobile devices
- Action buttons appropriately sized for touch
- Modal dialogs work well on small screens

**Performance Considerations:**
- Database indexes on `uuid` and `user_id` columns
- Use association queries to minimize N+1 queries
- Leverage Turbo Frames to avoid full page reloads

**Future Extensibility:**
- UUID field prepared for future sharing features
- Model structure ready for future has_many :exercises relationship
- Controller patterns can be replicated for other resources
- `/dashboard` route reserved for future comprehensive dashboard
