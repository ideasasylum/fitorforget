# WebAuthn Controller Manual Testing Guide

## Overview
This document outlines manual tests for the Stimulus WebAuthn controller. Since WebAuthn requires actual biometric hardware and user interaction, automated testing is impractical. Instead, perform these manual tests on actual devices.

## Test Environment Requirements
- HTTPS connection (use localhost in development - WebAuthn allows localhost without HTTPS)
- Device with biometric authentication (Face ID, Touch ID, fingerprint, Windows Hello)
- Modern browser: Chrome, Safari, Firefox, or Edge

## Critical Test Cases (2-8 focused tests)

### Test 1: Browser Support Detection
**Purpose:** Verify the controller detects WebAuthn browser API availability

**Steps:**
1. Open `/auth` in a modern browser (Chrome, Safari, Firefox, Edge)
2. Enter an email and click "Continue"
3. Observe the WebAuthn prompt appears

**Expected Result:**
- WebAuthn prompt displays loading indicator
- No "browser not supported" error appears

**Test on unsupported browser:**
1. Open `/auth` in an old browser (if available)
2. Enter email and click "Continue"

**Expected Result:**
- Error message: "Your browser doesn't support biometric authentication..."

---

### Test 2: Registration Credential Creation
**Purpose:** Verify registration flow triggers WebAuthn credential creation

**Steps:**
1. Open `/auth` in a browser
2. Enter a NEW email (not previously registered)
3. Click "Continue"
4. Observe biometric prompt appears on device
5. Complete the biometric verification

**Expected Result:**
- "Create your account" heading displays
- Loading indicator appears with "Waiting for biometric verification..." message
- Device biometric prompt appears (Face ID/Touch ID/fingerprint)
- After completion, user is logged in and redirected
- Success message: "Welcome! Your account has been created."

---

### Test 3: Authentication Credential Retrieval
**Purpose:** Verify authentication flow triggers WebAuthn credential verification

**Steps:**
1. Ensure you've already registered (complete Test 2 first)
2. Log out if logged in
3. Open `/auth` in a browser
4. Enter the SAME email used in registration
5. Click "Continue"
6. Observe biometric prompt appears on device
7. Complete the biometric verification

**Expected Result:**
- "Welcome back!" heading displays
- Loading indicator appears with "Waiting for biometric verification..." message
- Device biometric prompt appears
- After completion, user is logged in and redirected
- Success message: "Welcome back!"

---

### Test 4: Registration Cancellation Error
**Purpose:** Verify error handling when user cancels registration

**Steps:**
1. Open `/auth` in a browser
2. Enter a NEW email
3. Click "Continue"
4. When biometric prompt appears, cancel it (press Cancel or Esc)

**Expected Result:**
- Error message displays: "Registration cancelled. Please try again."
- "Try a different email" link appears
- No crash or console errors

---

### Test 5: Authentication Cancellation Error
**Purpose:** Verify error handling when user cancels authentication

**Steps:**
1. Ensure you've already registered
2. Open `/auth` in a browser
3. Enter your registered email
4. Click "Continue"
5. When biometric prompt appears, cancel it

**Expected Result:**
- Error message displays: "Sign in cancelled."
- "Try a different email" link appears
- No crash or console errors

---

### Test 6: Invalid Credential Error
**Purpose:** Verify error handling when credential doesn't match

**Steps:**
1. Register with email A on Device 1
2. Attempt to sign in with email A on Device 2 (without registering Device 2)
3. Observe the error

**Expected Result:**
- Error message displays: "Unable to verify your identity. This device may not be registered yet."
- "Try a different email" link appears

---

### Test 7: Multi-Device Registration
**Purpose:** Verify users can register multiple devices

**Steps:**
1. Register email A on Device 1 (complete biometric verification)
2. On Device 2, go to `/auth`
3. Enter the same email A
4. Complete biometric verification on Device 2

**Expected Result:**
- Device 2 should successfully register a new credential
- User can now authenticate from either device
- Both devices work independently for future logins

---

### Test 8: Base64 Encoding/Decoding
**Purpose:** Verify ArrayBuffer to base64 conversion works correctly

**Steps:**
1. Open browser console on `/auth`
2. Complete a registration or authentication flow
3. Check network tab for the POST to `/auth/verify`
4. Verify the `credential_response` parameter contains valid base64 strings

**Expected Result:**
- `credential_response` contains valid JSON
- All ArrayBuffer fields converted to base64 strings
- Backend successfully verifies the credential
- No encoding errors in console

---

## Testing Checklist by Device

### iOS Safari (Face ID/Touch ID)
- [ ] Test 1: Browser support detection
- [ ] Test 2: Registration credential creation
- [ ] Test 3: Authentication credential retrieval
- [ ] Test 4: Registration cancellation
- [ ] Test 5: Authentication cancellation

### Android Chrome (Fingerprint)
- [ ] Test 1: Browser support detection
- [ ] Test 2: Registration credential creation
- [ ] Test 3: Authentication credential retrieval
- [ ] Test 4: Registration cancellation
- [ ] Test 5: Authentication cancellation

### Desktop Chrome (Windows Hello/Touch ID)
- [ ] Test 1: Browser support detection
- [ ] Test 2: Registration credential creation
- [ ] Test 3: Authentication credential retrieval
- [ ] Test 7: Multi-device registration

### Desktop Safari (Touch ID on Mac)
- [ ] Test 1: Browser support detection
- [ ] Test 2: Registration credential creation
- [ ] Test 3: Authentication credential retrieval

---

## Known Limitations

1. **Automated testing not practical:** WebAuthn requires actual biometric hardware and user interaction
2. **HTTPS required in production:** Development allows localhost without HTTPS
3. **Browser support:** WebAuthn works in ~95% of modern browsers
4. **Simulator limitations:** iOS Simulator doesn't support WebAuthn - must use real device

---

## Debugging Tips

### Enable Debug Mode
In `/app/javascript/controllers/application.js`, set:
```javascript
application.debug = true
```

### Check Console for Errors
Look for these common errors:
- `NotAllowedError`: User cancelled or timeout
- `NotSupportedError`: Device doesn't support required features
- `InvalidStateError`: Credential already registered
- `NotFoundError`: No matching credential found

### Verify Challenge Data
Check that WebAuthn options are properly encoded:
```javascript
console.log("Options:", this.optionsValue)
console.log("Challenge:", this.optionsValue.challenge)
```

### Network Tab
Monitor POST requests to `/auth/verify` to ensure credential data is being sent correctly.

---

## Test Execution Record

| Test | iOS Safari | Android Chrome | Desktop Chrome | Desktop Safari | Pass/Fail |
|------|-----------|----------------|----------------|---------------|-----------|
| 1    |           |                |                |               |           |
| 2    |           |                |                |               |           |
| 3    |           |                |                |               |           |
| 4    |           |                |                |               |           |
| 5    |           |                |                |               |           |
| 6    |           |                |                |               |           |
| 7    |           |                |                |               |           |
| 8    |           |                |                |               |           |

---

## Notes

- Complete all tests on at least 2 different platforms (e.g., iOS and Desktop)
- Test registration and authentication separately
- Verify error messages are user-friendly
- Ensure loading states display correctly
- Confirm no page refreshes occur (Turbo Frame should handle everything)
