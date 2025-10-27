# Spec Requirements: Program Duplication / Save to My Programs

## Initial Description

Add "Save to My Programs" button on program show page when viewing someone else's program. When a user starts a workout from a program they don't own, automatically duplicate the program first, then create workout from their copy. Duplication copies all program attributes (title, description) and all exercises (name, repeat_count, description, video_url, position). The duplicated program belongs to the current user.

This enables:
- Users to share programs and others can save them
- Starting workouts from shared programs without needing to manually copy
- Users can then modify their saved copies independently

## Requirements Discussion

### First Round Questions

**Q1: Button Placement - Should the "Save to My Programs" button be a prominent primary-style button (like "Start Session") or a secondary/subtle link?**

**Answer:** Prominent primary button style

---

**Q2: Duplicate Prevention - Should we prevent users from duplicating the same program multiple times (checking if they already have a copy), or allow unlimited duplicates?**

**Answer:** Don't prevent duplicates - allow multiple copies

---

**Q3: Program Title - When duplicating, should we prefix the title with "Copy of..." or keep the original title as-is?**

**Answer:** Keep the original title as-is (no "Copy of..." prefix)

---

**Q4: Flash Messages - After clicking "Save to My Programs", should we show a success message and redirect to their new copy, or stay on the original program view?**

**Answer:** Show success message and redirect to their new copy

---

**Q5: Silent Auto-Duplication - When starting a workout from someone else's program, should we show a flash message like "Program saved to your library" or handle it silently in the background?**

**Answer:** Duplicate silently in background when starting workout from someone else's program

---

**Q6: Duplicate Click Protection - Should we disable the "Save" button after first click to prevent accidental double-submissions, or is Rails default form handling sufficient?**

**Answer:** Not necessary (Rails handles form resubmission well)

---

**Q7: Program Relationship Tracking - Should we store a reference to the original program (like original_program_uuid) for potential future features (analytics, attribution, updates), or keep duplicates completely independent?**

**Answer:** Don't store original program UUID - completely independent copies

---

**Q8: Authentication Requirement - For anonymous users viewing programs, should the "Save" button be hidden, or should it redirect to login/signup with a return_to parameter?**

**Answer:** Hide "Save" button for anonymous users for now. Future enhancement: redirect back to original page after login/signup (as long as domain matches)

---

### Existing Code to Reference

No similar existing features identified for reference.

User did not provide paths to similar duplication, deep-copy, or form handling patterns in the existing codebase.

---

### Follow-up Questions

No follow-up questions were needed. The user provided comprehensive answers covering all aspects of the feature.

---

## Visual Assets

### Files Provided:

No visual assets provided.

### Visual Insights:

No visual assets to analyze.

---

## Requirements Summary

### Functional Requirements

#### 1. "Save to My Programs" Button (Manual Duplication)

**Location:** Program show page (`/programs/:uuid`)

**Visibility Rules:**
- SHOW button: When authenticated user is viewing someone else's program
- HIDE button: When anonymous user viewing any program
- HIDE button: When authenticated user viewing their own program

**Button Styling:**
- Prominent primary button style (matching "Start Session" button prominence)
- Mobile-first design with 44x44px minimum touch target
- Tailwind CSS primary button classes

**Button Behavior:**
- POST to new controller action for program duplication
- No duplicate-click protection needed (Rails handles this)
- Standard Turbo form submission

**Success Flow:**
- Create deep copy of program (see Deep Copy Logic below)
- Show success flash message: "Program saved to your library" (or similar)
- Redirect to the NEW duplicated program's show page (`/programs/:new_uuid`)
- User is now viewing THEIR copy, can edit or start sessions from it

#### 2. Automatic Silent Duplication (Starting Workout from Non-Owned Program)

**Trigger:** User clicks "Start Session" on a program they don't own

**Behavior:**
- Silently duplicate the program in the background (no flash message)
- Create the workout/session from the NEW duplicated copy
- User now owns a copy and is tracking session against their own program
- No visible indication to user that duplication occurred
- From user's perspective: they just started a session like normal

**Edge Case Handling:**
- If user already duplicated this program before, still create another duplicate (no deduplication)
- Session always references user's owned program copy

#### 3. Deep Copy Logic

