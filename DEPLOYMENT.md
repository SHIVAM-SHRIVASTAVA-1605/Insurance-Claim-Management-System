# Deployment Guide - Insurance Claim Management System

## Quick Deployment to Firebase Hosting

### Step 1: Prerequisites
- Flutter web build completed ✓
- Node.js and npm installed
- Firebase account created

### Step 2: Install Firebase CLI
```bash
npm install -g firebase-tools
```

### Step 3: Login to Firebase
```bash
firebase login
```

### Step 4: Initialize Firebase Project
```bash
cd /path/to/insurance_claim_management
firebase init hosting
```

Configuration options:
- Public directory: `build/web`
- Single-page app: Yes
- GitHub automatic builds: No (optional)

### Step 5: Deploy
```bash
firebase deploy --only hosting
```

Your app will be live at: `https://your-project-id.web.app`

---

## Alternative: GitHub Pages Deployment

### Step 1: Build for GitHub Pages
```bash
flutter build web --base-href "/insurance_claim_management/"
```

### Step 2: Create gh-pages branch
```bash
git checkout -b gh-pages
```

### Step 3: Copy build files
```bash
cp -r build/web/* .
git add .
git commit -m "Deploy to GitHub Pages"
git push origin gh-pages
```

### Step 4: Enable GitHub Pages
1. Go to repository Settings
2. Navigate to Pages section
3. Select gh-pages branch
4. Save

Live at: `https://yourusername.github.io/insurance_claim_management/`

---

## Alternative: Netlify Deployment

### Option A: Drag and Drop
1. Build: `flutter build web`
2. Go to https://app.netlify.com/drop
3. Drag `build/web` folder
4. Done!

### Option B: Netlify CLI
```bash
npm install -g netlify-cli
netlify deploy --dir=build/web --prod
```

---

## Alternative: Vercel Deployment

### Step 1: Install Vercel CLI
```bash
npm install -g vercel
```

### Step 2: Deploy
```bash
vercel --prod
```

When prompted:
- Set up and deploy: Yes
- Project name: insurance-claim-management
- Directory: build/web

---

## Testing Your Deployment

### Checklist
- [ ] Homepage loads correctly
- [ ] Dashboard displays sample data
- [ ] Can create new claim
- [ ] Can add bills to claim
- [ ] Status transitions work
- [ ] Update advances/settlements work
- [ ] Can edit claim details
- [ ] Can delete claims and bills
- [ ] Responsive on mobile
- [ ] Works on different browsers (Chrome, Firefox, Safari, Edge)

### Browser Compatibility
Tested on:
- ✓ Chrome/Chromium
- ✓ Firefox
- ✓ Safari
- ✓ Edge

---

## Post-Deployment

### Custom Domain (Optional)
**Firebase:**
```bash
firebase hosting:channel:deploy preview
```

**Netlify:**
1. Go to Domain settings
2. Add custom domain
3. Configure DNS

### Analytics (Optional)
Add Google Analytics to track usage:
1. Create GA4 property
2. Add tracking code to `web/index.html`

### Performance Monitoring
- Use Lighthouse for performance audit
- Monitor loading times
- Check mobile responsiveness

---

## Troubleshooting

### Issue: White screen after deployment
**Solution:** Check browser console for errors, ensure base-href is correct

### Issue: 404 on refresh
**Solution:** Configure server for SPA routing
- Firebase: Already configured
- Netlify: Add `_redirects` file
- GitHub Pages: Use hash routing

### Issue: Assets not loading
**Solution:** Check base-href in build command and ensure all assets are included

---

## Environment-Specific Configuration

### Development
```bash
flutter run -d chrome
```

### Staging
```bash
flutter build web --dart-define=ENV=staging
firebase hosting:channel:deploy staging
```

### Production
```bash
flutter build web --release
firebase deploy --only hosting
```

---

## Security Recommendations

For production deployment:
1. Enable HTTPS (automatic on Firebase/Netlify/Vercel)
2. Add Content Security Policy
3. Implement rate limiting
4. Add authentication layer
5. Use environment variables for sensitive data
6. Enable CORS properly
7. Add security headers

---

## Monitoring

### Firebase Hosting
- View deployment history
- Check bandwidth usage
- Monitor errors in Firebase Console

### Performance
- Use web.dev/measure for performance insights
- Monitor Core Web Vitals
- Set up uptime monitoring

---

## Backup and Recovery

### Backup Strategy
- Keep source code in Git
- Tag releases
- Document configuration
- Save environment variables securely

### Rollback
**Firebase:**
```bash
firebase hosting:rollback
```

**Netlify:**
- Go to Deploys tab
- Select previous deploy
- Click "Publish deploy"

---

## Cost Estimate

### Firebase (Free Tier)
- Hosting: 10GB storage, 360MB/day transfer
- Perfect for this demo app

### Netlify (Free Tier)
- 100GB bandwidth/month
- Continuous deployment
- Ideal for small projects

### Vercel (Free Tier)
- 100GB bandwidth/month
- Unlimited deployments
- Great for demos

**All free tiers are sufficient for this assignment!**

---

## Next Steps

1. Deploy to your chosen platform
2. Test all functionality
3. Share the live link
4. Record video walkthrough
5. Submit GitHub repository

---

## Support

If you encounter issues:
1. Check deployment logs
2. Verify build output
3. Test locally first
4. Check platform-specific documentation
5. Review common issues above

---

**Your app is ready to deploy! Choose your platform and follow the steps above.**
