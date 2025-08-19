# Profile Component Documentation

## Overview

The `ProfileComponent` is a unified, reusable component that handles all profile scenarios in the sociord app:

1. **Logged-in user's own profile** (Explorer or Creator)
2. **Other user's buddy profile** (Explorer)
3. **Other user's creator profile** (Creator)

## Components Structure

```
lib/widgets/profile/
├── profile_component.dart      # Main unified component
├── profile_banner.dart         # Congratulatory/CTA banner
├── profile_hero.dart          # Main profile info & actions
├── profile_highlight.dart     # Highlights/Showcase section
├── profile_posts.dart         # Tabbed content (posts/clips)
└── README.md                  # This documentation
```

## Usage Examples

### 1. Own Creator Profile

```dart
final userData = ProfileData(
  imageUrl: kProfilePic,
  name: 'Arjun Sethi',
  gender: 'Male',
  age: 'Millennial',
  location: 'Mumbai, India',
  handle: '@arjun.sethi',
  buddies: 0,
  subscriptions: 0,
  following: 0,
  creatorCategory: 'Travel & Adventure',
);

ProfileComponent(
  userType: UserType.creator,
  viewType: ProfileViewType.own,
  relationship: RelationshipType.none,
  userData: userData,
  onEditProfilePressed: () => navigateToEditProfile(),
  onSettingsPressed: () => navigateToSettings(),
)
```

### 2. Other User's Buddy Profile

```dart
ProfileComponent(
  userType: UserType.explorer,
  viewType: ProfileViewType.other,
  relationship: RelationshipType.buddy,
  userData: userData,
  onBackPressed: () => Navigator.pop(context),
  onMessagePressed: () => navigateToChat(),
  onSharePressed: () => shareProfile(),
)
```

### 3. Other User's Creator Profile (Not Subscribed)

```dart
ProfileComponent(
  userType: UserType.creator,
  viewType: ProfileViewType.other,
  relationship: RelationshipType.none,
  userData: userData,
  onBackPressed: () => Navigator.pop(context),
  onSubscribePressed: () => subscribeToCreator(),
  onMessagePressed: () => navigateToChat(),
  onSharePressed: () => shareProfile(),
)
```

### 4. Other User's Creator Profile (Subscribed)

```dart
ProfileComponent(
  userType: UserType.creator,
  viewType: ProfileViewType.other,
  relationship: RelationshipType.subscribed,
  userData: userData,
  onBackPressed: () => Navigator.pop(context),
  onSubscribePressed: () => unsubscribeFromCreator(),
  onMessagePressed: () => navigateToChat(),
  onSharePressed: () => shareProfile(),
)
```

## Key Features

### 🔄 **Flexible User Types**

- **Explorer**: Regular users with uploads and tagged content
- **Creator**: Content creators with quickies, clips, and collections

### 👤 **Profile View Types**

- **Own**: User's own profile with edit options
- **Other**: Viewing someone else's profile

### 🤝 **Relationship Types**

- **None**: No relationship established
- **Buddy**: Explorer-to-Explorer relationship
- **Following**: Following a creator
- **Subscribed**: Subscribed to a creator

### 🎯 **Dynamic Actions**

- **Own Profile**: Edit Profile, Become Creator, Settings
- **Other Explorer**: Add Buddy, Message
- **Other Creator**: Subscribe/Unsubscribe, Message

### 📱 **Conditional UI Elements**

- Banner only shows for own profile
- Different action buttons based on relationship
- Back button for other profiles
- Different tab content for Explorers vs Creators

## Data Model

### ProfileData

```dart
class ProfileData {
  final String imageUrl;
  final String name;
  final String gender;
  final String age;
  final String location;
  final String handle;
  final int buddies;
  final int subscriptions;
  final int following;
  final String? creatorCategory;
  final bool isVerified;
}
```

## Enums

### UserType

```dart
enum UserType { explorer, creator }
```

### ProfileViewType

```dart
enum ProfileViewType { own, other }
```

### RelationshipType

```dart
enum RelationshipType { none, buddy, following, subscribed }
```

## Callbacks

All callbacks are optional and can be customized based on your needs:

- `onBackPressed`: Navigation back
- `onSettingsPressed`: Open settings
- `onEditProfilePressed`: Edit profile
- `onAddBuddyPressed`: Add as buddy
- `onFollowPressed`: Follow creator
- `onSubscribePressed`: Subscribe/unsubscribe
- `onMessagePressed`: Open chat
- `onSharePressed`: Share profile

## Migration from Old Components

The old individual components (`ProfileBanner`, `ProfileHero`, etc.) are still available and used internally by `ProfileComponent`. You can gradually migrate existing screens to use the unified component.

### Before (Old Way)

```dart
Scaffold(
  appBar: AppBar(...),
  body: Column(
    children: [
      ProfileBanner(...),
      ProfileHero(...),
      ProfileHighlight(...),
      ProfilePosts(...),
    ],
  ),
)
```

### After (New Way)

```dart
ProfileComponent(
  userType: UserType.creator,
  viewType: ProfileViewType.own,
  relationship: RelationshipType.none,
  userData: userData,
  // ... callbacks
)
```

## Benefits

1. **Consistency**: Same UI across all profile scenarios
2. **Maintainability**: Single component to update
3. **Flexibility**: Easy to add new user types or relationships
4. **Reusability**: Use anywhere in the app
5. **Type Safety**: Strong typing with enums
6. **Performance**: Optimized rendering based on view type
