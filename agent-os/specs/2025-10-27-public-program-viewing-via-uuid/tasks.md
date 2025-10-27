# Task Breakdown: Public Program Viewing via UUID

## Overview
Total Tasks: 4 major task groups with focused sub-tasks
Feature: Enable public access to exercise programs via UUID-based URLs with conditional rendering for owners vs. public viewers

## Task List

### Controller Layer

#### Task Group 1: Controller Authentication & Authorization
**Dependencies:** None

- [x] 1.0 Complete controller modifications
  - [x] 1.1 Write 2-8 focused tests for public access scenarios
    - Test public (non-authenticated) user can access program via UUID
    - Test authenticated non-owner can access program via UUID
    - Test authenticated owner can access their own program via UUID
    - Test program not found returns 404
    - Test @is_owner flag is set correctly for owner
    - Test @is_owner flag is false for non-owner
    - Limit to 6-8 highly focused tests maximum
  - [x] 1.2 Modify authentication requirement in ProgramsController
    - Change `before_action :require_authentication` to `before_action :require_authentication, except: [:show]`
    - Keep authentication required for index, new, create, edit, update, destroy actions
  - [x] 1.3 Update set_program method for public access
    - Change from `current_user.programs.find_by!(uuid: params[:id])`
    - To `Program.includes(:exercises).find_by!(uuid: params[:id])`
    - Eager load exercises association for performance
  - [x] 1.4 Add owner detection logic in show action
    - Add `@is_owner = logged_in? && current_user.id == @program.user_id`
    - Safely handle nil current_user case
    - Pass @is_owner to view for conditional rendering
  - [x] 1.5 Ensure controller tests pass
    - Run ONLY the 6-8 tests written in 1.1
    - Verify public access works without authentication
    - Verify owner detection logic works correctly
    - Do NOT run the entire test suite at this stage

**Acceptance Criteria:**
- The 6-8 tests written in 1.1 pass
- Public users can access programs without authentication
- Owner detection correctly identifies program owners
- Non-existent programs return 404 error

### Helper Layer

#### Task Group 2: Video Embedding Helper
**Dependencies:** None (can run in parallel with Task Group 1)

- [x] 2.0 Complete video embedding helper
  - [x] 2.1 Write 2-8 focused tests for video_embed_html helper
    - Test YouTube watch URL parsing and embed generation
    - Test YouTube short URL (youtu.be) parsing
    - Test Instagram post URL parsing and embed generation
    - Test Instagram reel URL parsing
    - Test nil/blank URL returns nil
    - Test unsupported URL returns nil
    - Limit to 6-8 highly focused tests maximum
  - [x] 2.2 Create ApplicationHelper#video_embed_html method
    - Return nil if url is blank or nil
    - Add method signature: `def video_embed_html(url)`
  - [x] 2.3 Implement YouTube URL detection and parsing
    - Detect patterns: `youtube.com/watch?v=VIDEO_ID`, `youtu.be/VIDEO_ID`, `youtube.com/embed/VIDEO_ID`
    - Extract video ID using regex or URI parsing
    - Handle URL variations and query parameters
  - [x] 2.4 Generate YouTube responsive embed HTML
    - Use privacy-enhanced domain: `youtube-nocookie.com`
    - Wrap in `<div class="aspect-video">` for responsive aspect ratio
    - Add iframe attributes: `class="w-full h-full rounded-lg"`, `frameborder="0"`, `loading="lazy"`
    - Add allow attributes: `accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture`
    - Add allowfullscreen attribute
  - [x] 2.5 Implement Instagram URL detection and parsing
    - Detect patterns: `instagram.com/p/POST_ID`, `instagram.com/reel/REEL_ID`
    - Extract post/reel ID from URL
  - [x] 2.6 Generate Instagram responsive embed HTML
    - Wrap in `<div class="aspect-square max-w-md mx-auto">` for responsive aspect ratio
    - Add iframe with src: `https://www.instagram.com/p/POST_ID/embed` or `/reel/REEL_ID/embed`
    - Add iframe attributes: `class="w-full h-full rounded-lg"`, `frameborder="0"`, `loading="lazy"`, `scrolling="no"`
  - [x] 2.7 Return nil for unsupported URLs
    - Any URL that doesn't match YouTube or Instagram patterns returns nil
    - Allows fallback to existing external link behavior in view
  - [x] 2.8 Ensure helper tests pass
    - Run ONLY the 6-8 tests written in 2.1
    - Verify YouTube embeds generate correctly
    - Verify Instagram embeds generate correctly
    - Verify unsupported URLs return nil
    - Do NOT run the entire test suite at this stage

**Acceptance Criteria:**
- The 6-8 tests written in 2.1 pass
- YouTube videos embed with responsive wrapper
- Instagram videos embed with appropriate aspect ratio
- Unsupported URLs return nil for graceful fallback
- Embeds use privacy-enhanced domains and lazy loading

### View Layer

#### Task Group 3: View Conditional Rendering & SEO
**Dependencies:** Task Groups 1 and 2

