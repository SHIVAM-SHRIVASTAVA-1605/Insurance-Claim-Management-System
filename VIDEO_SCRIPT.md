# Video Walkthrough Script
## Insurance Claim Management System
**Duration: 2-3 minutes**

---

## Introduction (15 seconds)
"Hello! I'm demonstrating the Insurance Claim Management System, a Flutter web application for managing hospital insurance claims. This app handles the complete lifecycle of insurance claims from creation to settlement."

---

## Part 1: Dashboard Overview (30 seconds)

**Show Dashboard:**
"Starting with the dashboard, we can see:
- Total statistics: 3 claims with their statuses
- Financial summary showing total claim amount and pending amount
- All claims listed with patient details, hospital information, and status"

**Point out:**
- Color-coded status badges (Grey for Draft, Blue for Submitted, Green for Approved)
- Financial breakdown for each claim (Total, Paid, Pending)
- Clean, intuitive Material Design 3 interface

---

## Part 2: Creating a New Claim (30 seconds)

**Click "New Claim" button:**
"Let me create a new claim by clicking the floating action button."

**Fill the form:**
- Patient Name: "Sarah Williams"
- Patient ID: "P004"
- Hospital Name: "Apollo Hospital"
- Select Admission Date: [Select today's date]
- "Notice the form validation - all fields are required"

**Click "Create Claim":**
"The claim is created in Draft status and appears on the dashboard."

---

## Part 3: Claim Details & Bill Management (45 seconds)

**Click on the newly created claim:**
"Opening the claim details shows:
- Patient and hospital information at the top
- Financial summary - currently all zeros since we haven't added bills yet
- Status is Draft, so we can submit it for review"

**Add a Bill:**
- Click "Add Bill"
- Description: "MRI Scan"
- Amount: "15000"
- Category: "Diagnostics"
- Select Date: [Today]
- Click "Add Bill"

**Show updated totals:**
"Notice how the total bill amount automatically updates to ₹15,000, and the pending amount reflects this change immediately."

**Add another bill:**
- Click "Add Bill" again
- Description: "Consultation Fee"  
- Amount: "2000"
- Category: "Doctor Fee"
- Click "Add Bill"

**Point out:**
"Now total is ₹17,000. Each bill can be edited or deleted individually."

---

## Part 4: Financial Management (30 seconds)

**Update Advances:**
"Let's say an advance of ₹10,000 was paid."
- Click "Update Advances"
- Enter: 10000
- Click "Update"
- "See how the pending amount automatically recalculates to ₹7,000"

**Update Settlements:**
"Now let's add a settlement."
- Click "Update Settlements"
- Enter: 5000
- Click "Update"
- "Pending amount is now ₹2,000 (17,000 - 10,000 - 5,000)"

---

## Part 5: Status Workflow (25 seconds)

**Show Status Transitions:**
"The app implements a complete status workflow with business rules:

**From Draft:**
- Click "Mark as Submitted"
- Status changes to Submitted (blue badge)

**From Submitted:**
- Now we can approve or reject
- Click "Mark as Approved"
- Status changes to Approved (green badge)

**From Approved:**
- Click "Mark as Partially Settled"
- Status changes to Partially Settled (orange badge)

"Each status transition follows insurance claim workflow rules. For example, you can't go back from Rejected status."

---

## Part 6: Edit Functionality (15 seconds)

**Click Edit icon:**
"We can edit claim details anytime."
- Update patient name to "Sarah M. Williams"
- Click "Update Claim"
- "Changes are saved immediately"

**Edit a Bill:**
- Click edit on a bill
- Change amount from 15000 to 16000
- Click "Update Bill"
- "Notice total recalculates automatically to ₹18,000"

---

## Part 7: Delete Functionality (10 seconds)

**Delete a Bill:**
- Click delete icon on a bill
- Confirm deletion
- "Bill removed, totals update automatically"

**Show Delete Claim:**
"Claims can also be deleted with confirmation to prevent accidents."

---

## Conclusion (10 seconds)

**Navigate back to Dashboard:**
"Back on the dashboard, we can see all claims at a glance with their current status and financial information. The app provides:
- Complete CRUD operations for claims and bills
- Automatic financial calculations
- Status workflow management
- Responsive design that works on any device

This was built using Flutter with Provider for state management, following clean architecture principles. Thank you for watching!"

---

## Recording Tips

### Preparation
1. Reset app state or use fresh data
2. Have sample data ready to type
3. Test run the complete flow
4. Close unnecessary tabs/windows
5. Check audio quality

### During Recording
- Speak clearly and at moderate pace
- Avoid long pauses
- Show, don't just tell (click and demonstrate)
- Keep cursor movements smooth
- Stay within 3 minutes

### Screen Recording Tools
- **Windows**: OBS Studio, Xbox Game Bar
- **Mac**: QuickTime, Screenshot app
- **Linux**: SimpleScreenRecorder, OBS Studio
- **Cross-platform**: Loom, Zoom

### Video Editing (if needed)
- Cut out mistakes
- Add title slide (optional)
- Add timestamps (optional)
- Export as MP4, 1080p
- Keep file size under 100MB

### Upload Options
- YouTube (Public/Unlisted)
- Google Drive (Share link)
- Loom
- Vimeo

---

## Video Checklist

- [ ] Audio is clear
- [ ] Screen is fully visible
- [ ] Demonstrated all features:
  - [ ] Dashboard view
  - [ ] Create claim
  - [ ] Add/edit/delete bills
  - [ ] Update advances/settlements
  - [ ] Status transitions
  - [ ] Edit claim
  - [ ] Delete operations
- [ ] Video length 2-3 minutes
- [ ] Shows functionality clearly
- [ ] Explains business logic
- [ ] Link is accessible
- [ ] Link added to repository README

---

**Ready to record? Follow this script and showcase your amazing work!**
