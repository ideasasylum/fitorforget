# Raw Feature Description

The application currently lacks integration tests that validate JavaScript and Turbo interactions, making it brittle. We need to create comprehensive system tests using Playwright that cover core user workflows:

1. Creating a program
2. Adding exercises to the program
3. Starting a workout from a program
4. Completing the workout and viewing the dashboard

Key technical challenge: The app uses WebAuthn authentication. We need to determine the best approach for handling authentication during system tests. Options include:
- Providing pre-authenticated session cookies to the browser
- Disabling authentication for system testing
- Other approaches

The webauthn-ruby gem has testing documentation at https://github.com/cedarcode/webauthn-ruby?tab=readme-ov-file#testing-your-integration but this appears focused on unit/integration testing rather than full system tests with a real browser.
