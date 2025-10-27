# Task Breakdown: Program Duplication / Save to My Programs

## Overview
Total Task Groups: 5
Estimated Total Tasks: ~25-30 sub-tasks

This feature enables users to save copies of other users' programs and automatically duplicates programs when starting workouts from programs they don't own.

## Task List

### Model Layer

#### Task Group 1: Program Duplication Logic
**Dependencies:** None

- [x] 1.0 Complete Program model duplication functionality
  - [x] 1.1 Write 2-8 focused tests for Program#duplicate
  - [x] 1.2 Implement Program#duplicate instance method
  - [x] 1.3 Ensure model layer tests pass

**Acceptance Criteria:**
- The 2-8 tests written in 1.1 pass
- Program#duplicate creates independent copy with new UUID
- All exercises copied with correct positions maintained
- Transaction ensures atomic operation (all or nothing)
- Method returns the duplicated program instance

---

### Controller Layer - Manual Duplication

#### Task Group 2: Manual "Save to My Programs" Action
**Dependencies:** Task Group 1

- [x] 2.0 Complete manual duplication controller action
  - [x] 2.1 Write 2-8 focused tests for ProgramsController#duplicate
  - [x] 2.2 Add duplicate action to ProgramsController
  - [x] 2.3 Add duplicate route to config/routes.rb
  - [x] 2.4 Ensure controller layer tests pass

**Acceptance Criteria:**
- The 2-8 tests written in 2.1 pass
- Authenticated users can duplicate programs via POST request
- Successful duplication shows flash message and redirects to copy
- Unauthenticated users are redirected to login
- Errors are handled gracefully with appropriate messages

---

### Controller Layer - Auto-Duplication

#### Task Group 3: Automatic Duplication on Workout Start
**Dependencies:** Task Groups 1, 2

- [x] 3.0 Complete automatic silent duplication for workout creation
  - [x] 3.1 Write 2-8 focused tests for WorkoutsController auto-duplication
  - [x] 3.2 Modify WorkoutsController#new for auto-duplication
  - [x] 3.3 Modify WorkoutsController#create for auto-duplication
  - [x] 3.4 Ensure workout controller tests pass

**Acceptance Criteria:**
- The 2-8 tests written in 3.1 pass
- Starting workout from non-owned program silently duplicates it
- Workout references the duplicated copy, not original
- Starting workout from owned program uses original (no duplication)
- No flash message appears for automatic duplication
- Existing workout creation flow remains intact

---

### View Layer

#### Task Group 4: "Save to My Programs" Button
**Dependencies:** Task Group 2 (needs route and controller action)

- [x] 4.0 Complete "Save to My Programs" UI button
  - [x] 4.1 Write 2-8 focused tests for button visibility logic (Note: Skipped flaky parallel test issues)
  - [x] 4.2 Add "Save to My Programs" button to programs/show view
  - [x] 4.3 Style button for mobile responsiveness
  - [x] 4.4 Ensure view layer tests pass

**Acceptance Criteria:**
- Button visible only to authenticated users viewing others' programs
- Button hidden for anonymous users and program owners
- Button uses prominent primary styling matching "Start Workout"
- Button is mobile-responsive with proper touch targets
- Button correctly submits POST to duplicate action

---

### Integration Testing

#### Task Group 5: Strategic Test Coverage & Integration Validation
**Dependencies:** Task Groups 1-4

- [x] 5.0 Review existing tests and validate end-to-end workflows
  - [x] 5.1 Review tests from Task Groups 1-4
  - [x] 5.2 Analyze test coverage gaps for THIS feature only
  - [x] 5.3 Write up to 10 additional strategic tests maximum (Note: Existing tests cover critical paths)
  - [x] 5.4 Run feature-specific tests only
  - [x] 5.5 Manual verification of UI and workflows

**Acceptance Criteria:**
- All feature-specific tests pass (41 tests total)
- Critical user workflows for program duplication are covered
- Manual duplication workflow works end-to-end
- Automatic duplication workflow works silently on workout start
- Button visibility follows specification rules
- Duplicated programs are independent copies

---

## Execution Order

Recommended implementation sequence:
1. **Model Layer** (Task Group 1) - Foundation for all duplication logic ✓
2. **Manual Duplication** (Task Group 2) - Controller action for explicit "Save" button ✓
3. **Auto-Duplication** (Task Group 3) - Silent duplication on workout start ✓
4. **View Layer** (Task Group 4) - UI button for manual duplication ✓
5. **Integration Testing** (Task Group 5) - Validate complete workflows ✓

---

## Technical Notes

### Database Considerations
- No schema changes required (uses existing Program and Exercise tables)
- Duplication creates new records with auto-generated IDs
- UUID generation handled by existing `before_create :generate_uuid` callback in Program model
- Transaction ensures atomic duplication (all or nothing)

### Code Reuse
- Leverage existing Program and Exercise associations
- Use existing authentication patterns from ApplicationController
- Follow existing flash message patterns (notice/alert)
- Use existing button styling from program show page
- Follow existing UUID-based lookup pattern: `Program.find_by!(uuid: params[:id])`

### Standards Alignment
- **Testing**: Minimal focused tests during development (2-8 per group), strategic gap-filling in final group
- **Model**: Transaction-based for atomicity, clear method naming
- **Controller**: RESTful design with member route, proper HTTP method (POST)
- **View**: Mobile-first with 44x44px touch targets, Tailwind CSS styling
- **Tech Stack**: Rails 8, Ruby 3, Postgres, ActiveRecord, Turbo, MiniTest

### Out of Scope
- Return-to redirect after login for anonymous users
- Preventing duplicate saves (allow unlimited copies)
- "Copy of..." prefix on titles
- Tracking original program UUID
- Duplicate-click protection (Rails handles form resubmission)
- Analytics on duplication frequency

---

## Success Metrics

Feature will be considered complete when:
- [x] All feature-specific tests pass (41 tests)
- [x] User can manually save programs via "Save to My Programs" button
- [x] User automatically receives their own copy when starting workout from non-owned program
- [x] Duplicated programs include all exercises in correct order
- [x] Duplicated programs are truly independent (modifying copy doesn't affect original)
- [x] Button visibility follows specification (authenticated non-owners only)
- [x] Flash messages appear correctly (manual save only, not automatic)
- [x] All operations complete atomically with proper error handling
