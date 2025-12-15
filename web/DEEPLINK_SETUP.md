# Web Hosting Setup for Universal Links

This directory contains files that need to be hosted on your domain (cardeira.org) to enable Universal Links (iOS) and App Links (Android).

## Files to Upload

### 1. .well-known/apple-app-site-association
Upload this file to: `https://cardeira.org/.well-known/apple-app-site-association`

**Important:**
- This file must be served WITHOUT a file extension
- Content-Type must be `application/json`
- Must be accessible via HTTPS
- Before deploying, replace `TEAMID` in the file with your Apple Developer Team ID

To find your Team ID:
1. Go to https://developer.apple.com/account
2. Click on "Membership" in the sidebar
3. Your Team ID will be displayed there

### 2. .well-known/assetlinks.json
Upload this file to: `https://cardeira.org/.well-known/assetlinks.json`

**Important:**
- Content-Type must be `application/json`
- Must be accessible via HTTPS
- The current SHA256 fingerprint is for your DEBUG keystore
- **Before publishing to production**, you MUST update this file with your release keystore fingerprint

To get your release keystore SHA256 fingerprint:
```bash
keytool -list -v -keystore /path/to/your/release-keystore.jks -alias your-key-alias
```

Then copy the SHA256 fingerprint (with colons) into the assetlinks.json file.

### 3. app/index.html
Upload this file to: `https://cardeira.org/app/index.html`

This is a redirect page that will:
- Open the app if it's installed
- Show a fallback message if the app isn't installed
- Work on all platforms

## Testing

### iOS
1. Upload all files to your server
2. Verify the apple-app-site-association file is accessible:
   ```bash
   curl https://cardeira.org/.well-known/apple-app-site-association
   ```
3. In iOS, open Safari and go to `https://cardeira.org/app`
4. The app should open automatically (may require uninstalling and reinstalling the app first)

### Android
1. Upload all files to your server
2. Verify the assetlinks.json file is accessible:
   ```bash
   curl https://cardeira.org/.well-known/assetlinks.json
   ```
3. Test the link:
   ```bash
   adb shell am start -a android.intent.action.VIEW -d "https://cardeira.org/app"
   ```

## QR Code

Once everything is set up, the QR code in your app will display: `https://cardeira.org/app`

When scanned with a phone camera:
- **If the app is installed**: Opens the app directly
- **If the app is NOT installed**: Opens the browser with instructions to download the app

## Troubleshooting

### iOS Universal Links not working?
- Make sure the apple-app-site-association file has NO file extension
- Verify it's served over HTTPS
- Check that your Team ID is correct in the file
- Try uninstalling and reinstalling the app
- Universal Links don't work when tapping links within the same app or in Safari's address bar - they must be tapped from another app (Messages, Mail, Notes, etc.)

### Android App Links not working?
- Verify assetlinks.json is accessible
- Make sure the SHA256 fingerprint matches your app's signing certificate
- Run: `adb shell pm get-app-links org.cardeira.cardeirapp` to check verification status
- App Links require Android 6.0 (API 23) or higher

## Server Configuration Examples

### Apache (.htaccess)
```apache
<Files "apple-app-site-association">
    ForceType application/json
</Files>
```

### Nginx
```nginx
location /.well-known/apple-app-site-association {
    default_type application/json;
}
```

### Netlify (_headers file)
```
/.well-known/apple-app-site-association
  Content-Type: application/json
```