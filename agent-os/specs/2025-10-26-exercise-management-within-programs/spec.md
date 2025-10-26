# Specification: Exercise Management within Programs

## Goal
Enable users to add, edit, reorder, and delete exercises inline on the program show page, with mobile-optimized controls and rich text editing for exercise descriptions.

## User Stories
- As a user, I want to add exercises to my program with name, repeat count, video URL, and rich text description so that I can build a complete workout program
- As a user, I want to edit or delete exercises directly on the program page so that I can manage my program efficiently without navigating away
- As a user, I want to reorder exercises via drag-and-drop on desktop or up/down arrows on mobile so that I can organize my workout sequence
- As a mobile user, I want a numeric keyboard for repeat count and touch-friendly controls so that exercise management feels natural on my device

## Core Requirements
- Inline CRUD operations for exercises on program show page (no separate pages)
- Drag-and-drop reordering for desktop with visual feedback
- Mobile up/down arrow buttons for reordering on small viewports
- Numeric-only repeat count field triggering mobile numeric keyboard
- ActionText rich text editor for exercise descriptions
- Video URL field with basic URL format validation
- Edit/delete icons next to each exercise in the list
- Authorization ensuring users only manage exercises in their own programs

## Reusable Components

### Existing Code to Leverage
- **Program Model & Controller**: Authorization pattern using `current_user.programs.find_by!(uuid: params[:id])` from `/Users/jamie/code/fitorforget/app/controllers/programs_controller.rb`
- **UUID Routing Pattern**: Using `to_param` override and UUID-based routing from `/Users/jamie/code/fitorforget/app/models/program.rb`
- **Form Error Handling**: Error display patterns with Tailwind styling from `/Users/jamie/code/fitorforget/app/views/programs/_form.html.erb`
- **Turbo Frame Pattern**: Inline editing flows from session authentication views at `/Users/jamie/code/fitorforget/app/views/sessions/`
- **Stimulus Controller Pattern**: JavaScript controller structure from `/Users/jamie/code/fitorforget/app/javascript/controllers/webauthn_controller.js`
- **Model Validation Pattern**: Presence, length, and format validations from User and Program models
- **Database Migration Pattern**: Foreign keys with cascade delete, NOT NULL constraints, and indexes from existing schema

### New Components Required
- **Exercise Model**: New ActiveRecord model with belongs_to Program relationship
- **ExercisesController**: Nested controller for CRUD operations scoped to program
- **Drag-and-Drop Stimulus Controller**: New controller for desktop reordering functionality
- **Reorder Action**: Custom controller action for position updates
- **ActionText Integration**: Install and configure ActionText for rich text descriptions
- **Exercise Partials**: View partials for exercise list items and inline forms

## Technical Approach

### Database Schema
- Create exercises table with foreign key to programs
- Fields: `name` (string, NOT NULL), `repeat_count` (integer, NOT NULL), `video_url` (string, nullable), `position` (integer, NOT NULL), `program_id` (integer, NOT NULL)
- ActionText `rich_text_description` association (handled by ActionText migration)
- Indexes on `program_id` and `position` for query performance
- Foreign key constraint with cascade delete matching programs table pattern
- URL format validation at database level for `video_url` when present

### Routing
- Nest exercises under programs: `/programs/:program_uuid/exercises`
- Use shallow nesting for exercise routes
- Custom `move` action for reordering: `PATCH /programs/:program_uuid/exercises/:id/move`
- Standard RESTful actions: create, update, destroy
- Program UUID parameter resolved in controller using `find_by!(uuid:)`

### Controller Authorization
- Use `before_action` to load program via UUID and verify ownership
- Scope all exercise queries through `@program.exercises` association
- Follow ProgramsController pattern for authorization checks
- Return appropriate errors if program not owned by current user

### Inline Editing with Turbo Frames
- Wrap exercise list in Turbo Frame for seamless updates
- Inline add form at top/bottom of exercise list
- Edit icons trigger inline edit form replacing list item
- Cancel button reverts to display mode without page reload
- Turbo Stream responses for create/update/delete operations

### Mobile Optimization
- `inputmode="numeric"` and `pattern="[0-9]*"` on repeat_count field
- Minimum 44x44px touch targets for all interactive elements
- Up/down arrow buttons visible only on mobile breakpoints (Tailwind responsive classes)
- Drag handles visible on desktop/tablet, hidden on mobile
- Mobile-optimized Trix editor (ActionText default) for descriptions

### ActionText Setup
- Install ActionText with `rails action_text:install`
- Configure Active Storage for rich text attachments
- Add `has_rich_text :description` to Exercise model
- Include Trix editor in exercise forms
- Mobile-friendly editor configuration

### Drag-and-Drop Implementation
- Stimulus controller using HTML5 Drag and Drop API
- Visual feedback during drag (opacity, placeholder)
- Update position field via AJAX to move endpoint
- Optimistic UI updates with server confirmation
- Fallback error handling if reorder fails

### Validation
- Server-side validations for all fields (name presence, repeat_count numericality)
- URL format validation for video_url (Rails URI validator)
- Client-side HTML5 validation for immediate feedback
- Field-specific error messages following Program form pattern
- Validate position uniqueness within program scope

## Out of Scope
- Exercise templates or exercise library
- Copying exercises between programs
- Bulk operations on multiple exercises
- Exercise search or filtering functionality
- Oembed video preview validation (noted as future enhancement)
- Video embedding/display on program show page
- Exercise completion tracking (separate roadmap item)
- Exercise analytics or history

## Success Criteria
- Users can complete full exercise CRUD lifecycle inline on program show page without navigation
- Drag-and-drop reordering works smoothly on desktop browsers with visual feedback
- Mobile users can reorder exercises using up/down arrows with numeric keyboard for repeat count
- ActionText editor enables rich formatting for exercise descriptions on all devices
- Authorization prevents users from accessing or modifying exercises in programs they don't own
- All operations provide clear feedback (success messages, error messages, loading states)
- Performance remains fast with 50+ exercises in a single program
