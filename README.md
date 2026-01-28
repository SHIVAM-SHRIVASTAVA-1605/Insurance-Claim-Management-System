# Insurance Claim Management System

A comprehensive Flutter application for managing hospital insurance claims with an intuitive UI and complete workflow management.

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)

## 🎯 Features

### Core Functionality
- ✅ **Patient Claim Management**: Create, edit, and delete insurance claims
- ✅ **Bill Management**: Add, edit, and delete bills for each claim
- ✅ **Financial Tracking**: Track advances, settlements, and pending amounts
- ✅ **Status Workflow**: Complete claim status lifecycle management
  - Draft → Submitted → Approved/Rejected → Partially Settled
- ✅ **Automatic Calculations**: Real-time calculation of totals and pending amounts
- ✅ **Dashboard View**: Comprehensive overview of all claims with statistics

### Status Transitions
The application implements a robust status workflow:
1. **Draft**: Initial claim creation stage
2. **Submitted**: Claim submitted for review
3. **Approved/Rejected**: Insurance company decision
4. **Partially Settled**: Partial payment made (from Approved status)

### Business Logic
- Automatic calculation of:
  - Total bill amount (sum of all bills)
  - Total paid (advances + settlements)
  - Pending amount (total - paid)
- Status-based transitions with validation
- Bill categorization (Accommodation, Surgery, Diagnostics, etc.)

## 🏗️ Architecture

### Project Structure
```
lib/
├── models/
│   ├── claim.dart           # Claim data model
│   ├── bill.dart            # Bill data model
│   └── claim_status.dart    # Status enumeration
├── providers/
│   └── claim_provider.dart  # State management
├── screens/
│   ├── dashboard_screen.dart         # Main dashboard
│   ├── claim_detail_screen.dart      # Claim details
│   ├── add_edit_claim_screen.dart    # Create/Edit claim
│   └── add_edit_bill_screen.dart     # Add/Edit bills
└── main.dart                # App entry point
```

### State Management
- **Provider Pattern**: Used for efficient state management
- **ChangeNotifier**: For reactive UI updates
- **Centralized State**: Single source of truth for all claims

### Design Patterns
- Repository pattern for data operations
- Factory pattern for model creation
- Observer pattern through Provider

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (>=3.5.3)
- Dart SDK
- A code editor (VS Code recommended)

### Installation

1. Clone the repository:
```bash
git clone <your-repo-url>
cd insurance_claim_management
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the application:

**For Web:**
```bash
flutter run -d chrome
```

**For Mobile:**
```bash
flutter run
```

### Building for Production

**Web Build:**
```bash
flutter build web
```

**Android APK:**
```bash
flutter build apk --release
```

**iOS:**
```bash
flutter build ios --release
```

## 📱 Screenshots & Usage

### Dashboard
- View all claims at a glance
- See statistics (total claims, pending, approved)
- View total claim amounts and pending amounts
- Quick access to create new claims

### Claim Details
- Complete patient and hospital information
- Financial summary with breakdown
- Status transition buttons
- Add/edit/delete bills
- Update advances and settlements

### Add/Edit Claim
- Patient name and ID
- Hospital name
- Admission and discharge dates
- Form validation

### Bill Management
- Description and amount
- Category selection (10+ categories)
- Date picker
- Automatic total calculation

## 🌐 Deployment

### Web Deployment Options

#### 1. Firebase Hosting (Recommended)
```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login

# Initialize Firebase
firebase init hosting

# Deploy
firebase deploy
```

#### 2. GitHub Pages
```bash
# Build the web app
flutter build web --base-href "/insurance_claim_management/"

# Copy build/web contents to gh-pages branch
```

#### 3. Netlify
```bash
# Install Netlify CLI
npm install -g netlify-cli

# Deploy
netlify deploy --dir=build/web --prod
```

#### 4. Vercel
```bash
# Install Vercel CLI
npm install -g vercel

# Deploy
vercel --prod
```

## 🔧 Configuration

### Web Configuration
The app is pre-configured for web deployment. The build output is in `build/web/`.

### Customization
- Colors and theme: Edit `lib/main.dart` ThemeData
- Sample data: Modify `lib/providers/claim_provider.dart` initializeSampleData()
- Bill categories: Update `lib/screens/add_edit_bill_screen.dart` categories list

## 📊 Data Models

### Claim Model
```dart
- id: String (UUID)
- patientName: String
- patientId: String
- hospitalName: String
- admissionDate: DateTime
- dischargeDate: DateTime?
- status: ClaimStatus
- bills: List<Bill>
- advances: double
- settlements: double
- createdAt: DateTime
- updatedAt: DateTime
```

### Bill Model
```dart
- id: String (UUID)
- description: String
- amount: double
- date: DateTime
- category: String
```

## 🎨 UI/UX Features

- **Material Design 3**: Modern, consistent design language
- **Responsive Layout**: Works on mobile, tablet, and desktop
- **Color-coded Status**: Easy visual identification of claim status
- **Indian Currency Format**: ₹ symbol with proper formatting
- **Intuitive Navigation**: Easy to navigate between screens
- **Validation**: Form validation for all inputs
- **Confirmation Dialogs**: Prevent accidental deletions
- **Success Feedback**: SnackBar notifications for user actions

## 🧪 Testing

Run tests:
```bash
flutter test
```

## 📦 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.1.1      # State management
  uuid: ^4.3.3          # Unique ID generation
  intl: ^0.19.0         # Date and number formatting
  cupertino_icons: ^1.0.8
```

## 🔐 Security Notes

- This is a demo application with in-memory data storage
- For production use:
  - Implement secure backend API
  - Add authentication and authorization
  - Use encrypted storage
  - Implement data validation
  - Add audit logging

## 🤝 Contributing

This is an assignment project. For educational purposes, feel free to fork and modify.

## 📝 License

This project is created as part of a Flutter internship assignment.

## 👨‍💻 Development

### Code Quality
- Follows Flutter best practices
- Clean code architecture
- Proper error handling
- Type-safe Dart code
- Null safety enabled

### Performance
- Efficient state management
- Optimized widget rebuilds
- Lazy loading where applicable
- Tree-shaking enabled for web

## 📞 Support

For questions or issues, please create an issue in the repository.

## 🎓 Learning Resources

This project demonstrates:
- Flutter state management with Provider
- CRUD operations
- Form handling and validation
- Navigation and routing
- Date and currency formatting
- Material Design 3 implementation
- Responsive UI design
- Business logic implementation

## 🚢 Deployment Checklist

- [x] Flutter web build completed
- [ ] Choose hosting platform (Firebase/Netlify/Vercel/GitHub Pages)
- [ ] Set up deployment pipeline
- [ ] Test on multiple browsers
- [ ] Configure custom domain (optional)
- [ ] Enable HTTPS
- [ ] Add analytics (optional)
- [ ] Monitor performance

## 📈 Future Enhancements

Potential features for production version:
- Backend API integration
- Database persistence (Firebase/PostgreSQL)
- User authentication
- PDF report generation
- Email notifications
- Document upload (bills, prescriptions)
- Search and filter functionality
- Export to Excel/CSV
- Multi-language support
- Dark mode
- Push notifications

---

**Built with ❤️ using Flutter**
