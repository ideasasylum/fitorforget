# Local Development Setup with SSL

This project uses `local.fitorforget.com` with SSL in development to properly test WebAuthn authentication, which requires HTTPS.

## Prerequisites

1. **SSL Certificates**: Already created using `mkcert`:
   - `local.fitorforget.com.pem` (certificate)
   - `local.fitorforget.com-key.pem` (private key)

2. **Hosts File Configuration**: Add the following line to your `/etc/hosts` file:

```
127.0.0.1 local.fitorforget.com
```

### How to Edit /etc/hosts

**On macOS/Linux:**
```bash
sudo nano /etc/hosts
```

Add the line:
```
127.0.0.1 local.fitorforget.com
```

Save and exit (Ctrl+O, Enter, Ctrl+X in nano).

## Running the Development Server

Start the Rails server as normal:

```bash
bin/rails server
```

or

```bash
bin/dev
```

The server will automatically start with SSL on port 3000.

## Accessing the Application

Open your browser and navigate to:

```
https://local.fitorforget.com:3000
```

**Note:**
- Use `https://` (not `http://`)
- Include the port `:3000`
- Your browser may show a security warning on first visit - this is expected with self-signed certificates. Click "Advanced" and "Proceed" to continue.

## Testing WebAuthn Authentication

Once the server is running and you can access the site:

1. Navigate to: `https://local.fitorforget.com:3000/auth`
2. Enter an email address
3. Your browser will prompt for biometric authentication (Face ID, Touch ID, fingerprint, etc.)
4. Complete the biometric prompt to register or sign in

## Troubleshooting

### "Connection refused" error
- Make sure you've added `127.0.0.1 local.fitorforget.com` to `/etc/hosts`
- Verify the Rails server is running

### "Your connection is not private" warning
- This is expected with self-signed certificates
- Click "Advanced" → "Proceed to local.fitorforget.com" (the exact text varies by browser)

### WebAuthn not working
- Ensure you're using `https://` and not `http://`
- Make sure you're on a supported browser (Chrome, Safari, Firefox, Edge - all modern versions)
- Check that your device has biometric hardware enabled

### Certificate issues
- If you regenerate certificates, restart the Rails server
- Clear your browser cache if certificates were recently changed
