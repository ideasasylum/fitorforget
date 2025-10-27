# Specification: Public Program Viewing via UUID

## Goal
Enable public access to exercise programs via UUID-based URLs so creators can share programs with clients, patients, or athletes without requiring account creation. The same controller action handles both authenticated owners (showing edit controls) and public viewers (read-only display).

## User Stories
- As a program creator, I want to share my program URL with clients so they can view it without signing up
- As a program viewer (non-authenticated), I want to see the full program with embedded videos so I can follow the exercises easily on my phone
- As a program owner viewing my own program, I want to see edit/delete actions so I can manage it while viewing
- As a non-authenticated viewer, I want to see a signup CTA so I know I can create my own programs
- As a program shared on social media, I want proper preview cards with title and description so recipients know what they're opening

## Core Requirements
- Any user (authenticated or anonymous) can access programs via UUID URL at `/programs/:uuid`
- Full program details displayed: title, description, and all exercises with names, reps, descriptions, and videos
- YouTube and Instagram videos are embedded inline with responsive aspect ratios
- Program owners see edit/delete actions and "Add Exercise" button when authenticated
- Non-owners see read-only view with no edit controls, drag handles, or reorder buttons
- Non-authenticated users see signup CTA at bottom of page
- Creator information remains anonymous (no user attribution displayed)
- Empty programs (no exercises) show existing empty state UI
- SEO meta tags include program title and description for social sharing

## Visual Design
No mockups provided. Feature adapts existing program show page design with conditional rendering:

**Owner View (authenticated + owns program):**
- Shows "Back to Programs" link
- Shows "Add Exercise" button above exercise list
- Shows drag handles (desktop) and up/down arrows (mobile) on exercises
- Shows edit/delete actions on each exercise
- Shows "Edit Program" and "Delete Program" buttons at bottom
- No signup CTA displayed

**Public/Non-Owner View:**
- Hides "Back to Programs" link (non-authenticated only)
- Hides "Add Exercise" button
- Hides all drag handles and reorder controls
- Hides edit/delete actions on exercises
- Hides "Edit Program" and "Delete Program" buttons
- Shows signup CTA section at bottom (non-authenticated only)

**Responsive Requirements:**
- Video embeds use aspect ratio containers (aspect-video for YouTube)
- Touch targets minimum 44x44px for any interactive elements
- Mobile-first layout already established in existing views
- Test on iOS Safari and Android Chrome

## Reusable Components

### Existing Code to Leverage
**Views:**
- `app/views/programs/show.html.erb` - Adapt with conditional rendering based on `@is_owner` variable
- `app/views/exercises/_list.html.erb` - Reuse as-is for rendering exercise collection
- `app/views/exercises/_exercise.html.erb` - Adapt with conditional rendering to hide edit controls for non-owners

**Helpers:**
- `ApplicationHelper#markdown` - Already exists for rendering exercise descriptions with Redcarpet
- `current_user` helper - Returns User object or nil (from ApplicationController)
- `logged_in?` helper - Returns boolean (from ApplicationController)

**Models:**
- `Program#to_param` - Already returns uuid for URL generation
- `Program.uuid` - Generated automatically via before_create callback with SecureRandom.uuid

**Authentication:**
- WebAuthn passwordless authentication system already in place
- Session management via `session[:user_id]`

### New Components Required
**Helper Method:**
- `ApplicationHelper#video_embed_html(url)` - Does not exist yet
  - Purpose: Parse video URLs and return responsive embed HTML
  - Must support YouTube (watch, youtu.be, embed URL formats)
  - Must support Instagram (posts and reels)
  - Must return nil or fallback link HTML for unsupported URLs
  - Must include responsive wrapper with aspect ratio preservation
  - Must add loading="lazy" for performance

**Why New Component Needed:**
- No existing helper for video URL parsing and embed generation
- Current implementation uses simple external links (line 21-28 in `_exercise.html.erb`)
- Embedding requires URL pattern detection, ID extraction, and responsive iframe generation

## Technical Approach

### Controller Modifications
**File:** `app/controllers/programs_controller.rb`

**Changes to `show` action:**
1. Remove authentication requirement: Modify `before_action :require_authentication, except: [:show]`
2. Update `set_program` method to find by UUID without user scoping: `@program = Program.find_by!(uuid: params[:id])`
3. Add owner detection in `show` action: `@is_owner = logged_in? && current_user.id == @program.user_id`
4. Eager load exercises association: `@program = Program.includes(:exercises).find_by!(uuid: params[:id])`

**Error Handling:**
- Program UUID not found raises `ActiveRecord::RecordNotFound` (handled by Rails default 404)

### View Modifications
**File:** `app/views/programs/show.html.erb`

**Conditional Rendering Pattern:**
- Wrap "Back to Programs" link: `<% if logged_in? %>`
- Wrap "Add Exercise" button: `<% if @is_owner %>`
- Wrap "Edit Program" and "Delete Program" buttons: `<% if @is_owner %>`
- Add signup CTA at bottom: `<% unless logged_in? %>`