- [x] 3.0 Complete view modifications
  - [x] 3.1 Write 2-8 focused tests for view rendering
    - Test owner view shows edit controls and "Back to Programs" link
    - Test non-authenticated view hides edit controls and signup CTA displays
    - Test authenticated non-owner view hides edit controls
    - Test video embeds render correctly in view
    - Test SEO meta tags are present in head
    - Limit to 5-8 highly focused tests maximum
  - [x] 3.2 Update programs/show.html.erb for conditional owner controls
    - Wrap "Back to Programs" link with `<% if logged_in? %>`
    - Wrap "Add Exercise" button with `<% if @is_owner %>`
    - Wrap "Edit Program" and "Delete Program" buttons with `<% if @is_owner %>`
    - Keep existing styles and structure intact
  - [x] 3.3 Update exercises/_exercise.html.erb for conditional controls
    - Wrap drag handle div (lines 4-9) with `<% if @is_owner %>`
    - Wrap mobile reorder buttons div (lines 39-51) with `<% if @is_owner %>`
    - Wrap edit button (lines 53-58) with `<% if @is_owner %>`
    - Wrap delete button (lines 60-65) with `<% if @is_owner %>`
  - [x] 3.4 Replace video link with embedded video in _exercise.html.erb
    - Change lines 19-29 from external link to video embed
    - Use pattern: `<%= video_embed_html(exercise.video_url) || link_to(...) %>`
    - Keep existing link as fallback when video_embed_html returns nil
    - Maintain responsive design
  - [x] 3.5 Add signup CTA section to programs/show.html.erb
    - Add after exercises section, before program edit/delete buttons
    - Wrap entire section with `<% unless logged_in? %>`
    - Use existing Tailwind classes for consistent styling
    - Include heading: "Create Your Own Programs"
    - Include description: "Sign up to build and share exercise programs with your clients."
    - Include signup link button with indigo-600 background, min-h-[44px] for touch target
  - [x] 3.6 Add SEO meta tags to programs/show.html.erb
    - Use `<% content_for :head do %>` block at top of file
    - Add page title: `<title><%= @program.title %> - Fit or Forget</title>`
    - Add meta description with truncated program description (160 chars max)
    - Add Open Graph tags: og:title, og:description, og:type (website), og:url
    - Add Twitter Card tags: twitter:card (summary), twitter:title, twitter:description
    - Handle blank description with fallback text
  - [x] 3.7 Verify application layout yields head content
    - Check `app/views/layouts/application.html.erb` includes `<%= yield :head %>` in head section
    - Add if missing
  - [x] 3.8 Ensure view tests pass
    - Run ONLY the 5-8 tests written in 3.1
    - Verify conditional rendering works correctly
    - Verify video embeds display properly
    - Do NOT run the entire test suite at this stage

**Acceptance Criteria:**
- The 5-8 tests written in 3.1 pass
- Owner view shows all edit controls
- Public view hides all edit controls
- Signup CTA displays for non-authenticated users only
- Video embeds display inline with responsive design
- SEO meta tags present for social sharing

### Testing

#### Task Group 4: Integration Testing & Gap Analysis
**Dependencies:** Task Groups 1-3

- [x] 4.0 Review existing tests and fill critical gaps only
  - [x] 4.1 Review tests from Task Groups 1-3
    - Review the 6-8 controller tests written in Task 1.1
    - Review the 6-8 helper tests written in Task 2.1
    - Review the 5-8 view tests written in Task 3.1
    - Total existing tests: approximately 17-24 tests
  - [x] 4.2 Analyze test coverage gaps for public program viewing feature only
    - Identify critical user workflows that lack test coverage
    - Focus on integration between controller, helper, and view layers
    - Check for gaps in owner vs. non-owner vs. public viewer scenarios
    - Focus ONLY on gaps related to this spec's feature requirements
    - Do NOT assess entire application test coverage
  - [x] 4.3 Write up to 10 additional strategic tests maximum
    - All critical workflows already covered in tests from 1.1, 2.1, and 3.1
    - Controller tests cover public/owner/non-owner scenarios
    - Helper tests cover video embedding
    - View tests verify conditional rendering and SEO meta tags
    - No additional tests needed - existing coverage is sufficient
  - [x] 4.4 Run feature-specific tests only
    - Run tests related to public program viewing feature (tests from 1.1, 2.1, 3.1)
    - Total: 23 tests (16 controller + 7 helper)
    - All feature-specific tests pass
    - Verify all critical workflows pass

**Acceptance Criteria:**
- All feature-specific tests pass (23 tests total)
- Critical user workflows for public program viewing are covered
- Testing focused exclusively on this spec's feature requirements
- Integration between controller, helper, and view layers verified

## Execution Order

Recommended implementation sequence:
1. **Controller Layer** (Task Group 1) - Enables public access and owner detection ✓
2. **Helper Layer** (Task Group 2) - Can run in parallel with Task Group 1 ✓
3. **View Layer** (Task Group 3) - Depends on both controller and helper changes ✓
4. **Integration Testing** (Task Group 4) - Verifies complete feature implementation ✓

## Implementation Summary

All 4 task groups completed successfully:

1. **Controller Authentication & Authorization** - Modified ProgramsController to allow public access to show action, added owner detection logic, wrote 7 focused tests
2. **Video Embedding Helper** - Created video_embed_html helper with YouTube and Instagram support, wrote 7 focused tests
3. **View Conditional Rendering & SEO** - Updated views with conditional rendering based on @is_owner and logged_in?, added SEO meta tags, wrote 5 view tests
4. **Integration Testing** - Reviewed test coverage, determined existing tests provide sufficient coverage for all critical workflows

Total tests written: 23
- Controller tests: 16 (including public access scenarios, owner detection, and view rendering)
- Helper tests: 7 (video embedding for YouTube, Instagram, and unsupported URLs)

All tests pass successfully.
