# Quick Start Guide

## 🚀 Get Started in 5 Minutes

### Step 1: Set Up Supabase (2 minutes)

1. Go to [supabase.com](https://supabase.com) and create a free account
2. Create a new project
3. In the SQL Editor, run this script:

```sql
CREATE TABLE notes (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  content TEXT NOT NULL,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

ALTER TABLE notes ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own notes" ON notes FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can create own notes" ON notes FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own notes" ON notes FOR UPDATE USING (auth.uid() = user_id);
CREATE POLICY "Users can delete own notes" ON notes FOR DELETE USING (auth.uid() = user_id);

CREATE INDEX notes_user_id_idx ON notes(user_id);
CREATE INDEX notes_created_at_idx ON notes(created_at DESC);
```

4. Go to Settings → API and copy:
   - Project URL
   - anon public key

### Step 2: Configure the App (1 minute)

1. Open `lib/services/supabase_service.dart`
2. Replace these lines:

```dart
static const String supabaseUrl = 'YOUR_SUPABASE_URL';
static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
```

With your actual credentials:

```dart
static const String supabaseUrl = 'https://xxxxx.supabase.co';
static const String supabaseAnonKey = 'eyJhbGci...';
```

### Step 3: Run the App (2 minutes)

```bash
cd notes_app
flutter pub get
flutter run
```

That's it! 🎉

## 📱 Test the App

1. **Sign up**: Create account with any email (e.g., `test@example.com`)
2. **Create note**: Tap the + button
3. **Search**: Type in the search bar
4. **Edit**: Tap any note to edit
5. **Delete**: Tap delete button in note detail

## 📦 Build APK

Already built! Find it at:
```
build/app/outputs/flutter-apk/app-debug.apk
```

To rebuild:
```bash
flutter build apk --debug
```

## 🆘 Troubleshooting

**"Invalid API credentials"**
- Double-check your Supabase URL and key in `supabase_service.dart`

**"Table does not exist"**
- Make sure you ran the SQL script in Supabase

**Build errors**
```bash
flutter clean
flutter pub get
flutter build apk --debug
```

## 📚 Full Documentation

See `README.md` for complete setup instructions and `SUPABASE_SETUP.md` for detailed Supabase configuration.

---

**Ready to submit!** ✅
- APK: `build/app/outputs/flutter-apk/app-debug.apk`
- All features working
- Documentation complete