**File:** `app/views/exercises/_exercise.html.erb`

**Conditional Rendering Pattern:**
- Wrap drag handle div: `<% if @is_owner %>`
- Wrap mobile reorder buttons div: `<% if @is_owner %>`
- Wrap edit button: `<% if @is_owner %>`
- Wrap delete button: `<% if @is_owner %>`
- Replace video link with: `<%= video_embed_html(exercise.video_url) || link_to(...) %>`

**Signup CTA Section (add to show.html.erb):**
```erb
<% unless logged_in? %>
  <div class="mt-8 pt-8 border-t border-gray-200 text-center">
    <h3 class="text-xl font-semibold text-gray-900 mb-3">Create Your Own Programs</h3>
    <p class="text-gray-600 mb-4">Sign up to build and share exercise programs with your clients.</p>
    <%= link_to "Sign Up Free", signup_path, class: "inline-flex items-center px-6 py-3 border border-transparent text-base font-medium rounded-lg text-white bg-indigo-600 hover:bg-indigo-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-indigo-500 transition-colors min-h-[44px]" %>
  </div>
<% end %>
```

### Video Embedding Helper
**File:** `app/helpers/application_helper.rb`

**Method:** `video_embed_html(url)`

**Implementation Strategy:**
1. Return nil if url is blank
2. Detect YouTube patterns: `youtube.com/watch?v=VIDEO_ID`, `youtu.be/VIDEO_ID`, `youtube.com/embed/VIDEO_ID`
3. Extract YouTube video ID using regex or URI parsing
4. Generate YouTube iframe with privacy-enhanced domain (`youtube-nocookie.com`)
5. Detect Instagram patterns: `instagram.com/p/POST_ID`, `instagram.com/reel/REEL_ID`
6. Generate Instagram iframe embed
7. Wrap iframes in responsive container with aspect ratio
8. Add loading="lazy" and appropriate attributes
9. Return nil for unsupported URLs (fallback to existing link)

**YouTube Embed Template:**
```erb
<div class="aspect-video">
  <iframe src="https://www.youtube-nocookie.com/embed/VIDEO_ID"
          class="w-full h-full rounded-lg"
          frameborder="0"
          loading="lazy"
          allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
          allowfullscreen>
  </iframe>
</div>
```

**Instagram Embed Template:**
```erb
<div class="aspect-square max-w-md mx-auto">
  <iframe src="https://www.instagram.com/p/POST_ID/embed"
          class="w-full h-full rounded-lg"
          frameborder="0"
          loading="lazy"
          scrolling="no">
  </iframe>
</div>
```

### SEO Meta Tags
**File:** `app/views/programs/show.html.erb`

**Add to `<head>` section using content_for:**
```erb
<% content_for :head do %>
  <title><%= @program.title %> - Fit or Forget</title>
  <meta name="description" content="<%= @program.description.present? ? truncate(@program.description, length: 160) : 'View this exercise program on Fit or Forget' %>">

  <!-- Open Graph tags -->
  <meta property="og:title" content="<%= @program.title %>">
  <meta property="og:description" content="<%= @program.description.present? ? truncate(@program.description, length: 200) : 'View this exercise program on Fit or Forget' %>">
  <meta property="og:type" content="website">
  <meta property="og:url" content="<%= program_url(@program) %>">

  <!-- Twitter Card tags -->
  <meta name="twitter:card" content="summary">
  <meta name="twitter:title" content="<%= @program.title %>">
  <meta name="twitter:description" content="<%= @program.description.present? ? truncate(@program.description, length: 200) : 'View this exercise program on Fit or Forget' %>">
<% end %>
```

**Update application layout** to yield head content:
- Ensure `app/views/layouts/application.html.erb` includes `<%= yield :head %>` in `<head>` section

## Out of Scope
- Privacy settings or private programs (all programs are public)
- Share button with copy-to-clipboard functionality
- Interactive elements (exercise completion checkboxes, session tracking) for public viewers
- Social sharing buttons or social media API integration
- Custom video player controls or autoplay settings
- Analytics or view count tracking
- Password-protected program sharing
- Expiring or temporary share links
- Video embedding for platforms beyond YouTube and Instagram
- Custom thumbnail/poster images for videos
- Comment or feedback system on public programs
- Printing or PDF export of programs
- Program cloning or forking by viewers
- Email sharing functionality

## Success Criteria
- Non-authenticated users can access any program via UUID URL without login redirect
- Program owners see full edit controls when viewing their own programs
- YouTube videos embed inline and play within the page on mobile devices
- Instagram videos embed inline with appropriate aspect ratio
- Signup CTA displays only for non-authenticated users
- Social media link previews show program title and description
- Page loads in under 2 seconds on 3G connection with lazy-loaded videos
- All touch targets meet 44x44px minimum on mobile
- Zero accessibility violations when tested with screen reader
