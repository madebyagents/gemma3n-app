# Style Guide
## Flutter Gemma 3N AI Chatbot App

### Design Philosophy
This app follows a clean, conversational design approach that prioritizes user experience and readability. The interface emphasizes simplicity, accessibility, and intuitive interaction patterns inspired by modern messaging applications.

---

## Visual Identity

### Brand Colors
```dart
// Primary Colors
static const Color primaryBlue = Color(0xFF007AFF);      // Main accent color
static const Color lightBlue = Color(0xFFE3F2FD);       // Message bubbles (user)
static const Color backgroundGray = Color(0xFFF5F5F5);   // App background

// Secondary Colors
static const Color darkGray = Color(0xFF2C2C2E);        // Text primary
static const Color mediumGray = Color(0xFF8E8E93);      // Text secondary
static const Color lightGray = Color(0xFFE5E5EA);       // AI message bubbles
static const Color white = Color(0xFFFFFFFF);           // Cards, input fields

// System Colors
static const Color success = Color(0xFF34C759);         // Success states
static const Color warning = Color(0xFFFF9500);         // Warning states
static const Color error = Color(0xFFFF3B30);           // Error states
```

### Typography
```dart
// Text Styles
static const TextStyle headingLarge = TextStyle(
  fontSize: 28,
  fontWeight: FontWeight.w700,
  color: darkGray,
  letterSpacing: -0.5,
);

static const TextStyle headingMedium = TextStyle(
  fontSize: 20,
  fontWeight: FontWeight.w600,
  color: darkGray,
  letterSpacing: -0.3,
);

static const TextStyle bodyLarge = TextStyle(
  fontSize: 17,
  fontWeight: FontWeight.w400,
  color: darkGray,
  lineHeight: 1.4,
);

static const TextStyle bodyMedium = TextStyle(
  fontSize: 15,
  fontWeight: FontWeight.w400,
  color: darkGray,
  lineHeight: 1.3,
);

static const TextStyle caption = TextStyle(
  fontSize: 13,
  fontWeight: FontWeight.w400,
  color: mediumGray,
  letterSpacing: 0.1,
);

static const TextStyle buttonText = TextStyle(
  fontSize: 17,
  fontWeight: FontWeight.w600,
  color: white,
);
```

---

## Layout & Spacing

### Grid System
- **Base Unit**: 8px
- **Content Margins**: 16px (2 units)
- **Section Spacing**: 24px (3 units)
- **Component Spacing**: 12px (1.5 units)
- **Element Spacing**: 8px (1 unit)

### Screen Layout
```dart
// Layout Constants
static const double screenPadding = 16.0;
static const double sectionSpacing = 24.0;
static const double componentSpacing = 12.0;
static const double elementSpacing = 8.0;

// Chat Specific
static const double messageSpacing = 8.0;
static const double messagePadding = 16.0;
static const double maxMessageWidth = 280.0;
```

---

## Component Specifications

### 1. App Bar
```dart
AppBar(
  backgroundColor: Colors.white,
  elevation: 0,
  centerTitle: true,
  title: Text(
    'Gemma Assistant',
    style: TextStyle(
      fontSize: 17,
      fontWeight: FontWeight.w600,
      color: Color(0xFF2C2C2E),
    ),
  ),
  leading: IconButton(
    icon: Icon(Icons.menu, color: Color(0xFF2C2C2E)),
    onPressed: () {},
  ),
  actions: [
    IconButton(
      icon: Icon(Icons.more_horiz, color: Color(0xFF2C2C2E)),
      onPressed: () {},
    ),
  ],
)
```

### 2. Message Bubbles

#### User Messages (Right-aligned, Blue)
```dart
Container(
  margin: EdgeInsets.only(left: 60, bottom: 8),
  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  decoration: BoxDecoration(
    color: Color(0xFF007AFF),
    borderRadius: BorderRadius.only(
      topLeft: Radius.circular(20),
      topRight: Radius.circular(20),
      bottomLeft: Radius.circular(20),
      bottomRight: Radius.circular(4),
    ),
  ),
  child: Text(
    message,
    style: TextStyle(
      fontSize: 16,
      color: Colors.white,
      height: 1.3,
    ),
  ),
)
```

#### AI Messages (Left-aligned, Gray)
```dart
Row(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Container(
      width: 32,
      height: 32,
      margin: EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: Color(0xFF2C2C2E),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.psychology,
        color: Colors.white,
        size: 18,
      ),
    ),
    Expanded(
      child: Container(
        margin: EdgeInsets.only(right: 60, bottom: 8),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Color(0xFFE5E5EA),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(20),
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        child: Text(
          message,
          style: TextStyle(
            fontSize: 16,
            color: Color(0xFF2C2C2E),
            height: 1.3,
          ),
        ),
      ),
    ),
  ],
)
```

### 3. Input Field
```dart
Container(
  margin: EdgeInsets.all(16),
  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(24),
    border: Border.all(color: Color(0xFFE5E5EA)),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.05),
        blurRadius: 10,
        offset: Offset(0, 2),
      ),
    ],
  ),
  child: Row(
    children: [
      IconButton(
        icon: Icon(Icons.add, color: Color(0xFF8E8E93)),
        onPressed: () {},
      ),
      Expanded(
        child: TextField(
          decoration: InputDecoration(
            hintText: 'Ask anything...',
            hintStyle: TextStyle(
              color: Color(0xFF8E8E93),
              fontSize: 16,
            ),
            border: InputBorder.none,
          ),
        ),
      ),
      IconButton(
        icon: Icon(Icons.mic, color: Color(0xFF8E8E93)),
        onPressed: () {},
      ),
      IconButton(
        icon: Icon(Icons.send, color: Color(0xFF007AFF)),
        onPressed: () {},
      ),
    ],
  ),
)
```

