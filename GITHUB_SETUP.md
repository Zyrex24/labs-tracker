# GitHub Setup Guide

This guide will help you push the Labs Tracker project to GitHub and set up collaboration.

## ✅ Pre-Push Checklist

Before pushing to GitHub, verify:

1. **No secrets committed**
   - No `*.jks` or `*.keystore` files
   - No `key.properties` files
   - No `google-services.json` or `GoogleService-Info.plist`
   - Check with: `git status` (should not show any of the above)

2. **Android manifest verified**
   - Confirmed NO `INTERNET` permission in `android/app/src/main/AndroidManifest.xml`
   - ✅ Already verified in this project

3. **Generated files excluded**
   - `*.g.dart` files are gitignored
   - `build/` directory is gitignored
   - Run `git status` to confirm

## 🚀 Push to GitHub (PowerShell)

### Step 1: Initialize Git Repository

```powershell
# Initialize git (if not already done)
git init

# Add all files
git add .

# Create initial commit
git commit -m "chore: initial commit - Labs Tracker with CI/CD"

# Rename branch to main
git branch -M main
```

### Step 2: Create GitHub Repository

1. Go to https://github.com/new
2. Repository name: `labs-tracker` (or your choice)
3. Description: "100% offline Flutter lab attendance tracker"
4. Choose: **Private** or **Public**
5. Do NOT initialize with README (we already have one)
6. Click "Create repository"

### Step 3: Connect and Push

Replace `YOUR_USERNAME` and `REPO_NAME` with your actual values:

```powershell
# Add remote
git remote add origin https://github.com/YOUR_USERNAME/REPO_NAME.git

# Push to GitHub
git push -u origin main
```

### Step 4: Verify CI is Working

1. Go to your repository on GitHub
2. Click **Actions** tab
3. You should see "Flutter CI" workflow running
4. Wait for it to complete (usually 3-5 minutes)
5. Green checkmark = success! ✅

### Step 5: Download Build Artifact

1. In **Actions** tab, click on the completed workflow run
2. Scroll down to **Artifacts** section
3. Download `app-release-unsigned.apk`
4. This APK can be installed on Android devices for testing

## 👥 Add Collaborators

### For Your Friend

1. Go to repository **Settings**
2. Click **Collaborators** (left sidebar)
3. Click **Add people**
4. Enter your friend's GitHub username
5. Select permission level:
   - **Write**: Can push directly (recommended for close collaboration)
   - **Maintain**: Can manage issues/PRs but not change settings
6. Click **Add [username] to this repository**

Your friend will receive an email invitation.

### For Your Friend to Accept

1. Check email for invitation
2. Click **Accept invitation** link
3. Clone the repository:
   ```powershell
   git clone https://github.com/YOUR_USERNAME/REPO_NAME.git
   cd REPO_NAME
   flutter pub get
   dart run build_runner build --delete-conflicting-outputs
   ```

## 🔄 Workflow for Collaboration

### Making Changes

```powershell
# Create a feature branch
git checkout -b feature/my-feature

# Make changes, then commit
git add .
git commit -m "feat: add my feature"

# Push branch
git push origin feature/my-feature
```

### Creating Pull Request

1. Go to repository on GitHub
2. Click **Pull requests** tab
3. Click **New pull request**
4. Select your branch
5. Add description
6. Click **Create pull request**
7. Wait for CI to pass
8. Request review or merge

### Syncing with Main

```powershell
# Switch to main branch
git checkout main

# Pull latest changes
git pull origin main

# Switch back to your branch
git checkout feature/my-feature

# Merge main into your branch
git merge main
```

## 📦 CI Artifacts

Every push to `main` or any PR will:
1. Run `flutter pub get`
2. Generate Drift code
3. Build release APK (unsigned)
4. Upload APK as artifact

**To download artifacts:**
1. Go to **Actions** tab
2. Click on any completed workflow run
3. Scroll to **Artifacts** section
4. Download `app-release-unsigned`

## 🔐 Security Notes

### What's Safe to Commit
- ✅ Source code
- ✅ `pubspec.yaml`
- ✅ Sample/template files (`*.sample`)
- ✅ README and documentation
- ✅ CI/CD workflows

### What's NEVER Committed
- ❌ Signing keystores (`*.jks`, `*.keystore`)
- ❌ `key.properties` with passwords
- ❌ API keys or secrets
- ❌ `google-services.json` (if added later)
- ❌ Personal certificates

The `.gitignore` file already protects against these.

## 🐛 Troubleshooting

### CI Fails on First Run

**Problem:** Drift code generation fails

**Solution:** This is expected on first CI run. The workflow includes code generation step.

### Permission Denied on Push

**Problem:** `fatal: Authentication failed`

**Solution:** 
1. Use personal access token instead of password
2. Generate token at: https://github.com/settings/tokens
3. Use token as password when pushing

### Merge Conflicts

**Problem:** Can't merge branch due to conflicts

**Solution:**
```powershell
git checkout main
git pull origin main
git checkout your-branch
git merge main
# Resolve conflicts in editor
git add .
git commit -m "chore: resolve merge conflicts"
git push
```

## 📱 Testing Unsigned APK

The CI-built APK is unsigned but can still be installed for testing:

1. Download APK from Actions artifacts
2. Transfer to Android device
3. Enable "Install unknown apps" in device settings
4. Install APK
5. Test the app

For production/Play Store, you'll need to sign the APK locally with your keystore.

## 🎉 You're All Set!

Your repository is now:
- ✅ Safely configured with proper `.gitignore`
- ✅ No secrets committed
- ✅ CI/CD pipeline running
- ✅ Ready for collaboration
- ✅ Builds verified on every push

Happy coding! 🚀

