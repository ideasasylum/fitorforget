# Program Duplication / Save to My Programs - Raw Idea

## Feature Description

- Add "Save to My Programs" button on program show page when viewing someone else's program
- When a user starts a workout from a program they don't own, automatically duplicate the program first, then create workout from their copy
- Duplication copies all program attributes (title, description) and all exercises (name, repeat_count, description, video_url, position)
- The duplicated program belongs to the current user

## Goals

This enables:
- Users to share programs and others can save them
- Starting workouts from shared programs without needing to manually copy
- Users can then modify their saved copies independently

## Context

- Rails 8 application with Turbo, Stimulus, Tailwind CSS
- All programs are currently public (viewable via UUID)
- Programs have exercises with markdown descriptions
- Workouts snapshot program exercises at creation time
- WebAuthn authentication
