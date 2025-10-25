# Product Roadmap

## Development Path

This roadmap outlines the feature development sequence for Fit or Forget, ordered by technical dependencies and the most direct path to delivering core value. Each feature represents an end-to-end implementation including frontend, backend, database, and testing.

---

1. [ ] **User Authentication & Account Management** — Implement WebAuthn passwordless authentication for user sign-up, login, and session management using device biometrics (Face ID, Touch ID, fingerprint). Users can create accounts to own programs and track history. Requires webauthn gem and credential storage. `M`

2. [ ] **Exercise Program CRUD** — Build the core Program model and controller with full CRUD operations. Users can create, edit, view, and delete exercise programs. Each program includes title, description, and UUID generation for sharing. `M`

3. [ ] **Exercise Management within Programs** — Create the Exercise model with belongs_to relationship to Program. Users can add, edit, reorder, and remove exercises within a program. Each exercise includes name, repeat count (e.g., "3x"), video URL, and formatted description field. `M`

4. [ ] **Public Program Viewing via UUID** — Implement public program access through UUID-based routes (e.g., /programs/:uuid). Anonymous users can view full program details including all exercises without authentication. UUID sharing system allows instant access via link. `S`

5. [ ] **Session Start & Exercise Progression** — Build session management allowing users to start a program session and progress through exercises sequentially. Implement UI for marking individual exercises as complete during an active session, with clear visual indicators of progress (e.g., "Exercise 2 of 8"). `M`

6. [ ] **Session Completion & History Tracking** — Create Session model to persist completed sessions with timestamps, associated program, and individual exercise completion records. Users can view their session history showing past completion dates and programs followed. `M`

7. [ ] **Mobile-Responsive Exercise Interface** — Implement mobile-first UI using Tailwind CSS with large touch targets, clear typography, and optimized layout for phone screens. Exercise view displays video embeds, descriptions with proper formatting, and prominent completion buttons. Test across device sizes. `M`

8. [ ] **Program Library & Dashboard** — Build user dashboard displaying all programs they've created (with edit/delete actions) and programs they've followed (with quick access to start new session). Implement basic filtering and sorting by recent activity. `S`

9. [ ] **Exercise Video Embed Optimization** — Enhance video integration to support multiple platforms (YouTube, Vimeo, etc.) with proper responsive embeds. Implement video preview validation and fallback for invalid URLs. Consider autoplay and mute options for better UX. `S`

10. [ ] **Exercise Description Formatting** — Add rich text formatting support for exercise descriptions (bold, lists, line breaks) using a simple markdown parser or Rails text helpers. Ensure formatted descriptions render properly on mobile. `XS`

11. [ ] **Scheduled Exercise Reminders** — Implement reminder system where users can set recurring notifications (e.g., "Monday, Wednesday, Friday at 7am") for specific programs. Build background job processing using Solid Queue (Rails 8 default) to send email reminders. `L`

12. [ ] **Progressive Web App (PWA) Setup** — Configure service workers, manifest file, and offline caching strategy to enable PWA installation. Users can add app to home screen and access previously viewed programs offline. Test installation flow on iOS and Android. `L`

> Notes
> - Items 1-8 constitute the MVP (Minimum Viable Product) delivering core creator-follower workflow
> - Items 9-10 are polish enhancements improving exercise content quality
> - Items 11-12 are advanced features requiring background processing and PWA infrastructure
> - Exercise timers intentionally omitted from initial roadmap - can be added as simple client-side feature later
> - SQLite is sufficient for MVP; consider scaling strategy if concurrent usage grows significantly
