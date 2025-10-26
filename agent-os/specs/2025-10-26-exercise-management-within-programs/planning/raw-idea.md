# Exercise Management within Programs - Raw Idea

## Feature Description
Create the Exercise model with belongs_to relationship to Program. Users can add, edit, reorder, and remove exercises within a program. Each exercise includes name, repeat count (e.g., "3x"), video URL, and formatted description field.

## Context from Roadmap
- **Roadmap Item**: #3
- **Complexity**: Medium (M)
- This is the third item in the roadmap, building on completed WebAuthn authentication and Program CRUD
- Exercises belong to programs (has_many :exercises relationship)
- Users manage exercises through their programs
- Each exercise needs: name, repeat_count, video_url, description
- Reordering functionality required (position/ordering)

## Additional Context
- This is a Rails 8 application
- Using Tailwind CSS for styling
- Turbo Frames for seamless navigation
- Stimulus for JavaScript interactions (reordering)
- SQLite database
- Mobile-first responsive design
- WebAuthn authentication complete (roadmap item 1)
- Program CRUD complete with UUID routing (roadmap item 2)

## Dependencies
- Completed: WebAuthn authentication (roadmap item #1)
- Completed: Program CRUD with UUID routing (roadmap item #2)

## Key Requirements
1. Exercise model with belongs_to Program relationship
2. CRUD operations for exercises (add, edit, remove)
3. Reordering functionality for exercises within a program
4. Exercise fields:
   - name
   - repeat_count (e.g., "3x")
   - video_url
   - description (formatted field)
5. User can only manage exercises within their own programs
