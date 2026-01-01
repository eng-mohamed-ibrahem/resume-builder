# Modern Theme System

This document describes the refactored theme system with modern UX principles.

## Overview

The theme has been completely refactored to provide a modern, smooth user experience with:

- **Vibrant Color Palettes**: Carefully curated colors for both light and dark themes
- **Smooth Transitions**: Cupertino-style page transitions for a fluid experience
- **Custom Gradients**: Beautiful gradient support via theme extensions
- **Enhanced Typography**: Complete Material 3 text theme with Inter font
- **Modern Components**: Updated styling for buttons, cards, inputs, and more
- **Glassmorphism Support**: Built-in support for glass-effect cards
- **Accessibility**: Proper contrast ratios and readable text sizes

## Color Palette

### Light Theme
- **Primary**: `#6366F1` (Vibrant Indigo)
- **Secondary**: `#8B5CF6` (Purple)
- **Accent**: `#EC4899` (Pink)
- **Surface**: `#FAFAFA`
- **Background**: `#FFFFFF`

### Dark Theme
- **Primary**: `#818CF8` (Soft Indigo)
- **Secondary**: `#A78BFA` (Soft Purple)
- **Accent**: `#F472B6` (Soft Pink)
- **Surface**: `#1E1E2E`
- **Background**: `#0F0F1A`

## Usage

### Basic Theme Access

```dart
import 'package:flutter/material.dart';
import 'package:resume_builder/core/theme/theme_extensions.dart';

class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Access colors
    final colors = context.colors;
    
    // Access text styles
    final textStyles = context.textStyles;
    
    // Access custom gradients
    final gradients = context.gradients;
    
    return Container(
      decoration: BoxDecoration(
        gradient: gradients.primaryGradient,
      ),
      child: Text(
        'Hello World',
        style: textStyles.headlineLarge,
      ),
    );
  }
}
```

### Using Custom Widgets

#### GradientCard

A card with optional gradient background:

```dart
GradientCard(
  useGradient: true, // Set to false for solid color
  padding: EdgeInsets.all(24),
  child: Column(
    children: [
      Text('Card Title'),
      Text('Card Content'),
    ],
  ),
)
```

#### GradientButton

An animated button with gradient background:

```dart
GradientButton(
  text: 'Click Me',
  icon: Icons.arrow_forward,
  isLoading: false,
  onPressed: () {
    // Handle button press
  },
)
```

#### GlassCard

A glassmorphism-style card:

```dart
GlassCard(
  opacity: 0.1, // Adjust transparency
  blur: 10,     // Adjust blur amount
  child: Text('Glass Effect'),
)
```

#### AnimatedGradientBackground

An animated gradient background:

```dart
AnimatedGradientBackground(
  child: YourContent(),
)
```

## Custom Gradients

The theme includes three predefined gradients accessible via `context.gradients`:

1. **Primary Gradient**: Indigo to Purple
2. **Secondary Gradient**: Purple to Pink
3. **Surface Gradient**: Subtle background gradient

### Example Usage

```dart
Container(
  decoration: BoxDecoration(
    gradient: context.gradients.primaryGradient,
    borderRadius: BorderRadius.circular(20),
    boxShadow: context.gradients.cardShadow,
  ),
  child: YourWidget(),
)
```

## Typography

The theme uses the Inter font family with a complete Material 3 text theme:

### Display Styles
- `displayLarge`: 57px, Bold (for hero text)
- `displayMedium`: 45px, Bold
- `displaySmall`: 36px, Semi-bold

### Headline Styles
- `headlineLarge`: 32px, Semi-bold
- `headlineMedium`: 28px, Semi-bold
- `headlineSmall`: 24px, Semi-bold

### Title Styles
- `titleLarge`: 22px, Semi-bold
- `titleMedium`: 16px, Semi-bold
- `titleSmall`: 14px, Semi-bold

