# Tech Stack

## Framework & Runtime
- **Application Framework:** Rails 8
- **Language/Runtime:** Ruby 3
- **Package Manager:** bundler, yarn

## Frontend
- **JavaScript Framework:** Turbo and Stimulus (Rails 8 defaults)
- **CSS Framework:** Tailwind CSS
- **UI Components:** Tailwind UI (optional, for rapid prototyping)
- **Design Approach:** Mobile-first responsive design

## Database & Storage
- **Database:** SQLite (NOT Postgres)
- **ORM/Query Builder:** ActiveRecord
- **Caching:** Rails 8 built-in caching (Solid Cache if needed)
- **Background Jobs:** Solid Queue (Rails 8 default, for future reminder feature)

## Testing & Quality
- **Test Framework:** minitest
- **Linting/Formatting:** Standardrb

## Deployment & Infrastructure
- **Hosting:** Railway, Fly.io, or Hatchbox (SQLite-compatible Rails hosts)
- **CI/CD:** GitHub Actions
- **File Storage:** Local filesystem for SQLite; consider Tigris/S3 if file uploads added later

## Third-Party Services
- **Authentication:** WebAuthn (passwordless, biometric) via `webauthn` gem
- **Email:** ActionMailer with SendGrid, Postmark, or Resend (for future reminders)
- **Monitoring:** Sentry or Honeybadger (optional for production error tracking)
- **Video Hosting:** External (users provide YouTube/Vimeo links; no video upload/hosting)

## Progressive Web App (Future)
- **Service Workers:** Workbox or custom implementation
- **Manifest:** Rails-generated manifest.json
- **Offline Strategy:** Cache-first for viewed programs, network-first for new content

## Architecture Notes

### SQLite Considerations
- SQLite is excellent for single-server deployments with moderate concurrent usage
- Rails 8 significantly improved SQLite support with performance optimizations
- For multi-server scaling, consider migrating to Postgres, but SQLite is ideal for MVP
- Use SQLite in WAL (Write-Ahead Logging) mode for better concurrent read performance
- Database backups via Litestream or similar SQLite replication tools

### Mobile-First Design Philosophy
- All UI components designed for touch interaction (minimum 44x44px touch targets)
- Large, clear typography for readability on small screens
- Simplified navigation patterns optimized for mobile devices
- Progressive enhancement: works on all devices, optimized for phones
- Test regularly on actual mobile devices, not just browser DevTools

### Turbo & Stimulus Usage
- Turbo Frames for partial page updates (e.g., marking exercises complete without full reload)
- Turbo Streams for real-time updates if needed
- Stimulus controllers for interactive components (timers, video embeds, exercise progression UI)
- Minimize custom JavaScript; leverage Rails conventions and Hotwire patterns

### Deployment Strategy
- Deploy to platforms supporting SQLite persistence (Railway, Fly.io with volumes)
- Avoid traditional Heroku (ephemeral filesystem incompatible with SQLite)
- Use environment variables for configuration (API keys, email settings)
- Set up automated database backups (Litestream recommended)
- Consider read replicas via Litestream for scaling reads if needed

### WebAuthn Authentication Strategy
- Passwordless authentication using device biometrics (Face ID, Touch ID, fingerprint)
- Most secure authentication method (phishing-resistant)
- Excellent UX on mobile devices (perfect for mobile-first app)
- Requires HTTPS in production (standard for all modern deployments)
- ~95% browser support (all modern phones and browsers)
- Simpler implementation than password + reset flows (no email required for auth)
- Store WebAuthn credentials in database (credential_id, public_key, sign_count)

### Future PWA Implementation
- Service worker caching for offline program access
- Cache exercise videos? (Large; may skip and require network)
- Install prompts for iOS Safari and Android Chrome
- Background sync for session completion when offline
- Push notifications for exercise reminders (requires VAPID keys, push service)
