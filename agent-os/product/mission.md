# Product Mission

## Pitch
Fit or Forget is a mobile-first exercise program webapp that helps coaches, trainers, and physical therapists deliver at-home exercise and rehab programs to their clients by providing simple program creation, effortless sharing via links, and straightforward session tracking that keeps clients accountable.

## Users

### Primary Customers
- **Program Creators**: Coaches, personal trainers, physical therapists, and rehabilitation specialists who need to prescribe and deliver at-home exercise programs to their clients
- **Program Followers**: Clients, patients, athletes, and individuals following prescribed exercise or rehabilitation programs at home

### User Personas

**Sarah - Physical Therapist** (32-45)
- **Role:** Physical therapist at a sports medicine clinic
- **Context:** Treats 20-30 patients per week, most requiring home exercise programs between sessions
- **Pain Points:** Emailing PDF exercise sheets is clunky, no way to track if patients are actually doing exercises, patients lose or forget instructions, video demonstrations require separate links or apps
- **Goals:** Quickly create exercise programs during appointments, easily share them with patients, have confidence that patients can follow along independently, see basic compliance data

**Marcus - Weekend Athlete** (28-40)
- **Role:** Software developer recovering from a running injury
- **Context:** Received home rehab exercises from physical therapist, needs to do them 3x per week
- **Pain Points:** Paper instructions get lost, can't remember proper form, forgets to do exercises, no easy way to track completion
- **Goals:** Access exercises anytime on phone, watch video demonstrations, check off completed exercises, build consistency habit

**Jennifer - Personal Trainer** (26-38)
- **Role:** Independent personal trainer working with remote clients
- **Context:** Designs custom workout programs for 15+ clients, many training from home
- **Pain Points:** Existing platforms are expensive or overly complex, clients need simple tools they'll actually use, hard to ensure clients follow programs between check-ins
- **Goals:** Create programs quickly, share them instantly, keep it simple so clients stay engaged

## The Problem

### Fragmented Home Exercise Delivery
Coaches and therapists currently deliver home exercise programs through fragmented methods: PDFs via email, screenshots, handwritten notes, or expensive complex platforms. These methods make it difficult to include video demonstrations, ensure clients have access when needed, and track basic compliance. Clients struggle to remember proper form, lose instructions, and lack motivation without tracking.

**Our Solution:** A dead-simple webapp where creators build exercise programs once, share via a single link, and clients access everything they need in one mobile-friendly interface with built-in session tracking.

### No Lightweight Tracking for Home Programs
Unlike gym workouts where trainers can observe, home exercise programs exist in a black box. Coaches don't know if clients are following through, and clients lack the structure and accountability of tracked sessions. Existing solutions are either too complex (full workout platforms) or non-existent (paper sheets).

**Our Solution:** Session-based completion tracking that's as simple as checking off a grocery list. Clients start a session, work through exercises, mark each complete, and build a completion history. Coaches can design programs knowing clients have clear guidance.

## Differentiators

### Frictionless Sharing via UUID Links
Unlike platforms requiring account creation before access, we provide instant sharing through UUID links. Create a program, copy the link, send it to your client - they access it immediately. No sign-up friction for followers until they want to track history.

This results in near-zero adoption barrier and immediate value delivery to both creators and followers.

### Mobile-First Simplicity
Unlike comprehensive fitness platforms with dozens of features, we focus exclusively on the home exercise program use case. Every feature is designed for someone following exercises on their phone in their living room: large touch targets, clear exercise flow, integrated video links, simple completion tracking.

This results in higher client engagement and program adherence because the tool fits the context perfectly.

### Built for the Creator-Follower Relationship
Unlike general workout apps designed for self-directed fitness enthusiasts, we optimize for the professional-client dynamic. Creators build programs to share (not personal workouts), followers execute prescribed programs (not self-designed routines), and the sharing model reflects real-world workflows.

This results in a tool that matches how rehabilitation and coaching actually work, not retrofitted from consumer fitness apps.

## Key Features

### Core Features
- **Exercise Program Builder:** Create programs containing multiple exercises, each with name, repeat count (e.g., "3x"), video link, and formatted description text
- **UUID-Based Sharing:** Every program gets a unique shareable link that works immediately without recipient sign-up
- **Session Tracking:** Start a session, progress through exercises one by one, mark each complete, finish session
- **Video Integration:** Embed video links directly in exercises for form demonstration
- **Mobile-Responsive Design:** Touch-friendly interface optimized for phone use during workouts

### Account Features
- **User Accounts:** Optional account creation to save created programs and track completion history
- **Exercise History:** View past completed sessions and track consistency over time
- **Program Library:** Access all programs you've created or followed

### Future Features
- **Exercise Reminders:** Schedule notifications to stay consistent with program
- **Built-in Timers:** Countdown timers for holds and timed exercises
- **Progressive Web App:** Install to home screen, work offline, feel like a native app
- **Program Templates:** Save and reuse common exercise combinations
- **Completion Insights:** Basic analytics for creators to see client engagement patterns