### Body Styles
- `bodyLarge`: 16px, Regular
- `bodyMedium`: 14px, Regular
- `bodySmall`: 12px, Regular

### Label Styles
- `labelLarge`: 14px, Semi-bold
- `labelMedium`: 12px, Semi-bold
- `labelSmall`: 11px, Medium

## Component Styling

### Buttons

All buttons have been updated with:
- Larger padding (32x16)
- Rounded corners (16px radius)
- Smooth hover/press animations
- Custom overlay colors

```dart
// Elevated Button
ElevatedButton(
  onPressed: () {},
  child: Text('Primary Action'),
)

// Outlined Button
OutlinedButton(
  onPressed: () {},
  child: Text('Secondary Action'),
)

// Text Button
TextButton(
  onPressed: () {},
  child: Text('Tertiary Action'),
)
```

### Input Fields

Input fields feature:
- Rounded corners (16px)
- Subtle borders
- Smooth focus transitions
- Proper error states

```dart
TextField(
  decoration: InputDecoration(
    labelText: 'Email',
    hintText: 'Enter your email',
  ),
)
```

### Cards

Cards have:
- No elevation (flat design)
- Rounded corners (20px)
- Subtle borders
- Custom shadows

```dart
Card(
  child: Padding(
    padding: EdgeInsets.all(20),
    child: YourContent(),
  ),
)
```

## Shadows

The theme includes predefined shadow styles:

### Card Shadow
```dart
BoxDecoration(
  boxShadow: context.gradients.cardShadow,
)
```

### Button Shadow
```dart
BoxDecoration(
  boxShadow: context.gradients.buttonShadow,
)
```

## Page Transitions

Smooth page transitions are configured:
- **iOS/Android/macOS**: Cupertino-style transitions
- **Windows/Linux**: Fade upwards transitions

## Best Practices

1. **Use Extension Methods**: Always use `context.colors`, `context.textStyles`, and `context.gradients` for consistency
2. **Respect Theme**: Don't hardcode colors; use theme colors
3. **Typography Scale**: Use predefined text styles instead of custom sizes
4. **Spacing**: Use multiples of 4 (4, 8, 12, 16, 20, 24, etc.)
5. **Border Radius**: Use 12, 16, or 20 for consistency
6. **Animations**: Keep animations subtle and under 300ms

## Migration Guide

If you have existing widgets using the old theme:

### Before
```dart
Container(
  decoration: BoxDecoration(
    color: Color(0xFF6366F1),
    borderRadius: BorderRadius.circular(12),
  ),
  child: Text(
    'Hello',
    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
  ),
)
```

### After
```dart
Container(
  decoration: BoxDecoration(
    gradient: context.gradients.primaryGradient,
    borderRadius: BorderRadius.circular(16),
    boxShadow: context.gradients.cardShadow,
  ),
  child: Text(
    'Hello',
    style: context.textStyles.titleLarge,
  ),
)
```

## Dark Mode

The theme automatically adapts to system dark mode. Both themes are fully designed with:
- Proper contrast ratios
- Readable text colors
- Appropriate surface colors
- Consistent component styling

To test dark mode:
```dart
MaterialApp(
  theme: AppTheme.lightTheme,
  darkTheme: AppTheme.darkTheme,
  themeMode: ThemeMode.system, // or ThemeMode.light / ThemeMode.dark
)
```

## Performance Tips

1. **Avoid Rebuilds**: Use `const` constructors where possible
2. **Cache Gradients**: The gradients are cached in the theme extension
3. **Optimize Shadows**: Use shadows sparingly on scrollable lists
4. **Animation Controllers**: Always dispose animation controllers

## Accessibility

The theme includes:
- WCAG AA compliant contrast ratios
- Readable font sizes (minimum 12px)
- Proper focus indicators
- Touch target sizes (minimum 48x48)

## Future Enhancements

Potential additions to consider:
- Additional gradient presets
- Animation curve presets
- Spacing constants
- Breakpoint definitions for responsive design
- Custom icon theme
