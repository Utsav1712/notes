# Notes App - Flutter + Supabase

A simple and elegant notes application built with Flutter and Supabase, demonstrating authentication, CRUD operations, and search functionality.

## 📱 Features

- **Authentication**
  - Email & password sign up
  - Login with session persistence
  - Secure logout
  - Auto-login on app restart

- **Notes Management**
  - Create notes with title and content
  - Edit existing notes
  - Delete notes with confirmation
  - View all your notes in a clean list

- **Search**
  - Real-time search by note title
  - Client-side filtering for instant results

- **Security**
  - Row Level Security (RLS) ensures users only see their own notes
  - Secure authentication with Supabase Auth

## 🛠 Tech Stack

- **Flutter** - UI framework
- **Supabase** - Backend (Authentication + PostgreSQL database)
- **Provider** - State management
- **Material Design 3** - UI design system

## 📋 Prerequisites

Before you begin, ensure you have:

- Flutter SDK (3.0.0 or higher) installed
- Android Studio or VS Code with Flutter extensions
- A Supabase account (free tier works fine)
- Android device or emulator for testing

## 🚀 Setup Instructions

### 1. Clone the Repository

```bash
git clone <your-repository-url>
cd notes_app
```

### 2. Install Dependencies

```bash
flutter pub get
```

### 3. Set Up Supabase

#### Create a Supabase Project

1. Go to [supabase.com](https://supabase.com) and sign in
2. Click "New Project"
3. Fill in your project details
4. Wait for the project to be created

#### Create the Notes Table

1. In your Supabase dashboard, go to the **SQL Editor**
2. Run the following SQL script:

```sql
-- Create notes table
CREATE TABLE notes (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE notes ENABLE ROW LEVEL SECURITY;

-- Create policies for user isolation
CREATE POLICY "Users can view own notes"
  ON notes FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can create own notes"
  ON notes FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own notes"
  ON notes FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own notes"
  ON notes FOR DELETE
  USING (auth.uid() = user_id);

-- Create indexes for performance
CREATE INDEX notes_user_id_idx ON notes(user_id);
CREATE INDEX notes_created_at_idx ON notes(created_at DESC);
```

#### Get Your Supabase Credentials

1. In your Supabase dashboard, go to **Settings** → **API**
2. Copy your **Project URL**
3. Copy your **anon public** key

### 4. Configure the App

Open `lib/services/supabase_service.dart` and replace the placeholders:

```dart
static const String supabaseUrl = 'YOUR_SUPABASE_URL';
static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
```

Replace `YOUR_SUPABASE_URL` and `YOUR_SUPABASE_ANON_KEY` with the values you copied.

### 5. Run the App

```bash
flutter run
```

The app will launch on your connected device or emulator.

## 📦 Building the APK

### Debug APK (Recommended for Testing)

```bash
flutter build apk --debug
```

The APK will be generated at:
```
build/app/outputs/flutter-apk/app-debug.apk
```

### Release APK

```bash
flutter build apk --release
```

The APK will be generated at:
```
build/app/outputs/flutter-apk/app-release.apk
```

### Install APK on Device

```bash
# Connect your Android device via USB or start an emulator
adb install build/app/outputs/flutter-apk/app-debug.apk
```

## 🗄 Database Schema

### Notes Table

| Column | Type | Description |
|--------|------|-------------|
| `id` | UUID | Primary key, auto-generated |
| `user_id` | UUID | Foreign key to auth.users, identifies note owner |
| `title` | TEXT | Note title |
| `content` | TEXT | Note content |
| `created_at` | TIMESTAMP | Creation timestamp |
| `updated_at` | TIMESTAMP | Last update timestamp |

### Row Level Security (RLS)

The `notes` table has RLS enabled with the following policies:

- **SELECT**: Users can only view their own notes (`auth.uid() = user_id`)
- **INSERT**: Users can only create notes for themselves
- **UPDATE**: Users can only update their own notes
- **DELETE**: Users can only delete their own notes

This ensures complete data isolation between users.

## 🔐 Authentication Approach

### Implementation

- **Supabase Auth** handles all authentication logic
- Email/password authentication is used
- Session tokens are stored securely by the Supabase Flutter SDK
- Sessions persist across app restarts using secure storage

### Flow

1. **Sign Up**: User creates account → Supabase creates user → Auto-login
2. **Login**: User enters credentials → Supabase validates → Session created
3. **Session Persistence**: On app restart → Check for existing session → Auto-login if valid
4. **Logout**: Clear session → Redirect to login screen

### Security

- Passwords are hashed by Supabase (never stored in plain text)
- Session tokens are stored securely
- All API calls include authentication headers automatically

## 🔍 Search Implementation

### Approach

- **Client-side search** using Dart's `where()` method
- Real-time filtering as user types
- Case-insensitive search on note titles

### Why Client-Side?

- Instant results (no network latency)
- Simple implementation
- Sufficient for typical note counts
- No additional backend queries needed

### Trade-off

For apps with thousands of notes, server-side search with full-text search would be more efficient.

## 📁 Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/
│   └── note_model.dart      # Note data model
├── providers/
│   ├── auth_provider.dart   # Authentication state management
│   └── notes_provider.dart  # Notes CRUD & search logic
├── services/
│   └── supabase_service.dart # Supabase client singleton
├── screens/
│   ├── splash_screen.dart   # Initial loading screen
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── signup_screen.dart
│   └── notes/
│       ├── notes_list_screen.dart
│       ├── create_note_screen.dart
│       └── note_detail_screen.dart
└── widgets/
    └── note_card.dart       # Reusable note card widget
```

## 🎯 Assumptions & Trade-offs

### Assumptions

1. Users will have a stable internet connection (no offline mode)
2. Note count per user will be reasonable (< 1000 notes)
3. Email verification is not required for this demo
4. Debug APK is acceptable for submission

### Trade-offs

| Decision | Reason | Alternative |
|----------|--------|-------------|
| Provider for state management | Simple, built-in, easy to understand | Riverpod/Bloc (more complex but scalable) |
| Client-side search | Instant results, simple implementation | Server-side search (better for large datasets) |
| No offline support | Reduces complexity, meets requirements | Local database + sync (complex) |
| Debug APK | Quick to build, no signing required | Release APK (requires keystore setup) |
| Material Design 3 | Modern, clean, built-in | Custom design (more time-consuming) |

## 🧪 Testing

### Manual Testing Checklist

- [x] Sign up with new account
- [x] Login with existing account
- [x] Session persists after app restart
- [x] Create a new note
- [x] Edit an existing note
- [x] Delete a note
- [x] Search notes by title
- [x] Logout functionality
- [x] User isolation (different users can't see each other's notes)

### Test Accounts

You can create test accounts with any email format:
- `test1@example.com` / `password123`
- `test2@example.com` / `password123`

## 🐛 Troubleshooting

### "Invalid API credentials" error

- Verify your Supabase URL and anon key are correct in `supabase_service.dart`
- Check that you copied the **anon public** key, not the service role key

### "Table 'notes' does not exist" error

- Make sure you ran the SQL script in your Supabase dashboard
- Verify the table was created in the **Table Editor**

### Build errors

```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter build apk --debug
```

### Session not persisting

- Check that your Supabase project is active
- Verify internet connection
- Try logging out and logging in again

## 📝 License

This project is created for educational and evaluation purposes.

## 👤 Author

Created as part of a Flutter Developer technical assignment.

---

**Note**: Remember to replace the Supabase credentials in `lib/services/supabase_service.dart` before running the app!
