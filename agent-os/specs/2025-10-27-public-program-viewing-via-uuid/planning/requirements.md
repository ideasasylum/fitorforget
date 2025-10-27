# Spec Requirements: Public Program Viewing via UUID

## Initial Description
This feature enables public access to exercise programs through UUID-based URLs, allowing program creators to share their programs with clients, patients, or athletes without requiring recipients to create accounts. Anyone with the UUID link can view the complete program including all exercises, video links, and descriptions. This is a core feature for the creator-follower workflow and removes the primary friction point for program distribution.

## Requirements Discussion

### First Round Questions

**Q1:** Should all programs be public by default, or should users be able to mark programs as private?
**Answer:** All programs are public - no privacy toggle needed.

**Q2:** When the program owner views their own program via the UUID link, should they see edit/delete actions, or should the public view always be read-only?
**Answer:** Owners should see edit actions. Use the SAME controller action to handle rendering for logged-in/logged-out/public program viewing.

**Q3:** Should the public view display the creator's name, username, or any identifying information about who created the program?
**Answer:** The creator should be anonymous.

**Q4:** For exercise video URLs, should we embed videos inline (requires parsing YouTube/Vimeo URLs) or keep the current approach of "Watch video" links that open in new tabs?
**Answer:** Embed videos inline. Support YouTube and Instagram (other services optional).

**Q5:** Are there any interactive elements (like exercise completion checkboxes or session tracking) that should be available in the public view, or should it be purely informational?
**Answer:** No interactive elements for public view, must be mobile optimized.

**Q6:** Should there be a "Share" button with copy-to-clipboard functionality, or is it sufficient for users to copy the URL from their browser?
**Answer:** No sharing UI needed - users can just share the URL.

**Q7:** If someone tries to access a private program's UUID link without being logged in, what should happen? (Show login prompt, show 404, show "Program is private" message)
**Answer:** All programs are public (no private programs).

**Q8:** Should the public view include SEO meta tags (title, description, Open Graph tags) for better link previews when shared on social media or messaging apps?
**Answer:** Yes! Use program title and description.

**Q9:** Should there be any call-to-action on the public page (e.g., "Create your own program" signup button) or navigation back to the app?
**Answer:** Yes - "Signup to create your own program" CTA at bottom of page.

**Q10:** For programs with no exercises yet, should the public view show an empty state or should empty programs not be accessible publicly?
**Answer:** Default state - all programs are public.

### Existing Code to Reference

**Similar Features Identified:**
- Feature: Current authenticated program show page - Path: `app/views/programs/show.html.erb`
- Components to potentially reuse: Exercise display partial (`app/views/exercises/_exercise.html.erb`), exercise list partial (`app/views/exercises/_list.html.erb`)
- Backend logic to reference: ProgramsController#show action currently requires authentication and scopes to current_user.programs

