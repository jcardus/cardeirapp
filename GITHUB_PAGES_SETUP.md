# GitHub Pages Deployment Setup

This guide will help you deploy your Flutter web app to GitHub Pages with your custom domain `cardeira.org`.

## Prerequisites

1. Push your code to a GitHub repository
2. You have access to your domain's DNS settings

## Step 1: Enable GitHub Pages

1. Go to your GitHub repository
2. Click **Settings** → **Pages** (in the left sidebar)
3. Under **Source**, select **GitHub Actions**
4. Click **Save**

## Step 2: Configure Custom Domain

1. Still in **Settings** → **Pages**
2. Under **Custom domain**, enter: `cardeira.org`
3. Click **Save**
4. Wait for DNS check to complete (this may take a few minutes)

## Step 3: Update Your DNS Settings

Go to your domain registrar (where you bought cardeira.org) and add these DNS records:

### For Apex Domain (cardeira.org):

Add **A records** pointing to GitHub's IP addresses:
```
185.199.108.153
185.199.109.153
185.199.110.153
185.199.111.153
```

### For www subdomain (optional):

Add a **CNAME record**:
```
www.cardeira.org → YOUR-GITHUB-USERNAME.github.io
```

**Example DNS Configuration:**
```
Type    Name    Value
----    ----    -----
A       @       185.199.108.153
A       @       185.199.109.153
A       @       185.199.110.153
A       @       185.199.111.153
CNAME   www     yourusername.github.io
```

## Step 4: Verify DNS

After updating DNS (may take up to 24 hours, but usually faster):

1. Check if DNS is propagated:
   ```bash
   dig cardeira.org
   ```

2. The A records should point to GitHub's IPs

## Step 5: Deploy

Once DNS is configured and GitHub Pages is enabled:

1. Push your code to the `main` branch:
   ```bash
   git add .
   git commit -m "Setup GitHub Pages deployment"
   git push origin main
   ```

2. The GitHub Action will automatically:
   - Build your Flutter web app
   - Deploy it to GitHub Pages

3. Check the **Actions** tab in your repository to monitor the deployment

## Step 6: Enable HTTPS

1. After DNS propagates and the first deployment succeeds
2. Go to **Settings** → **Pages**
3. Check **Enforce HTTPS**
4. Wait a few minutes for the SSL certificate to be issued

## Your App Will Be Available At:

- **https://cardeira.org** - Main site
- **https://cardeira.org/app** - Deep link page (QR code will point here)
- **https://cardeira.org/.well-known/apple-app-site-association** - iOS Universal Links
- **https://cardeira.org/.well-known/assetlinks.json** - Android App Links

## Troubleshooting

### DNS not propagating?
- Wait up to 24 hours
- Check with: `dig cardeira.org` or `nslookup cardeira.org`
- Use https://dnschecker.org to check globally

### Build failing?
- Check the **Actions** tab for error details
- Make sure your `main` branch is the default branch
- Verify Flutter version in `.github/workflows/deploy.yml` matches your local version

### Custom domain not working?
- Ensure CNAME file exists in `web/CNAME` (already created)
- Re-add the custom domain in Settings → Pages if needed
- Wait for GitHub's DNS check to pass

### Universal Links not working after deployment?
- Test the files are accessible:
  ```bash
  curl https://cardeira.org/.well-known/apple-app-site-association
  curl https://cardeira.org/.well-known/assetlinks.json
  ```
- Make sure they return JSON (not HTML error pages)
- Check HTTPS is enabled

## Manual Deployment (if needed)

If you prefer to deploy manually instead of using GitHub Actions:

```bash
# Build the web app
flutter build web --release

# The output will be in build/web/
# Upload that folder to your hosting provider
```

## Next Steps

After deployment is complete:
1. Test the QR code in your app - it should open https://cardeira.org/app
2. Verify Universal Links work on iPhone
3. Verify App Links work on Android

See `web/DEEPLINK_SETUP.md` for testing instructions.