**Program Attributes Copied:**
- `title` (keep exact original title, no "Copy of..." prefix)
- `description`
- All other program fields except:
  - `id` (new auto-generated ID)
  - `uuid` (new auto-generated UUID)
  - `user_id` (set to current_user.id)
  - `created_at` / `updated_at` (new timestamps)

**Exercise Deep Copy:**
- Duplicate ALL exercises belonging to the original program
- For each exercise, copy:
  - `name`
  - `repeat_count`
  - `description` (markdown content)
  - `video_url`
  - `position` (maintain original ordering)
- Exercise IDs are new (auto-generated)
- Exercises belong to the NEW program copy

**Data Independence:**
- Do NOT store `original_program_uuid` or any reference to source program
- Duplicated program and exercises are completely independent
- User can modify, delete, or update their copy without affecting original
- Original program owner has no visibility into duplicates

#### 4. Controller Actions

**New Action Required: `ProgramsController#duplicate`**

**Route:**
```ruby
POST /programs/:uuid/duplicate
```

**Responsibilities:**
- Verify user is authenticated (redirect to login if not)
- Find source program by UUID
- Verify user doesn't already own this program (if they do, return error or redirect)
- Perform deep copy (program + all exercises)
- Set flash success message
- Redirect to new program show page

**Integration Point: Modify `SessionsController#create` (or equivalent)**

**Before Creating Session:**
- Check if `current_user` owns the program
- If NOT owned: silently duplicate program first
- Create session referencing the NEW duplicated program
- No flash message for silent duplication

#### 5. Flash Messages

**Manual Save Success:**
- Message: "Program saved to your library" (or similar user-friendly message)
- Type: `notice` (success/info style)
- Displayed on redirected program show page

**Automatic Duplication (Silent):**
- No flash message
- User unaware that duplication occurred

**Error Cases:**
- If duplication fails: "Unable to save program. Please try again."
- If not authenticated: redirect to login (future: with return_to parameter)

### Reusability Opportunities

No existing similar features were identified by the user.

**Potential Code Patterns to Investigate During Implementation:**
- ActiveRecord deep copy/duplication patterns
- Program and Exercise model associations (has_many with dependent: :destroy)
- Turbo form submission patterns
- Flash message display patterns
- Session creation logic (for integration point)
- Authentication checks and redirects

### Scope Boundaries

**In Scope:**
- "Save to My Programs" button on program show page
- Manual program duplication via button click
- Automatic silent duplication when starting session from non-owned program
- Deep copy of program and all exercises
- Flash messages and redirect after manual save
- Authentication checks (hide button for anonymous)
- Controller action for duplication
- Integration with session start flow

**Out of Scope (Current Implementation):**
- Return-to redirect after login/signup (future enhancement)
- Duplicate prevention (allow unlimited copies)
- Original program attribution tracking
- Analytics or insights on program duplications
- "Copy of..." title prefixing
- Duplicate click protection mechanisms
- Showing user which programs they've already duplicated
- Program version tracking or updates from original

**Future Enhancements Noted:**
- Return-to redirect: After authentication, redirect back to original program page (verify domain matches for security)
- This would improve UX for anonymous users who want to save a program - they login, then land back on the program to click "Save"

### Technical Considerations

**Rails Version:**
- Rails 8.1 with Turbo, Stimulus, Tailwind CSS

**Database:**
- SQLite with ActiveRecord
- Program has_many :exercises relationship
- UUID-based program identification (already implemented)

**Authentication:**
- WebAuthn passwordless authentication
- `current_user` helper available
- Authentication checks required for button visibility and duplication action

**Mobile-First Design:**
- 44x44px minimum touch targets
- Primary button styling for prominence
- Tailwind CSS classes for responsive design

**Integration Points:**
- Program show page view (add button)
- Session creation flow (add silent duplication check)
- Programs controller (add duplicate action)

**Deep Copy Implementation:**
- ActiveRecord associations and callbacks
- Transaction for atomic program + exercises copy
- UUID generation for new program
- Preserve exercise order (position attribute)

**Error Handling:**
- Transaction rollback if exercise copy fails
- User-friendly error messages
- Graceful handling of missing programs (404)

**Turbo Compatibility:**
- Standard form submission with Turbo
- Flash messages display properly with Turbo
- Redirects work with Turbo navigation
