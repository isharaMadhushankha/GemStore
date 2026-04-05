# GemStore

A Flutter marketplace app for listing, browsing, and booking gems, powered by Supabase Authentication, Database, and Storage.

## Overview

GemStore currently includes:

- Email/password authentication (login + sign up)
- Public gem marketplace feed with real-time updates
- Add, edit, and delete your own gem listings
- Gem detail view with booking request flow
- Orders management (sent and received tabs)
- Seller-side order confirmation/cancellation

## Tech Stack

- Flutter SDK: `^3.10.1`
- Dart SDK: `^3.10.1`
- Supabase Flutter: `^2.12.2`
- Image Picker: `^1.2.1`

## Project Structure

```text
lib/
  main.dart
  auth_screen.dart
  home_screen.dart
  add_gem_screen.dart
  edit_gem_screen.dart
  gem_detail_screen.dart
  orders_screen.dart
  utils/
    snackbar_utils.dart
  widgets/
    gem_dialog.dart
```

## App Flow

1. App starts and initializes Supabase (`main.dart`).
2. Session is checked:
   - If session exists -> Home screen
   - If no session -> Auth screen
3. Home screen shows live gem listings from `gems` table.
4. Users can:
   - Add a gem listing
   - Edit/delete own listings
   - Open gem details and place booking requests
5. Orders screen supports:
   - Sent requests (buyer view)
   - Received requests (seller view)
   - Confirm/cancel actions for sellers

## Features

### Authentication

- Single auth screen with tabs for Login and Register
- Supabase email/password sign-in and sign-up
- Logout from home screen

### Gem Listings

- Real-time list using Supabase stream
- Listing card includes image, name, price, and contact
- Owner controls: edit and delete

### Add/Edit Gem

- Pick image from gallery
- Upload image to Supabase Storage bucket: `images`
- Save or update listing in `gems`

### Gem Detail + Booking

- Detailed gem view with seller contact
- Optional booking message
- Booking request saved to `orders`

### Orders

- Two tabs:
  - `Sent`: buyer orders
  - `Received`: seller orders
- Seller can confirm or cancel pending orders
- Status banners/snackbars for order updates

## Supabase Setup

Supabase is initialized in `main.dart` using hardcoded URL and anon key.

Before running in production, you should move these values to a secure configuration strategy.

### Required Supabase resources

1. Auth enabled for email/password
2. Storage bucket:
   - `images` (public or properly policy-protected)
3. Database tables:
   - `gems`
   - `orders`

## Suggested Database Schema

Use this as a baseline schema compatible with current code.

```sql
create extension if not exists "pgcrypto";

create table if not exists public.gems (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null,
  gem_name text not null,
  price numeric not null default 0,
  contact_no text,
  image_url text,
  created_at timestamptz not null default now()
);

create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  gem_id uuid not null,
  buyer_id uuid not null,
  seller_id uuid not null,
  gem_name text,
  price numeric,
  contact_no text,
  image_url text,
  message text,
  status text not null default 'pending',
  created_at timestamptz not null default now()
);
```

## Getting Started

### 1. Install dependencies

```bash
flutter pub get
```

### 2. Run the app

```bash
flutter run
```

## Notes and Limitations

- Search field is currently UI-only (no filtering logic yet).
- There is no dedicated profile/favorites module in the current codebase.
- `orders` status handling expects values like `pending`, `confirmed`, and `cancelled`.

## Recommended Next Improvements

1. Move Supabase credentials to environment-based config.
2. Add Row Level Security (RLS) policies for `gems`, `orders`, and storage.
3. Implement real search/filter logic in home feed.
4. Add form validation and stronger input sanitization.
5. Add automated tests for auth, listing CRUD, and order workflow.

---

Version: `1.0.1`
Last updated: `2026-04-05`
Status: Active
