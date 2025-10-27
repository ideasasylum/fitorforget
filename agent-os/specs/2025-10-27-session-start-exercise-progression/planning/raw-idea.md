# Raw Idea: Session Start & Exercise Progression

## Feature Description from Roadmap

Build session management allowing users to start a program session and progress through exercises sequentially. Implement UI for marking individual exercises as complete during an active session, with clear visual indicators of progress (e.g., 'Exercise 2 of 8').

## Additional Context

This is the workout tracking feature where:
- Users can start a workout session from a program
- They progress through exercises one by one
- Mark each exercise as complete
- See visual progress indicators
- Mobile-first UI with large touch targets

## Technical Context

- Rails 8 application with Turbo, Stimulus, Tailwind CSS
- Existing Program and Exercise models with UUID routing
- WebAuthn authentication
- Mobile-first design with 44x44px touch targets
- All programs are public, but sessions belong to authenticated users

## Roadmap Reference

Roadmap Item #5: Session Start & Exercise Progression
