# Spec Requirements: Exercise Management within Programs

## Initial Description
Create the Exercise model with belongs_to relationship to Program. Users can add, edit, reorder, and remove exercises within a program. Each exercise includes name, repeat count (e.g., "3x"), video URL, and formatted description field.

## Requirements Discussion

### First Round Questions

**Q1: Where should users manage exercises - should they be managed inline on the program show page, or would you prefer a separate exercises management interface?**
**Answer:** Manage exercises inline on the program show page

**Q2: For reordering exercises, I'm assuming drag-and-drop reordering would be the primary method, with up/down arrow buttons as fallback for mobile. Is that correct?**
**Answer:** Drag-and-drop with up/down arrows visible on mobile viewports

**Q3: For the repeat_count field (e.g., "3x"), should this be a plain text field where users can enter any format (like "3x" or "3 sets" or "10 reps"), or should it be structured (separate numeric and unit fields), or numeric-only?**
**Answer:** Numeric number only - must present numeric keyboard on mobile browsers

**Q4: For video_url validation, should we validate that it's a properly formatted URL from specific providers (YouTube, Vimeo), or just ensure it's a valid URL format, or implement oembed preview validation?**
**Answer:** Just check it's a valid URL. Note: Eventually will use oembed for video previews (future enhancement)

**Q5: For the description field formatting, I'm thinking we should use ActionText for rich text editing (Rails built-in WYSIWYG editor). Should we use ActionText, a simpler markdown approach, or plain text with manual formatting?**
**Answer:** Use ActionText for rich text editing

**Q6: For routing, I assume exercises should be nested under programs (e.g., /programs/:program_uuid/exercises). Is that the preferred pattern?**
**Answer:** Yes, use `/programs/:program_uuid/exercises`

**Q7: For the display and editing pattern, should we show exercises in a list with separate "edit" links that navigate to edit pages, or use inline editing where clicking an exercise opens an inline edit form on the same page?**
**Answer:** Inline editing (edit/delete icons next to each exercise)

**Q8: Are there any features we should explicitly exclude from this spec to keep scope focused? For example: exercise templates/library, copying exercises between programs, bulk operations, exercise search/filtering?**
**Answer:** Exclude exercise templates, copying exercises between programs, exercise search/filtering

### Existing Code to Reference

**Similar Features Identified:**
No similar existing features identified for reference.

### Follow-up Questions
No follow-up questions were needed.

## Visual Assets

### Files Provided:
No visual assets provided.

### Visual Insights:
N/A - No visual assets to analyze.

## Requirements Summary

### Functional Requirements

**Exercise Model:**
- Belongs to Program (has_many :exercises relationship)
- Fields required:
  - `name` (string, required)
  - `repeat_count` (integer, required) - numeric value only, no text
  - `video_url` (string, optional) - validated as valid URL format
  - `description` (ActionText rich_text field, optional)
  - `position` (integer, required) - for ordering within program

**Exercise CRUD Operations:**
- Create: Inline form on program show page to add new exercise
- Read: Display all exercises in ordered list on program show page
- Update: Inline editing triggered by edit icon next to each exercise
- Delete: Delete icon next to each exercise with confirmation

**Reordering Functionality:**
- Drag-and-drop reordering for desktop/tablet viewports
- Up/down arrow buttons visible and functional on mobile viewports
- Persist new order via position field updates
- Immediate visual feedback during reordering

**Inline Management Interface:**
- All exercise management happens on program show page
- No separate exercises index or dedicated exercise pages
- Edit/delete icons positioned next to each exercise in list
- Forms appear inline when adding or editing exercises
- Cancel button to close inline forms without saving

**Mobile Optimization:**
- Repeat count field must trigger numeric keyboard on mobile devices (inputmode="numeric")
- Touch-friendly drag handles and reorder buttons (44x44px minimum)
- Large, tappable edit/delete icons
- Inline forms optimized for mobile viewports

**Authorization:**
- Users can only manage exercises within their own programs
- Authorization check required before any exercise CRUD operation
- Exercise operations inherit program ownership verification

**Nested Routing:**
- Routes nested under programs: `/programs/:program_uuid/exercises`
- Use program UUID for routing (not database ID)
- Exercise routes:
  - POST `/programs/:program_uuid/exercises` (create)
  - PATCH `/programs/:program_uuid/exercises/:id` (update)
  - DELETE `/programs/:program_uuid/exercises/:id` (destroy)
  - PATCH `/programs/:program_uuid/exercises/:id/move` (reorder)

**ActionText Integration:**
- Description field uses ActionText rich_text association
- Requires Active Storage setup for ActionText attachments
- Rich text editor embedded inline in exercise forms
- Support for basic formatting: bold, italic, lists, links
- Mobile-friendly rich text editing experience

**URL Validation:**
- Video URL validated as properly formatted URL
- Accept any valid URL (not restricted to specific providers)
- Optional field - can be blank
- Future enhancement noted: oembed preview validation

### Reusability Opportunities
No existing features identified to reuse or reference. This is a net-new feature building on the completed Program CRUD foundation.

### Scope Boundaries

**In Scope:**
- Exercise model with belongs_to Program relationship
- Full CRUD operations for exercises (inline on program show page)
- Drag-and-drop reordering with mobile-friendly up/down arrows
- Numeric-only repeat count field with mobile numeric keyboard
- ActionText rich text editing for descriptions
- Video URL validation (valid URL format only)
- Nested routing under programs using UUID
- Inline editing interface with edit/delete icons
- Authorization ensuring users manage only their own program exercises
- Mobile-first responsive design for all exercise management UI

**Out of Scope:**
- Exercise templates or exercise library
- Copying exercises between programs
- Bulk operations on exercises
- Exercise search or filtering functionality
- Oembed video preview validation (future enhancement)
- Video embedding/display on program show page (handled in future roadmap items)
- Exercise completion tracking (separate roadmap item: Session Start & Exercise Progression)

### Technical Considerations

**Database Schema:**
- Exercise table with foreign key to programs
- Position field (integer) for ordering
- Indexes on program_id and position for query performance
- NOT NULL constraints on name, repeat_count, position, program_id
- URL format validation at database level for video_url

**Rails 8 & Turbo Integration:**
- Turbo Frames for inline form rendering without page reload
- Turbo Streams for live updates after create/update/delete
- Stimulus controller for drag-and-drop reordering logic
- Stimulus controller for mobile up/down arrow reordering

**ActionText Setup:**
- Requires Active Storage for rich text attachments
- ActionText rich_text association for Exercise description
- Mobile-optimized Trix editor (ActionText default)
- Storage configuration for ActionText attachments (SQLite default)

**Mobile Input Optimization:**
- `inputmode="numeric"` attribute on repeat_count field
- `pattern="[0-9]*"` for iOS numeric keyboard trigger
- Large touch targets (44x44px minimum) for all interactive elements
- Mobile-specific reorder controls (up/down arrows)

**Routing Pattern:**
- Shallow nested routes under programs
- Program UUID resolution in controller (find by uuid, not id)
- Exercise operations scoped to current program context
- RESTful routes for exercises with custom move action

**Authorization:**
- Verify current user owns program before exercise operations
- Use before_action filter to load and authorize program
- Scope exercise queries through authorized program association
- Return 404 or redirect if program not owned by current user

**Tailwind CSS Styling:**
- Mobile-first responsive classes for all exercise UI
- Large touch targets using Tailwind spacing utilities
- Clear visual hierarchy for exercise list and forms
- Consistent with existing program UI patterns
- Drag handle and reorder button styling