### 4. Suggestion Chips
```dart
Container(
  margin: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  decoration: BoxDecoration(
    color: Color(0xFFE3F2FD),
    borderRadius: BorderRadius.circular(20),
    border: Border.all(color: Color(0xFFBBDEFB), width: 0.5),
  ),
  child: Text(
    'Suggest',
    style: TextStyle(
      fontSize: 14,
      color: Color(0xFF1976D2),
      fontWeight: FontWeight.w500,
    ),
  ),
)
```

### 5. Loading States
```dart
// Typing Indicator
Container(
  margin: EdgeInsets.only(right: 60, bottom: 8),
  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  decoration: BoxDecoration(
    color: Color(0xFFE5E5EA),
    borderRadius: BorderRadius.only(
      topLeft: Radius.circular(4),
      topRight: Radius.circular(20),
      bottomLeft: Radius.circular(20),
      bottomRight: Radius.circular(20),
    ),
  ),
  child: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF8E8E93)),
        ),
      ),
      SizedBox(width: 8),
      Text(
        'Thinking...',
        style: TextStyle(
          fontSize: 16,
          color: Color(0xFF8E8E93),
          fontStyle: FontStyle.italic,
        ),
      ),
    ],
  ),
)
```

---

## Interaction Patterns

### Animation Specifications
```dart
// Standard Durations
static const Duration fastAnimation = Duration(milliseconds: 150);
static const Duration normalAnimation = Duration(milliseconds: 250);
static const Duration slowAnimation = Duration(milliseconds: 400);

// Curves
static const Curve standardCurve = Curves.easeInOut;
static const Curve bounceCurve = Curves.elasticOut;
static const Curve smoothCurve = Curves.decelerate;
```

### Touch Targets
- **Minimum Size**: 44x44px (iOS standard)
- **Button Height**: 44px minimum
- **Icon Buttons**: 44x44px
- **Text Fields**: 44px minimum height

### Feedback Patterns
- **Haptic Feedback**: Light impact for button taps
- **Visual Feedback**: 0.95 scale transform on press
- **Loading States**: Show immediate feedback for user actions

---

## Dark Mode Support

### Dark Theme Colors
```dart
// Dark Mode Palette
static const Color darkBackground = Color(0xFF000000);
static const Color darkSurface = Color(0xFF1C1C1E);
static const Color darkCard = Color(0xFF2C2C2E);
static const Color darkText = Color(0xFFFFFFFF);
static const Color darkTextSecondary = Color(0xFF8E8E93);
static const Color darkBorder = Color(0xFF38383A);

// Message Bubbles - Dark Mode
static const Color darkUserMessage = Color(0xFF0A84FF);
static const Color darkAIMessage = Color(0xFF2C2C2E);
```

---

## Accessibility Guidelines

### Color Contrast
- **Text on Background**: Minimum 4.5:1 ratio
- **Large Text**: Minimum 3:1 ratio
- **Interactive Elements**: Minimum 3:1 ratio

### Font Scaling
- Support Dynamic Type (iOS) / Font Scale (Android)
- Test at 200% font size
- Maintain layout integrity at all scales

### Screen Reader Support
```dart
// Semantic Labels
Semantics(
  label: 'Send message',
  hint: 'Double tap to send your message to the AI assistant',
  child: IconButton(...),
)
```

---

## Implementation Guidelines

### State Management
- Use consistent loading states across all components
- Implement proper error handling with user-friendly messages
- Maintain scroll position during content updates

### Performance
- Lazy load conversation history
- Implement message virtualization for long conversations
- Optimize image loading and caching

### Platform Considerations
#### iOS Specific
- Use iOS-style navigation patterns
- Implement swipe gestures for message actions
- Follow iOS Human Interface Guidelines

#### Android Specific
- Use Material Design components where appropriate
- Implement Android-specific navigation patterns
- Follow Material Design Guidelines

---

## Component Library Structure
```
lib/
├── theme/
│   ├── app_colors.dart
│   ├── app_text_styles.dart
│   ├── app_theme.dart
│   └── dimensions.dart
├── widgets/
│   ├── chat/
│   │   ├── message_bubble.dart
│   │   ├── typing_indicator.dart
│   │   └── input_field.dart
│   ├── common/
│   │   ├── custom_app_bar.dart
│   │   ├── suggestion_chip.dart
│   │   └── loading_overlay.dart
│   └── buttons/
│       ├── primary_button.dart
│       └── icon_button.dart
```

---

## Design Tokens (Flutter Implementation)
```dart
class AppDesignTokens {
  // Spacing
  static const double spaceXS = 4.0;
  static const double spaceSM = 8.0;
  static const double spaceMD = 16.0;
  static const double spaceLG = 24.0;
  static const double spaceXL = 32.0;
  
  // Border Radius
  static const double radiusXS = 4.0;
  static const double radiusSM = 8.0;
  static const double radiusMD = 12.0;
  static const double radiusLG = 20.0;
  static const double radiusXL = 24.0;
  
  // Shadows
  static const BoxShadow shadowLight = BoxShadow(
    color: Color(0x0A000000),
    blurRadius: 8,
    offset: Offset(0, 2),
  );
  
  static const BoxShadow shadowMedium = BoxShadow(
    color: Color(0x14000000),
    blurRadius: 16,
    offset: Offset(0, 4),
  );
}
```

---

*Style Guide Version: 1.0*  
*Created: [Current Date]*  
*Last Updated: [Current Date]* 