**Technical Foundation Already in Place:**
- Programs already use UUID-based routing (Program#to_param returns uuid)
- UUID generation happens automatically via before_create callback in Program model
- Exercise video URLs are validated but currently shown as external links
- Markdown rendering helper already exists for exercise descriptions
- Mobile-first Tailwind CSS design system already implemented
- WebAuthn passwordless authentication system for detecting logged-in users

### Follow-up Questions
No follow-up questions needed - all requirements are clear.

## Visual Assets

### Files Provided:
No visual assets provided.

### Visual Insights:
No visual analysis required - feature will adapt existing program show page design with conditional rendering.

## Requirements Summary

### Functional Requirements

**Core Functionality:**
- Any user (authenticated or anonymous) can access a program via its UUID URL (e.g., `/programs/:uuid`)
- Public view displays full program details: title, description, and all exercises
- Each exercise shows: name, repeat count, embedded video (if provided), and formatted description
- Creator information is not displayed (anonymous programs)
- Programs are always public (no privacy settings or private programs)

**Authentication-Aware Behavior:**
- Same controller action (ProgramsController#show) handles all viewing scenarios
- If viewer is the program owner (logged in + owns program): show edit/delete actions
- If viewer is logged in but not owner: show read-only view
- If viewer is anonymous (not logged in): show read-only view
- No separate controller actions or routes for public vs. authenticated views

**Video Embedding:**
- Parse video URLs to detect YouTube and Instagram
- Render inline embedded players for supported platforms
- YouTube: Standard iframe embed with responsive wrapper
- Instagram: Instagram embed (iframe or oEmbed API)
- Other video URLs: Fall back to current "Watch video" external link behavior
- Videos must be responsive and work well on mobile devices

**Call-to-Action:**
- Bottom of public program page includes signup CTA
- CTA text: "Sign up to create your own program" (or similar)
- CTA links to signup page
- CTA should be visually distinct but not intrusive
- Only shown to non-authenticated users (hide if logged in)

**Empty State:**
- Programs with no exercises still publicly accessible
- Show existing empty state UI from authenticated view
- Message: "No exercises yet" with appropriate icon

### Reusability Opportunities

**Views to Reuse/Adapt:**
- `app/views/programs/show.html.erb` - Main program show page (adapt with conditional rendering)
- `app/views/exercises/_list.html.erb` - Exercise list partial (reuse as-is)
- `app/views/exercises/_exercise.html.erb` - Individual exercise display (adapt to remove edit/delete/reorder controls for non-owners)

**Helpers to Extend:**
- `ApplicationHelper#markdown` - Already exists for exercise description rendering
- New helper needed: `video_embed_html(url)` to parse and generate embed code for YouTube/Instagram

**Controller Pattern:**
- Modify existing `ProgramsController#show` to remove authentication requirement
- Keep `set_program` but change query from `current_user.programs.find_by!` to `Program.find_by!`
- Add owner check: `@is_owner = logged_in? && current_user == @program.user`
- Pass `@is_owner` to view for conditional rendering of edit/delete actions

### Scope Boundaries

**In Scope:**
- Public UUID-based program access for all users
- Inline video embedding for YouTube and Instagram
- Conditional display of edit/delete actions for program owners
- Anonymous program display (no creator info)
- SEO meta tags using program title and description
- Signup CTA for non-authenticated users at bottom of page
- Mobile-responsive video embeds
- Reusing existing exercise display components with conditional controls

**Out of Scope:**
- Privacy settings or private programs (all programs are public)
- Sharing UI with copy-to-clipboard functionality (users copy URL manually)
- Interactive elements like exercise completion tracking in public view
- Session tracking or progress features for anonymous users
- Social sharing buttons or social media integration beyond SEO meta tags
- Video embedding for platforms beyond YouTube and Instagram (use fallback link)
- Custom video player controls or autoplay settings
- Analytics or view count tracking for programs
- Password-protected program sharing
- Expiring or temporary share links

**Future Enhancements Mentioned:**
- None explicitly mentioned - this feature is foundational for later session tracking features (roadmap item #5 and #6)

### Technical Considerations

**Controller Modifications:**
- Remove `before_action :require_authentication` from `ProgramsController#show` only
- Change `set_program` to find by UUID without scoping to current_user
- Add owner detection logic: `@is_owner = logged_in? && current_user == @program.user`
- Handle case where program UUID doesn't exist (404 error)

**View Adaptations:**
- Conditionally render edit/delete actions based on `@is_owner`
- Conditionally render "Back to Programs" link only for authenticated users
- Hide drag handles and reorder buttons for non-owners
- Hide "Add Exercise" button for non-owners
- Replace video links with embedded players using new helper
- Add signup CTA at bottom for anonymous users

**Video Embedding Strategy:**
- Create `ApplicationHelper#video_embed_html(url)` helper method
- Detect YouTube URLs: `youtube.com/watch?v=`, `youtu.be/`, `youtube.com/embed/`
- Extract YouTube video ID and generate iframe embed with responsive wrapper
- Detect Instagram URLs: `instagram.com/p/`, `instagram.com/reel/`
- Generate Instagram embed using oEmbed API or direct iframe embed
- Use responsive aspect ratio containers (Tailwind: `aspect-video` for YouTube)
- Add `loading="lazy"` attribute for performance
- Fall back to existing external link behavior for unsupported URLs
- Consider privacy-enhanced mode for YouTube (`youtube-nocookie.com`)

**SEO Meta Tags:**
- Set `<title>` tag to program title (e.g., "Knee Rehab Program - Fit or Forget")
- Add `<meta name="description">` using program description (truncate if too long)
- Add Open Graph tags:
  - `og:title` - Program title
  - `og:description` - Program description
  - `og:type` - "website"
  - `og:url` - Canonical program URL
- Add Twitter Card tags for better Twitter link previews
- Consider using `content_for :head` in view to inject tags
- Default fallback if program description is blank

**Mobile Optimization:**
- Video embeds must be responsive (use aspect ratio containers)
- Touch targets for any interactive elements (44x44px minimum) - applies only to owner edit actions
- Ensure proper text wrapping and spacing for small screens
- Test video embed behavior on iOS Safari and Android Chrome
- Lazy load video embeds to improve initial page load performance
- Consider thumbnail/poster images for videos before user interaction

**Authentication Detection:**
- Use existing `logged_in?` helper method (returns true if current_user exists)
- Use existing `current_user` helper method (returns User or nil)
- Owner check: `current_user == @program.user` (safe because current_user can be nil)
- No changes needed to authentication system itself

**Error Handling:**
- Program UUID not found: Render 404 page
- Invalid video URL format: Fall back to external link (already gracefully handled)
- Missing program title or description: Display empty states appropriately

**Performance Considerations:**
- Eager load exercises association in controller: `@program.includes(:exercises)`
- Add database index on programs.uuid if not already present
- Use fragment caching for exercise list if program has many exercises
- Lazy load video embeds to avoid blocking page render

**Standards Compliance:**
- Follow Rails 8 conventions for Turbo/Stimulus (but no interactive JS needed for public view)
- Use Tailwind CSS classes matching existing design system
- Follow mobile-first responsive design patterns already established
- Maintain consistent touch target sizing (44x44px minimum)
- Use semantic HTML for accessibility
- Ensure video embeds have proper ARIA labels
- Test with screen readers for accessibility compliance
