# Supabase Setup Guide

This guide will walk you through setting up Supabase for the Notes App.

## Step 1: Create Supabase Account

1. Go to [https://supabase.com](https://supabase.com)
2. Click "Start your project"
3. Sign up with GitHub, Google, or email

## Step 2: Create a New Project

1. Click "New Project" in your dashboard
2. Fill in the details:
   - **Name**: notes-app (or any name you prefer)
   - **Database Password**: Create a strong password (save it somewhere safe)
   - **Region**: Choose the closest region to you
   - **Pricing Plan**: Free tier is sufficient
3. Click "Create new project"
4. Wait 2-3 minutes for the project to be provisioned

## Step 3: Create the Database Table

1. In your project dashboard, click on the **SQL Editor** icon in the left sidebar
2. Click "New Query"
3. Copy and paste the following SQL script:

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

4. Click "Run" or press `Ctrl+Enter` (Windows/Linux) / `Cmd+Enter` (Mac)
5. You should see "Success. No rows returned"

## Step 4: Verify Table Creation

1. Click on the **Table Editor** icon in the left sidebar
2. You should see a table named "notes"
3. Click on it to view the structure
4. Verify all columns are present: id, user_id, title, content, created_at, updated_at

## Step 5: Get Your API Credentials

1. Click on the **Settings** icon (gear icon) in the left sidebar
2. Click on **API** in the settings menu
3. You'll see two important values:

   **Project URL**
   ```
   https://xxxxxxxxxxxxx.supabase.co
   ```
   
   **anon public key**
   ```
   eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
   ```

4. Copy both values

## Step 6: Configure the Flutter App

1. Open the file `lib/services/supabase_service.dart`
2. Find these lines:

```dart
static const String supabaseUrl = 'YOUR_SUPABASE_URL';
static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';
```

3. Replace them with your actual values:

```dart
static const String supabaseUrl = 'https://xxxxxxxxxxxxx.supabase.co';
static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...';
```

4. Save the file

## Step 7: Enable Email Authentication (Optional)

By default, Supabase allows email/password authentication. If you want to customize it:

1. Go to **Authentication** → **Providers** in your Supabase dashboard
2. Make sure **Email** is enabled
3. You can disable "Confirm email" for testing purposes

## Step 8: Test the Setup

1. Run the Flutter app:
   ```bash
   flutter run
   ```

2. Try to sign up with a test account:
   - Email: `test@example.com`
   - Password: `Test123!`

3. If successful, you should be logged in and see the notes list screen

4. Verify in Supabase:
   - Go to **Authentication** → **Users** in your dashboard
   - You should see your test user listed

## Troubleshooting

### "Invalid API credentials" error

- Double-check that you copied the **anon public** key, not the service_role key
- Make sure there are no extra spaces in the URL or key
- Verify the URL starts with `https://` and ends with `.supabase.co`

### "relation 'notes' does not exist" error

- Go back to the SQL Editor and run the table creation script again
- Check the Table Editor to verify the table exists

### Can't sign up users

- Go to **Authentication** → **Providers** and make sure Email is enabled
- Check if you have any custom email templates that might be causing issues

## Security Notes

⚠️ **Important**: 
- Never commit your Supabase credentials to a public repository
- The `anon public` key is safe to use in client-side code (it's designed for that)
- Row Level Security (RLS) policies protect your data even if someone has the anon key
- For production apps, consider adding email verification

## Next Steps

Once setup is complete:
1. Test all features (create, edit, delete notes)
2. Test with multiple users to verify isolation
3. Build the APK: `flutter build apk --debug`
4. Test the APK on a real device

---

**Need Help?**
- Supabase Documentation: https://supabase.com/docs
- Supabase Discord: https://discord.supabase.com
