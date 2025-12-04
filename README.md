# ✨ Cool SwiftUI Animations

<p align="center">
  <img src="https://img.shields.io/badge/SwiftUI-blue.svg?style=for-the-badge&logo=swift&logoColor=white" alt="SwiftUI">
  <img src="https://img.shields.io/badge/iOS%2018+-000000?style=for-the-badge&logo=apple&logoColor=white" alt="iOS 18+">
  <img src="https://img.shields.io/badge/License-Apache%202.0-green.svg?style=for-the-badge" alt="License">
</p>

<p align="center">
  <b>🚀 A curated collection of stunning animations, transitions, and UI effects to inspire iOS developers</b>
</p>

---

## 🎯 Overview

**CoolSwiftUIAnimations** is a treasure trove of beautifully crafted SwiftUI animations and transitions. Whether you're looking for inspiration or ready-to-use components, this repository has you covered with modern, production-ready code that showcases the power of SwiftUI's animation system.

## 🌟 Features

- 🎨 **25+ Ready-to-Use Components** - Copy, paste, and customize
- 📱 **iOS 17+ Optimized** - Leveraging the latest SwiftUI APIs
- 🔧 **Modular Architecture** - Each animation is self-contained
- 📖 **Well-Documented Code** - Easy to understand and modify
- 🎭 **Preview Support** - See animations instantly in Xcode previews

---

## 📚 Animation Catalog

### 🎡 Carousels & Scrolling

| Component | Description |
|-----------|-------------|
| **Coverflow Carousel** | Beautiful 3D coverflow effect like Apple Music |
| **Parallax Carousel** | Smooth parallax scrolling effect |
| **Auto Scrolling Infinite Carousel** | Automatically looping carousel |
| **Looping Stacked Cards** | Tinder-style card stack with looping |
| **Vertical Circular Carousel** | Unique vertical circular scroll effect |
| **Apple Books Scroll Animation** | Recreating Apple Books' signature scroll |
| **Scrollable Tab View** | Custom tab view with smooth scrolling |
| **StackedScrollView** | Stacked card scroll interaction |

### 🎬 Transitions & Effects

| Component | Description |
|-----------|-------------|
| **Flip Transition** | Custom 3D flip transition between views |
| **Ripple Transition** | Elegant ripple effect for view transitions |
| **Particle Effects** | Like/Star/Share button particle burst |
| **Heart App Animation** | Pulsing heart with particle effects |
| **Staggered View** | Cascading entrance animations |
| **iMessage Morph Menu Effect** | Apple iMessage-style morphing menu |

### 🎛️ UI Components

| Component | Description |
|-----------|-------------|
| **Slide to Confirm** | Swipe-to-confirm button with shimmer |
| **Animated Paging Indicators** | Custom animated page indicators |
| **Toasts** | Beautiful toast notification system |
| **Skeleton** | Loading skeleton placeholder animations |
| **Pull to Search** | Pull-down to reveal search animation |
| **App-wide Overlay** | Global overlay management system |

### 📱 Complete App Patterns

| Component | Description |
|-----------|-------------|
| **Animated Dialog Family App** | Dialog-based family management UI |
| **Apple Invites Onboarding** | Apple-style onboarding experience |
| **Task Management App** | Complete task app with animations |
| **Custom Paywall Using StoreKit** | Animated paywall with StoreKit |
| **Slack Header Animation** | Slack-style collapsing header |
| **TabView Offset Reader** | TabView with offset tracking |
| **Resizable ScrollView Header** | Dynamic header resizing on scroll |

---

## 📋 Requirements

- **iOS 17.0+**
- **Xcode 16.0+**
- **Swift 5.9+**

---

## 🚀 Getting Started

### Clone the Repository

```bash
git clone https://github.com/naykutguven/CoolSwiftUIAnimations.git
```

### Open in Xcode

1. Open `CoolSwiftUIAnimations.xcodeproj` in Xcode
2. Select your target device or simulator
3. Build and run (⌘ + R)

### Using Individual Components

Each animation is self-contained in its own folder. Simply:

1. Navigate to the component you want
2. Copy the Swift file(s) to your project
3. Customize colors, sizes, and timing to match your design system

---

## 🎨 Example Usage

### Particle Effect Button

```swift
Image(systemName: "heart.fill")
    .particleEffect(
        systemImage: "heart.fill",
        status: isLiked,
        activeTint: .pink,
        inactiveTint: .gray
    )
```

### Flip Transition

```swift
CardView()
    .transition(.flip)
```

### Slide to Confirm

```swift
SlideToConfirmButton(
    config: .init(
        idleText: "Swipe to Pay",
        onSwipeText: "Keep Sliding...",
        confirmationText: "Confirmed!",
        tint: .green,
        foreground: .white
    )
) {
    // Handle confirmation
}
```

---

## 🤝 Contributing

Contributions are welcome! If you have a cool animation to share:

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingAnimation`)
3. Commit your changes (`git commit -m 'Add AmazingAnimation'`)
4. Push to the branch (`git push origin feature/AmazingAnimation`)
5. Open a Pull Request

---

## 📄 License

This project is licensed under the Apache License 2.0 - see the [LICENSE](LICENSE) file for details.

---

## ⭐ Show Your Support

If this project helped you, please consider giving it a ⭐ on GitHub!

---

<p align="center">
  Made with ❤️ for the iOS community
</p>